import 'package:chat/AppColors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';

class ChatListHeader extends StatelessWidget {
  const ChatListHeader({super.key});

  @override
  Widget build(BuildContext context) {
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
          const ChatListMenu()
        ],
      ),
    );
  }
}

class ChatListMenu extends StatelessWidget {
  const ChatListMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      ChatListMenuItem(iconWidget: menuList[1]),
      const SizedBox(width: 10),
      ChatListMenuItem(iconWidget: menuList[0])
    ]);
  }
}

class ChatListMenuItem extends StatelessWidget {
  Widget iconWidget;

  ChatListMenuItem({super.key, required this.iconWidget});

  @override
  Widget build(BuildContext context) {
    return iconWidget;
  }
}

List<Widget> menuList = [
  const Icon(CupertinoIcons.search, size: 24, color: AppColors.color_FF000000),
  const Icon(CupertinoIcons.sort_up, size: 24, color: AppColors.color_FF000000)
];
