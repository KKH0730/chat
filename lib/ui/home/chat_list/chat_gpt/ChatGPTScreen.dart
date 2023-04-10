import 'package:chat/AppColors.dart';
import 'package:chat/data/bloc/ChatBloc.dart';
import 'package:chat/data/model/ChatMessage.dart';
import 'package:chat/data/model/UserInfo.dart';
import 'package:chat/ui/home/chat_list/chat/component/ChatContainer.dart';
import 'package:chat/ui/home/chat_list/chat/component/ChatInputContainer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class ChatGPTScreen extends StatelessWidget {
  static const String CHAT_GPT_UID = 'CHATGPT';
  static const String CHAT_GPT_NAME = 'AI Assistant';

  late ChatBloc chatBloc;

  ChatGPTScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Map<dynamic, dynamic> friendInfo = ModalRoute.of(context)?.settings.arguments as Map<dynamic, dynamic>;
    UserInfo otherUserInfo = friendInfo['otherUserInfo'] as UserInfo;
    List<ChatMessage> chatMessages = friendInfo['chatMessages'] as List<ChatMessage>;
    chatBloc = ChatBloc(chatMessages: chatMessages);

    return CupertinoPageScaffold(
        resizeToAvoidBottomInset: true,
        navigationBar: CupertinoNavigationBar(
          backgroundColor: AppColors.color_FFBFCDDF,
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
                padding: const EdgeInsets.only(left: 10),
                child: const Icon(
                  CupertinoIcons.back,
                  size: 28,
                  color: Colors.black,
                )),
          ),
          middle: const Text(
            'AI Assistant',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          padding: EdgeInsetsDirectional.zero,
        ),
        child: Column(
          children: [
            ChatContainer(chatMessages: chatMessages, otherUserInfo: otherUserInfo, chatBloc: chatBloc, isChatWithChatGPT: true),
            ChatInputContainer(otherUserInfo: otherUserInfo, chatBloc: chatBloc, isChatWithChatGPT: true),
          ],
        )
    );
  }
}
