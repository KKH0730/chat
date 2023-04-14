import 'dart:async';

import 'package:chat/data/repository/ChatListRepository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat/data/model/userInfo.dart' as userInfo;

import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuple/tuple.dart';
import '../model/ChatListItem.dart';
import '../model/ChatMessage.dart';

class ChatListBloc {
  final Future<SharedPreferences> prefs = SharedPreferences.getInstance();
  final chatListRepository = Get.find<ChatListRepository>();

  BehaviorSubject<Map<String, ChatListItem>> chatListFetcher = BehaviorSubject();

  PublishSubject<Tuple2<String, ChatListItem>> addedChatListPublisher = PublishSubject();
  PublishSubject<Tuple2<String, ChatListItem>> changedChatListPublisher = PublishSubject();
  PublishSubject<List<ChatMessage>> chatMessagesWithChatGPTPublisher = PublishSubject();
  PublishSubject<int> checkMessageCountPublisher = PublishSubject();


  // onChangedChild 호출 시 UserInfo(상대방의 Name과 ProfieUri)를 다시 호출하지 않기 위해 저장
  final Map<String, userInfo.UserInfo> otherUserInfoData = {};
  List<StreamSubscription> chatListSubscriptionList = [];

  ChatListBloc() {
    addedChatListPublisher.listen((chatListTuple) {
      print('kkhdev listen');
      if (chatListTuple.item2.chatMessages.isEmpty || chatListTuple.item1.isEmpty) {
        chatListFetcher.sink.add({});
        return;
      }
      otherUserInfoData[chatListTuple.item1] =
          userInfo.UserInfo(
              uid:  chatListTuple.item2.chatMessages.first.otherUid,
              name: chatListTuple.item2.chatMessages.first.otherName,
              profileUri: chatListTuple.item2.chatMessages.first.otherProfileUri
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
            if (chatListTuple.item2.chatMessages.first.timestamp >= entries[i].value.chatMessages.first.timestamp) {
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
      print('kkhdev listen sink add');
      chatListFetcher.sink.add(Map.fromEntries(entries));
      fetchCheckMessageCount(chatListTuple.item1);
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
      // chatListMap[chatListTuple.item1] = chatListTuple.item2;

      var index = -1;
      List<MapEntry<String, ChatListItem>> entries = chatListMap.entries.toList();
      for (int i = 0; i < entries.length; i++) {
        if (entries[i].key == chatListTuple.item1) {
          index = i;
          break;
        }
      }

      if (index != -1) {
        List<ChatMessage> tempChatMessages = entries[index].value.chatMessages.toList();
        entries.removeAt(index);

        // ChatListItem chatListItem = ChatListItem(unCheckedMessageCount: chatListTuple.item2.unCheckedMessageCount, chatMessages: tempChatMessages);
        // entries.insert(0, MapEntry(chatListTuple.item1, chatListItem));
        entries.insert(0, MapEntry(chatListTuple.item1, chatListTuple.item2));

        chatListFetcher.sink.add(Map.fromEntries(entries));
        fetchCheckMessageCount(chatListTuple.item1);
      }
    });
  }

  void reqChatList() async {
    prefs.then((prefs) async {
      String uid = prefs.getString('myUid')!;
      chatListSubscriptionList.add(await chatListRepository.observeAddedChatList(addedChatListPublisher, uid));
      chatListSubscriptionList.add(chatListRepository.observeChangedChild(changedChatListPublisher, uid));
    });
  }

  void getChatMessagesWithChatGPT(String myUid, String otherUid, String otherName) async {
    List<ChatMessage> chatMessages = await chatListRepository.getChatMessagesWithChatGPT(myUid, otherUid, otherName);
    chatMessagesWithChatGPTPublisher.sink.add(chatMessages);
  }

  void fetchUnCheckedMessageCountZero(String key, String myUid, String otherUid) {
    Map<String, ChatListItem> chatListMap = chatListFetcher.hasValue ? chatListFetcher.value : {};
    chatListMap[key]?.unCheckedMessageCount = 0;

    chatListRepository.fetchUnCheckedMessageCountZero(myUid, otherUid);
  }

  void fetchCheckMessageCount(String key) {
    Map<String, ChatListItem> chatListMap = chatListFetcher.hasValue ? chatListFetcher.value : {};

    int totalUnCheckedMessageCount = 0;
    chatListMap.forEach((key, value) {
      totalUnCheckedMessageCount += value.unCheckedMessageCount;
    });
    checkMessageCountPublisher.sink.add(totalUnCheckedMessageCount);
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
