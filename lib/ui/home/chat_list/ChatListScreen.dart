import 'package:chat/data/bloc/ChatListBloc.dart';
import 'package:chat/data/model/ChatMessage.dart';
import 'package:chat/data/model/UserInfo.dart';
import 'package:chat/ui/home/chat_list/chat_gpt/ChatGPTScreen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../AppColors.dart';
import 'component/ChatListContainer.dart';

class ChatListScreen extends StatefulWidget {
  static bool isJoinChattingRoom = false;
  ChatListBloc chatListBloc = ChatListBloc();

  ChatListScreen({super.key});

  @override
  State<StatefulWidget> createState() => _ChatListScreen(chatListBloc: chatListBloc);
}

class _ChatListScreen extends State<ChatListScreen> {
  ChatListBloc chatListBloc;
  final Future<SharedPreferences> prefs = SharedPreferences.getInstance();

  _ChatListScreen({ required this.chatListBloc });

  @override
  void initState() {
    super.initState();
    chatListBloc.chatMessagesWithChatGPTPublisher.listen((chatMessages) {
      prefs.then((prefs) {
        int millisecond = DateTime.now().millisecondsSinceEpoch;

        ChatMessage chatMessage = ChatMessage(
            messageId: millisecond.toString(),
            timestamp: millisecond,
            message: '안녕하세요? 저는 AI Assistance 입니다. 궁금한 점이 있다면 성심 성의껏 답변해 드리겠습니다!',
            myName: prefs.getString('myName') ?? '',
            otherName: ChatGPTScreen.CHAT_GPT_NAME,
            myUid: prefs.getString('myUid') ?? '',
            otherUid: ChatGPTScreen.CHAT_GPT_UID,
            isSender: false
        );
        chatMessages.add(chatMessage);
        Navigator.pushNamed(
            context,
            '/ChatGPTScreen',
            arguments: {
              'otherUserInfo': UserInfo(uid: ChatGPTScreen.CHAT_GPT_UID, name: ChatGPTScreen.CHAT_GPT_NAME, profileUri: ''),
              'chatMessages': chatMessages
            }
        );
      });
    });
  }

  @override
  void dispose() {
    chatListBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [_chatListHeader(context), ChatListContainer(chatListBloc: chatListBloc)],
        ),
      ),
    );
  }

  Widget _chatListHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'chat_list_header'.tr(),
            style: const TextStyle(
                color: AppColors.color_FF000000,
                fontSize: 20,
                fontWeight: FontWeight.w700),
          ),
          _chatListMenu(context)
        ],
      ),
    );
  }

  Widget _chatListMenu(BuildContext context) {
    return Row(
        children: [
          GestureDetector(
            onTap: () {
              prefs.then((prefs) {
                chatListBloc.getChatMessagesWithChatGPT(
                  prefs.getString('myUid') ?? '',
                  ChatGPTScreen.CHAT_GPT_UID,
                  ChatGPTScreen.CHAT_GPT_NAME,
                );
              });
            },
            child: menuList[0],
          )
        ]
    );
  }
}

List<Widget> menuList = [
  Image.asset('assets/images/ic_chatbot.png', width: 30, height: 30),
];
