import 'package:chat/data/model/ChatMessage.dart';

class ChatListItem {
  int unCheckedMessageCount;
  List<ChatMessage> chatMessages;

  ChatListItem({ required this.unCheckedMessageCount, required this.chatMessages });
}