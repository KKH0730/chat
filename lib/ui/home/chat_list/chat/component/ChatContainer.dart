import 'dart:async';

import 'package:chat/AppColors.dart';
import 'package:chat/data/bloc/ChatBloc.dart';
import 'package:chat/data/model/ChatMessage.dart';
import 'package:chat/data/model/UserInfo.dart';
import 'package:chat/ui/common/CommonComponent.dart';
import 'package:chat/utils/DateUtil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ChatMessageComponent.dart';
import 'ChatProfileImage.dart';

class ChatContainer extends StatefulWidget {
  List<ChatMessage> chatMessages;
  UserInfo otherUserInfo;
  ChatBloc chatBloc;
  bool isChatWithChatGPT;

  ChatContainer({super.key, required this.chatMessages, required this.otherUserInfo, required this.chatBloc, required this.isChatWithChatGPT});

  @override
  State<StatefulWidget> createState() => _ChatContainerState(chatMessages: chatMessages, otherUserInfo: otherUserInfo, chatBloc: chatBloc, isChatWithChatGPT: isChatWithChatGPT);
}

class _ChatContainerState extends State<ChatContainer> {
  List<ChatMessage> chatMessages;
  UserInfo otherUserInfo;
  ChatBloc chatBloc;

  final scrollController = ScrollController();
  double scrollOffset = 0;
  int firstVisibleItemIndex = 0;

  bool isChatWithChatGPT;
  bool isRenderedChatMessages = false;
  GlobalKey listViewKey = GlobalKey();
  StreamController<double> scrollBarStreamController = StreamController();
  final Future<SharedPreferences> prefs = SharedPreferences.getInstance();

