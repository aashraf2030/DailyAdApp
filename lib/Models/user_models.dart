class LeaderboardUser {

  late final String username;
  late final String name;
  late final String email;
  late final String phone;
  late final int views;
  late final int points;

  LeaderboardUser.fromJson(Map<String, dynamic> json)
  {
    username = json["username"];
    name = json["name"];
    email = json["email"];
    phone = json["phone"];
    views = json["views"];
    points = json["points"];
  }

}