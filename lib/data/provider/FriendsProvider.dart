import 'package:chat/data/model/ChatMessage.dart';
import 'package:chat/data/model/UserInfo.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:tuple/tuple.dart';

class FriendsProvider {
  final DatabaseReference databaseReference = FirebaseDatabase.instance.refFromURL('https://chat-module-3187e-default-rtdb.firebaseio.com/');

  Future<List<UserInfo>> getFriendsUserInfoList(String myUid) async {
    DatabaseEvent event = await databaseReference
        .child('user_info')
        .child(myUid)
        .child('friends')
        .once();

    List<UserInfo> friendsUserInfoList = [];
    for (var element in event.snapshot.children) {
      String otherUid = Map.from(element.value as Map<dynamic, dynamic>)['uid'];
      UserInfo otherUserInfo = await reqGetUserInfo(otherUid);
      friendsUserInfoList.add(otherUserInfo);
    }

    return friendsUserInfoList;
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

  Future<List<ChatMessage>> getChatMessages(String myUid, UserInfo otherUserInfo) async {
    DatabaseEvent event = await databaseReference
        .child('chat_rooms')
        .child(myUid)
        .child('${myUid}_${otherUserInfo.uid}')
        .orderByChild('timestamp')
        .endBefore(DateTime.now().millisecondsSinceEpoch)
        .once();

    List<ChatMessage> chatMessages = [];
    for (DataSnapshot chatListSnapshot in event.snapshot.children) {
      if (chatMessages.length >= 20) {
        break;
      }

      if (chatListSnapshot.key == 'unCheckedMessageCount') {
        continue;
      }

      var chatMap = chatListSnapshot.value as Map<dynamic, dynamic>;
      ChatMessage chatMessage = ChatMessage.fromJson(chatListSnapshot.key!, Map.from(chatMap));

      // 각 메세지에 유저 정보(프로필 이미지, 닉네임)를 넣어준다.
      chatMessage.otherName = otherUserInfo.name;
      chatMessage.otherProfileUri = otherUserInfo.profileUri;
      chatMessages.add(chatMessage);
    }
    return chatMessages;
  }
}