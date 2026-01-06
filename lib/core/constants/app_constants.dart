/// Application-wide constants
/// All magic strings and numbers should be defined here
class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  // ============================================
  // Network Configuration
  // ============================================
  static const int connectionTimeout = 30; // seconds
  static const int receiveTimeout = 60; // seconds
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  // ============================================
  // Cache Configuration
  // ============================================
  static const Duration profileCacheDuration = Duration(minutes: 5);
  static const Duration adsCacheDuration = Duration(minutes: 3);

  // ============================================
  // Shared Preferences Keys
  // ============================================
  static const String prefKeyGuest = "guest";
  static const String prefKeyUserId = "id";
  static const String prefKeySession = "session";

  // ============================================
  // UI Configuration
  // ============================================
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 12.0;
  static const double defaultElevation = 4.0;
  
  // Navigation Bar
  static const double navBarHeight = 72.0;
  static const double navBarIconSize = 22.0;
  static const int navBarAnimationDuration = 300; // milliseconds
  
  // Fixed Ads Area
  static const double fixedAdsTopOffset = 220.0;

  // ============================================
  // Colors
  // ============================================
  static const int primaryBlue = 0xFF2596FA;
  static const int primaryDark = 0xFF364A62;
  static const int whatsAppGreen = 0xFF25D366;
  static const int backgroundColor = 0xFFFAFFFF;
  static const int gradientStart = 0xFFF8F9FA;
  static const int gradientEnd = 0xFFFFFFFF;

  // ============================================
  // Contact Information
  // ============================================
  static const String whatsAppNumber = '966570949696';
  static const String whatsAppMessage = 'مرحباً، أحتاج المساعدة';

  // ============================================
  // Error Messages (Arabic)
  // ============================================
  static const String errorGeneric = "حدث خطأ غير متوقع";
  static const String errorNetwork = "فشل الاتصال بالإنترنت";
  static const String errorTimeout = "انتهت مهلة الاتصال";
  static const String errorServer = "خطأ في الخادم";
  static const String errorInvalidAuth = "بيانات تسجيل الدخول غير صحيحة";
  static const String errorSessionExpired = "انتهت صلاحية الجلسة";
  static const String errorProfileFetch = "لم نستطع استحضار الملف الشخصي";
  static const String errorWhatsAppOpen = "عذراً، لا يمكن فتح واتساب";
  static const String errorNoResults = "لا توجد نتائج";
  
  // Success Messages
  static const String successGeneric = "تمت العملية بنجاح";
  static const String successLogin = "تم تسجيل الدخول بنجاح";
  static const String successLogout = "تم تسجيل الخروج بنجاح";
  static const String successAdCreated = "تم إنشاء الإعلان بنجاح";
  static const String successAdUpdated = "تم تحديث الإعلان بنجاح";

  // Store & Payment Errors (Arabic)
  static const String errorPaymentFailed = "فشلت عملية الدفع، يرجى المحاولة مرة أخرى";
  static const String errorPaymentCancelled = "تم إلغاء عملية الدفع";
  static const String errorInsufficientFunds = "رصيد غير كافٍ";
  static const String errorCardDeclined = "تم رفض البطاقة";
  static const String errorOrderCreation = "فشل إنشاء الطلب";
  static const String errorProductLoad = "فشل تحميل المنتجات";
  static const String errorInvalidAmount = "المبلغ غير صحيح";

  // ============================================
  // Response Status Codes
  // ============================================
  static const String statusSuccess = "Success";
  static const String statusValid = "Valid";
  static const String statusError = "Error";
  static const String statusInvalidAuth = "Invalid Auth";
  static const String statusInvalidRequest = "Invalid Request";
  static const String statusUnverified = "Unverified";
  static const String statusUserExists = "User Exists";

  // ============================================
  // UI Labels (Arabic)
  // ============================================
  static const String labelHome = "الرئيسية";
  static const String labelSearch = "بحث";
  static const String labelMyAds = "إعلاناتي";
  static const String labelProfile = "الحساب";
  static const String labelAdmin = "الإدارة";
  static const String labelRequests = "الطلبات";
  static const String labelPayments = "المدفوعات";
  static const String labelChat = "الدردشة";
  static const String labelGuest = "زائر";
  static const String labelNoPhone = "لا يوجد رقم هاتف";
  static const String labelNoDate = "لا يوجد تاريخ";
  
  // Placeholders
  static const String placeholderInvalid = "Invalid";
  static const String placeholderSearch = "ابحث عن فئة...";
  static const String placeholderWelcome = "مرحباً بك! 👋";
  static const String placeholderDiscover = "اكتشف أحدث الإعلانات";
  static const String placeholderCustomBrowse = "تصفح مخصص";
  static const String placeholderTryAgain = "جرب كلمة بحث أخرى";

  // ============================================
  // Animation Durations
  // ============================================
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);

  // ============================================
  // Validation Rules
  // ============================================
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 30;
}

