import 'dart:async';
import 'dart:ffi';

import 'package:chat/data/model/Result.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';

import '../../utils/DateUtil.dart';
import '../model/ChatMessage.dart';
import '../repository/ChatRepository.dart';

class ChatBloc {
  DateUtil dateUtils = Get.find<DateUtil>();
  final User? user = FirebaseAuth.instance.currentUser;
  final chatRepository = Get.find<ChatRepository>();

  final StreamController<List<ChatMessage>> chatMessagesController = StreamController();
  Stream<List<ChatMessage>> get chatMessageStream =>
      chatMessagesController.stream;

  final dateNotificationController = StreamController<String>();
  Stream<String> get dateNotificationStream =>
      dateNotificationController.stream;

  final messageController = StreamController<String>();
  Stream<String> get messageStream => dateNotificationController.stream;

  List<ChatMessage> chatMessages = [];
  StreamSubscription? subscription;

  ChatBloc({ required this.chatMessages }) {
    chatMessagesController.sink.add(chatMessages);
  }

  void observeAddedChatMessage(
      String myUid,
      String otherUid,
      String myProfileUri,
      String otherProfileUri,
      String lastMessageKey) {
    if (user != null) {
      subscription = chatRepository.reqChatMessages(myUid, otherUid, myProfileUri, otherProfileUri, lastMessageKey).listen((event) {
        if (event.snapshot.value != null) {
          ChatMessage chatMessage = ChatMessage.fromJson(event.snapshot.key!, Map.from(event.snapshot.value as Map<dynamic, dynamic>));

          chatMessage.myProfileUri = myProfileUri;
          chatMessage.otherProfileUri = otherProfileUri;

          chatMessages.add(chatMessage);
          chatMessagesController.sink.add(chatMessages);
        }
      });
    }
  }

  void fetchChatMessage(String message, String myName, String myUid, String otherName, String otherUid) async {
    Result<bool> result = await chatRepository.fetchChatMessage(message, myName,
        myUid, otherName, otherUid, DateTime.now().millisecondsSinceEpoch);
    if (result.success == null || result.success == false) {
      messageController.sink.add('에러 발생!!!');
    }
  }

  void showDateNotification(String timeMillisecond) {
    if (timeMillisecond.isEmpty) {
      dateNotificationController.sink.add('');
    } else {
      var time = int.tryParse(timeMillisecond) ?? DateTime.now().millisecond;
      dateNotificationController.sink.add(dateUtils.getChatLastDate(time));
    }
  }

  void dispose() {
    print('kkhdev dispose');
    subscription?.cancel();
    chatMessagesController.close();
    dateNotificationController.close();
    messageController.close();
  }
}
