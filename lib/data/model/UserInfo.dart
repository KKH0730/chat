class UserInfo {
  String name;
  String profileUri;

  UserInfo({required this.name, required this.profileUri});

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(name: json['name'], profileUri: json['profileUri']);
  }
}
