import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/AppColors.dart';
import 'package:chat/data/bloc/ChatListBloc.dart';
import 'package:chat/data/model/ChatListItem.dart';
import 'package:chat/data/model/ChatMessage.dart';
import 'package:chat/data/model/UserInfo.dart';
import 'package:chat/main.dart';
import 'package:chat/ui/common/CommonComponent.dart';
import 'package:chat/utils/DateUtil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class ChatListContainer extends StatefulWidget {
  ChatListBloc chatListBloc;

  ChatListContainer({super.key, required this.chatListBloc });


  @override
  State<StatefulWidget> createState() => _ChatListState(chatListBloc: chatListBloc);
}

class _ChatListState extends State<ChatListContainer> with RouteAware {
  ChatListBloc chatListBloc;

  _ChatListState({ required this.chatListBloc });

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
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPushNext() {
    super.didPush();

    // 채팅방 입장
    chatListBloc.pauseSubscription();
  }

  @override
  void didPopNext() {
    super.didPopNext();

    // 채팅방 -> 채팅 리스트 화면으로 돌아옴
    chatListBloc.resumeSubscription();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        child: StreamBuilder(
          stream: chatListBloc.chatListFetcher.stream,
          builder: (context, snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingScreen();
            } else if (snapshot.hasError) {
              return const ErrorScreen();
            } else if (!snapshot.hasData || snapshot.data?.isEmpty == true) {
              return const NoDataScreen();
            } else {
              final chatLisMap = snapshot.data!;
              return ListView.builder(
                  itemCount: chatLisMap.length,
                  itemBuilder: (context, index) {
                    var key = chatLisMap.keys.elementAt(index);
                    ChatListItem? chatListItem = chatLisMap[key];
                    return chatListItem == null || chatListItem.chatMessages.isEmpty
                        ? Container()
                        : GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                              context,
                              '/ChatScreen',
                              arguments: {
                                'otherUserInfo': UserInfo(uid: chatListItem.chatMessages.first.otherUid, name: chatListItem.chatMessages.first.otherName, profileUri: chatListItem.chatMessages.first.otherProfileUri),
                                'chatMessages': chatListItem.chatMessages
                              }
                          );
                        },
                        child: _chatListUnit(chatListItem)
                    );
                  });
            }
          },
        ),
      ),
    );
  }

  Widget _chatListUnit(ChatListItem chatListItem) {
    ChatMessage chatMessage = chatListItem.chatMessages[0];
    return Container(
        height: 75,
        color: Colors.transparent,
        alignment: Alignment.center,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(width: 50, height: 50, child: _chatListProfileImage(chatMessage)),
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
                            color: AppColors.color_C2A0A0A1,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ]
                  ),
                )
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  DateUtil.getChatLastDate(chatMessage.timestamp),
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.normal, color: AppColors.color_C2A0A0A1),
                ),
                const SizedBox(height: 5),
                if (chatListItem.unCheckedMessageCount > 0)
                  Container(
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text(
                          chatListItem.unCheckedMessageCount > 99 ? "99+" : chatListItem.unCheckedMessageCount.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 8, fontWeight: FontWeight.normal, color: AppColors.color_FFFFFFFF),
                        ),
                      )
                  ),
                if (chatListItem.unCheckedMessageCount <= 0)
                  const SizedBox(
                    width: 20,
                    height: 20,
                  )
              ],
            )
          ],
        )
    );
  }

  Widget _chatListProfileImage(ChatMessage chatMessage) {
    return CircleAvatar(
      backgroundColor: Colors.transparent,
      backgroundImage: chatMessage.otherProfileUri.isNotEmpty
          ? CachedNetworkImageProvider(
        chatMessage.otherProfileUri,
        cacheManager: DefaultCacheManager(),
      )
          : Image.asset('assets/images/ic_user_default.png').image,
    );
  }
}