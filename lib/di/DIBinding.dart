import 'package:chat/utils/DateUtil.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/bloc/ChatListBloc.dart';
import '../data/provider/ChatListProvider.dart';
import '../data/provider/ChatProvider.dart';
import '../data/repository/ChatListRepository.dart';
import '../data/repository/ChatRepository.dart';

class DIBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DateUtil());
    Get.lazyPut(() => ChatListBloc());
    Get.lazyPut(() => ChatListRepository());
    Get.lazyPut(() => ChatRepository());

    // Firebase
    // Get.put(() => FirebaseAuth.instance.currentUser);
    // Get.put(() => FirebaseDatabase.instance.refFromURL('https://chat-module-3187e-default-rtdb.firebaseio.com/'));

    // Provider
    Get.lazyPut(() => ChatListProvider());
    Get.lazyPut(() => ChatProvider());

    // Network
    Get.lazyPut(() => Client());
  }
}
