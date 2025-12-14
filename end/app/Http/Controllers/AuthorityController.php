<?php

namespace App\Http\Controllers;

use App\Models\Ad;
use App\Models\Request as AdRequest;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\URL;
use Illuminate\Support\Facades\Validator;
use PHPOpenSourceSaver\JWTAuth\Facades\JWTAuth;

class AuthorityController extends Controller
{
    /**
     * Map category string to number (Flutter compatibility)
     */
    private function mapCategoryToNumber(string $category): int
    {
        $map = [
            'Electronics' => 0,
            'Fashion' => 1,
            'Health' => 2,
            'Home' => 3,
            'Groceries' => 4,
            'Games' => 5,
            'Books' => 6,
            'Automotive' => 7,
            'Pet' => 8,
            'Food' => 9,
            'Other' => 10,
        ];
        
        return $map[$category] ?? 10;
    }
    /**
     * Get pending ad creation/renewal requests
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function getDefaultRequests(Request $request): JsonResponse
    {
        try {
            $user = $request->attributes->get('auth_user');
            
            if (!$user) {
                return response()->json([
                    'status' => 'Error',
                    'message' => 'User not authenticated'
                ], 401, [], JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
            }
            
            if (!$user->isAdmin) {
                return response()->json([
                    'status' => 'Error',
                    'message' => 'Unauthorized'
                ], 403, [], JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
            }

            $tier = $request->input('tier');
            $requestType = $request->input('request_type'); // 'Create' or 'Renew' or null for all
            
            // Query with eager loading to avoid N+1 problem
            // This will execute 3 queries total instead of 1 + N*2 queries
            $query = AdRequest::with(['userRelation', 'adRelation']);
            
            // Filter by request type if specified
            if ($requestType && in_array($requestType, ['Create', 'Renew'])) {
                $query->where('type', $requestType);
            } else {
                // Default: get both Create and Renew
                $query->whereIn('type', ['Create', 'Renew']);
            }
            
            $query->orderBy('creation', 'desc');

            if ($tier) {
                $query->where('param', $tier);
            }

            $requestsData = $query->get();
            
            // Safely map data with null checks
            $requests = $requestsData->map(function ($req) {
                try {
                    $userData = null;
                    $adData = null;
                    
                    // Safely get user
                    try {
                        if ($req->userRelation) {
                            $user = $req->userRelation;
                            $userData = [
                                'id' => $user->id ?? null,
                                'username' => $user->username ?? null,
                                'email' => $user->email ?? null,
                                'phone' => $user->phone ?? null,
                            ];
                        }
                    } catch (\Exception $e) {
                        \Log::warning('Failed to load user for request: ' . $e->getMessage());
                    }
                    
                    // Safely get ad
                    try {
                        if ($req->adRelation) {
                            $ad = $req->adRelation;
                            $adData = [
                                'id' => $ad->id ?? null,
                                'name' => $ad->name ?? null,
                                'path' => $ad->path ?? null,
                                'image' => $ad->image ?? null,
                                'type' => $ad->type ?? null,
                                'category' => $ad->category ?? null,
                                'targetViews' => $ad->targetViews ?? 0,
                                'views' => $ad->views ?? 0,
                            ];
                        }
                    } catch (\Exception $e) {
                        \Log::warning('Failed to load ad for request: ' . $e->getMessage());
                    }
                    
                    // Map to Flutter expected format
                    $mappedData = [
                        'reqid' => $req->id,
                        'type' => $req->type,
                        'creation' => $req->creation ? $req->creation->format('Y-m-d H:i:s') : null,
                        'param' => $req->param,
                        'tier' => $req->param ?? 'Dynamic', // For RenewRequest
                        'lastUpdate' => $req->creation ? $req->creation->format('Y-m-d H:i:s') : null, // For RenewRequest
                    ];
                    
                    // Add user data (Flutter expects direct fields, not nested)
                    if ($userData) {
                        $mappedData['username'] = $userData['username'] ?? '';
                        $mappedData['userphone'] = $userData['phone'] ?? '';
                    } else {
                        // Set defaults if user is null
                        $mappedData['username'] = '';
                        $mappedData['userphone'] = '';
                    }
                    
                    // Add ad data (Flutter expects direct fields, not nested)
                    if ($adData) {
                        $mappedData['adname'] = $adData['name'] ?? '';
                        $mappedData['path'] = $adData['path'] ?? '';
                        // Generate image URL through API storage route (with CORS support)
                        if ($adData['image']) {
                            try {
                                // Use API storage route for CORS support
                                $mappedData['image'] = url('api/storage/' . $adData['image']);
                            } catch (\Exception $e) {
                                \Log::warning('Failed to generate image URL: ' . $e->getMessage());
                                $mappedData['image'] = '';
                            }
                        } else {
                            $mappedData['image'] = '';
                        }
                        $mappedData['target'] = $adData['targetViews'] ?? 0;
                        $mappedData['category'] = $this->mapCategoryToNumber($adData['category'] ?? 'Other');
                        $mappedData['adtype'] = $adData['type'] ?? 'Dynamic';
                        $mappedData['views'] = $adData['views'] ?? 0;
                    } else {
                        // Set defaults if ad is null
                        $mappedData['adname'] = '';
                        $mappedData['path'] = '';
                        $mappedData['image'] = '';
                        $mappedData['target'] = 0;
                        $mappedData['category'] = 10; // Other
                        $mappedData['adtype'] = 'Dynamic';
                        $mappedData['views'] = 0;
                    }
                    
                    return $mappedData;
                } catch (\Exception $e) {
                    \Log::error('Error mapping request: ' . $e->getMessage());
                    return null;
                }
            })->filter(); // Remove null entries

            // Ensure proper JSON encoding without HTML entities
            return response()->json($requests->values(), 200, [], JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
            
        } catch (\Exception $e) {
            \Log::error('getDefaultRequests CRITICAL ERROR', [
                'message' => $e->getMessage(),
                'file' => $e->getFile(),
                'line' => $e->getLine(),
                'trace' => $e->getTraceAsString(),
            ]);
            
            // Return error with details in debug mode
            return response()->json([
                'status' => 'Error',
                'message' => 'Failed to fetch requests: ' . $e->getMessage(),
                'error_details' => [
                    'message' => $e->getMessage(),
                    'file' => $e->getFile(),
                    'line' => $e->getLine(),
                ]
            ], 500, [], JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
        }
    }

    /**
     * Get money withdrawal requests
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function getMoneyRequests(Request $request): JsonResponse
    {
        try {
            $user = $request->attributes->get('auth_user');
            
            if (!$user) {
                return response()->json([
                    'status' => 'Error',
                    'message' => 'User not authenticated'
                ], 401, [], JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
            }
            
            if (!$user->isAdmin) {
                return response()->json([
                    'status' => 'Error',
                    'message' => 'Unauthorized'
                ], 403, [], JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
            }

            $requests = AdRequest::with('userRelation')
                ->where('type', 'Money')
                ->orderBy('creation', 'desc')
                ->get()
                ->map(function ($req) {
                    return [
                        'id' => $req->id,
                        'creation' => $req->creation->format('Y-m-d H:i:s'),
                        'amount' => $req->param,
                        'user' => [
                            'id' => $req->userRelation->id,
                            'username' => $req->userRelation->username,
                            'email' => $req->userRelation->email,
                            'points' => (float) $req->userRelation->points,
                        ],
                    ];
                });

            return response()->json($requests, 200, [], JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'Error',
                'message' => 'Failed to fetch money requests'
            ], 500, [], JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
        }
    }

    /**
     * Handle request (approve/reject)
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function handleRequest(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'req' => 'required|uuid|exists:requests,id',
            'state' => 'required|boolean',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'Error',
                'message' => 'Validation Error'
            ], 422);
        }

        try {
            $user = $request->attributes->get('auth_user');
            
            if (!$user->isAdmin) {
                return response()->json([
                    'status' => 'Error',
                    'message' => 'Unauthorized'
                ], 403, [], JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
            }

            $adRequest = AdRequest::with(['adRelation', 'userRelation'])->find($request->req);

            if (!$adRequest) {
                return response()->json([
                    'status' => 'Error',
                    'message' => 'Request not found'
                ], 404);
            }

            DB::transaction(function () use ($adRequest, $request) {
                if ($request->state) {
                    // Approved
                    if ($adRequest->type === 'Create' || $adRequest->type === 'Renew') {
                        if ($adRequest->adRelation) {
                            $adRequest->adRelation->isPublished = true;
                            $adRequest->adRelation->renewal_date = now()->addDays(30);
                            $adRequest->adRelation->save();
                        }
                    } elseif ($adRequest->type === 'Money') {
                        // Deduct points
                        $amount = (float) $adRequest->param;
                        $adRequest->userRelation->decrement('points', $amount);
                    }
                }
                
                // Delete request
                $adRequest->delete();
            });

            return response()->json([
                'status' => 'Success',
                'message' => $request->state ? 'Request approved' : 'Request rejected'
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'Error',
                'message' => 'Failed to handle request',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Exchange points for money request
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function pointsExchange(Request $request): JsonResponse
    {
        try {
            $user = $request->attributes->get('auth_user');

            if ($user->points < 10) {
                return response()->json([
                    'status' => 'Error',
                    'message' => 'Insufficient points (minimum 10)'
                ], 400);
            }

            // Create money request
            AdRequest::create([
                'user' => $user->id,
                'type' => 'Money',
                'creation' => now(),
                'param' => (string) $user->points,
            ]);

            return response()->json([
                'status' => 'Success',
                'message' => 'Exchange request submitted'
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'Error',
                'message' => 'Failed to submit exchange request'
            ], 500);
        }
    }

    /**
     * Get my requests
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function getMyRequests(Request $request): JsonResponse
    {
        try {
            $user = $request->attributes->get('auth_user');

            $requests = AdRequest::with('adRelation')
                ->where('user', $user->id)
                ->orderBy('creation', 'desc')
                ->get()
                ->map(function ($req) {
                    return [
                        'id' => $req->id,
                        'type' => $req->type,
                        'creation' => $req->creation->format('Y-m-d H:i:s'),
                        'param' => $req->param,
                        'ad' => $req->adRelation ? [
                            'id' => $req->adRelation->id,
                            'name' => $req->adRelation->name,
                        ] : null,
                    ];
                });

            return response()->json($requests, 200, [], JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'Error',
                'message' => 'Failed to fetch requests'
            ], 500, [], JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
        }
    }

    /**
     * Delete request
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function deleteRequest(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'req' => 'required|uuid|exists:requests,id',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'Error',
                'message' => 'Validation Error'
            ], 422);
        }

        try {
            $user = $request->attributes->get('auth_user');

            $adRequest = AdRequest::where('id', $request->req)
                ->where('user', $user->id)
                ->first();

            if (!$adRequest) {
                return response()->json([
                    'status' => 'Error',
                    'message' => 'Request not found or unauthorized'
                ], 404);
            }

            $adRequest->delete();

            return response()->json([
                'status' => 'Success',
                'message' => 'Request deleted successfully'
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'Error',
                'message' => 'Failed to delete request'
            ], 500);
        }
    }
}

