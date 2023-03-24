import 'dart:async';

import 'package:chat/data/repository/ChatListRepository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../model/ChatMessage.dart';

class ChatListBloc {
  final User? user = FirebaseAuth.instance.currentUser;
  final chatListRepository = Get.find<ChatListRepository>();
  final chatListController = StreamController<List<List<ChatMessage>>>();
  Stream<List<List<ChatMessage>>> get chatListStream =>
      chatListController.stream;

  void reqChatList() async {
    if (user != null) {
      final List<List<ChatMessage>> chatList =
          await chatListRepository.reqChatList(user!.uid);
      chatListController.sink.add(chatList);
    }
  }

  void dispose() {
    chatListController.close();
  }
}
