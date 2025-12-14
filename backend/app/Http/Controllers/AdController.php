<?php

namespace App\Http\Controllers;

use App\Models\Ad;
use App\Models\Request as AdRequest;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;
use PHPOpenSourceSaver\JWTAuth\Facades\JWTAuth;

class AdController extends Controller
{
    /**
     * Map category numbers to strings (Flutter compatibility)
     *
     * @param int $categoryNumber
     * @return string
     */
    private function mapCategory(int $categoryNumber): string
    {
        $map = [
            0 => 'Electronics',
            1 => 'Fashion',
            2 => 'Health',
            3 => 'Home',
            4 => 'Groceries',
            5 => 'Games',
            6 => 'Books',
            7 => 'Automotive',
            8 => 'Pet',
            9 => 'Food',
            10 => 'Other',
        ];

        return $map[$categoryNumber] ?? 'Other';
    }

    /**
     * Map category strings to numbers (Flutter compatibility)
     *
     * @param string $category
     * @return int
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
     * Create new ad
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function createAd(Request $request): JsonResponse
    {
        // Get all request data (works for both JSON and multipart/form-data)
        // Laravel automatically merges request->request (form fields) and request->files (uploaded files)
        $allRequestData = $request->all();
        
        // Support both category number (Flutter) and string format
        $categoryInput = $allRequestData['category'] ?? null;
        $category = is_numeric($categoryInput) ? $this->mapCategory((int)$categoryInput) : $categoryInput;
        
        // Convert targetViews to integer (multipart sends as string)
        $targetViewsInput = $allRequestData['targetViews'] ?? null;
        $targetViews = is_numeric($targetViewsInput) ? (int)$targetViewsInput : null;

        // Prepare data for validation
        $validationData = array_merge($allRequestData, [
            'category' => $category,
            'targetViews' => $targetViews,
        ]);

        $validator = Validator::make($validationData, [
            'name' => 'required|string|max:255',
            'path' => 'required|string',
            'type' => 'required|in:Fixed,Dynamic',
            'targetViews' => 'required|integer|min:1',
            'category' => 'required|in:Electronics,Fashion,Health,Home,Groceries,Games,Books,Automotive,Pet,Food,Other',
            'keywords' => 'required|string',
            'file' => 'required|file|mimes:jpeg,png,jpg,gif|max:2048',
        ], [
            'name.required' => 'اسم الإعلان مطلوب',
            'path.required' => 'رابط الإعلان مطلوب',
            'type.required' => 'نوع الإعلان مطلوب',
            'type.in' => 'نوع الإعلان يجب أن يكون Fixed أو Dynamic',
            'targetViews.required' => 'عدد المشاهدات المطلوبة مطلوب',
            'targetViews.integer' => 'عدد المشاهدات يجب أن يكون رقماً',
            'targetViews.min' => 'عدد المشاهدات يجب أن يكون على الأقل 1',
            'category.required' => 'الفئة مطلوبة',
            'category.in' => 'الفئة غير صحيحة',
            'keywords.required' => 'الكلمات المفتاحية مطلوبة',
            'file.required' => 'صورة الإعلان مطلوبة',
            'file.file' => 'يجب أن يكون الملف صورة',
            'file.mimes' => 'نوع الصورة يجب أن يكون jpeg, png, jpg, أو gif',
            'file.max' => 'حجم الصورة يجب أن يكون أقل من 2MB',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'Error',
                'message' => 'Validation Error',
                'errors' => $validator->errors(),
                'debug' => [
                    'received_category' => $allRequestData['category'] ?? null,
                    'mapped_category' => $category,
                    'received_targetViews' => $allRequestData['targetViews'] ?? null,
                    'converted_targetViews' => $targetViews,
                    'all_inputs' => array_keys($allRequestData),
                    'request_keys' => array_keys($request->request->all()),
                    'files_keys' => array_keys($request->allFiles()),
                    'has_file' => $request->hasFile('file'),
                    'content_type' => $request->header('Content-Type'),
                ]
            ], 422);
        }

        try {
            // Get user from middleware (already authenticated)
            // Middleware adds auth_user to request->attributes
            $user = $request->attributes->get('auth_user');
            
            if (!$user) {
                return response()->json([
                    'status' => 'Error',
                    'message' => 'User not authenticated'
                ], 401);
            }
            
            if (!$user->isVerified) {
                return response()->json([
                    'status' => 'Error',
                    'message' => 'User must be verified to create ads'
                ], 403);
            }

            // Handle file upload
            $imagePath = '';
            if ($request->hasFile('file')) {
                $image = $request->file('file');
                $imageName = time() . '_' . $image->getClientOriginalName();
                $imagePath = $image->storeAs('ads', $imageName, 'public');
            }

            // Create ad (use converted values from allRequestData)
            $ad = Ad::create([
                'name' => $allRequestData['name'],
                'path' => $allRequestData['path'],
                'views' => 0,
                'targetViews' => $targetViews, // Use converted integer value
                'image' => $imagePath,
                'type' => $allRequestData['type'],
                'category' => $category, // Use mapped category string
                'creation_date' => now(),
                'renewal_date' => now()->addDays(30),
                'isPublished' => false,
                'keywords' => $allRequestData['keywords'],
                'userid' => $user->id,
            ]);

            // Create request for admin approval
            AdRequest::create([
                'ad' => $ad->id,
                'user' => $user->id,
                'type' => 'Create',
                'creation' => now(),
                'param' => $request->type,
            ]);

            return response()->json([
                'status' => 'Success',
                'message' => 'Ad created and sent for approval',
                'data' => [
                    'ad_id' => $ad->id,
                    'name' => $ad->name,
                    'isPublished' => $ad->isPublished,
                ]
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'Error',
                'message' => 'Failed to create ad',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Edit existing ad
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function editAd(Request $request): JsonResponse
    {
        // Support both category number (Flutter) and string format
        $categoryInput = $request->input('category');
        $category = is_numeric($categoryInput) ? $this->mapCategory((int)$categoryInput) : $categoryInput;

        $validator = Validator::make(array_merge($request->all(), ['category' => $category]), [
            'ad' => 'required|uuid|exists:ads,id',
            'name' => 'required|string|max:255',
            'path' => 'required|string',
            'type' => 'required|in:Fixed,Dynamic',
            'targetViews' => 'required|integer|min:1',
            'category' => 'required|in:Electronics,Fashion,Health,Home,Groceries,Games,Books,Automotive,Pet,Food,Other',
            'keywords' => 'required|string',
            'file' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'Error',
                'message' => 'Validation Error',
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            $user = $request->attributes->get('auth_user');
            
            $ad = Ad::where('id', $request->ad)
                ->where('userid', $user->id)
                ->first();

            if (!$ad) {
                return response()->json([
                    'status' => 'Error',
                    'message' => 'Ad not found or unauthorized'
                ], 404);
            }

            // Handle file upload if new image provided
            if ($request->hasFile('file')) {
                // Delete old image
                if ($ad->image) {
                    Storage::disk('public')->delete($ad->image);
                }
                
                $image = $request->file('file');
                $imageName = time() . '_' . $image->getClientOriginalName();
                $ad->image = $image->storeAs('ads', $imageName, 'public');
            }

            // Update ad
            $ad->update([
                'name' => $request->name,
                'path' => $request->path,
                'type' => $request->type,
                'targetViews' => $request->targetViews,
                'category' => $category,
                'keywords' => $request->keywords,
            ]);

            return response()->json([
                'status' => 'Success',
                'message' => 'Ad updated successfully'
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'Error',
                'message' => 'Failed to update ad',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get user's ads
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function getUserAds(Request $request): JsonResponse
    {
        try {
            $user = $request->attributes->get('auth_user');
            
            $ads = Ad::where('userid', $user->id)
                ->orderBy('creation_date', 'desc')
                ->get()
                ->map(function ($ad) {
                    return [
                        'id' => $ad->id,
                        'name' => $ad->name,
                        'path' => $ad->path,
                        'views' => $ad->views,
                        'targetViews' => $ad->targetViews,
                        'image' => $ad->image ? url('api/storage/' . $ad->image) : null,
                        'type' => $ad->type,
                        'category' => $this->mapCategoryToNumber($ad->category),  // Convert to number
                        'lastUpdate' => $ad->renewal_date ? $ad->renewal_date->format('Y-m-d H:i:s') : '',
                        'creation_date' => $ad->creation_date->format('Y-m-d H:i:s'),
                        'renewal_date' => $ad->renewal_date->format('Y-m-d H:i:s'),
                        'isPublished' => $ad->isPublished,
                        'keywords' => $ad->keywords,
                    ];
                });

            return response()->json($ads, 200);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'Error',
                'message' => 'Failed to fetch ads',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Fetch ads by category
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function fetchCategoryAds(Request $request): JsonResponse
    {
        // Note: 'id' is optional and not used - user is identified from JWT token in header
        // This endpoint supports optional authentication (guests can view ads)
        $validator = Validator::make($request->all(), [
            'category' => 'required|integer',
            'full' => 'boolean',
            'id' => 'nullable|string', // Optional - not used, but accepted for Flutter compatibility
            'adType' => 'nullable|string|in:Fixed,Dynamic', // Optional - filter by ad type
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'Error',
                'message' => 'Validation Error'
            ], 422);
        }

        try {
            // Get authenticated user from OptionalJwtMiddleware (null if guest)
            $user = $request->attributes->get('auth_user');
            
            $categoryMap = [
                -1 => null, // All categories
                0 => 'Electronics',
                1 => 'Fashion',
                2 => 'Health',
                3 => 'Home',
                4 => 'Groceries',
                5 => 'Games',
                6 => 'Books',
                7 => 'Automotive',
                8 => 'Pet',
                9 => 'Food',
                10 => 'Other',
            ];

            $query = Ad::where('isPublished', true);
            
            // Filter by category if not -1 (all)
            if ($request->category != -1 && isset($categoryMap[$request->category])) {
                $query->where('category', $categoryMap[$request->category]);
            }
            
            // Filter by ad type if specified (e.g., 'Dynamic' for Container "جميع الإعلانات")
            if ($request->has('adType') && $request->adType) {
                $query->where('type', $request->adType);
            }
            
            // Exclude user's own ads if authenticated
            // NOTE: This is only for preventing users from watching their own ads
            // For browsing categories, we should show all ads
            // if ($user) {
            //     $query->where('userid', '!=', $user->id);
            // }

            // Get full or limited data
            if ($request->full) {
                // Return all ads (both Fixed and Dynamic) or filtered by adType if specified
                $query->orderBy('creation_date', 'desc');
            } else {
                // Return only Fixed ads with limit (if adType not specified)
                if (!$request->has('adType') || !$request->adType) {
                    $query->where('type', 'Fixed');
                }
                $query->orderBy('creation_date', 'desc')
                    ->limit(10);
            }

            $ads = $query->get()->map(function ($ad) {
                return [
                    'id' => $ad->id,
                    'name' => $ad->name,
                    'path' => $ad->path,
                    'views' => $ad->views,
                    'targetViews' => $ad->targetViews,
                    'image' => $ad->image ? url('api/storage/' . $ad->image) : null,
                    'type' => $ad->type,
                    'category' => $this->mapCategoryToNumber($ad->category),  // Convert to number
                    'lastUpdate' => $ad->renewal_date ? $ad->renewal_date->format('Y-m-d H:i:s') : '',
                    'isPublished' => $ad->isPublished,
                    'keywords' => $ad->keywords,
                    'userid' => $ad->userid, // Add userid to check if ad belongs to current user
                ];
            });

            return response()->json($ads, 200);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'Error',
                'message' => 'Failed to fetch ads',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Renew ad
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function renewAd(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'ad' => 'required|uuid|exists:ads,id',
            'tier' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'Error',
                'message' => 'Validation Error'
            ], 422);
        }

        try {
            $user = $request->attributes->get('auth_user');
            
            $ad = Ad::where('id', $request->ad)
                ->where('userid', $user->id)
                ->first();

            if (!$ad) {
                return response()->json([
                    'status' => 'Error',
                    'message' => 'Ad not found or unauthorized'
                ], 404);
            }

            // Create renewal request
            AdRequest::create([
                'ad' => $ad->id,
                'user' => $user->id,
                'type' => 'Renew',
                'creation' => now(),
                'param' => $request->tier,
            ]);

            return response()->json([
                'status' => 'Success',
                'message' => 'Renewal request submitted'
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'Error',
                'message' => 'Failed to renew ad',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}

