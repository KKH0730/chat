import 'dart:async';

import 'package:chat/data/repository/ChatListRepository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat/data/model/userInfo.dart' as userInfo;

import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';
import '../model/ChatListItem.dart';
import '../model/ChatMessage.dart';

class ChatListBloc {
  final User? user = FirebaseAuth.instance.currentUser;
  final chatListRepository = Get.find<ChatListRepository>();

  BehaviorSubject<Map<String, ChatListItem>> chatListFetcher = BehaviorSubject();

  PublishSubject<Tuple2<String, ChatListItem>> addedChatListPublisher = PublishSubject();
  PublishSubject<Tuple2<String, ChatListItem>> changedChatListPublisher = PublishSubject();
  List<StreamSubscription> chatListSubscriptionList = [];

  // onChangedChild 호출 시 UserInfo(상대방의 Name과 ProfieUri)를 다시 호출하지 않기 위해 저장
  final Map<String, userInfo.UserInfo> otherUserInfoData = {};

  ChatListBloc() {
    addedChatListPublisher.listen((chatListTuple) {
      if (chatListTuple.item2.chatMessages.isEmpty) {
        return;
      }
      otherUserInfoData[chatListTuple.item1] =
          userInfo.UserInfo(
              uid:  chatListTuple.item2.chatMessages.last.otherUid,
              name: chatListTuple.item2.chatMessages.last.otherName,
              profileUri: chatListTuple.item2.chatMessages.last.otherProfileUri
          );
      Map<String, ChatListItem> chatListMap = chatListFetcher.hasValue ? chatListFetcher.value : {};

      List<MapEntry<String, ChatListItem>> entries = chatListMap.entries.toList();
      if (entries.isEmpty) {
        entries.add(MapEntry(chatListTuple.item1, chatListTuple.item2));
      } else {
        for (int i = 0; i < entries.length; i++) {
          if (entries[i].value.chatMessages.isEmpty) {
            entries.add(MapEntry(chatListTuple.item1, chatListTuple.item2));
            break;
          } else {
            if (chatListTuple.item2.chatMessages[chatListTuple.item2.chatMessages.length - 1].timestamp >=
                entries[i].value.chatMessages[entries[i].value.chatMessages.length - 1].timestamp) {
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
      if (chatListTuple.item2.chatMessages.isEmpty) {
        return;
      }

      for (var element in chatListTuple.item2.chatMessages) {
        element.otherName = otherUserInfoData[chatListTuple.item1]?.name ?? '';
        element.otherProfileUri = otherUserInfoData[chatListTuple.item1]?.profileUri ?? '';
      }

      Map<String, ChatListItem> chatListMap = chatListFetcher.hasValue ? chatListFetcher.value : {};
      chatListMap[chatListTuple.item1] = chatListTuple.item2;

      var index = -1;
      List<MapEntry<String, ChatListItem>> entries = chatListMap.entries.toList();
      for (int i = 0; i < entries.length; i++) {
        if (entries[i].key == chatListTuple.item1) {
          index = i;
          break;
        }
      }

      if (index != -1) {
        List<ChatMessage> tempChatMessages = entries[index].value.chatMessages.reversed.toList();
        entries.removeAt(index);

        ChatListItem chatListItem = ChatListItem(unCheckedMessageCount: chatListTuple.item2.unCheckedMessageCount, chatMessages: tempChatMessages);
        entries.insert(0, MapEntry(chatListTuple.item1, chatListItem));
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

  void pauseSubscription() {
    for (var element in chatListSubscriptionList) {
      element.pause();
    }
  }

  void resumeSubscription() {
    for (var element in chatListSubscriptionList) {
      element.resume();
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
