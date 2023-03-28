import 'package:chat/data/bloc/ChatBloc.dart';
import 'package:chat/data/model/ChatMessage.dart';
import 'package:chat/utils/DateUtil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

import '../../../../../AppColors.dart';
import '../../component/ChatListContainer.dart';
import 'ChatMessageComponent.dart';
import 'DateNotification.dart';

class ChatContainer extends StatefulWidget {
  List<ChatMessage> chatMessages;
  ChatBloc chatBloc;

  ChatContainer({ super.key, required this.chatMessages, required this.chatBloc });

  @override
  State<StatefulWidget> createState() => _ChatContainerState(chatMessages: chatMessages, chatBloc: chatBloc);
}

class _ChatContainerState extends State<ChatContainer> {
  final scrollController = ScrollController();
  double scrollOffset = 0;
  int firstVisibleItemIndex = 0;
  List<ChatMessage> chatMessages;
  late ChatBloc chatBloc;
  var isRenderedChatMessages = false;

  _ChatContainerState({ required this.chatMessages, required this.chatBloc });

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_scrollListenerWithItemCount);

    var lastChatMessage = chatMessages[chatMessages.length - 1];
    chatBloc.observeAddedChatMessage(
        lastChatMessage.myUid,
        lastChatMessage.otherUid,
        lastChatMessage.myProfileUri,
        lastChatMessage.otherProfileUri,
        lastChatMessage.messageId);
  }

  @override
  void dispose() {
    chatBloc.dispose();
    scrollController.removeListener(_scrollListenerWithItemCount);
    super.dispose();
  }

  void _scrollListenerWithItemCount() {
    int itemCount = chatBloc.chatMessages.length;
    double scrollOffset = scrollController.position.pixels;
    double viewportHeight = scrollController.position.viewportDimension;
    double scrollRange = scrollController.position.maxScrollExtent -
        scrollController.position.minScrollExtent;
    int firstVisibleItemIndex =
        (scrollOffset / (scrollRange + viewportHeight) * itemCount).floor();

    if (!scrollController.position.outOfRange && isRenderedChatMessages) {
      if (this.firstVisibleItemIndex >= firstVisibleItemIndex &&
          this.scrollOffset > scrollOffset &&
          this.scrollOffset != 0) {
        chatBloc.showDateNotification(
            chatBloc.chatMessages[firstVisibleItemIndex].lastDate.toString());
      } else {
        chatBloc.showDateNotification('');
      }
      this.scrollOffset = scrollOffset;
      this.firstVisibleItemIndex = firstVisibleItemIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        color: AppColors.color_FFBFCDDF,
        child: Stack(
          children: [
            _chatMessages(chatBloc.chatMessageStream),
            Align(
              alignment: Alignment.topCenter,
              child: _dateNotification(chatBloc.dateNotificationStream),
            )
          ],
        ),
      ),
    ));
  }

  Widget _chatMessages(Stream<List<ChatMessage>> stream) {
    DateUtil dateUtils = Get.find<DateUtil>();
    return StreamBuilder(
      stream: stream,
      builder: (context, snapShot) {
        if (snapShot.hasData) {
          List<ChatMessage>? chatMessages = snapShot.data;
          if (chatMessages == null) {
            return _chatErrorScreen();
          } else if (chatMessages.isEmpty) {
            return Container();
          } else {
            SchedulerBinding.instance.addPostFrameCallback((_) {
              scrollController
                  .jumpTo(scrollController.position.maxScrollExtent);
              isRenderedChatMessages = true;
            });
            return ListView.builder(
                controller: scrollController,
                shrinkWrap: true,
                itemCount: chatMessages.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      if (index == 0) const SizedBox(height: 25),
                      // if (index > 0
                      //     && index < chatMessages.length
                      //     && !dateUtils.isSameDate(chatMessages[index - 1].lastDate, chatMessages[index].lastDate)
                      // )
                      //   Align(
                      //     alignment: Alignment.center,
                      //     child: Text(chatMessages[index].lastDate.toString()),
                      //   ),
                      ChatMessageComponent(chatMessage: chatMessages[index]),
                      const SizedBox(height: 20),
                    ],
                  );
                });
          }
        } else if (snapShot.hasError) {
          return _chatErrorScreen();
        } else {
          return _chatLoadingScreen();
        }
      },
    );
  }

  Widget _dateNotification(Stream<String> stream) {
    return StreamBuilder(
      stream: stream,
      builder: (context, snapShot) {
        if (snapShot.hasData && snapShot.data != null) {
          return DateNotification(message: snapShot.data!);
        } else {
          return DateNotification(message: '');
        }
      },
    );
  }

  Widget _chatErrorScreen() {
    return Container(
      alignment: Alignment.center,
      child: const Text(
        '에러 발생!!!',
        style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.color_FF0000FF),
      ),
    );
  }

  Widget _chatLoadingScreen() {
    return Expanded(
      child: Container(
        alignment: Alignment.center,
        child: const Text(
          '로딩중!!!',
          style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.color_FF000000),
        ),
      ),
    );
  }
}
