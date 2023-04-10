import 'package:chat/data/model/ChatMessage.dart';
import 'package:chat/data/model/UserInfo.dart';
import 'package:chat/data/repository/FriendsRepository.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

class FriendsBloc {
  FriendsRepository friendsRepository = Get.find<FriendsRepository>();
  PublishSubject friendsUidListFetcher = PublishSubject<List<UserInfo>>();
  PublishSubject chatMessagesFetcher = PublishSubject<Tuple2<UserInfo, List<ChatMessage>>>();

  void getFriendsUserInfoList(String myUid) async {
    List<UserInfo> userInfoList = await friendsRepository.getFriendsUserInfoList(myUid);
    friendsUidListFetcher.sink.add(userInfoList);
  }

  void getChatMessages(String myUid, UserInfo otherUserInfo) async {
    List<ChatMessage> chatMessages = await friendsRepository.getChatMessages(myUid, otherUserInfo);
    chatMessagesFetcher.sink.add(Tuple2(otherUserInfo, chatMessages));
  }
}