import 'dart:async';

import 'package:chat/data/model/ChatMessage.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';
import '../model/ChatListItem.dart';
import '../provider/ChatListProvider.dart';

class ChatListRepository {
  final ChatListProvider chatListProvider = Get.find<ChatListProvider>();

  void fetchUnCheckedMessageCount(String myUid, String otherUid) => chatListProvider.fetchUnCheckedMessageCount(myUid, otherUid);

  StreamSubscription observeAddedChatList(PublishSubject<Tuple2<String, ChatListItem>> addedChatListPublisher, String myUid) =>
      chatListProvider.observeAddedChatList(addedChatListPublisher, myUid);

  StreamSubscription observeChangedChild(PublishSubject<Tuple2<String, ChatListItem>> changedChatListPublisher, String myUid) =>
      chatListProvider.observeChangedChild(changedChatListPublisher, myUid);

  Future<List<ChatMessage>> getChatMessagesWithChatGPT(String myUid, String otherUid, String otherName) =>
      chatListProvider.getChatMessagesWithChatGPT(myUid, otherUid, otherName);
}
