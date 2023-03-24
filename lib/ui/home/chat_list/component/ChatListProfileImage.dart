import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/data/model/ChatMessage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class ChatListProfileImage extends StatelessWidget {
  ChatMessage chatMessage;

  ChatListProfileImage({super.key, required this.chatMessage});

  @override
  Widget build(BuildContext context) {
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
