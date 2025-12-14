<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Symfony\Component\HttpFoundation\StreamedResponse;

class StorageController extends Controller
{
    /**
     * Serve storage files with CORS headers
     *
     * @param Request $request
     * @param string $path
     * @return StreamedResponse|\Illuminate\Http\JsonResponse
     */
    public function serveFile(Request $request, string $path)
    {
        try {
            // Check if file exists in public disk
            if (!Storage::disk('public')->exists($path)) {
                return response()->json([
                    'status' => 'Error',
                    'message' => 'File not found'
                ], 404);
            }

            // Get file
            $file = Storage::disk('public')->path($path);
            
            // Determine mime type
            $mimeType = Storage::disk('public')->mimeType($path);
            
            // Create response with CORS headers
            return response()->file($file, [
                'Content-Type' => $mimeType,
                'Access-Control-Allow-Origin' => '*',
                'Access-Control-Allow-Methods' => 'GET, OPTIONS',
                'Access-Control-Allow-Headers' => 'Content-Type, Authorization',
                'Cache-Control' => 'public, max-age=31536000',
            ]);
            
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'Error',
                'message' => 'Failed to serve file: ' . $e->getMessage()
            ], 500);
        }
    }
}

