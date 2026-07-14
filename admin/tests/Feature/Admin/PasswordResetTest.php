<?php

namespace Tests\Feature\Admin;

use App\Events\EmailVerificationEvent;
use App\Models\User;
use App\Models\Verification;
use App\Repositories\VerificationRepository;
use Illuminate\Foundation\Testing\DatabaseTransactions;
use Illuminate\Support\Facades\Event;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

/**
 * Regression tests for audit finding B4 (plan task W1-4): AuthController::
 * forgotPassword() returned the raw Verification model - including the OTP
 * and reset token - directly in the API response, and never actually
 * dispatched EmailVerificationEvent, so the OTP never reached the account's
 * real inbox. Anyone who knew (or guessed) a registered email could read the
 * reset token straight from the forgot-password response with no proof of
 * owning that inbox at all.
 *
 * Fix:
 *  - forgotPassword() now returns a generic message only and dispatches
 *    EmailVerificationEvent (which the existing, already-queued
 *    EmailVerificationListener sends by email) - no OTP/token/Verification
 *    model in the response, and the response is identical whether or not
 *    the account exists (ForgotPasswordRequest no longer validates
 *    exists:users,email).
 *  - The /forgot-password route is now named forgot.password, which
 *    EmailVerificationListener::handle() already checked for (via routeIs())
 *    to pick the forgot-password email template over the signup-verification
 *    one - previously always false, so this also fixes which email template
 *    would have been sent once the event was dispatched.
 *  - verifications.expires_at (new column) + Verification::isExpired() gate
 *    both otpVerify() and resetPassword() - a verification row past its TTL
 *    behaves as if it doesn't exist.
 *  - otpVerify() returning `reset_token` after a *correct, non-expired* OTP
 *    is unaffected: that is the intended second step of the flow (proof of
 *    email ownership -> token), distinct from the forgot-password leak.
 *
 * Uses DatabaseTransactions against the real dev database (see
 * SongMediaFlowTest for why RefreshDatabase is not used here).
 */
class PasswordResetTest extends TestCase
{
    use DatabaseTransactions;

    public function test_forgot_password_response_never_contains_the_otp_token_or_verification_model(): void
    {
        $user = User::factory()->create();

        $response = $this->postJson('/api/forgot-password', ['email' => $user->email]);

        $response->assertOk();
        $response->assertJsonStructure(['message']);
        $response->assertJsonMissingPath('data');
        $response->assertJsonMissingPath('otp');
        $response->assertJsonMissingPath('token');
        $response->assertJsonMissingPath('reset_token');
        $response->assertJsonMissingPath('email');

        $body = $response->getContent();
        $this->assertStringNotContainsString('"otp"', $body);
        $this->assertStringNotContainsString('"token"', $body);
    }

    public function test_forgot_password_returns_the_same_generic_message_for_an_unregistered_email(): void
    {
        $registered = User::factory()->create();
        $registeredResponse = $this->postJson('/api/forgot-password', ['email' => $registered->email]);

        $unregisteredResponse = $this->postJson('/api/forgot-password', ['email' => 'not-a-real-account-'.uniqid().'@example.com']);

        $registeredResponse->assertOk();
        $unregisteredResponse->assertOk();
        $this->assertSame(
            $registeredResponse->json('message'),
            $unregisteredResponse->json('message'),
            'The response must not reveal whether the account exists.'
        );
    }

    public function test_forgot_password_dispatches_the_email_verification_event_for_a_real_account(): void
    {
        Event::fake([EmailVerificationEvent::class]);
        $user = User::factory()->create();

        $this->postJson('/api/forgot-password', ['email' => $user->email]);

        Event::assertDispatched(EmailVerificationEvent::class, fn ($event) => $event->user->is($user));
    }

    public function test_forgot_password_does_not_dispatch_anything_for_an_unregistered_email(): void
    {
        Event::fake([EmailVerificationEvent::class]);

        $this->postJson('/api/forgot-password', ['email' => 'no-such-account-'.uniqid().'@example.com']);

        Event::assertNotDispatched(EmailVerificationEvent::class);
    }

