class AuthResult{
  late String status;
  String? id;
  String? session;

  AuthResult.fromJson(Map<String, dynamic> json)
  {
    status = json["status"] ?? "Error";
    
    // Support both formats:
    // 1. Direct format: {"status": "...", "id": "...", "session": "..."}
    // 2. Nested format: {"status": "...", "data": {"id": "...", "session": "..."}}
    if (json.containsKey("id") && json.containsKey("session")) {
      id = json["id"];
      session = json["session"];
    } else if (json.containsKey("data") && json["data"] is Map) {
      final data = json["data"] as Map<String, dynamic>;
      id = data["id"];
      session = data["session"];
    } else {
      id = null;
      session = null;
    }
  }

  AuthResult(this.status);

  @override
  String toString() {
    return "{Status : $status, id : $id, session : $session}";
  }
}


class UserProfile{
  String name = "Invalid";
  String username = "Invalid";
  String email = "Invalid";
  String phone = "Invalid";
  String join = "Invalid";
  double points = 0.0;
  UserProfile();
  UserProfile.guest()
  {
    name = "زائر";
    username = "زائر";
    email = "زائر";
    phone = "لا يوجد رقم هاتف";
    join = "لا يوجد تاريخ";
    points = 0.0;
  }
  UserProfile.fromJson(Map<String, dynamic> json)
  {
    name = json["name"] ?? "Invalid";
    username = json["username"] ?? "Invalid";
    email = json["email"] ?? "Invalid";
    phone = json["phone"] ?? "لا يوجد رقم هاتف";
    join = json["join"] ?? "Invalid";
    // Handle both int and double from API
    if (json["points"] is int) {
      points = (json["points"] as int).toDouble();
    } else if (json["points"] is double) {
      points = json["points"] as double;
    } else {
      points = (json["points"] ?? 0).toDouble();
    }
  }
}