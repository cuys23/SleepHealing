<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Web\LoginController;
use App\Http\Controllers\Web\DashboardController;
use App\Http\Controllers\Web\AlbamController;
use App\Http\Controllers\Web\BannerController;
use App\Http\Controllers\Web\CategoryController;
use App\Http\Controllers\Web\NotificationController;
use App\Http\Controllers\Web\PlaylistController;
use App\Http\Controllers\Web\ProfileController;
use App\Http\Controllers\Web\SettingController;
use App\Http\Controllers\Web\ShiftController;
use App\Http\Controllers\Web\SubscriptionPlanController;
use App\Http\Controllers\Web\UserController;
use App\Http\Controllers\Web\WebSettingController;
use App\Http\Controllers\Web\EmailVerifyController;
use App\Http\Controllers\CreateSuperAdmin;
use App\Http\Controllers\FCMController;
use App\Http\Controllers\MailConfigurationController;
use App\Http\Controllers\SMSConfigurationController;

// Email verification
Route::get('/email-verify/{userId}/{token}', [EmailVerifyController::class, 'verify'])->name('email-verify');

// Guest routes (unauthenticated only)
Route::middleware(['web', 'guest'])->group(function () {
    Route::get('/login', [LoginController::class, 'index'])->name('login');
    Route::post('/login', [LoginController::class, 'login'])->name('login.post');
});

// Create super admin (protected by check_has_root middleware)
Route::middleware(['web', 'check_has_root'])->group(function () {
    Route::get('/create-superadmin', [CreateSuperAdmin::class, 'index'])->name('create.root');
    Route::post('/create-superadmin', [CreateSuperAdmin::class, 'store'])->name('create.superadmin');
});

// Logout
Route::post('/logout', [LoginController::class, 'logout'])->middleware('web')->name('logout');

