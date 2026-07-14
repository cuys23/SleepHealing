<?php

namespace Tests\Feature\Admin;

use App\Http\Middleware\VerifyCsrfToken;
use App\Models\DeviceKey;
use App\Models\Subscription;
use App\Models\SubscriptionPlan;
use App\Models\User;
use Illuminate\Foundation\Testing\DatabaseTransactions;
use Illuminate\Support\Facades\DB;
use Tests\TestCase;

/**
 * Regression tests for two confirmed Eloquent relationship bugs found during
 * the database audit:
 *
 * - DeviceKey::user() referenced the lowercase `user::class` instead of
 *   `User::class`. On a case-sensitive filesystem (Linux/Docker), Composer's
 *   PSR-4 autoloader cannot resolve "App\Models\user" since only User.php
 *   exists, so this throws a Class-not-found error at runtime rather than
 *   silently working, as it would on a case-insensitive dev filesystem.
 *
 * - SubscriptionPlan::subscriptions() declared hasOne(Subscription::class)
 *   even though subscriptions.subscription_plan_id allows many subscriptions
 *   per plan. hasOne silently returns only the first matching row.
 */
class ModelRelationshipTest extends TestCase
{
    use DatabaseTransactions;

    protected function setUp(): void
    {
        parent::setUp();
        $this->withoutMiddleware(VerifyCsrfToken::class);
    }

    private function admin(): User
    {
        $user = User::factory()->create();
        $user->assignRole(\Spatie\Permission\Models\Role::findOrCreate('admin', 'web'));

        return $user;
    }

    /**
     * Deliberately avoids App\Models\User::factory()/::create() so this test
     * proves the fix on its own merits. PHP class-name lookups are
     * case-insensitive ONCE a class is already loaded/declared in the
     * process, so if any earlier code path (including another test in the
     * same PHPUnit run) already autoloaded App\Models\User, the old
     * `user::class` typo would resolve by accident and this regression test
     * would pass even against the buggy code. Inserting the user row via
     * DB::table() keeps the Eloquent User class untouched until the
     * assertion, so a case-sensitive autoload failure surfaces reliably
     * regardless of test order.
     */
    public function test_device_key_user_relation_resolves_a_valid_user(): void
    {
        $userId = DB::table('users')->insertGetId([
            'name' => 'Device Owner',
            'email' => 'device-owner-'.uniqid().'@example.com',
            'password' => 'x',
            'created_at' => now(),
            'updated_at' => now(),
        ]);
        $deviceKeyId = DB::table('device_keys')->insertGetId([
            'user_id' => $userId,
            'key' => 'test-device-token',
            'device_type' => 'ios',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $resolved = DeviceKey::find($deviceKeyId)->user;

        $this->assertInstanceOf(User::class, $resolved);
        $this->assertSame($userId, $resolved->id);
    }

    public function test_subscription_plan_subscriptions_returns_every_subscription_as_a_collection(): void
    {
        $plan = SubscriptionPlan::factory()->create();
        $userA = User::factory()->create();
        $userB = User::factory()->create();

        $subscriptionA = Subscription::factory()->create([
            'user_id' => $userA->id,
            'subscription_plan_id' => $plan->id,
        ]);
        $subscriptionB = Subscription::factory()->create([
            'user_id' => $userB->id,
            'subscription_plan_id' => $plan->id,
        ]);

        $plan->refresh();
        $subscriptions = $plan->subscriptions;

        $this->assertInstanceOf(\Illuminate\Database\Eloquent\Collection::class, $subscriptions);
        $this->assertCount(2, $subscriptions);
        $this->assertTrue($subscriptions->contains('id', $subscriptionA->id));
        $this->assertTrue($subscriptions->contains('id', $subscriptionB->id));
    }

    /**
     * Regression test for the direct consequence of the hasOne -> hasMany
     * fix: SubscriptionPlanController::delete() guards against deleting a
     * plan that still has subscribers. With hasOne, a plan with zero
     * subscriptions correctly evaluated as falsy (null). A naive hasMany
     * swap would make `if ($plan->subscriptions)` always truthy (a
     * Collection object, even when empty), blocking every deletion. The
     * fix uses `subscriptions()->exists()` instead.
     */
    public function test_subscription_plan_without_subscribers_can_still_be_deleted(): void
    {
        $plan = SubscriptionPlan::factory()->create();

        $response = $this->actingAs($this->admin())
            ->get(route('subscriptionPlan.delete', $plan));

        $response->assertSessionHas('success');
        $this->assertNull(SubscriptionPlan::find($plan->id));
    }

    public function test_subscription_plan_with_a_subscriber_cannot_be_deleted(): void
    {
        $plan = SubscriptionPlan::factory()->create();
        Subscription::factory()->create([
            'user_id' => User::factory()->create()->id,
            'subscription_plan_id' => $plan->id,
        ]);

        $response = $this->actingAs($this->admin())
            ->get(route('subscriptionPlan.delete', $plan));

        $response->assertSessionHas('errors');
        $this->assertNotNull(SubscriptionPlan::find($plan->id));
    }
}
