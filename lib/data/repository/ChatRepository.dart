import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:rxdart/rxdart.dart';

import '../model/ChatMessage.dart';
import '../model/Result.dart';
import '../provider/ChatProvider.dart';

class ChatRepository {
  final ChatProvider chatProvider = Get.find<ChatProvider>();

  Stream<DatabaseEvent> reqChatMessages(
          String myUid,
          String otherUid,
          String myProfileUri,
          String otherProfileUri,
          String lastMessageKey) =>
      chatProvider.reqChatMessages(
          myUid, otherUid, myProfileUri, otherProfileUri, lastMessageKey);

  Future<Result<bool>> fetchChatMessage(String message, String myName,
      String myUid, String otherName, String otherUid, int timeMillisecond) {
    return chatProvider.fetchChatMessage(
        message, myName, myUid, otherName, otherUid, timeMillisecond);
  }
}
