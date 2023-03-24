import 'package:get/get.dart';
import '../model/ChatMessage.dart';
import '../provider/ChatListProvider.dart';

class ChatListRepository {
  final ChatListProvider chatListProvider = Get.find<ChatListProvider>();

  Future<List<List<ChatMessage>>> reqChatList(String myUid) =>
      chatListProvider.reqChatList(myUid);
}
