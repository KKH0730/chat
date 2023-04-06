import 'dart:async';

import 'package:chat/data/model/Result.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';
import '../../utils/DateUtil.dart';
import '../model/ChatMessage.dart';
import '../repository/ChatRepository.dart';

class ChatBloc {
  final User? user = FirebaseAuth.instance.currentUser;
  final ChatRepository chatRepository = ChatRepository();

  BehaviorSubject<List<ChatMessage>> chatMessagesFetcher = BehaviorSubject();
  PublishSubject<ChatMessage> addedChatMessagePublisher = PublishSubject();
  PublishSubject<bool> otherConnectionPublisher = PublishSubject();

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
  // 채팅 상대방이 앱을 종료했는지 안했는지 확인
  bool isConnectedOtherDevice = false;

  ChatBloc({ required List<ChatMessage> chatMessages }) {
    chatMessagesFetcher.sink.add(chatMessages);

    // if (chatMessages.isNotEmpty) {
    //   observeOtherConnectionState(chatMessages[0].myUid, chatMessages[0].otherUid);
    // }

    addedChatMessagePublisher.listen((value) {
      List<ChatMessage> chatMessages = chatMessagesFetcher.hasValue && chatMessagesFetcher.value.isNotEmpty ? chatMessagesFetcher.value : [];
      chatMessages.insert(0, value);
      chatMessagesFetcher.sink.add(chatMessages);
    });

    otherConnectionPublisher.listen((value) {isConnectedOtherDevice = value;});
  }

  // void observeOtherConnectionState(String myUid, String otherUid) {
  //   chatListSubscriptionList.add(chatRepository.observeOtherConnectionState(otherConnectionPublisher, myUid, otherUid));
  // }

  void observeAddedChatMessage(
      String myUid,
      String otherUid,
      String myProfileUri,
      String otherProfileUri,
      int lastTimeStamp
  ) {
    if (user != null) {
      chatListSubscriptionList.add(chatRepository.reqChatMessages(addedChatMessagePublisher, myUid, otherUid, myProfileUri, otherProfileUri, lastTimeStamp));
    }
  }

  void reqPreviousMessage(String myUid, String otherUid, String myProfileUri, String otherProfileUri, int lastTimestamp, String msg) async {
    print('kkhdev 33 isPagingNetworkConnected : $isPagingNetworkConnected, isCalledWholeChatMessages : $isCalledWholeChatMessages');
    if (isPagingNetworkConnected || isCalledWholeChatMessages) {
      return;
    }
    isPagingNetworkConnected = true;
    var previousChatMessages = await chatRepository.reqPreviousMessage(myUid, otherUid, myProfileUri, otherProfileUri, lastTimestamp, msg);
    if (previousChatMessages.isEmpty) {
      isCalledWholeChatMessages = true;
      return;
    }
    List<ChatMessage> chatMessages = chatMessagesFetcher.hasValue && chatMessagesFetcher.value.isNotEmpty ? chatMessagesFetcher.value : [];
    chatMessages.addAll(previousChatMessages.reversed.toList());
    chatMessagesFetcher.sink.add(chatMessages);

    isPagingNetworkConnected = false;
  }

  void fetchChatMessage(String message, String myName, String myUid, String otherName, String otherUid) async {
    Result<bool> result = await chatRepository.fetchChatMessage(message, myName, myUid, otherName, otherUid, DateTime.now().millisecondsSinceEpoch);
    if (result.success == null || result.success == false) {
      messageController.sink.add('에러 발생!!!');
    }
  }

  void fetchUnCheckedMessageCountZero(String myUid, String otherUid) {
    chatRepository.fetchUnCheckedMessageCountZero(myUid, otherUid);
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
