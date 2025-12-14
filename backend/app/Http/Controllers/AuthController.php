<?php

namespace App\Http\Controllers;

use App\Models\Session;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;
use PHPOpenSourceSaver\JWTAuth\Facades\JWTAuth;

class AuthController extends Controller
{
    /**
     * Generate professional HTML email template
     */
    /**
     * Generate plain text version of email
     */
    private function getPlainTextVersion(string $greeting, string $title, string $code, string $note): string
    {
        return "{$greeting}

{$title}

{$code}

{$note}

⚠️ ملاحظة هامة:
• لا تشارك هذا الرمز مع أي شخص
• إذا لم تقم بطلب هذا الرمز، يرجى تجاهل هذه الرسالة

مع أطيب التحيات،
فريق تطبيق الاعلان اليومي

© " . date('Y') . " تطبيق الاعلان اليومي - جميع الحقوق محفوظة
";
    }

    private function getEmailTemplate(string $title, string $greeting, string $content, string $code = null, string $footer = null): string
    {
        $primaryColor = '#2596FA'; // Primary Blue
        $darkColor = '#364A62'; // Dark Blue
        $lightBg = '#E9F9FF'; // Light Blue Background
        $white = '#FFFFFF';

        $codeSection = '';
        if ($code) {
            $codeSection = "
            <div style='text-align: center; margin: 30px 0;'>
                <div style='display: inline-block; background: linear-gradient(135deg, {$primaryColor}, {$darkColor}); padding: 3px; border-radius: 12px; box-shadow: 0 4px 15px rgba(37, 150, 250, 0.3);'>
                    <div style='background: {$white}; padding: 20px 40px; border-radius: 10px;'>
                        <div style='font-size: 36px; font-weight: bold; letter-spacing: 8px; color: {$darkColor}; font-family: Arial, sans-serif;'>
                            {$code}
                        </div>
                    </div>
                </div>
            </div>";
        }

        $footerText = $footer ?? 'مع أطيب التحيات،<br>فريق تطبيق الاعلان اليومي 💙';

        return "
<!DOCTYPE html>
<html dir='rtl' lang='ar'>
<head>
    <meta charset='UTF-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1.0'>
    <title>{$title}</title>
</head>
<body style='margin: 0; padding: 0; font-family: Arial, sans-serif; background-color: {$lightBg};'>
    <table width='100%' cellpadding='0' cellspacing='0' style='background-color: {$lightBg}; padding: 40px 20px;'>
        <tr>
            <td align='center'>
                <table width='600' cellpadding='0' cellspacing='0' style='background-color: {$white}; border-radius: 20px; overflow: hidden; box-shadow: 0 8px 30px rgba(0, 0, 0, 0.1); max-width: 100%;'>
                    <!-- Header -->
                    <tr>
                        <td style='background: linear-gradient(135deg, {$primaryColor}, {$darkColor}); padding: 40px 30px; text-align: center;'>
                            <div style='display: inline-block; width: 80px; height: 80px; background: rgba(255, 255, 255, 0.2); border-radius: 50%; line-height: 80px; margin-bottom: 20px;'>
                                <span style='font-size: 40px; color: {$white};'>📱</span>
                            </div>
                            <h1 style='margin: 0; color: {$white}; font-size: 28px; font-weight: bold; text-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);'>
                                تطبيق الاعلان اليومي
                            </h1>
                            <p style='margin: 10px 0 0 0; color: rgba(255, 255, 255, 0.9); font-size: 16px;'>
                                {$title}
                            </p>
                        </td>
                    </tr>
                    
                    <!-- Content -->
                    <tr>
                        <td style='padding: 40px 30px;'>
                            <p style='margin: 0 0 20px 0; color: {$darkColor}; font-size: 18px; line-height: 1.6;'>
                                {$greeting}
                            </p>
                            
                            {$content}
                            
                            {$codeSection}
                            
                            <div style='margin-top: 30px; padding-top: 20px; border-top: 2px solid {$lightBg};'>
                                <p style='margin: 0; color: #666; font-size: 14px; line-height: 1.6;'>
                                    <strong style='color: {$darkColor};'>⚠️ ملاحظة هامة:</strong><br>
                                    • لا تشارك هذا الرمز مع أي شخص<br>
                                    • إذا لم تقم بطلب هذا الرمز، يرجى تجاهل هذه الرسالة<br>
                                    • للدعم الفني، تواصل معنا عبر التطبيق
                                </p>
                            </div>
                        </td>
                    </tr>
                    
                    <!-- Footer -->
                    <tr>
                        <td style='background-color: {$lightBg}; padding: 30px; text-align: center; border-top: 1px solid #E0E0E0;'>
                            <p style='margin: 0; color: {$darkColor}; font-size: 16px; font-weight: bold;'>
                                {$footerText}
                            </p>
                            <p style='margin: 15px 0 0 0; color: #999; font-size: 12px;'>
                                © " . date('Y') . " تطبيق الاعلان اليومي - جميع الحقوق محفوظة
                            </p>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</body>
</html>";
    }
    /**
     * Register a new user
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function register(Request $request): JsonResponse
    {
        // Support both Flutter format (name, user, pass) and standard format
        $data = [
            'fullname' => $request->input('fullname') ?? $request->input('name'),
            'username' => $request->input('username') ?? $request->input('user'),
            'email' => $request->input('email'),
            'password' => $request->input('password') ?? $request->input('pass'),
            'phone' => $request->input('phone'),
        ];

        $validator = Validator::make($data, [
            'fullname' => 'required|string|max:255',
            'username' => 'required|string|max:255|unique:users',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:6',
            'phone' => 'nullable|string|max:20',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'Error',
                'message' => 'Validation Error',
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            // Create verification code
            $verificationCode = str_pad(random_int(100000, 999999), 6, '0', STR_PAD_LEFT);

            // Create user
            // Note: password from Flutter is already SHA-256 hashed, so we store it directly

            // DEBUG: Log registration password (REMOVE IN PRODUCTION!)
            \Log::info('👤 New User Registration:', [
                'username' => $data['username'],
                'email' => $data['email'],
                'password_length' => strlen($data['password']),
                'password_hash' => $data['password']
            ]);

            $user = User::create([
                'fullname' => $data['fullname'],
                'username' => $data['username'],
                'email' => $data['email'],
                'password' => $data['password'], // Already SHA-256 hashed from Flutter
                'phone' => $data['phone'],
                'verification' => $verificationCode,
                'joinDate' => now(),
                'isVerified' => false,
                'isAdmin' => false,
                'isDeleted' => false,
                'points' => 0,
            ]);

            // Generate JWT token
            $token = JWTAuth::fromUser($user);

            // Create session
            Session::create([
                'userid' => $user->id,
                'ip' => $request->ip(),
                'last_used' => now(),
                'is_reset' => false,
            ]);

            // Send verification email
            try {
                $emailBody = $this->getEmailTemplate(
                    '🎉 مرحباً بك في تطبيق الاعلان اليومي 🎉',
                    "عزيزي/عزيزتي <strong>{$user->fullname}</strong>،<br><br>شكراً لانضمامك إلى منصة تطبيق الاعلان اليومي!<br>نحن سعداء بوجودك معنا.",
                    "<p style='color: #364A62; font-size: 16px; line-height: 1.8; text-align: center; margin: 20px 0;'>
                        <strong>🔐 رمز التحقق الخاص بك:</strong><br>
                        <span style='color: #666; font-size: 14px;'>⏱️ مدة صلاحية الرمز: 15 دقيقة</span>
                    </p>",
                    $verificationCode
                );

                Mail::html($emailBody, function ($message) use ($user) {
                    $fromAddress = config('mail.from.address');
                    $fromName = config('mail.from.name');

                    $message->from($fromAddress, $fromName)
                        ->to($user->email)
                        ->replyTo($fromAddress, $fromName)
                        ->subject('تطبيق الاعلان اليومي - رمز التحقق');

                    // Add headers to prevent spam
                    $message->getHeaders()
                        ->addTextHeader('X-Mailer', 'Laravel/' . app()->version())
                        ->addTextHeader('X-Priority', '1')
                        ->addTextHeader('List-Unsubscribe', '<mailto:' . $fromAddress . '?subject=unsubscribe>')
                        ->addTextHeader('Precedence', 'bulk');
                });
            } catch (\Exception $e) {
                // Log error but don't fail registration
                \Log::error('Failed to send verification email: ' . $e->getMessage());
            }

            return response()->json([
                'status' => 'Success',
                'message' => 'User registered successfully',
                'data' => [
                    'id' => $user->id,
                    'session' => $token,
                    'user' => [
                        'fullname' => $user->fullname,
                        'username' => $user->username,
                        'email' => $user->email,
                        'phone' => $user->phone,
                        'points' => $user->points,
                        'isVerified' => $user->isVerified,
                        'isAdmin' => $user->isAdmin,
                    ]
                ]
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'Error',
                'message' => 'Registration failed',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Login user
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function login(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'user' => 'required|string', // username or email
            'pass' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'Error',
                'message' => 'Validation Error',
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            // Find user by username or email
            $user = User::where('username', $request->user)
                ->orWhere('email', $request->user)
                ->where('isDeleted', false)
                ->first();

            if (!$user) {
                return response()->json([
                    'status' => 'Invalid Auth',
                    'message' => 'Invalid credentials'
                ], 401);
            }

            // Verify password (expecting SHA-256 hash from Flutter)
            // Flutter sends password as: base64_encode(sha256(password))
            // So we compare directly (both are SHA-256 hashes)

            // DEBUG: Log password comparison (REMOVE IN PRODUCTION!)
            \Log::info('🔐 Login Attempt:', [
                'user' => $request->user,
                'stored_password_length' => strlen($user->password),
                'received_password_length' => strlen($request->pass),
                'stored_password' => $user->password,
                'received_password' => $request->pass,
                'passwords_match' => $user->password === $request->pass
            ]);

            if ($user->password !== $request->pass) {
                \Log::warning('❌ Password mismatch for user: ' . $user->username);
                return response()->json([
                    'status' => 'Invalid Auth',
                    'message' => 'Invalid credentials'
                ], 401);
            }

            \Log::info('✅ Password matched for user: ' . $user->username);

            // Check if user is verified
            if (!$user->isVerified) {
                // Generate new token for unverified user
                $token = JWTAuth::fromUser($user);

                return response()->json([
                    'status' => 'Unverified',
                    'message' => 'Please verify your email',
                    'data' => [
                        'id' => $user->id,
                        'session' => $token,
                    ]
                ], 403);
            }

            // Generate JWT token
            $token = JWTAuth::fromUser($user);

            // Update or create session
            Session::updateOrCreate(
                ['userid' => $user->id],
                [
                    'ip' => $request->ip(),
                    'last_used' => now(),
                    'is_reset' => false,
                ]
            );

            return response()->json([
                'status' => 'Valid',
                'message' => 'Login successful',
                'data' => [
                    'id' => $user->id,
                    'session' => $token,
                    'user' => [
                        'fullname' => $user->fullname,
                        'username' => $user->username,
                        'email' => $user->email,
                        'phone' => $user->phone,
                        'points' => $user->points,
                        'isVerified' => $user->isVerified,
                        'isAdmin' => $user->isAdmin,
                    ]
                ]
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'Error',
                'message' => 'Login failed',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Logout user
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function logout(Request $request): JsonResponse
    {
        try {
            $user = JWTAuth::parseToken()->authenticate();

            if (!$user) {
                return response()->json([
                    'status' => 'Error',
                    'message' => 'User not found'
                ], 404);
            }

            // Invalidate token
            JWTAuth::invalidate(JWTAuth::getToken());

            // Delete session
            Session::where('userid', $user->id)->delete();

            return response()->json([
                'status' => 'Valid',
                'message' => 'Logout successful'
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'Error',
                'message' => 'Logout failed',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Check if user is logged in
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function isLoggedIn(Request $request): JsonResponse
    {
        try {
            $user = JWTAuth::parseToken()->authenticate();

            if (!$user) {
                return response()->json([
                    'status' => 'Invalid',
                    'message' => 'Invalid session'
                ], 401);
            }

            // Update session last_used
            Session::where('userid', $user->id)->update([
                'last_used' => now()
            ]);

            return response()->json([
                'status' => 'Valid',
                'message' => 'Session is valid'
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'Invalid',
                'message' => 'Invalid session'
            ], 401);
        }
    }

    /**
     * Get user profile
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function profile(Request $request): JsonResponse
    {
        try {
            $user = JWTAuth::parseToken()->authenticate();

            if (!$user) {
                return response()->json([
                    'status' => 'Error',
                    'message' => 'User not found'
                ], 404);
            }

            return response()->json([
                'status' => 'Success',
                'name' => $user->fullname,
                'username' => $user->username,
                'email' => $user->email,
                'phone' => $user->phone ?? 'لا يوجد رقم هاتف',
                'join' => $user->joinDate->format('Y-m-d'),
                'points' => (float) $user->points,
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'Error',
                'message' => 'Failed to fetch profile',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Check if user is admin
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function isAdmin(Request $request): JsonResponse
    {
        try {
            $user = JWTAuth::parseToken()->authenticate();

            if (!$user) {
                return response()->json([
                    'status' => 'Invalid',
                    'message' => 'Invalid session'
                ], 401);
            }

            return response()->json([
                'status' => $user->isAdmin ? 'Valid' : 'Invalid',
                'isAdmin' => $user->isAdmin
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'Error',
                'message' => 'Failed to check admin status'
            ], 500);
        }
    }

    /**
     * Delete user account
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function delete(Request $request): JsonResponse
    {
        try {
            $user = JWTAuth::parseToken()->authenticate();

            if (!$user) {
                return response()->json([
                    'status' => 'Error',
                    'message' => 'User not found'
                ], 404);
            }

            // Soft delete - just mark as deleted
            $user->isDeleted = true;
            $user->save();

            // Delete all sessions
            Session::where('userid', $user->id)->delete();

            // Invalidate token
            JWTAuth::invalidate(JWTAuth::getToken());

            return response()->json([
                'status' => 'Success',
                'message' => 'Account deleted successfully'
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'Error',
                'message' => 'Failed to delete account',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Send verification code
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function sendCode(Request $request): JsonResponse
    {
        try {
            // Get user from middleware (already authenticated)
            $user = $request->attributes->get('auth_user');

            if (!$user) {
                return response()->json([
                    'status' => 'Invalid Request',
                    'message' => 'User not found'
                ], 404);
            }

            // Generate new verification code
            $verificationCode = str_pad(random_int(100000, 999999), 6, '0', STR_PAD_LEFT);
            $user->verification = $verificationCode;
            $user->save();

            // Send verification code via email
            try {
                $emailBody = $this->getEmailTemplate(
                    '🔐 رمز التحقق',
                    "مرحباً <strong>{$user->fullname}</strong>،",
                    "<p style='color: #364A62; font-size: 16px; line-height: 1.8; text-align: center; margin: 20px 0;'>
                        <strong>رمز التحقق الخاص بك:</strong><br>
                        <span style='color: #666; font-size: 14px;'>⏱️ مدة صلاحية الرمز: 15 دقيقة</span>
                    </p>",
                    $verificationCode
                );

                Mail::html($emailBody, function ($message) use ($user) {
                    $fromAddress = config('mail.from.address');
                    $fromName = config('mail.from.name');

                    $message->from($fromAddress, $fromName)
                        ->to($user->email)
                        ->replyTo($fromAddress, $fromName)
                        ->subject('تطبيق الاعلان اليومي - رمز التحقق');

                    // Add headers to prevent spam
                    $message->getHeaders()
                        ->addTextHeader('X-Mailer', 'Laravel/' . app()->version())
                        ->addTextHeader('X-Priority', '1')
                        ->addTextHeader('List-Unsubscribe', '<mailto:' . $fromAddress . '?subject=unsubscribe>')
                        ->addTextHeader('Precedence', 'bulk');
                });
            } catch (\Exception $e) {
                return response()->json([
                    'status' => 'Error',
                    'message' => 'Failed to send verification email'
                ], 500);
            }

            return response()->json([
                'status' => 'Success',
                'message' => 'Verification code sent successfully',
                'code' => $verificationCode // Remove in production
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'Error',
                'message' => 'Failed to send verification code',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Verify user email
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function verify(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'code' => 'required|string|size:6',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'Error',
                'message' => 'Invalid code format'
            ], 422);
        }

        try {
            // Get user from middleware (already authenticated)
            $user = $request->attributes->get('auth_user');

            if (!$user) {
                return response()->json([
                    'status' => 'Invalid Request',
                    'message' => 'User not found'
                ], 404);
            }

            if ($user->verification !== $request->code) {
                return response()->json([
                    'status' => 'Invalid Code',
                    'message' => 'Verification code is incorrect'
                ], 400);
            }

            $user->isVerified = true;
            $user->save();

            return response()->json([
                'status' => 'Success',
                'message' => 'Email verified successfully'
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'Error',
                'message' => 'Verification failed',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Check if user is verified
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function verifyCheck(Request $request): JsonResponse
    {
        try {
            $user = JWTAuth::parseToken()->authenticate();

            if (!$user) {
                return response()->json([
                    'status' => 'Invalid Request',
                    'message' => 'User not found'
                ], 404);
            }

            return response()->json([
                'status' => $user->isVerified ? 'Success' : 'Unverified',
                'isVerified' => $user->isVerified
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'Error',
                'message' => 'Failed to check verification status'
            ], 500);
        }
    }

    /**
     * Request password reset
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function resetPass(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'Invalid Request',
                'message' => 'Invalid email format'
            ], 422);
        }

        try {
            $user = User::where('email', $request->email)
                ->where('isDeleted', false)
                ->first();

            if (!$user) {
                return response()->json([
                    'status' => 'Invalid Request',
                    'message' => 'Email not found'
                ], 404);
            }

            // Generate reset code
            $resetCode = str_pad(random_int(100000, 999999), 6, '0', STR_PAD_LEFT);
            $user->verification = $resetCode;
            $user->save();

            // Create reset session
            $token = JWTAuth::fromUser($user);
            Session::create([
                'userid' => $user->id,
                'ip' => $request->ip(),
                'last_used' => now(),
                'is_reset' => true,
            ]);

            // Send password reset code via email
            try {
                $emailBody = $this->getEmailTemplate(
                    '🔑 إعادة تعيين كلمة المرور',
                    "مرحباً <strong>{$user->fullname}</strong>،<br><br>لقد طلبت إعادة تعيين كلمة المرور الخاصة بك.",
                    "<p style='color: #364A62; font-size: 16px; line-height: 1.8; text-align: center; margin: 20px 0;'>
                        <strong>رمز إعادة التعيين الخاص بك:</strong><br>
                        <span style='color: #666; font-size: 14px;'>⏱️ مدة صلاحية الرمز: 15 دقيقة</span>
                    </p>",
                    $resetCode,
                    'مع أطيب التحيات،<br>فريق تطبيق الاعلان اليومي 💙'
                );

                // Get plain text version
                $plainText = $this->getPlainTextVersion(
                    "مرحباً {$user->fullname}",
                    "طلب إعادة تعيين كلمة المرور",
                    "رمز إعادة التعيين: {$resetCode}",
                    "مدة الصلاحية: 15 دقيقة"
                );

                Mail::html($emailBody, function ($message) use ($user) {
                    $fromAddress = config('mail.from.address');
                    $fromName = config('mail.from.name');

                    $message->from($fromAddress, $fromName)
                        ->to($user->email)
                        ->replyTo($fromAddress, $fromName)
                        ->subject('تطبيق الاعلان اليومي - اعادة تعيين كلمة المرور');

                    // Add headers to prevent spam
                    $message->getHeaders()
                        ->addTextHeader('X-Mailer', 'Laravel/' . app()->version())
                        ->addTextHeader('X-Priority', '1')
                        ->addTextHeader('List-Unsubscribe', '<mailto:' . $fromAddress . '?subject=unsubscribe>')
                        ->addTextHeader('Precedence', 'bulk');
                });
            } catch (\Exception $e) {
                return response()->json([
                    'status' => 'Error',
                    'message' => 'Failed to send reset email'
                ], 500);
            }

            return response()->json([
                'status' => 'Valid',
                'message' => 'Reset code sent successfully',
                'id' => $user->id,
                'session' => $token,
                'code' => $resetCode // Remove in production
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'Error',
                'message' => 'Failed to initiate password reset',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Validate reset code
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function validateResetPass(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'code' => 'required|string|size:6',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'Invalid Request',
                'message' => 'Invalid code format'
            ], 422);
        }

        try {
            $user = JWTAuth::parseToken()->authenticate();

            if (!$user) {
                return response()->json([
                    'status' => 'Invalid Request',
                    'message' => 'User not found'
                ], 404);
            }

            // Check if session is for reset
            $session = Session::where('userid', $user->id)
                ->where('is_reset', true)
                ->first();

            if (!$session) {
                return response()->json([
                    'status' => 'Invalid Request',
                    'message' => 'Invalid reset session'
                ], 400);
            }

            if ($user->verification !== $request->code) {
                return response()->json([
                    'status' => 'Invalid Code',
                    'message' => 'Reset code is incorrect'
                ], 400);
            }

            return response()->json([
                'status' => 'Success',
                'message' => 'Reset code validated successfully'
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'Error',
                'message' => 'Validation failed',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Change password
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function changePass(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'pass' => 'required|string|min:6',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'Invalid Request',
                'message' => 'Invalid password format'
            ], 422);
        }

        try {
            $user = JWTAuth::parseToken()->authenticate();

            if (!$user) {
                return response()->json([
                    'status' => 'Invalid Request',
                    'message' => 'User not found'
                ], 404);
            }

            // Check if this is a reset session
            $session = Session::where('userid', $user->id)
                ->where('is_reset', true)
                ->first();

            if (!$session) {
                return response()->json([
                    'status' => 'Invalid Request',
                    'message' => 'Invalid reset session'
                ], 400);
            }

            // Update password (expecting SHA-256 hash from Flutter)
            // Flutter sends password as: base64_encode(sha256(password))
            // So we store it directly (no need for bcrypt hashing)
            $user->password = $request->pass;
            $user->save();

            // Delete reset session
            $session->delete();

            return response()->json([
                'status' => 'Success',
                'message' => 'Password changed successfully'
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'Error',
                'message' => 'Failed to change password',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}

