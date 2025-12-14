<?php

namespace App\Http\Controllers;

use App\Models\Conversation;
use App\Models\Message;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class ChatController extends Controller
{
    /**
     * Get or create conversation for current user
     * Each user has only one active conversation with admin
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function getOrCreateConversation(Request $request): JsonResponse
    {
        try {
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
                    'message' => 'User must be verified'
                ], 403);
            }

            // Security: Ensure we only get/create conversation for the authenticated user
            // The user_id is taken from the JWT token, so it's always the current user
            $conversation = Conversation::firstOrCreate(
                [
                    'user_id' => $user->id, // Always the authenticated user's ID
                    'is_active' => true,
                ],
                [
                    'subject' => 'دردشة مع الإدارة',
                    'is_active' => true,
                    'last_message_at' => now(),
                ]
            );
            
            // Double-check: Ensure the conversation belongs to the authenticated user
            if ($conversation->user_id !== $user->id) {
                return response()->json([
                    'status' => 'Error',
                    'message' => 'Unauthorized access to conversation'
                ], 403);
            }

            // Load relationships
            $conversation->load(['user', 'admin', 'latestMessage']);

            return response()->json([
                'status' => 'Success',
                'data' => [
                    'id' => $conversation->id,
                    'user_id' => $conversation->user_id,
                    'user_name' => $conversation->user->username ?? 'Unknown',
                    'user_email' => $conversation->user->email ?? '',
                    'admin_id' => $conversation->admin_id,
                    'admin_name' => $conversation->admin ? $conversation->admin->username : null,
                    'subject' => $conversation->subject,
                    'unread_count' => $conversation->unread_count_user,
                    'last_message' => $conversation->latestMessage ? [
                        'content' => $conversation->latestMessage->content,
                        'sender_type' => $conversation->latestMessage->sender_type,
                        'created_at' => $conversation->latestMessage->created_at->format('Y-m-d H:i:s'),
                    ] : null,
                    'last_message_at' => $conversation->last_message_at ? $conversation->last_message_at->format('Y-m-d H:i:s') : null,
                    'created_at' => $conversation->created_at->format('Y-m-d H:i:s'),
                ]
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'Error',
                'message' => 'Failed to get conversation',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get messages for a conversation
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function getMessages(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'conversation_id' => 'required|uuid|exists:conversations,id',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'Error',
                'message' => 'Validation Error'
            ], 422);
        }

        try {
            $user = $request->attributes->get('auth_user');
            
            $conversation = Conversation::find($request->conversation_id);

            // Check if user has access to this conversation
            if (!$user->isAdmin && $conversation->user_id !== $user->id) {
                return response()->json([
                    'status' => 'Error',
                    'message' => 'Unauthorized'
                ], 403);
            }

            // Mark messages as read
            if ($user->isAdmin) {
                // Admin reads messages - update unread_count_admin
                Message::where('conversation_id', $conversation->id)
                    ->where('sender_type', 'user')
                    ->where('is_read', false)
                    ->update([
                        'is_read' => true,
                        'read_at' => now(),
                    ]);
                $conversation->unread_count_admin = 0;
                $conversation->save();
            } else {
                // User reads messages - update unread_count_user
                Message::where('conversation_id', $conversation->id)
                    ->where('sender_type', 'admin')
                    ->where('is_read', false)
                    ->update([
                        'is_read' => true,
                        'read_at' => now(),
                    ]);
                $conversation->unread_count_user = 0;
                $conversation->save();
            }

            $messages = Message::where('conversation_id', $request->conversation_id)
                ->orderBy('created_at', 'asc')
                ->get()
                ->map(function ($message) use ($request) {
                    return [
                        'id' => $message->id,
                        'conversation_id' => $request->conversation_id,
                        'content' => $message->content,
                        'sender_id' => $message->sender_id,
                        'sender_type' => $message->sender_type,
                        'sender_name' => $message->sender->username ?? 'Unknown',
                        'is_read' => $message->is_read,
                        'created_at' => $message->created_at->format('Y-m-d H:i:s'),
                    ];
                });

            return response()->json($messages, 200);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'Error',
                'message' => 'Failed to fetch messages',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Send a message
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function sendMessage(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'conversation_id' => 'required|uuid|exists:conversations,id',
            'content' => 'required|string|max:5000',
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
            
            $conversation = Conversation::find($request->conversation_id);

            // Check if user has access to this conversation
            if (!$user->isAdmin && $conversation->user_id !== $user->id) {
                return response()->json([
                    'status' => 'Error',
                    'message' => 'Unauthorized'
                ], 403);
            }

            // Determine sender type
            $senderType = $user->isAdmin ? 'admin' : 'user';

            // If admin is sending first message, assign admin to conversation
            if ($user->isAdmin && !$conversation->admin_id) {
                $conversation->admin_id = $user->id;
            }

            DB::transaction(function () use ($conversation, $user, $request, $senderType) {
                // Create message
                $message = Message::create([
                    'conversation_id' => $conversation->id,
                    'sender_id' => $user->id,
                    'sender_type' => $senderType,
                    'content' => $request->content,
                    'is_read' => false,
                ]);

                // Update conversation
                $conversation->last_message_at = now();
                
                // Update unread counts
                if ($senderType === 'user') {
                    $conversation->unread_count_admin++;
                } else {
                    $conversation->unread_count_user++;
                }
                
                $conversation->save();

                return $message;
            });

            // Get the created message
            $message = Message::where('conversation_id', $conversation->id)
                ->where('sender_id', $user->id)
                ->where('sender_type', $senderType)
                ->latest()
                ->first();

            return response()->json([
                'status' => 'Success',
                'message' => 'Message sent successfully',
                'data' => [
                    'id' => $message->id,
                    'conversation_id' => $conversation->id,
                    'content' => $message->content,
                    'sender_id' => $message->sender_id,
                    'sender_type' => $message->sender_type,
                    'sender_name' => $user->username,
                    'is_read' => $message->is_read,
                    'created_at' => $message->created_at->format('Y-m-d H:i:s'),
                ]
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'Error',
                'message' => 'Failed to send message',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get all conversations for admin
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function getAdminConversations(Request $request): JsonResponse
    {
        try {
            $user = $request->attributes->get('auth_user');
            
            if (!$user->isAdmin) {
                return response()->json([
                    'status' => 'Error',
                    'message' => 'Unauthorized'
                ], 403);
            }

            $conversations = Conversation::with(['user', 'admin', 'latestMessage'])
                ->where('is_active', true)
                ->orderBy('last_message_at', 'desc')
                ->get()
                ->map(function ($conversation) {
                    return [
                        'id' => $conversation->id,
                        'user_id' => $conversation->user_id,
                        'user_name' => $conversation->user->username ?? 'Unknown',
                        'user_email' => $conversation->user->email ?? '',
                        'admin_id' => $conversation->admin_id,
                        'admin_name' => $conversation->admin ? $conversation->admin->username : null,
                        'subject' => $conversation->subject,
                        'unread_count' => $conversation->unread_count_admin,
                        'last_message' => $conversation->latestMessage ? [
                            'content' => $conversation->latestMessage->content,
                            'sender_type' => $conversation->latestMessage->sender_type,
                            'created_at' => $conversation->latestMessage->created_at->format('Y-m-d H:i:s'),
                        ] : null,
                        'last_message_at' => $conversation->last_message_at ? $conversation->last_message_at->format('Y-m-d H:i:s') : null,
                        'created_at' => $conversation->created_at->format('Y-m-d H:i:s'),
                    ];
                });

            return response()->json($conversations, 200);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'Error',
                'message' => 'Failed to fetch conversations',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Assign conversation to admin
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function assignConversation(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'conversation_id' => 'required|uuid|exists:conversations,id',
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
                ], 403);
            }

            $conversation = Conversation::find($request->conversation_id);
            $conversation->admin_id = $user->id;
            $conversation->save();

            return response()->json([
                'status' => 'Success',
                'message' => 'Conversation assigned successfully'
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'Error',
                'message' => 'Failed to assign conversation',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}

