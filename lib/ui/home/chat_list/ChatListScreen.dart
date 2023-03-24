import 'package:flutter/material.dart';
import 'component/ChatListContainer.dart';
import 'component/ChatListHeader.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        color: Colors.white,
        child: Column(
          children: const [ChatListHeader(), ChatListContainer()],
        ),
      ),
    );
  }
}
