import 'package:chat/data/model/ChatMessage.dart';
import 'package:chat/data/model/UserInfo.dart';
import 'package:chat/data/provider/FriendsProvider.dart';
import 'package:get/get.dart';

class FriendsRepository {
  FriendsProvider friendsProvider = Get.find<FriendsProvider>();


  Future<List<UserInfo>> getFriendsUserInfoList(String myUid) => friendsProvider.getFriendsUserInfoList(myUid);

  Future<List<ChatMessage>> getChatMessages(String myUid, UserInfo otherUserInfo) => friendsProvider.getChatMessages(myUid, otherUserInfo);
}