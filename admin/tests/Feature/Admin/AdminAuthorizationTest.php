<?php

namespace Tests\Feature\Admin;

use App\Http\Middleware\VerifyCsrfToken;
use App\Models\User;
use Illuminate\Foundation\Testing\DatabaseTransactions;
use Spatie\Permission\Models\Role;
use Tests\TestCase;

/**
 * Regression tests for audit finding B3 (plan task W1-3): any user who signed
 * up through the public mobile API (role "user") could log into the Laravel
 * Admin web panel with the exact same credentials and reach every Admin
 * route, because LoginController::isAuthenticate() only checked
 * email+password, and the protected route group (routes/web.php) carried no
 * role/permission middleware at all.
 *
 * Fix has two layers, both covered here:
 *  - Layer 1 (LoginController::isAuthenticate): reject the login attempt
 *    itself unless the user has the "root" or "admin" role.
 *  - Layer 2 (routes/web.php): the whole protected route group now also
 *    requires role:root|admin, so even an already-established session (or a
 *    future login path that bypasses Layer 1) cannot reach Admin routes.
 *
 * Uses DatabaseTransactions against the real dev database (see
 * SongMediaFlowTest for why RefreshDatabase is not used here).
 */
class AdminAuthorizationTest extends TestCase
{
    use DatabaseTransactions;

    protected function setUp(): void
    {
        parent::setUp();
        $this->withoutMiddleware(VerifyCsrfToken::class);

        // DashboardController::index() unconditionally queries User::role('user'),
        // regardless of which role this test's own user has. Spatie throws
        // RoleDoesNotExist for a role row that doesn't exist at all (not just
        // "no users have it"), and DatabaseTransactions rolls back every role
        // created by a previous test - so every role the app can reference must
        // exist inside *this* test's own transaction, not just the one under test.
        foreach (config('acl.roles') as $role) {
            Role::findOrCreate($role, 'web');
        }
    }

    private function userWithRole(string $role, string $password = 'secret'): User
    {
        $user = User::factory()->create([
            'status' => true,
            'password' => \Illuminate\Support\Facades\Hash::make($password),
        ]);
        $user->assignRole(Role::findOrCreate($role, 'web'));

        return $user;
    }

    public function test_a_standard_app_user_cannot_log_into_the_admin_panel(): void
    {
        $user = $this->userWithRole('user');

        $response = $this->post(route('login.post'), [
            'email' => $user->email,
            'password' => 'secret',
        ]);

        $this->assertGuest();
        $response->assertSessionHasErrors(['email']);
    }

    public function test_a_visitor_role_cannot_log_into_the_admin_panel(): void
    {
        $visitor = $this->userWithRole('visitor');

        $response = $this->post(route('login.post'), [
            'email' => $visitor->email,
            'password' => 'secret',
        ]);

        $this->assertGuest();
        $response->assertSessionHasErrors(['email']);
    }

    public function test_an_admin_role_can_log_into_the_admin_panel(): void
    {
        $admin = $this->userWithRole('admin');

        $response = $this->post(route('login.post'), [
            'email' => $admin->email,
            'password' => 'secret',
        ]);

        $this->assertAuthenticatedAs($admin);
        $response->assertRedirect(route('root'));
    }

    public function test_a_root_role_can_log_into_the_admin_panel(): void
    {
        $root = $this->userWithRole('root');

        $response = $this->post(route('login.post'), [
            'email' => $root->email,
            'password' => 'secret',
        ]);

        $this->assertAuthenticatedAs($root);
        $response->assertRedirect(route('root'));
    }

    public function test_wrong_password_is_still_rejected_the_same_way_as_wrong_role(): void
    {
        $admin = $this->userWithRole('admin');

        $response = $this->post(route('login.post'), [
            'email' => $admin->email,
            'password' => 'not-the-real-password',
        ]);

        $this->assertGuest();
        $response->assertSessionHasErrors(['email']);
    }

    public function test_a_standard_app_user_session_cannot_reach_admin_routes(): void
    {
        $user = $this->userWithRole('user');

        $response = $this->actingAs($user)->get(route('root'));

        $response->assertForbidden();
    }

    public function test_a_standard_app_user_session_cannot_reach_a_nested_admin_route(): void
    {
        $user = $this->userWithRole('user');

        $response = $this->actingAs($user)->get(route('user.index'));

        $response->assertForbidden();
    }

    public function test_an_admin_session_can_reach_the_dashboard(): void
    {
        $admin = $this->userWithRole('admin');

        $response = $this->actingAs($admin)->get(route('root'));

        $response->assertOk();
    }

    public function test_a_root_session_can_reach_the_dashboard(): void
    {
        $root = $this->userWithRole('root');

        $response = $this->actingAs($root)->get(route('root'));

        $response->assertOk();
    }

    public function test_an_unauthenticated_guest_is_redirected_to_login_not_shown_admin_routes(): void
    {
        $response = $this->get(route('root'));

        $response->assertRedirect(route('login'));
    }
}
