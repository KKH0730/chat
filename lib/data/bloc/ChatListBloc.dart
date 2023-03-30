import 'dart:async';

import 'package:chat/data/repository/ChatListRepository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat/data/model/userInfo.dart' as data;

import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';
import '../model/ChatMessage.dart';

class ChatListBloc {
  final User? user = FirebaseAuth.instance.currentUser;
  final chatListRepository = Get.find<ChatListRepository>();

  late BehaviorSubject<Map<String, List<ChatMessage>>> chatListFetcher;

  late PublishSubject<Tuple2<String, List<ChatMessage>>> addedChatListPublisher;
  late PublishSubject<Tuple2<String, List<ChatMessage>>> changedChatListPublisher;
  late List<StreamSubscription> chatListSubscriptionList;

  // onChangedChild 호출 시 UserInfo(상대방의 Name과 ProfieUri)를 다시 호출하지 않기 위해 저장
  final Map<String, data.UserInfo> otherUserInfoData = {};

  ChatListBloc() {
    chatListFetcher = BehaviorSubject();
    addedChatListPublisher = PublishSubject();
    changedChatListPublisher = PublishSubject();
    chatListSubscriptionList = [];

    addedChatListPublisher.listen((chatListTuple) {
      if (chatListTuple.item2.isEmpty) {
        return;
      }
      otherUserInfoData[chatListTuple.item1] =
          data.UserInfo(name: chatListTuple.item2.last.otherName, profileUri: chatListTuple.item2.last.otherProfileUri);
      Map<String, List<ChatMessage>> chatListMap = chatListFetcher.hasValue ? chatListFetcher.value : {};

      List<MapEntry<String, List<ChatMessage>>> entries = chatListMap.entries.toList();
      if (entries.isEmpty) {
        entries.add(MapEntry(chatListTuple.item1, chatListTuple.item2));
      } else {
        for (int i = 0; i < entries.length; i++) {
          if (entries[i].value.isEmpty) {
            entries.add(MapEntry(chatListTuple.item1, chatListTuple.item2));
            break;
          } else {
            if (chatListTuple.item2[chatListTuple.item2.length - 1].timestamp >=
                entries[i].value[entries[i].value.length - 1].timestamp) {
              entries.insert(i, MapEntry(chatListTuple.item1, chatListTuple.item2));
              break;
            } else {
              if (i == entries.length - 1) {
                entries.add(MapEntry(chatListTuple.item1, chatListTuple.item2));
              } else {
                continue;
              }
            }
          }
        }
      }

      chatListFetcher.sink.add(Map.fromEntries(entries));
    });

    changedChatListPublisher.listen((chatListTuple) {
      if (chatListTuple.item2.isEmpty) {
        return;
      }

      for (var element in chatListTuple.item2) {
        element.otherName = otherUserInfoData[chatListTuple.item1]?.name ?? '';
        element.otherProfileUri = otherUserInfoData[chatListTuple.item1]?.profileUri ?? '';
      }

      Map<String, List<ChatMessage>> chatListMap = chatListFetcher.hasValue ? chatListFetcher.value : {};
      chatListMap[chatListTuple.item1] = chatListTuple.item2;

      var index = -1;
      List<MapEntry<String, List<ChatMessage>>> entries = chatListMap.entries.toList();
      for (int i = 0; i < entries.length; i++) {
        if (entries[i].key == chatListTuple.item1) {
          index = i;
          break;
        }
      }

      if (index != -1) {
        List<ChatMessage> tempChatMessages = entries[index].value;
        entries.removeAt(index);
        entries.insert(0, MapEntry(chatListTuple.item1, tempChatMessages));
        chatListFetcher.sink.add(Map.fromEntries(entries));
      }
    });
  }

  void reqChatList() {
    if (user != null) {
      chatListSubscriptionList.add(chatListRepository.observeAddedChatList(addedChatListPublisher, user!.uid));
      chatListSubscriptionList.add(chatListRepository.observeChangedChild(changedChatListPublisher, user!.uid));
    }
  }

  void dispose() {
    chatListFetcher.close();
    addedChatListPublisher.close();
    changedChatListPublisher.close();
    for (var element in chatListSubscriptionList) {
      element.cancel();
    }
  }
}
