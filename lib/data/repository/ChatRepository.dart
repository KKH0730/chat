import 'dart:async';


import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';

import '../model/ChatMessage.dart';
import '../model/Result.dart';
import '../provider/ChatProvider.dart';

class ChatRepository {
  final ChatProvider chatProvider = Get.find<ChatProvider>();

  StreamSubscription reqChatMessages(PublishSubject<ChatMessage> addedChatMessagePublisher, String myUid,
          String otherUid, String myProfileUri, String otherProfileUri) =>
      chatProvider.reqChatMessages(addedChatMessagePublisher, myUid, otherUid, myProfileUri, otherProfileUri);

  Future<List<ChatMessage>> reqPreviousMessage(String myUid, String otherUid, String myProfileUri, String otherProfileUri, int lastTimestamp, String msg) {
    return chatProvider.reqPreviousMessage(myUid, otherUid, myProfileUri, otherProfileUri, lastTimestamp, msg);
  }

  Future<Result<bool>> fetchChatMessage(
      String message, String myName, String myUid, String otherName, String otherUid, int timeMillisecond) {
    return chatProvider.fetchChatMessage(message, myName, myUid, otherName, otherUid, timeMillisecond);
  }
}
