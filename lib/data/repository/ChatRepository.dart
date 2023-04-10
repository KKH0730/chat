import 'dart:async';


import 'package:rxdart/rxdart.dart';

import '../model/ChatMessage.dart';
import '../provider/ChatProvider.dart';

class ChatRepository {
  final ChatProvider chatProvider = ChatProvider();

  StreamSubscription reqChatMessages(PublishSubject<ChatMessage> addedChatMessagePublisher, String myUid,
          String otherUid, String myProfileUri, String otherProfileUri, int lastTimeStamp, bool isChatWithChatGPT) =>
      chatProvider.reqChatMessages(addedChatMessagePublisher, myUid, otherUid, myProfileUri, otherProfileUri, lastTimeStamp, isChatWithChatGPT);

  Future<List<ChatMessage>> reqPreviousMessage(String myUid, String otherUid, String myProfileUri, String otherProfileUri, int lastTimestamp, String msg) {
    return chatProvider.reqPreviousMessage(myUid, otherUid, myProfileUri, otherProfileUri, lastTimestamp, msg);
  }

  void fetchChatMessage(String message, String myName, String myUid, String otherName, String otherUid, int timeMillisecond) =>
      chatProvider.fetchChatMessage(message, myName, myUid, otherName, otherUid, timeMillisecond);

  void fetchUnCheckedMessageCountZero(String myUid, String otherUid) => chatProvider.fetchUnCheckedMessageCountZero(myUid, otherUid);

  void fetchMessageToChatGPT(String myUid, String myName, String inputText, PublishSubject<String> chatGPTMessagePublisher) =>
      chatProvider.fetchMessageToChatGPT(myUid, myName, inputText, chatGPTMessagePublisher);

  Future<void> fetchChatMessageWithChatGPT(String message, String myName, String myUid, String otherName, String otherUid, int timeMillisecond, bool isSendToChatGTP) =>
      chatProvider.fetchChatMessageWithChatGPT(message, myName, myUid, otherName, otherUid, timeMillisecond, isSendToChatGTP);
}
