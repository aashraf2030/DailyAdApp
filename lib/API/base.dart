class BackendAPI{
  static const base = "https://adsapp-abu-sultan.com/";

  //Auth APIs
  static const auth = "auth/";
  static const login = "$base${auth}login";
  static const is_loggedin = "$base${auth}is_logged_in";
  static const logout = "$base${auth}logout";
  static const register = "$base${auth}register";
  static const verify = "$base${auth}verify";
  static const verify_check = "$base${auth}is_verified";
  static const send_code = "$base${auth}send_code";
  static const change_pass = "$base${auth}change_pass";
  static const pass_reset = "$base${auth}pass_reset";
  static const validate_reset = "$base${auth}validate_reset";
  static const is_admin = "$base${auth}is_admin";
  static const profile = "$base${auth}profile";

  //Ad APIs
  static const ad = "ad/";
  static const create_ad = "$base${ad}create_ad";
  static const edit_ad = "$base${ad}edit_ad";
  static const get_user_ad = "$base${ad}get_user_ads";
  static const fetch_cat_ad = "$base${ad}fetch_cat";
  static const renew_ad = "$base${ad}renew";

  //View APIs
  static const view = "view/";
  static const watch = "${base}${view}watch";

  //Authority APIs
  static const authority = "authority/";
  static const default_req = "$base${authority}default_req";
  static const renew_req = "$base${authority}renew_req";
  static const money_req = "$base${authority}money_req";
  static const my_req = "$base${authority}my_req";
  static const handle_req = "$base${authority}handle_req";
  static const delete_req = "$base${authority}delete_req";
  static const leaderboard = "$base${authority}leaderboard";
  static const point_exchange = "$base${authority}points_exchange";

}
