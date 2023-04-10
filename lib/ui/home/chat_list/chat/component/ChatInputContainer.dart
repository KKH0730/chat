import 'package:chat/AppColors.dart';
import 'package:chat/data/bloc/ChatBloc.dart';
import 'package:chat/data/model/ChatMessage.dart';
import 'package:chat/data/model/UserInfo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ChatInputContainer extends StatefulWidget {
  UserInfo otherUserInfo;
  ChatBloc chatBloc;
  bool isChatWithChatGPT;

  ChatInputContainer({ super.key, required this.otherUserInfo, required this.chatBloc, required this.isChatWithChatGPT });

  @override
  State<StatefulWidget> createState() =>
      _ChatInputContainerState(otherUserInfo: otherUserInfo, chatBloc: chatBloc, isChatWithChatGPT: isChatWithChatGPT);
}

class _ChatInputContainerState extends State<ChatInputContainer>  {
  final Future<SharedPreferences> prefs = SharedPreferences.getInstance();
  ChatBloc chatBloc;
  UserInfo otherUserInfo;
  bool isChatWithChatGPT;
  bool isEnableSendButton = true;
  TextEditingController textEditingController = TextEditingController();

  _ChatInputContainerState({required this.otherUserInfo, required this.chatBloc, required this.isChatWithChatGPT });

  @override
  void initState() {
    super.initState();

    chatBloc.sendButtonControlSubject.listen((isEnable) {
      setState(() => isEnableSendButton = isEnable);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding:
              const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: CupertinoTextField(
                  cursorColor: AppColors.color_FF4A58E8,
                  controller: textEditingController,
                  padding: const EdgeInsets.only(
                      left: 15, top: 10, bottom: 10, right: 50),
                  style: const TextStyle(fontSize: 14),
                  decoration: BoxDecoration(
                      color: AppColors.color_79ECE9E9,
                      borderRadius: BorderRadius.circular(50.0),
                      border: Border.all(color: AppColors.color_5FE5E5E5)),
                  onChanged: (value) {
                    setState(() {
                      textEditingController.selection =
                          TextSelection.fromPosition(TextPosition(offset: textEditingController.text.length));
                    });
                  },
                  onSubmitted: (value) {
                    if (!isEnableSendButton) {
                      return;
                    }
                    var message = textEditingController.text;
                    if (value.isEmpty) {
                      return;
                    }
                    textEditingController.clear();

                    prefs.then((prefs) {
                      if (isChatWithChatGPT) {
                        chatBloc.fetchMessageToChatGPT(
                            prefs.getString('myUid')!,
                            prefs.getString('myName')!,
                            message
                        );
                      } else {
                        chatBloc.fetchChatMessage(
                          message,
                          prefs.getString('myName')!,
                          prefs.getString('myUid')!,
                          otherUserInfo.name,
                          otherUserInfo.uid,
                        );
                      }
                    });
                  }),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                if (!isEnableSendButton) {
                  return;
                }
                var message = textEditingController.text;
                if (message.isEmpty) {
                  return;
                }
                textEditingController.clear();

                prefs.then((prefs) {
                  if (isChatWithChatGPT) {
                    chatBloc.fetchMessageToChatGPT(
                        prefs.getString('myUid')!,
                        prefs.getString('myName')!,
                        message
                    );
                  } else {
                    chatBloc.fetchChatMessage(
                      message,
                      prefs.getString('myName')!,
                      prefs.getString('myUid')!,
                      otherUserInfo.name,
                      otherUserInfo.uid,
                    );
                  }
                });
              },
              child: Visibility(
                visible: textEditingController.text.isNotEmpty ? true : false,
                child: Container(
                  width: 47,
                  height: 47,
                  padding: const EdgeInsets.only(right: 15),
                  child: _sendButton(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sendButton() {
    return Container(
      decoration:
      const BoxDecoration(shape: BoxShape.circle, color: Colors.yellow),
      child: const Icon(
        Icons.arrow_upward_outlined,
        size: 26,
        color: Colors.black,
      ),
    );
  }
}