// Authenticated admin routes
Route::middleware(['web', 'auth'])->group(function () {

    // Dashboard
    Route::get('/', [DashboardController::class, 'index'])->name('root');

    // Profile
    Route::prefix('profile')->name('profile.')->group(function () {
        Route::get('/', [ProfileController::class, 'index'])->name('index');
        Route::get('/edit', [ProfileController::class, 'edit'])->name('edit');
        Route::post('/update', [ProfileController::class, 'update'])->name('update');
        Route::get('/change-password', [ProfileController::class, 'showChangePassword'])->name('change-password');
        Route::post('/change-password', [ProfileController::class, 'changePassword'])->name('change-password.post');
    });

    // Albums
    Route::prefix('albums')->name('albam.')->group(function () {
        Route::get('/', [AlbamController::class, 'index'])->name('index');
        Route::get('/create', [AlbamController::class, 'create'])->name('create');
        Route::post('/store', [AlbamController::class, 'store'])->name('store');
        Route::get('/{albam}/edit', [AlbamController::class, 'edit'])->name('edit');
        Route::post('/{albam}/update', [AlbamController::class, 'update'])->name('update');
        Route::get('/{albam}/delete', [AlbamController::class, 'delete'])->name('delete');
        Route::get('/{albam}/toggle-status', [AlbamController::class, 'toggle'])->name('status.toggle');
        Route::get('/{albam}/toggle-paid', [AlbamController::class, 'updatePaidStatus'])->name('paid.toggle');
        Route::get('/{albam}/playlist', [AlbamController::class, 'getPlaylist'])->name('tree');
        Route::post('/{albam}/playlist/update', [AlbamController::class, 'updatePlaylist'])->name('tree.update');
    });

    // Categories
    Route::prefix('categories')->name('category.')->group(function () {
        Route::get('/', [CategoryController::class, 'index'])->name('index');
        Route::get('/create', [CategoryController::class, 'create'])->name('create');
        Route::post('/store', [CategoryController::class, 'store'])->name('store');
        Route::get('/{category}/edit', [CategoryController::class, 'edit'])->name('edit');
        Route::post('/{category}/update', [CategoryController::class, 'update'])->name('update');
        Route::get('/{category}/delete', [CategoryController::class, 'delete'])->name('delete');
        Route::get('/{category}/toggle-status', [CategoryController::class, 'toggle'])->name('status.toggle');
        Route::get('/{category}/albums', [CategoryController::class, 'getAlbams'])->name('tree');
        Route::post('/{category}/albums/update', [CategoryController::class, 'updateAlbum'])->name('tree.update');
    });

    // Playlists
    Route::prefix('playlists')->name('playlist.')->group(function () {
        Route::get('/', [PlaylistController::class, 'index'])->name('index');
        Route::get('/create', [PlaylistController::class, 'create'])->name('create');
        Route::post('/store', [PlaylistController::class, 'store'])->name('store');
        Route::get('/{playlist}/show', [PlaylistController::class, 'show'])->name('show');
        Route::get('/{playlist}/edit', [PlaylistController::class, 'edit'])->name('edit');
        Route::post('/{playlist}/update', [PlaylistController::class, 'update'])->name('update');
        Route::get('/{playlist}/delete', [PlaylistController::class, 'delete'])->name('delete');
        Route::get('/{playlist}/toggle-status', [PlaylistController::class, 'toggle'])->name('status.toggle');
        Route::get('/{playlist}/toggle-paid', [PlaylistController::class, 'updatePaidStatus'])->name('paid.toggle');
        Route::get('/{playlist}/readmore', [PlaylistController::class, 'readmore'])->name('readmore');
        Route::post('/{playlist}/readmore/update', [PlaylistController::class, 'readmoreUpdate'])->name('readmore.update');
    });

    // Banners
    Route::prefix('banners')->name('banner.')->group(function () {
        Route::get('/', [BannerController::class, 'index'])->name('index');
        Route::get('/create', [BannerController::class, 'create'])->name('create');
        Route::post('/store', [BannerController::class, 'store'])->name('store');
        Route::get('/{banner}/edit', [BannerController::class, 'edit'])->name('edit');
        Route::post('/{banner}/update', [BannerController::class, 'update'])->name('update');
        Route::get('/{banner}/delete', [BannerController::class, 'delete'])->name('delete');
        Route::get('/{banner}/toggle-status', [BannerController::class, 'toggle'])->name('status.toggle');
    });

    // Shifts
    Route::prefix('shifts')->name('shift.')->group(function () {
        Route::get('/', [ShiftController::class, 'index'])->name('index');
        Route::get('/{shift}/toggle-status', [ShiftController::class, 'toggle'])->name('status.toggle');
        Route::get('/{shift}/delete', [ShiftController::class, 'delete'])->name('delete');
        Route::get('/{shift}/albums', [ShiftController::class, 'getAlbams'])->name('tree');
        Route::post('/{shift}/albums/update', [ShiftController::class, 'updateAlbum'])->name('tree.update');
    });

    // Users
    Route::prefix('users')->name('user.')->group(function () {
        Route::get('/', [UserController::class, 'index'])->name('index');
        Route::get('/{user}/show', [UserController::class, 'show'])->name('show');
        Route::get('/{user}/edit', [UserController::class, 'edit'])->name('edit');
        Route::post('/{user}/update', [UserController::class, 'update'])->name('update');
        Route::get('/{user}/delete', [UserController::class, 'delete'])->name('delete');
        Route::get('/{user}/toggle-status', [UserController::class, 'toggle'])->name('status.toggle');
    });

    // Subscription Plans
    Route::prefix('subscription-plans')->name('subscriptionPlan.')->group(function () {
        Route::get('/', [SubscriptionPlanController::class, 'index'])->name('index');
        Route::get('/create', [SubscriptionPlanController::class, 'create'])->name('create');
        Route::post('/store', [SubscriptionPlanController::class, 'store'])->name('store');
        Route::get('/{subscriptionPlan}/show', [SubscriptionPlanController::class, 'show'])->name('show');
        Route::get('/{subscriptionPlan}/edit', [SubscriptionPlanController::class, 'edit'])->name('edit');
        Route::post('/{subscriptionPlan}/update', [SubscriptionPlanController::class, 'update'])->name('update');
        Route::get('/{subscriptionPlan}/delete', [SubscriptionPlanController::class, 'delete'])->name('delete');
        Route::get('/{subscriptionPlan}/toggle-status', [SubscriptionPlanController::class, 'toggle'])->name('status.toggle');
    });

    // Notifications
    Route::prefix('notifications')->name('notification.')->group(function () {
        Route::get('/', [NotificationController::class, 'index'])->name('index');
        Route::post('/send', [NotificationController::class, 'sendNotification'])->name('send');
        Route::get('/filters', [NotificationController::class, 'userFilters'])->name('filter');
    });

    // Settings (pages: privacy-policy, terms-conditions, etc.)
    Route::prefix('settings')->name('setting.')->group(function () {
        Route::get('/{slug}', [SettingController::class, 'show'])->name('show');
        Route::get('/{slug}/edit', [SettingController::class, 'edit'])->name('edit');
        Route::post('/{setting}/update', [SettingController::class, 'update'])->name('update');
    });

    // Web Settings
    Route::prefix('web-settings')->name('webSetting.')->group(function () {
        Route::get('/', [WebSettingController::class, 'index'])->name('index');
        Route::post('/{webSetting}/update', [WebSettingController::class, 'update'])->name('update');
        Route::get('/{webSetting}/toggle', [WebSettingController::class, 'toggle'])->name('toggle');
        Route::get('/{webSetting}/toggle-ads', [WebSettingController::class, 'AdsToggle'])->name('toggle.ads');
    });

    // Mail Configuration
    Route::prefix('mail-config')->name('mailConfig.')->group(function () {
        Route::get('/', [MailConfigurationController::class, 'index'])->name('index');
        Route::post('/update', [MailConfigurationController::class, 'update'])->name('update');
    });

    // SMS Configuration
    Route::prefix('sms-config')->name('smsConfig.')->group(function () {
        Route::get('/', [SMSConfigurationController::class, 'index'])->name('index');
        Route::post('/update', [SMSConfigurationController::class, 'update'])->name('update');
    });

    // FCM (Firebase) Configuration
    Route::prefix('fcm')->name('fcm.')->group(function () {
        Route::get('/', [FCMController::class, 'index'])->name('index');
        Route::post('/update', [FCMController::class, 'update'])->name('update');
    });
});
