import 'dart:async';

import 'package:chat/ui/home/chat_list/chat_gpt/ChatGPTScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/DateUtil.dart';
import '../model/ChatMessage.dart';
import '../repository/ChatRepository.dart';

class ChatBloc {
  final User? user = FirebaseAuth.instance.currentUser;
  final ChatRepository chatRepository = ChatRepository();
  final Future<SharedPreferences> prefs = SharedPreferences.getInstance();

  BehaviorSubject<List<ChatMessage>> chatMessagesFetcher = BehaviorSubject();
  PublishSubject<ChatMessage> addedChatMessagePublisher = PublishSubject();
  PublishSubject<String> chatGPTMessagePublisher = PublishSubject();
  BehaviorSubject<bool> sendButtonControlSubject = BehaviorSubject.seeded(true);
  PublishSubject<bool> showLoadingPublisher = PublishSubject();

  final dateNotificationController = StreamController<String>();
  Stream<String> get dateNotificationStream => dateNotificationController.stream;

  final recentMessageNotificationController = StreamController<ChatMessage?>();
  Stream<ChatMessage?> get recentMessageNotificationStream => recentMessageNotificationController.stream;

  List<StreamSubscription> chatListSubscriptionList = [];

  bool isPagingNetworkConnected = false;
  bool isCalledWholeChatMessages = false;

  ChatBloc({ required List<ChatMessage> chatMessages }) {
    chatMessagesFetcher.sink.add(chatMessages);

    addedChatMessagePublisher.listen((value) {
      List<ChatMessage> chatMessages = chatMessagesFetcher.hasValue && chatMessagesFetcher.value.isNotEmpty ? chatMessagesFetcher.value : [];
      chatMessages.insert(0, value);
      chatMessagesFetcher.sink.add(chatMessages);
    });

    chatGPTMessagePublisher.listen((content) {
      prefs.then((prefs) async {
        showLoadingWidget(false);
        await chatRepository.fetchChatMessageWithChatGPT(
            content,
            prefs.getString('myName') ?? '',
            prefs.getString('myUid') ?? '',
            ChatGPTScreen.CHAT_GPT_NAME,
            ChatGPTScreen.CHAT_GPT_UID,
            DateTime.now().millisecondsSinceEpoch,
            false
        );
        enableChatSendButton(true);
      });
    });

    showLoadingPublisher.listen((isShow) {
      List<ChatMessage> chatMessages = chatMessagesFetcher.hasValue && chatMessagesFetcher.value.isNotEmpty ? chatMessagesFetcher.value : [];
      if (isShow) {
        ChatMessage loadingDummy = ChatMessage(
            messageId: '',
            timestamp: 0,
            message: '',
            myName: '',
            otherName: '',
            myUid: '',
            otherUid: '',
            isSender: true
        );
        loadingDummy.isLoading = true;
        chatMessages.insert(0, loadingDummy);
      } else {
        if (chatMessages.isNotEmpty && chatMessages.first.isLoading) {
          chatMessages.removeAt(0);
        }
      }
      chatMessagesFetcher.sink.add(chatMessages);
    });
  }

  void observeAddedChatMessage(
      String myUid,
      String otherUid,
      String myProfileUri,
      String otherProfileUri,
      int lastTimeStamp,
      bool isChatWithChatGPT
  ) {
    if (user != null) {
      chatListSubscriptionList.add(chatRepository.reqChatMessages(addedChatMessagePublisher, myUid, otherUid, myProfileUri, otherProfileUri, lastTimeStamp, isChatWithChatGPT));
    }
  }

  void reqPreviousMessage(String myUid, String otherUid, String myProfileUri, String otherProfileUri, int lastTimestamp, String msg) async {
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

  void fetchChatMessage(String message, String myName, String myUid, String otherName, String otherUid) {
    chatRepository.fetchChatMessage(message, myName, myUid, otherName, otherUid, DateTime.now().millisecondsSinceEpoch);
  }

  void fetchUnCheckedMessageCountZero(String myUid, String otherUid) {
    chatRepository.fetchUnCheckedMessageCountZero(myUid, otherUid);
  }

  void fetchMessageToChatGPT(String myUid, String myName, String inputText) async {
    enableChatSendButton(false);
    await chatRepository.fetchChatMessageWithChatGPT(inputText, myName, myUid, ChatGPTScreen.CHAT_GPT_NAME, ChatGPTScreen.CHAT_GPT_UID, DateTime.now().millisecondsSinceEpoch, true);

    showLoadingWidget(true);
    chatRepository.fetchMessageToChatGPT(myUid, myName, inputText, chatGPTMessagePublisher);
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

  void enableChatSendButton(bool isEnable) {
    sendButtonControlSubject.sink.add(isEnable);
  }

  void showLoadingWidget(bool isShow) {
    showLoadingPublisher.sink.add(isShow);
  }

  void dispose() {
    chatMessagesFetcher.close();
    addedChatMessagePublisher.close();
    chatGPTMessagePublisher.close();
    sendButtonControlSubject.close();
    showLoadingPublisher.close();

    dateNotificationController.close();
    recentMessageNotificationController.close();

    for (var element in chatListSubscriptionList) { element.cancel(); }
  }
}
