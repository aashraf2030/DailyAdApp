<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use PHPOpenSourceSaver\JWTAuth\Facades\JWTAuth;
use Symfony\Component\HttpFoundation\Response;

/**
 * Optional JWT Middleware
 * Attempts to authenticate but doesn't fail if no token is provided.
 * Used for endpoints that work for both guests and authenticated users.
 */
class OptionalJwtMiddleware
{
    public function handle(Request $request, Closure $next): Response
    {
        try {
            // Try to get token from Authorization header OR request body
            $token = $request->bearerToken() ?? $request->input('session');
            
            if ($token && !empty($token)) {
                // Try to authenticate
                $user = JWTAuth::setToken($token)->authenticate();
                
                if ($user && !$user->isDeleted) {
                    // User authenticated successfully
                    $request->attributes->set('auth_user', $user);
                }
            }
        } catch (\Exception $e) {
            // Silently continue - this is optional authentication
        }
        
        return $next($request);
    }
}

