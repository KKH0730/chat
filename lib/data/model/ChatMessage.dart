class ChatMessage {
  String messageId;
  int timestamp;
  String message;
  String myName;
  String otherName;
  String myUid;
  String otherUid;
  String myProfileUri = '';
  String otherProfileUri = '';
  bool isSender;
  bool isLoading = false;

  ChatMessage({
    required this.messageId,
    required this.timestamp,
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
      timestamp: json['timestamp'],
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
        'timestamp': timestamp,
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
