import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../../../../../data/model/ChatMessage.dart';

class ChatProfileImage extends StatelessWidget {
  ChatMessage chatMessage;
  double width;
  double height;

  ChatProfileImage(
      {super.key,
      required this.chatMessage,
      required this.width,
      required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        backgroundImage: chatMessage.otherProfileUri.isNotEmpty
            ? CachedNetworkImageProvider(
                chatMessage.otherProfileUri,
                cacheManager: DefaultCacheManager(),
              )
            : Image.asset('assets/images/ic_user_default.png').image,
      ),
    );
  }
}
