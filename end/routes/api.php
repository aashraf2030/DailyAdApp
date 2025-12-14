<?php

use App\Http\Controllers\AdController;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\AuthorityController;
use App\Http\Controllers\ChatController;
use App\Http\Controllers\StorageController;
use App\Http\Controllers\StoreController;
use App\Http\Controllers\ViewController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/

// Authentication Routes (Public)
Route::prefix('auth')->group(function () {
    // Register & Login
    Route::post('/register', [AuthController::class, 'register']);
    Route::post('/login', [AuthController::class, 'login']);

    // Password Reset (Public)
    Route::post('/pass_reset', [AuthController::class, 'resetPass']);

    // Protected Auth Routes
    Route::middleware(['jwt.custom'])->group(function () {
        Route::post('/logout', [AuthController::class, 'logout']);
        Route::post('/profile', [AuthController::class, 'profile']);
        Route::post('/is_logged_in', [AuthController::class, 'isLoggedIn']);
        Route::post('/is_admin', [AuthController::class, 'isAdmin']);
        Route::post('/delete', [AuthController::class, 'delete']); // Changed to POST for body support

        // Email Verification
        Route::post('/send_code', [AuthController::class, 'sendCode']);
        Route::post('/verify', [AuthController::class, 'verify']);
        Route::post('/is_verified', [AuthController::class, 'verifyCheck']);

        // Password Reset (Protected)
        Route::post('/validate_reset', [AuthController::class, 'validateResetPass']);
        Route::post('/change_pass', [AuthController::class, 'changePass']);
    });
});

// Ad Routes
Route::prefix('ad')->group(function () {
    // Public routes with optional authentication
    Route::post('/fetch_cat', [AdController::class, 'fetchCategoryAds'])
        ->middleware('jwt.optional'); // Filters out user's own ads if authenticated

    // Protected routes (Authentication required)
    Route::middleware(['jwt.custom'])->group(function () {
        Route::post('/create_ad', [AdController::class, 'createAd']); // Changed to POST for multipart support
        Route::post('/edit_ad', [AdController::class, 'editAd']); // Changed to POST for multipart support
        Route::post('/get_user_ads', [AdController::class, 'getUserAds']);
        Route::post('/renew', [AdController::class, 'renewAd']);
    });
});

// View Routes (Protected)
Route::prefix('view')->middleware(['jwt.custom'])->group(function () {
    Route::post('/watch', [ViewController::class, 'watch']);
});

// Authority Routes
Route::prefix('authority')->group(function () {
    // Public routes (Guest access allowed)
    Route::post('/leaderboard', [ViewController::class, 'leaderboard']); // Guests can view leaderboard

    // Protected routes (Authentication required)
    Route::middleware(['jwt.custom'])->group(function () {
        // Admin only routes
        Route::post('/default_req', [AuthorityController::class, 'getDefaultRequests']); // Gets Create requests
        Route::post('/renew_req', function (Request $request) {
            // Pass 'Renew' as request_type to filter only renewal requests
            $request->merge(['request_type' => 'Renew']);
            return app(AuthorityController::class)->getDefaultRequests($request);
        }); // Gets Renew requests
        Route::post('/money_req', [AuthorityController::class, 'getMoneyRequests']);
        Route::post('/handle_req', [AuthorityController::class, 'handleRequest']);

        // User routes
        Route::post('/my_req', [AuthorityController::class, 'getMyRequests']);
        Route::post('/delete_req', [AuthorityController::class, 'deleteRequest']);
        Route::post('/points_exchange', [AuthorityController::class, 'pointsExchange']);
    });
});

// Storage Route (for serving files with CORS)
Route::get('/storage/{path}', [StorageController::class, 'serveFile'])
    ->where('path', '.*'); // Allow any path (e.g., ads/image.jpg)

// Chat Routes (Protected)
Route::prefix('chat')->middleware(['jwt.custom'])->group(function () {
    // User routes
    Route::post('/conversation', [ChatController::class, 'getOrCreateConversation']); // Get or create user's conversation
    Route::post('/messages', [ChatController::class, 'getMessages']); // Get messages for conversation
    Route::post('/send', [ChatController::class, 'sendMessage']); // Send a message

    // Admin only routes
    Route::get('/admin/conversations', [ChatController::class, 'getAdminConversations']); // Get all conversations for admin
    Route::post('/admin/assign', [ChatController::class, 'assignConversation']); // Assign conversation to admin
});

// Test Route
Route::get('/test', function () {
    return response()->json([
        'status' => 'Success',
        'message' => 'API is working!',
        'timestamp' => now()->toDateTimeString(),
        'version' => '1.0.0',
    ]);
});

// --- Store Routes ---
Route::get('/store/products', [StoreController::class, 'getProducts']);

Route::group(['middleware' => ['jwt.custom']], function () {
    Route::post('/store/order', [StoreController::class, 'createOrder']);

    // Admin Routes (Should have admin check middleware in real app)
    Route::post('/store/add_product', [StoreController::class, 'addProduct']);
    Route::post('/store/edit_product', [StoreController::class, 'editProduct']);
    Route::post('/store/delete_product', [StoreController::class, 'deleteProduct']);
});

// Image Proxy Route
Route::get('/store/image/{path}', [StoreController::class, 'getImage'])->where('path', '.*');
