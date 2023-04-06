import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../AppColors.dart';
import 'component/ChatListContainer.dart';

class ChatListScreen extends StatelessWidget {
  static bool isJoinChattingRoom = false;

  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [_chatListHeader(), const ChatListContainer()],
        ),
      ),
    );
  }

  Widget _chatListHeader() {
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
          _chatListMenu()
        ],
      ),
    );
  }

  Widget _chatListMenu() {
    return Row(
        children: [
          menuList[1],
          const SizedBox(width: 10),
          menuList[0]
        ]
    );
  }
}

List<Widget> menuList = [
  const Icon(CupertinoIcons.search, size: 24, color: AppColors.color_FF000000),
  const Icon(CupertinoIcons.sort_up, size: 24, color: AppColors.color_FF000000)
];
