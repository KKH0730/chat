import 'dart:async';

import 'package:chat/data/model/ChatListItem.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';
import '../model/ChatMessage.dart';
import '../model/UserInfo.dart';

class ChatListProvider {
  final DatabaseReference databaseReference =
      FirebaseDatabase.instance.refFromURL('https://chat-module-3187e-default-rtdb.firebaseio.com/');
  Client client = Get.find<Client>();


  void fetchUnCheckedMessageCount(String myUid, String otherUid) {
    var databaseRef = databaseReference
        .child('chat_rooms')
        .child(myUid)
        .child('${myUid}_$otherUid');

    databaseRef.runTransaction((Object? transaction) {
      if (transaction == null) {
        return Transaction.abort();
      }

      Map<String, dynamic> chatMessagesMap = Map<String, dynamic>.from(transaction as Map);
      chatMessagesMap['unCheckedMessageCount'] = (chatMessagesMap['unCheckedMessageCount'] ?? 0) + 1;

      return Transaction.success(chatMessagesMap);
    });
  }

  StreamSubscription observeAddedChatList(PublishSubject<Tuple2<String, ChatListItem>> addedChatListPublisher, String myUid) {
    StreamSubscription subscription = databaseReference
        .child('chat_rooms')
        .child(myUid)
        .orderByChild('timestamp')
        .endBefore(DateTime.now().millisecondsSinceEpoch)
        .onChildAdded
        .listen((event) async {
          try {
            List<ChatMessage> chatMessages = [];
            int unCheckedMessage = 0;

            List<DataSnapshot> chatListSnapshotList = [];
            for (DataSnapshot element in event.snapshot.children.toList().reversed) {
              if (chatListSnapshotList.length >= 20) {
                break;
              }

              if (element.key == 'unCheckedMessageCount') {
                unCheckedMessage = element.value as int;
                continue;
              }

              chatListSnapshotList.add(element);
            }

            if (chatListSnapshotList.isEmpty) {
              return;
            }

            ChatMessage lastChatMessage = ChatMessage.fromJson(
                chatListSnapshotList.first.key!, Map.from(chatListSnapshotList.first.value as Map<dynamic, dynamic>));
            var userInfo = await reqGetUserInfo(lastChatMessage.otherUid);


            for (DataSnapshot chatListSnapshot in chatListSnapshotList) {
              var chatMap = chatListSnapshot.value as Map<dynamic, dynamic>;
              ChatMessage chatMessage = ChatMessage.fromJson(chatListSnapshot.key!, Map.from(chatMap));

              // 각 메세지에 유저 정보(프로필 이미지, 닉네임)를 넣어준다.
              chatMessage.otherName = userInfo.name;
              chatMessage.otherProfileUri = userInfo.profileUri;
              chatMessages.add(chatMessage);
            }
            if (!addedChatListPublisher.isPaused && !addedChatListPublisher.isClosed) {
              ChatListItem chatListItem = ChatListItem(unCheckedMessageCount: unCheckedMessage, chatMessages: chatMessages);
              addedChatListPublisher.sink.add(Tuple2<String, ChatListItem>(event.snapshot.key!, chatListItem));
            }
          } catch (e) {
            print(e);
          }
        });
    return subscription;
  }

  StreamSubscription observeChangedChild(PublishSubject<Tuple2<String, ChatListItem>> changedChatListPublisher, String myUid) {
    StreamSubscription subscription = databaseReference
        .child('chat_rooms')
        .child(myUid)
        .orderByChild('timestamp')
        .endBefore(DateTime.now().millisecondsSinceEpoch)
        .onChildChanged
        .listen((event) async {

      try {
            List<ChatMessage> chatMessages = [];
            int unCheckedMessage = 0;

            List<DataSnapshot> dataSnapshotList = event.snapshot.children.toList();
            if (dataSnapshotList.last.key == 'unCheckedMessageCount') {
              unCheckedMessage = dataSnapshotList.last.value as int;
              dataSnapshotList.removeAt(event.snapshot.children.length - 1);
            }

            List<DataSnapshot> chatListSnapshotList = [];
            if (dataSnapshotList.length <= 20) {
              chatListSnapshotList = dataSnapshotList.toList();
            } else {
              chatListSnapshotList = dataSnapshotList.toList().sublist(dataSnapshotList.length - 20, dataSnapshotList.length);
            }

            for (DataSnapshot chatListSnapshot in chatListSnapshotList) {
              var chatMap = chatListSnapshot.value as Map<dynamic, dynamic>;
              ChatMessage chatMessage = ChatMessage.fromJson(chatListSnapshot.key!, Map.from(chatMap));
              chatMessages.add(chatMessage);
            }
            if (!changedChatListPublisher.isPaused && !changedChatListPublisher.isClosed) {
              ChatListItem chatListItem = ChatListItem(unCheckedMessageCount: unCheckedMessage, chatMessages: chatMessages);
              changedChatListPublisher.sink.add(Tuple2<String, ChatListItem>(event.snapshot.key!, chatListItem));
            }
          } catch (e) {
            print(e);
          }
    });
    return subscription;
  }

  Future<UserInfo> reqGetUserInfo(String otherUid) async {
    try {
      final DatabaseEvent userInfoQueryEvent = await databaseReference.child('user_info').child(otherUid).once();
      if (userInfoQueryEvent.snapshot.value != null) {
        Map<dynamic, dynamic> userInfoMap = userInfoQueryEvent.snapshot.value as Map<dynamic, dynamic>;
        return UserInfo(uid: userInfoMap['uid'], name: userInfoMap['name'], profileUri: userInfoMap['profileUri']);
      } else {
        return UserInfo(uid: '', name: '', profileUri: '');
      }
    } catch (e) {
      return UserInfo(uid: '', name: '', profileUri: '');
    }
  }

  Future<List<ChatMessage>> getChatMessagesWithChatGPT(String myUid, String otherUid, String otherName) async {
    DatabaseEvent event = await databaseReference
        .child('chat_gpt_rooms')
        .child(myUid)
        .child('${myUid}_$otherUid')
        .orderByChild('timestamp')
        .endBefore(DateTime.now().millisecondsSinceEpoch)
        .once();

    try {
      List<ChatMessage> chatMessages = [];
      for (DataSnapshot element in event.snapshot.children.toList().reversed) {
        if (chatMessages.length >= 20) {
          break;
        }

        if (element.key == 'unCheckedMessageCount') {
          continue;
        }
        var chatMap = element.value as Map<dynamic, dynamic>;
        ChatMessage chatMessage = ChatMessage.fromJson(element.key!, Map.from(chatMap));
        chatMessages.add(chatMessage);
      }
      return chatMessages;
    } catch (e) {
      print('error : $e');
      return [];
    }
  }
}
