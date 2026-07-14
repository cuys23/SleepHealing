<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\API\AuthController;
use App\Http\Controllers\API\AlbamController;
use App\Http\Controllers\API\BannerController;
use App\Http\Controllers\API\CategoryController;
use App\Http\Controllers\API\ConfigController;
use App\Http\Controllers\API\ContactController;
use App\Http\Controllers\API\FavoriteConstroller;
use App\Http\Controllers\API\NotificationsController;
use App\Http\Controllers\API\PlayListController;
use App\Http\Controllers\API\SettingController;
use App\Http\Controllers\API\ShiftController;
use App\Http\Controllers\API\SubscriptionController;
use App\Http\Controllers\API\UserController;

// Config
Route::get('/v2/config', [ConfigController::class, 'index']);
Route::get('/general-settings', [SettingController::class, 'generalSettings']);

// Auth (public)
Route::post('/sign-in', [AuthController::class, 'signIn']);
Route::post('/sign-up', [AuthController::class, 'signUp']);
Route::post('/forgot-password', [AuthController::class, 'forgotPassword'])->name('forgot.password');
Route::post('/verify-otp', [AuthController::class, 'otpVerify']);
Route::post('/reset-password', [AuthController::class, 'resetPassword']);
Route::post('/social-login', [AuthController::class, 'socialLogin']);
Route::get('/email-verify', [AuthController::class, 'emailVerify']);

// Public catalog
Route::get('/categories', [CategoryController::class, 'index']);
Route::get('/categories/{id}', [CategoryController::class, 'show']);
Route::get('/albams', [AlbamController::class, 'index']);
Route::get('/banner', [BannerController::class, 'index']);
Route::get('/shift', [ShiftController::class, 'index']);
Route::get('/play-lists', [PlayListController::class, 'index']);
Route::get('/play-lists/{id}/view-count', [PlayListController::class, 'viewCount']);
Route::get('/play-lists/{playlist}/content', [PlayListController::class, 'readmore']);
Route::get('/play-lists/{playlist}/readmore', [PlayListController::class, 'readmore']);

// Settings / legal pages (public)
Route::get('/legal-pages/{page}', [SettingController::class, 'show']);
Route::get('/settings/{page}', [SettingController::class, 'show']);
Route::get('/settings/lang/{local}', [SettingController::class, 'switchLang']);

// Contact
Route::post('/contact', [ContactController::class, 'store']);

// Authenticated routes
Route::middleware('auth:api')->group(function () {

    // Auth actions
    Route::get('/logout', [AuthController::class, 'logout']);
    Route::get('/resend-token', [AuthController::class, 'tokenResend']);

    // User profile
    Route::get('/profiles', [UserController::class, 'index']);
    Route::post('/update/profile-photo', [UserController::class, 'updateProfile']);
    Route::post('/update-password', [UserController::class, 'passwordUpdate']);
    Route::delete('/user/delete', [UserController::class, 'deleteProfile']);

    // Favorites
    Route::get('/favorites', [FavoriteConstroller::class, 'index']);
    Route::post('/favorites', [FavoriteConstroller::class, 'store']);

    // Notifications
    Route::get('/notifications', [NotificationsController::class, 'index']);
    Route::post('/notifications', [NotificationsController::class, 'store']);
    Route::put('/notifications/{notification}', [NotificationsController::class, 'update']);
    Route::delete('/notifications/{notification}', [NotificationsController::class, 'delete']);

    // Subscriptions
    Route::get('/subscription/plans', [SubscriptionController::class, 'index']);
    Route::post('/get/subscription', [SubscriptionController::class, 'store']);
    Route::get('/my-subscription/plans', [SubscriptionController::class, 'myPlans']);
});
