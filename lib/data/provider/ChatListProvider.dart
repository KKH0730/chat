import 'package:chat/data/model/ChatMessage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import '../model/UserInfo.dart';

class ChatListProvider {
  final DatabaseReference databaseReference = FirebaseDatabase.instance
      .refFromURL('https://chat-module-3187e-default-rtdb.firebaseio.com/');
  Client client = Get.find<Client>();

  Future<List<List<ChatMessage>>> reqChatList(String myUid) async {
    try {
      List<List<ChatMessage>> wholeChatList = [];
      final DatabaseEvent chatRoomsQueryEvent =
          await databaseReference
              .child('chat_rooms')
              .child(myUid)
              .orderByKey()
              .once();

      if (chatRoomsQueryEvent.snapshot.value != null) {
        Map<dynamic, dynamic> chatListMap =
            chatRoomsQueryEvent.snapshot.value as Map<dynamic, dynamic>;

        for (var chatListEntry in chatListMap.entries) {
          List<ChatMessage> chatList = [];
          Map<dynamic, dynamic> chatListMap = Map.from(chatListEntry.value);
          ChatMessage lastChatMessage = ChatMessage.fromJson(
              chatListMap.entries.last.key,
              Map.from(chatListMap.entries.last.value));
          // 마지막 메세지에서 상대의 UID를 가져온다.
          UserInfo userInfo = await reqGetUserInfo(lastChatMessage.otherUid);

          for (var chatEntry in chatListEntry.value.entries) {
            ChatMessage chatMessage =
                ChatMessage.fromJson(chatEntry.key, Map.from(chatEntry.value));

            // 각 메세지에 유저 정보(프로필 이미지, 닉네임)를 넣어준다.
            chatMessage.otherName = userInfo.name;
            chatMessage.otherProfileUri = userInfo.profileUri;

            chatList.add(chatMessage);
          }
          if (chatList.isNotEmpty) {
            wholeChatList.add(chatList);
          }
        }
      }
      return wholeChatList;
    } catch (e) {
      print('Error occurred while fetching chat list: $e');
      return [];
    }
  }

  Future<UserInfo> reqGetUserInfo(String otherUid) async {
    try {
      final DatabaseEvent userInfoQueryEvent =
          await databaseReference.child('user_info').child(otherUid).once();
      if (userInfoQueryEvent.snapshot.value != null) {
        Map<dynamic, dynamic> userInfoMap =
            userInfoQueryEvent.snapshot.value as Map<dynamic, dynamic>;
        return UserInfo(
            name: userInfoMap['name'], profileUri: userInfoMap['profileUri']);
      } else {
        return UserInfo(name: '', profileUri: '');
      }
    } catch (e) {
      return UserInfo(name: '', profileUri: '');
    }
  }
}
