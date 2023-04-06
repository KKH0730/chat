class UserInfo {
  String uid;
  String name;
  String profileUri;

  UserInfo({ required this.uid, required this.name, required this.profileUri });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(uid: json['uid'], name: json['name'], profileUri: json['profileUri']);
  }
}