    /**
     * Deliberately does not use Mail::fake(): EmailVerificationListener calls
     * Mail::send('view', ...) with a raw Blade view, not a Mailable class, and
     * MailFake::send() only records/asserts actual Mailable instances - a raw
     * view-based send is silently a no-op under Mail::fake(). Running this
     * for real (MAIL_MAILER=array in the test environment, so nothing hits a
     * real SMTP server) is what actually proves the forgot-password Blade
     * view renders successfully with real $user/$verification data and the
     * request completes without error - Event::fake() in the test above
     * would skip over that entirely.
     */
    public function test_forgot_password_runs_the_real_email_pipeline_without_error(): void
    {
        $user = User::factory()->create();

        $response = $this->postJson('/api/forgot-password', ['email' => $user->email]);

        $response->assertOk();

        $verification = (new VerificationRepository)->findByEmail($user->email);
        $this->assertNotNull($verification, 'A verification row must be created so the emailed OTP is checkable.');
        $this->assertNotNull($verification->expires_at, 'A freshly issued OTP must have an expiry.');
        $this->assertFalse($verification->isExpired());
    }

    public function test_verify_otp_rejects_an_expired_verification(): void
    {
        $verification = Verification::factory()->expired()->create();

        $response = $this->postJson('/api/verify-otp', [
            'email' => $verification->email,
            'otp' => $verification->otp,
        ]);

        $response->assertOk();
        $response->assertJsonMissingPath('data');
        $this->assertSame('Invalid OTP', $response->json('message'));
    }

    public function test_verify_otp_accepts_a_correct_non_expired_otp(): void
    {
        $verification = Verification::factory()->create();

        $response = $this->postJson('/api/verify-otp', [
            'email' => $verification->email,
            'otp' => $verification->otp,
        ]);

        $response->assertOk();
        $this->assertSame($verification->token, $response->json('data.reset_token'));
    }

    public function test_reset_password_rejects_an_expired_token(): void
    {
        $verification = Verification::factory()->expired()->create();
        User::factory()->create(['email' => $verification->email]);

        $response = $this->postJson('/api/reset-password', [
            'reset_token' => $verification->token,
            'password' => 'brand-new-password',
            'password_confirmation' => 'brand-new-password',
        ]);

        $response->assertStatus(400);
        $this->assertNotNull(Verification::find($verification->id), 'An expired token must not be consumed/deleted.');
    }

    public function test_reset_password_with_a_valid_token_changes_the_password_and_deletes_the_verification(): void
    {
        $verification = Verification::factory()->create();
        $user = User::factory()->create(['email' => $verification->email, 'password' => Hash::make('old-password')]);

        $response = $this->postJson('/api/reset-password', [
            'reset_token' => $verification->token,
            'password' => 'brand-new-password',
            'password_confirmation' => 'brand-new-password',
        ]);

        $response->assertOk();

        $user->refresh();
        $this->assertTrue(Hash::check('brand-new-password', $user->password));
        $this->assertNull(Verification::find($verification->id), 'The verification row must be deleted (single use) after a successful reset.');
    }

    public function test_reset_password_rejects_a_reused_token(): void
    {
        $verification = Verification::factory()->create();
        User::factory()->create(['email' => $verification->email]);

        $first = $this->postJson('/api/reset-password', [
            'reset_token' => $verification->token,
            'password' => 'first-new-password',
            'password_confirmation' => 'first-new-password',
        ]);
        $first->assertOk();

        $second = $this->postJson('/api/reset-password', [
            'reset_token' => $verification->token,
            'password' => 'second-new-password',
            'password_confirmation' => 'second-new-password',
        ]);

        // The first reset already deleted the verification row, so the
        // second attempt's reset_token no longer exists at all -
        // ResetPasswordRequest's exists:verifications,token rule rejects it
        // at validation (422) before the controller's own expired/invalid
        // check (400) is ever reached. Either way the reset must not repeat.
        $second->assertStatus(422);

        $user = User::where('email', $verification->email)->first();
        $this->assertTrue(Hash::check('first-new-password', $user->password), 'The second (reused-token) attempt must not have changed the password again.');
    }
}
