<?php

namespace App\Http\Controllers;

use App\Models\Ad;
use App\Models\User;
use App\Models\View;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use PHPOpenSourceSaver\JWTAuth\Facades\JWTAuth;

class ViewController extends Controller
{
    /**
     * Watch an ad (record view and award points)
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function watch(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'ad' => 'required|uuid|exists:ads,id',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'Error',
                'message' => 'Validation Error'
            ], 422);
        }

        try {
            $user = $request->attributes->get('auth_user');
            
            if (!$user || !$user->isVerified) {
                return response()->json([
                    'status' => 'Error',
                    'message' => 'User must be verified'
                ], 403);
            }

            $ad = Ad::find($request->ad);

            if (!$ad || !$ad->isPublished) {
                return response()->json([
                    'status' => 'Error',
                    'message' => 'Ad not found or not published'
                ], 404);
            }

            // Check if user is trying to watch their own ad
            if ($ad->userid === $user->id) {
                return response()->json([
                    'status' => 'Error',
                    'message' => 'Cannot watch your own ad'
                ], 400);
            }

            // Check if user already viewed this ad
            $existingView = View::where('ad', $ad->id)
                ->where('user', $user->id)
                ->first();

            if ($existingView) {
                return response()->json([
                    'status' => 'Error',
                    'message' => 'Ad already viewed'
                ], 400);
            }

            // Calculate points: 0.10 per view (10 views = 1 point)
            $pointsAwarded = 0.10;

            DB::transaction(function () use ($ad, $user, $pointsAwarded) {
                // Create view record
                View::create([
                    'ad' => $ad->id,
                    'user' => $user->id,
                    'time' => now(),
                    'points' => $pointsAwarded,
                ]);

                // Increment ad views
                $ad->increment('views');

                // Award points to user
                $user->increment('points', $pointsAwarded);
            });

            return response()->json([
                'status' => 'Success',
                'message' => 'View recorded',
                'data' => [
                    'points_awarded' => $pointsAwarded,
                    'total_points' => $user->points + $pointsAwarded,
                ]
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'Error',
                'message' => 'Failed to record view',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get leaderboard
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function leaderboard(Request $request): JsonResponse
    {
        try {
            // Try to authenticate user (optional for guest access)
            $user = null;
            try {
                if ($request->has('session') || $request->hasHeader('Authorization')) {
                    $user = $request->attributes->get('auth_user');
                }
            } catch (\Exception $e) {
                // Guest user - continue without authentication
                $user = null;
            }

            $users = User::where('isDeleted', false)
                ->where('isVerified', true)
                ->orderBy('points', 'desc')
                ->limit(50)
                ->get()
                ->map(function ($u, $index) use ($user) {
                    return [
                        'rank' => $index + 1,
                        'username' => $u->username,
                        'points' => (float) $u->points,
                        'isCurrentUser' => $user ? ($u->id === $user->id) : false,
                    ];
                });

            return response()->json($users, 200);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'Error',
                'message' => 'Failed to fetch leaderboard'
            ], 500);
        }
    }
}

