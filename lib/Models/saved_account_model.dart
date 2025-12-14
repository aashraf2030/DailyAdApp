class SavedAccount {
  final String username;
  final String name;
  final String userId;
  final String avatarLetter;
  final DateTime savedAt;

  SavedAccount({
    required this.username,
    required this.name,
    required this.userId,
    required this.avatarLetter,
    required this.savedAt,
  });

  // Convert to JSON for SharedPreferences
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'name': name,
      'userId': userId,
      'avatarLetter': avatarLetter,
      'savedAt': savedAt.toIso8601String(),
    };
  }

  // Create from JSON
  factory SavedAccount.fromJson(Map<String, dynamic> json) {
    return SavedAccount(
      username: json['username'] ?? '',
      name: json['name'] ?? '',
      userId: json['userId'] ?? '',
      avatarLetter: json['avatarLetter'] ?? 'U',
      savedAt: DateTime.parse(json['savedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Get avatar letter from name
  static String getAvatarLetter(String name) {
    if (name.isEmpty) return 'U';
    return name[0].toUpperCase();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SavedAccount && other.userId == userId;
  }

  @override
  int get hashCode => userId.hashCode;
}

