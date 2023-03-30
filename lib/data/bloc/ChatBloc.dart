import 'dart:async';

import 'package:chat/data/model/Result.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';
import '../../utils/DateUtil.dart';
import '../model/ChatMessage.dart';
import '../repository/ChatRepository.dart';

class ChatBloc {
  final User? user = FirebaseAuth.instance.currentUser;
  final chatRepository = Get.find<ChatRepository>();

  BehaviorSubject<List<ChatMessage>> chatMessagesFetcher = BehaviorSubject();
  PublishSubject<ChatMessage> addedChatMessagePublisher = PublishSubject();

  final dateNotificationController = StreamController<String>();
  Stream<String> get dateNotificationStream => dateNotificationController.stream;

  final messageController = StreamController<String>();
  Stream<String> get messageStream => dateNotificationController.stream;

  final recentMessageNotificationController = StreamController<ChatMessage?>();
  Stream<ChatMessage?> get recentMessageNotificationStream => recentMessageNotificationController.stream;

  final bottomPaddingController = StreamController<double>();
  Stream<double> get bottomPaddingStream => bottomPaddingController.stream;

  List<StreamSubscription> chatListSubscriptionList = [];

  bool isPagingNetworkConnected = false;
  bool isCalledWholeChatMessages = false;

  ChatBloc({ required chatMessages }) {
    chatMessagesFetcher.sink.add(chatMessages);

    addedChatMessagePublisher.listen((value) {
      List<ChatMessage> chatMessages = chatMessagesFetcher.hasValue && chatMessagesFetcher.value.isNotEmpty ? chatMessagesFetcher.value : [];
      chatMessages.add(value);
      chatMessagesFetcher.sink.add(chatMessages);
    });
  }

  void observeAddedChatMessage(
      String myUid,
      String otherUid,
      String myProfileUri,
      String otherProfileUri) {
    if (user != null) {
      chatListSubscriptionList.add(chatRepository.reqChatMessages(addedChatMessagePublisher, myUid, otherUid, myProfileUri, otherProfileUri));
    }
  }

  void reqPreviousMessage(String myUid, String otherUid, String myProfileUri, String otherProfileUri, int lastTimestamp, String msg) async {
    if (isPagingNetworkConnected || isCalledWholeChatMessages) {
      return;
    }
    isPagingNetworkConnected = true;
    var previousChatMessages = await chatRepository.reqPreviousMessage(myUid, otherUid, myProfileUri, otherProfileUri, lastTimestamp, msg);
    List<ChatMessage> slicedChatMessages = [];
    if (previousChatMessages.length <= 20) {
      slicedChatMessages = previousChatMessages.reversed.toList();
      isCalledWholeChatMessages = true;
    } else {
      slicedChatMessages = previousChatMessages.sublist(previousChatMessages.length - 20, previousChatMessages.length).reversed.toList();
    }


    List<ChatMessage> chatMessages = chatMessagesFetcher.hasValue && chatMessagesFetcher.value.isNotEmpty ? chatMessagesFetcher.value : [];
    chatMessages.addAll(slicedChatMessages);
    // chatMessages.insertAll(0, slicedChatMessages);
    chatMessagesFetcher.sink.add(chatMessages);

    isPagingNetworkConnected = false;
  }

  void fetchChatMessage(String message, String myName, String myUid, String otherName, String otherUid) async {
    Result<bool> result = await chatRepository.fetchChatMessage(message, myName, myUid, otherName, otherUid, DateTime.now().millisecondsSinceEpoch);
    if (result.success == null || result.success == false) {
      messageController.sink.add('에러 발생!!!');
    }
  }

  List<ChatMessage> getChatMessages() {
    return chatMessagesFetcher.hasValue && chatMessagesFetcher.value.isNotEmpty ? chatMessagesFetcher.value : [];
  }

  void showDateNotification(String timeMillisecond) {
    if (timeMillisecond.isEmpty) {
      dateNotificationController.sink.add('');
    } else {
      var time = int.tryParse(timeMillisecond) ?? DateTime.now().millisecond;
      dateNotificationController.sink.add(DateUtil.transMillisecondToDate2(time));
    }
  }

  void dispose() {
    addedChatMessagePublisher.close();
    dateNotificationController.close();
    messageController.close();
    for (var element in chatListSubscriptionList) { element.cancel(); }
  }
}
