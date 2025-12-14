<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use PHPOpenSourceSaver\JWTAuth\Facades\JWTAuth;
use PHPOpenSourceSaver\JWTAuth\Exceptions\JWTException;
use Symfony\Component\HttpFoundation\Response;

class JwtMiddleware
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        try {
            // Get token from Authorization header (primary method)
            // For multipart/form-data, body is not parsed yet, so we only check header
            $token = null;
            
            if ($request->hasHeader('Authorization')) {
                $token = $request->bearerToken();
            }
            
            // For non-multipart requests, also check body (JSON requests)
            if (!$token && !str_contains($request->header('Content-Type', ''), 'multipart')) {
                // Try to get from request body (for JSON requests)
                $sessionInput = $request->input('session');
                if ($sessionInput && !empty($sessionInput)) {
                    $token = trim((string) $sessionInput);
                    // Set Authorization header for JWTAuth
                    $request->headers->set('Authorization', 'Bearer ' . $token);
                }
            }

            // If still no token, return 401
            if (!$token || $token === '') {
                return response()->json([
                    'status' => 'Error',
                    'message' => 'Token not provided. Please include Authorization header.'
                ], 401);
            }

            // Authenticate user with token
            try {
                $user = JWTAuth::setToken($token)->authenticate();
            } catch (JWTException $e) {
                return response()->json([
                    'status' => 'Error',
                    'message' => 'Token is invalid or expired: ' . $e->getMessage()
                ], 401);
            }
            
            if (!$user) {
                return response()->json([
                    'status' => 'Error',
                    'message' => 'User not found'
                ], 404);
            }

            // Check if user is deleted
            if ($user->isDeleted) {
                return response()->json([
                    'status' => 'Error',
                    'message' => 'Account has been deleted'
                ], 403);
            }

            // Attach user to request attributes (preserves object type)
            // Using attributes instead of request->request to avoid type conversion issues
            $request->attributes->set('auth_user', $user);
            
        } catch (\Exception $e) {
            // Catch any other exceptions
            return response()->json([
                'status' => 'Error',
                'message' => 'Authentication failed: ' . $e->getMessage()
            ], 401);
        }

        return $next($request);
    }
}

