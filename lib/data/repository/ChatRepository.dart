import 'dart:async';


import 'package:rxdart/rxdart.dart';

import '../model/ChatMessage.dart';
import '../model/Result.dart';
import '../provider/ChatProvider.dart';

class ChatRepository {
  final ChatProvider chatProvider = ChatProvider();

  void fetchMessageToChatGPT(String inputText, PublishSubject<ChatMessage> chatGPTMessagePublisher) =>
    chatProvider.fetchMessageToChatGPT(inputText, chatGPTMessagePublisher);

  StreamSubscription observeOtherConnectionState(PublishSubject<bool> otherConnectionPublisher, String myUid, String otherUid) =>
      chatProvider.observeOtherConnectionState(otherConnectionPublisher, myUid, otherUid);


  StreamSubscription reqChatMessages(PublishSubject<ChatMessage> addedChatMessagePublisher, String myUid,
          String otherUid, String myProfileUri, String otherProfileUri, int lastTimeStamp) =>
      chatProvider.reqChatMessages(addedChatMessagePublisher, myUid, otherUid, myProfileUri, otherProfileUri, lastTimeStamp);

  Future<List<ChatMessage>> reqPreviousMessage(String myUid, String otherUid, String myProfileUri, String otherProfileUri, int lastTimestamp, String msg) {
    return chatProvider.reqPreviousMessage(myUid, otherUid, myProfileUri, otherProfileUri, lastTimestamp, msg);
  }

  Future<Result<bool>> fetchChatMessage(
      String message, String myName, String myUid, String otherName, String otherUid, int timeMillisecond) {
    return chatProvider.fetchChatMessage(message, myName, myUid, otherName, otherUid, timeMillisecond);
  }

  void fetchUnCheckedMessageCountZero(String myUid, String otherUid) => chatProvider.fetchUnCheckedMessageCountZero(myUid, otherUid);
}
