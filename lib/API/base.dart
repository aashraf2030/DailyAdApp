class BackendAPI{
  // Production URL (Active)
  static const domain = "https://hitech-wp.com/";
  static const base = "${domain}api/";
  
  // Local Development URL (Commented for now)
  // static const base = "http://127.0.0.1:8000/api/";  // Android Emulator
  
  // Other local options:
  // static const base = "http://127.0.0.1:8000/api/";  // Desktop/Web
  // static const base = "http://192.168.1.X:8000/api/";  // Real Device (replace X with your IP)
  // static const base = "http://localhost:8000/api/";  // iOS Simulator
  // static const base = "https://adsapp-abu-sultan.com/api/";

  static const auth = "auth/";
  static const login = "$base${auth}login";
  static const is_loggedin = "$base${auth}is_logged_in";
  static const logout = "$base${auth}logout";
  static const register = "$base${auth}register";
  static const delete_user = "$base${auth}delete";
  static const verify = "$base${auth}verify";
  static const verify_check = "$base${auth}is_verified";
  static const send_code = "$base${auth}send_code";
  static const change_pass = "$base${auth}change_pass";
  static const pass_reset = "$base${auth}pass_reset";
  static const validate_reset = "$base${auth}validate_reset";
  static const is_admin = "$base${auth}is_admin";
  static const profile = "$base${auth}profile";

  static const ad = "ad/";
  static const create_ad = "$base${ad}create_ad";
  static const edit_ad = "$base${ad}edit_ad";
  static const get_user_ad = "$base${ad}get_user_ads";
  static const fetch_cat_ad = "$base${ad}fetch_cat";
  static const renew_ad = "$base${ad}renew";
  
  static const ad_payment = "ad-payment/";
  static const ad_payment_initialize = "$base${ad_payment}initialize";
  static const ad_payment_status = "$base${ad_payment}status";
  static const ad_payment_confirm_apple = "$base${ad_payment}confirm_apple_pay";
  static const validate_coupon = "$base${ad_payment}validate_coupon";

  static const view = "view/";
  static const watch = "${base}${view}watch";

  static const authority = "authority/";
  static const defaultReq = "$base${authority}default_req";
  static const renewReq = "$base${authority}renew_req";
  static const moneyReq = "$base${authority}money_req";
  static const myReq = "$base${authority}my_req";
  static const handleReq = "$base${authority}handle_req";
  static const deleteReq = "$base${authority}delete_req";
  static const leaderboard = "$base${authority}leaderboard";
  static const pointExchange = "$base${authority}points_exchange";

  static const chat = "chat/";
  static const getConversation = "$base${chat}conversation";
  static const getMessages = "$base${chat}messages";
  static const sendMessage = "$base${chat}send";
  static const adminConversations = "$base${chat}admin/conversations";
  static const assignConversation = "$base${chat}admin/assign";

}
