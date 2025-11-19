class LeaderboardUser {

  late final int rank;
  late final String username;
  late final double points;
  late final bool isCurrentUser;

  LeaderboardUser.fromJson(Map<String, dynamic> json)
  {
    rank = json["rank"] ?? 0;
    username = json["username"] ?? "";
    points = (json["points"] ?? 0).toDouble();
    isCurrentUser = json["isCurrentUser"] ?? false;
  }

}