  _ChatContainerState({ required this.chatMessages, required this.otherUserInfo, required this.chatBloc, required this.isChatWithChatGPT });

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_scrollListener);

    prefs.then((prefs) =>
        chatBloc.observeAddedChatMessage(
            prefs.getString('myUid')!,
            otherUserInfo.uid,
            prefs.getString('myProfileUri')!,
            otherUserInfo.profileUri,
            chatMessages.isNotEmpty ? chatMessages.first.timestamp : DateTime.now().millisecondsSinceEpoch,
            isChatWithChatGPT
        )
    );


    chatBloc.addedChatMessagePublisher.listen((value) {
      // 새로운 메세지가 왔을 떄, ListView의 offest과 가장 하단의 offest의 차이가 메세지 2개정도 차이났을 때는 가장 하단으로 스크롤 해줌
      if (scrollController.offset - scrollController.position.minScrollExtent < 200 || value.isSender) {
        scrollController.animateTo(
            scrollController.position.minScrollExtent,
            duration: const Duration(milliseconds: 500),
            curve: Curves.ease
        );
      } else {
        // 새로운 메세지가 왔을 떄, ListView의 offest과 가장 하단의 offest의 차이가 메세지 2개보다 더 차이가 나면 메세지가 왔다고 채팅 입력창 위에 알림 표시해줌.
        if (!value.isSender) {
          chatBloc.recentMessageNotificationController.sink.add(value);
        }
      }
    });
  }

  @override
  void dispose() {
    chatBloc.dispose();
    if (chatMessages.isNotEmpty) {
      chatBloc.fetchUnCheckedMessageCountZero(chatMessages.first.myUid, chatMessages.first.otherUid);
    }
    scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  void _scrollListener() {
    int itemCount = chatBloc.getChatMessages().length;
    double scrollOffset = scrollController.position.pixels;
    double viewportHeight = scrollController.position.viewportDimension;
    double scrollRange = scrollController.position.maxScrollExtent - scrollController.position.minScrollExtent;
    int firstVisibleItemIndex = (scrollOffset / scrollRange * itemCount).floor();

    if (listViewKey.currentContext != null) {
      if (listViewKey.currentContext!.size != null) {
        double listViewHeight = listViewKey.currentContext!.size!.height;
        double scrollbarPosition = (scrollController.position.maxScrollExtent - scrollOffset) / (scrollRange + viewportHeight) * listViewHeight;
        scrollBarStreamController.sink.add(scrollbarPosition);
      }
    }

    if (!scrollController.position.outOfRange) {
      chatBloc.showDateNotification(chatBloc.getChatMessages()[firstVisibleItemIndex].timestamp.toString());

      this.scrollOffset = scrollOffset;
      this.firstVisibleItemIndex = firstVisibleItemIndex;
    }

    if (scrollController.offset.floor() == scrollController.position.maxScrollExtent.floor() && chatMessages.isNotEmpty) {
      var firstChatMessage = chatBloc.getChatMessages().last;

      chatBloc.reqPreviousMessage(firstChatMessage.myUid, firstChatMessage.otherUid, firstChatMessage.myProfileUri,
          firstChatMessage.otherProfileUri, firstChatMessage.timestamp, firstChatMessage.message);
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
              _chatMessages(chatBloc.chatMessagesFetcher.stream),
              _recentMessageNotificationWidget(chatBloc.recentMessageNotificationStream, () {
                chatBloc.recentMessageNotificationController.sink.add(null);
                scrollController.animateTo(
                    scrollController.position.minScrollExtent,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.ease
                );
              }),
              StreamBuilder(
                stream: scrollBarStreamController.stream,
                builder: (context, snapshot) {
                  return Positioned(
                    top: snapshot.hasData && snapshot.data != null? snapshot.data! : 0,
                    right: 0,
                    child: _dateNotificationWidget(chatBloc.dateNotificationStream),
                  );
                  },
              )
            ],
          ),
        ),
        )
    );
  }

  Widget _chatMessages(Stream<List<ChatMessage>> stream) {
    return StreamBuilder(
      stream: stream,
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingScreen();
        } else if (snapshot.hasError) {
          return const ErrorScreen();
        } else if (!snapshot.hasData || snapshot.data?.isEmpty == true) {
          return Container();
        } else {
          List<ChatMessage>? chatMessages = snapshot.data;
          if (chatMessages == null) {
            return const ErrorScreen();
          } else if (chatMessages.isEmpty) {
            return Container();
          } else {
            if (!isRenderedChatMessages) {
              SchedulerBinding.instance.addPostFrameCallback((_) {
                scrollController.jumpTo(scrollController.position.minScrollExtent);
                isRenderedChatMessages = true;
              });
            }
            return Scrollbar(
              controller: scrollController,
              interactive: true,
              thickness: 4,
              trackVisibility: true,
              radius: const Radius.circular(4),
              child: ListView.builder(
                  key: listViewKey,
                  controller: scrollController,
                  reverse: true,
                  shrinkWrap: true,
                  itemCount: chatMessages.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        if (index == chatMessages.length - 1 && !chatMessages[index].isLoading) const SizedBox(height: 10),
                        if (index == chatMessages.length - 1 && !chatMessages[index].isLoading) _dateTextWidget(chatMessages[index].timestamp),
                        if (index == chatMessages.length - 1 && !chatMessages[index].isLoading) const SizedBox(height: 20),
                        if (index > 0 &&
                            index < chatMessages.length - 1 &&
                            !DateUtil.isSameDate(chatMessages[index + 1].timestamp, chatMessages[index].timestamp))
                          _dateTextWidget(chatMessages[index].timestamp),
                        if (index > 0 &&
                            index < chatMessages.length - 1 &&
                            !DateUtil.isSameDate(chatMessages[index + 1].timestamp, chatMessages[index].timestamp))
                          const SizedBox(height: 20),

                        if (chatMessages[index].isLoading)
                          _chatLoadingWidget(),
                        if (!chatMessages[index].isLoading)
                          ChatMessageComponent(chatMessage: chatMessages[index], isChatWithChatGPT: isChatWithChatGPT),

                        const SizedBox(height: 20),
                      ],
                    );
                  }
              ),
            );
          }
        }
      },
    );
  }

  Widget _chatLoadingWidget() {
    return Column(
      children: const [
        SizedBox(height: 10),
        CupertinoActivityIndicator(
          animating: true,
          radius: 20.0,
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _dateTextWidget(int millisecond) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        margin: const EdgeInsets.only(top: 20, right: 10),
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 15),
        decoration: BoxDecoration(
          color: AppColors.color_59464545,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          DateUtil.transMillisecondToDate(millisecond),
          style: const TextStyle(color: Colors.white, fontSize: 10),
        ),
      ),
    );
  }

  Widget _dateNotificationWidget(Stream<String> stream) {
    return Align(
      alignment: Alignment.topRight,
      child: StreamBuilder(
        stream: stream,
        builder: (context, snapShot) {
          if (snapShot.hasData && snapShot.data != null) {
            return _dateNotification(snapShot.data!);
          } else {
            return _dateNotification('');
          }
        },
      ),
    );
  }

  Widget _dateNotification(String message) {
    return FutureBuilder(
      future: Future.delayed(const Duration(milliseconds: 600)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return message.isEmpty
              ? Container()
              : Container(
            margin: const EdgeInsets.only(top: 20, right: 10),
            padding:
            const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            decoration: BoxDecoration(
              color: AppColors.color_7B000000,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _recentMessageNotificationWidget(Stream<ChatMessage?> stream, Function onTap) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: StreamBuilder(
        stream: stream,
        builder: (context, snapShot) {
          if (snapShot.hasData && snapShot.data != null) {
            ChatMessage? chatMessage = snapShot.data;
            return chatMessage == null
                ? Container()
                : GestureDetector(
                    onTap: () {
                      onTap();
                    },
                    child: Container(
                      // color: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ChatProfileImage(chatMessage: chatMessage, width: 24, height: 24, isChatWithChatGPT: isChatWithChatGPT),
                          const SizedBox(width: 5),
                          Text(
                            chatMessage.otherName,
                            style: const TextStyle(fontSize: 10, color: AppColors.color_59464545),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              chatMessage.message,
                              style: const TextStyle(fontSize: 10, color: AppColors.color_FF000000),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(
                            CupertinoIcons.chevron_down,
                            size: 18,
                            color: AppColors.color_A3E5E5E8,
                          )
                        ],
                      ),
                    ),
                  );
          } else {
            return Container();
          }
        },
      ),
    );
  }
}
