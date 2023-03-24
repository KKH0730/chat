import 'package:chat/AppColors.dart';
import 'package:chat/data/bloc/ChatBloc.dart';
import 'package:chat/ui/home/chat_list/chat/component/ChatContainer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../data/model/ChatMessage.dart';
import 'component/ChatInputContainer.dart';

class ChatScreen extends StatelessWidget {
  late ChatBloc chatBloc;

  ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    late List<ChatMessage> chatMessages =
        ModalRoute.of(context)?.settings.arguments as List<ChatMessage>;
    chatBloc = ChatBloc(chatMessages: chatMessages);

    ChatMessage lastChatMessage = chatMessages[chatMessages.length - 1];

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
          middle: Text(
            lastChatMessage.otherName,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          padding: EdgeInsetsDirectional.zero,
        ),
        child: Column(
          children: [
            ChatContainer(chatMessages: chatMessages, chatBloc: chatBloc),
            ChatInputContainer(lastMessage: lastChatMessage, chatBloc: chatBloc),
          ],
        ));
  }
}
