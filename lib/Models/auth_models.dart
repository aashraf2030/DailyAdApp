class AuthResult{
  late String status;
  String? id;
  String? session;

  AuthResult.fromJson(Map<String, dynamic> json)
  {
    status = json["status"];
    id = json["id"];
    session = json["session"];
  }

  AuthResult(this.status);

  @override
  String toString() {
    return "{Status : ${status}, id : ${id}, session : ${session}}";
  }
}


class UserProfile{
  String name = "Invalid";
  String username = "Invalid";
  String email = "Invalid";
  String phone = "Invalid";
  String join = "Invalid";
  int points = 0;
  UserProfile();
  UserProfile.fromJson(Map<String, dynamic> json)
  {
    name = json["name"];
    username = json["username"];
    email = json["email"];
    phone = json["phone"]?? "لا يوجد رقم هاتف";
    join = json["join"];
    points = json["points"];
  }
}