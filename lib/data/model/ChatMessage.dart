class ChatMessage {
  String messageId;
  int lastDate;
  String message;
  String myName;
  String otherName;
  String myUid;
  String otherUid;
  String myProfileUri = '';
  String otherProfileUri = '';
  bool isSender;

  ChatMessage({
    required this.messageId,
    required this.lastDate,
    required this.message,
    required this.myName,
    required this.otherName,
    required this.myUid,
    required this.otherUid,
    required this.isSender,
  });

  factory ChatMessage.fromJson(String messageId, Map<String, dynamic> json) {
    return ChatMessage(
      messageId: messageId,
      lastDate: json['lastDate'],
      message: json['message'],
      myName: json['myName'],
      otherName: json['otherName'],
      myUid: json['myUid'],
      otherUid: json['otherUid'],
      isSender: json['isSender'],
    );
  }

  Map<String, dynamic> toJson() => {
        'messageId': messageId,
        'lastDate': lastDate,
        'message': message,
        'myName': myName,
        'otherName': otherName,
        'myUid': myUid,
        'otherUid': otherUid,
        'myProfileUri': myProfileUri,
        'otherProfileUri': otherProfileUri,
        "isSender": isSender
      };
}
