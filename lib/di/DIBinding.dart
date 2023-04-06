import 'package:chat/data/bloc/FriendsBloc.dart';
import 'package:chat/data/provider/FriendsProvider.dart';
import 'package:chat/utils/DateUtil.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';

import '../data/bloc/ChatListBloc.dart';
import '../data/provider/ChatListProvider.dart';
import '../data/provider/ChatProvider.dart';
import '../data/repository/ChatListRepository.dart';
import '../data/repository/ChatRepository.dart';
import '../data/repository/FriendsRepository.dart';

class DIBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FriendsBloc());
    Get.lazyPut(() => ChatListBloc());
    Get.lazyPut(() => FriendsRepository());
    Get.lazyPut(() => ChatListRepository());
    Get.lazyPut(() => ChatRepository());

    // Firebase
    // Get.put(() => FirebaseAuth.instance.currentUser);
    // Get.put(() => FirebaseDatabase.instance.refFromURL('https://chat-module-3187e-default-rtdb.firebaseio.com/'));

    // Provider
    Get.lazyPut(() => FriendsProvider());
    Get.lazyPut(() => ChatListProvider());
    Get.lazyPut(() => ChatProvider());

    // Network
    Get.lazyPut(() => Client());
  }
}
