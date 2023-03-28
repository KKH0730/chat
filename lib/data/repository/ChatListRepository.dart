import 'dart:async';

import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';
import '../model/ChatMessage.dart';
import '../provider/ChatListProvider.dart';

class ChatListRepository {
  final ChatListProvider chatListProvider = Get.find<ChatListProvider>();

  StreamSubscription observeAddedChatList(PublishSubject<Tuple2<String, List<ChatMessage>>> addedChatListPublisher, String myUid) =>
      chatListProvider.observeAddedChatList(addedChatListPublisher, myUid);

  StreamSubscription observeChangedChild(PublishSubject<Tuple2<String, List<ChatMessage>>> changedChatListPublisher, String myUid) =>
      chatListProvider.observeChangedChild(changedChatListPublisher, myUid);
}
