import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/data/bloc/ChatListBloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';

import '../../../../AppColors.dart';
import '../../../../data/model/ChatMessage.dart';
import '../../../../main.dart';
import '../../../../utils/DateUtil.dart';
import 'ChatListProfileImage.dart';

class ChatListContainer extends StatefulWidget {
  const ChatListContainer({super.key});

  @override
  State<StatefulWidget> createState() => ChatListState();
}

class ChatListState extends State<ChatListContainer> with RouteAware {
  ChatListBloc chatListBloc = ChatListBloc();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      routeObserver.subscribe(this, ModalRoute.of(context)!);
    });
    chatListBloc.reqChatList();
  }

  @override
  void dispose() {
    chatListBloc.dispose();
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPushNext() {
    super.didPush();
  }

  @override
  void didPopNext() {
    super.didPopNext();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        child: StreamBuilder(
          stream: chatListBloc.chatListFetcher.stream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final chatLisMap = snapshot.data!;
              return ListView.builder(
                  itemCount: chatLisMap.length,
                  itemBuilder: (context, index) {
                    var key = chatLisMap.keys.elementAt(index);
                    List<ChatMessage>? chatMessages = chatLisMap[key];
                    return GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/ChatScreen', arguments: chatMessages),
                      child: chatMessages == null || chatMessages.isEmpty
                          ? Container()
                          : ChatListUnit(chatMessages[chatMessages.length - 1]),
                    );
                  });
            } else if (snapshot.hasError) {
              return const ChatListErrorScreen();
            } else {
              return const LoadingScreen();
            }
          },
        ),
      ),
    );
  }
}

class ChatListUnit extends StatelessWidget {
  DateUtil dateUtils = Get.find<DateUtil>();
  late ChatMessage chatMessage;

  ChatListUnit(this.chatMessage, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 75,
        color: Colors.transparent,
        alignment: Alignment.center,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(width: 50, height: 50, child: ChatListProfileImage(chatMessage: chatMessage)),
            const SizedBox(width: 20),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    chatMessage.otherName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.color_FF000000),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    chatMessage.message,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: AppColors.color_A3A3A8CD,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            )),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: Align(
                alignment: Alignment.topRight,
                child: Text(
                  dateUtils.getChatLastDate(chatMessage.lastDate),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: AppColors.color_A3A3A8CD),
                ),
              ),
            )
          ],
        ));
  }
}

class ChatListErrorScreen extends StatelessWidget {
  const ChatListErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: const Text(
        '에러 발생!!!',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.color_FF0000FF),
      ),
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        alignment: Alignment.center,
        child: const Text(
          '로딩중!!!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.color_FF000000),
        ),
      ),
    );
  }
}
