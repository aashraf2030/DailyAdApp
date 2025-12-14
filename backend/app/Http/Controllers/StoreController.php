<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Mail;
use Tymon\JWTAuth\Facades\JWTAuth;

class StoreController extends Controller
{
    // --- Public Routes ---

    public function getProducts()
    {
        $products = DB::table('products')->where('is_active', true)->get();
        return response()->json($products);
    }

    // --- Protected Routes (User) ---

    public function createOrder(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'items' => 'required|json',
            'total_price' => 'required|numeric',
            'address' => 'required|string',
            'phone' => 'required|string',
            'receiver_name' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json(['status' => 'Error', 'message' => $validator->errors()->first()], 400);
        }

        try {
            $user = JWTAuth::parseToken()->authenticate();

            $orderId = DB::table('orders')->insertGetId([
                'user_id' => $user->id,
                'items' => $request->items,
                'total_price' => $request->total_price,
                'address' => $request->address,
                'phone' => $request->phone,
                'receiver_name' => $request->receiver_name,
                'created_at' => now(),
                'updated_at' => now(),
            ]);

            // Send Email to Admin (Mock implementation)
            // In production, use Mail::to('admin@example.com')->send(new OrderPlaced($order));
            // For now, we'll just log it or assume it's sent.

            return response()->json(['status' => 'Success', 'message' => 'Order placed successfully', 'order_id' => $orderId]);

        } catch (\Exception $e) {
            return response()->json(['status' => 'Error', 'message' => 'Failed to place order', 'error' => $e->getMessage()], 500);
        }
    }

    // --- Admin Routes ---

    public function addProduct(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string',
            'description' => 'nullable|string',
            'price' => 'required|numeric',
            'image' => 'required|image|mimes:jpeg,png,jpg,gif,svg|max:2048',
            'stock' => 'required|integer',
        ]);

        if ($validator->fails()) {
            return response()->json(['status' => 'Error', 'message' => $validator->errors()->first()], 400);
        }

        try {
            $imagePath = null;
            if ($request->hasFile('image')) {
                $image = $request->file('image');
                $imageName = time() . '.' . $image->getClientOriginalExtension();
                $image->move(public_path('images/products'), $imageName);
                $imagePath = 'images/products/' . $imageName;
            }

            $id = DB::table('products')->insertGetId([
                'name' => $request->name,
                'description' => $request->description ?? "",
                'price' => $request->price,
                'image' => $imagePath, // Save path
                'category' => 'General', // Default or remove column if nullable
                'stock' => $request->stock,
                'created_at' => now(),
                'updated_at' => now(),
            ]);

            return response()->json(['status' => 'Success', 'message' => 'Product added successfully', 'id' => $id]);
        } catch (\Exception $e) {
            return response()->json(['status' => 'Error', 'message' => 'Failed to add product: ' . $e->getMessage()], 500);
        }
    }

    public function editProduct(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'id' => 'required|integer|exists:products,id',
            'name' => 'required|string',
            'description' => 'nullable|string',
            'price' => 'required|numeric',
            'image' => 'nullable', // Can be string (old URL) or file (new upload)
            'stock' => 'required|integer',
        ]);

        if ($validator->fails()) {
            return response()->json(['status' => 'Error', 'message' => $validator->errors()->first()], 400);
        }

        try {
            $updateData = [
                'name' => $request->name,
                'description' => $request->description ?? "",
                'price' => $request->price,
                'stock' => $request->stock,
                'updated_at' => now(),
            ];

            if ($request->hasFile('image')) {
                $image = $request->file('image');
                $imageName = time() . '.' . $image->getClientOriginalExtension();
                $image->move(public_path('images/products'), $imageName);
                $updateData['image'] = 'images/products/' . $imageName;
            }

            DB::table('products')->where('id', $request->id)->update($updateData);

            return response()->json(['status' => 'Success', 'message' => 'Product updated successfully']);
        } catch (\Exception $e) {
            return response()->json(['status' => 'Error', 'message' => 'Failed to update product'], 500);
        }
    }

    public function deleteProduct(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'id' => 'required|integer|exists:products,id',
        ]);

        if ($validator->fails()) {
            return response()->json(['status' => 'Error', 'message' => $validator->errors()->first()], 400);
        }

        try {
            // Soft delete by setting is_active to false, or hard delete
            // Let's do hard delete for now as per simple requirements, or soft delete if preferred.
            // Using hard delete for simplicity in this demo.
            DB::table('products')->where('id', $request->id)->delete();

            return response()->json(['status' => 'Success', 'message' => 'Product deleted successfully']);
        } catch (\Exception $e) {
            return response()->json(['status' => 'Error', 'message' => 'Failed to delete product'], 500);
        }
    }

    public function getImage($path)
    {
        $fullPath = public_path($path);

        if (!file_exists($fullPath)) {
            return response()->json(['message' => 'Image not found'], 404);
        }

        $file = file_get_contents($fullPath);
        $type = mime_content_type($fullPath);

        return response($file, 200)
            ->header('Content-Type', $type)
            ->header('Access-Control-Allow-Origin', '*');
    }
}
