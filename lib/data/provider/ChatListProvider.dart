import 'dart:async';
import 'dart:collection';

import 'package:chat/data/bloc/ChatListBloc.dart';
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

  StreamSubscription observeAddedChatList(PublishSubject<Tuple2<String, List<ChatMessage>>> addedChatListPublisher, String myUid) {
    StreamSubscription subscription = databaseReference
        .child('chat_rooms')
        .child(myUid)
        .orderByChild('timestamp')
        .endBefore(DateTime.now().millisecondsSinceEpoch)
        .onChildAdded
        .listen((event) async {
          try {
            List<ChatMessage> chatMessages = [];
            ChatMessage lastChatMessage = ChatMessage.fromJson(
                event.snapshot.children.last.key!, Map.from(event.snapshot.children.last.value as Map<dynamic, dynamic>));
            var userInfo = await reqGetUserInfo(lastChatMessage.otherUid);

            List<DataSnapshot> chatListSnapshotList = [];
            if (event.snapshot.children.length <= 20) {
              chatListSnapshotList = event.snapshot.children.toList().reversed.toList();
            } else {
              chatListSnapshotList = event.snapshot.children.toList().sublist(event.snapshot.children.length - 20, event.snapshot.children.length).reversed.toList();
            }

            for (DataSnapshot chatListSnapshot in chatListSnapshotList) {
              var chatMap = chatListSnapshot.value as Map<dynamic, dynamic>;
              ChatMessage chatMessage = ChatMessage.fromJson(chatListSnapshot.key!, Map.from(chatMap));

              // 각 메세지에 유저 정보(프로필 이미지, 닉네임)를 넣어준다.
              chatMessage.otherName = userInfo.name;
              chatMessage.otherProfileUri = userInfo.profileUri;
              chatMessages.add(chatMessage);
            }
            if (!addedChatListPublisher.isPaused && !addedChatListPublisher.isClosed) {
              addedChatListPublisher.sink.add(Tuple2<String, List<ChatMessage>>(event.snapshot.key!, chatMessages));
            }
          } catch (e) {
            print(e);
          }
        });
    return subscription;
  }

  StreamSubscription observeChangedChild(PublishSubject<Tuple2<String, List<ChatMessage>>> changedChatListPublisher, String myUid) {
    StreamSubscription subscription = databaseReference
        .child('chat_rooms')
        .child(myUid)
        .onChildChanged
        .listen((event) async {
          try {
            List<ChatMessage> chatMessages = [];
            for (DataSnapshot chatListSnapshot in event.snapshot.children) {
              var chatMap = chatListSnapshot.value as Map<dynamic, dynamic>;
              ChatMessage chatMessage = ChatMessage.fromJson(chatListSnapshot.key!, Map.from(chatMap));
              chatMessages.add(chatMessage);
            }
            if (!changedChatListPublisher.isPaused && !changedChatListPublisher.isClosed) {
              changedChatListPublisher.sink.add(Tuple2<String, List<ChatMessage>>(event.snapshot.key!, chatMessages));
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
        return UserInfo(name: userInfoMap['name'], profileUri: userInfoMap['profileUri']);
      } else {
        return UserInfo(name: '', profileUri: '');
      }
    } catch (e) {
      return UserInfo(name: '', profileUri: '');
    }
  }
}
