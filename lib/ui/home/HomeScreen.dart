import 'package:chat/ui/home/chat_list/ChatListScreen.dart';
import 'package:chat/ui/home/friends/FriendsListScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final bottomNavigationItems = [
    const BottomNavigationBarItem(
        icon: Icon(CupertinoIcons.person),
        activeIcon: Icon(CupertinoIcons.person_alt_circle),
    ),
    const BottomNavigationBarItem(
        icon: Icon(CupertinoIcons.chat_bubble),
        activeIcon: Icon(CupertinoIcons.chat_bubble_fill)
    ),
    const BottomNavigationBarItem(icon: Icon(CupertinoIcons.shopping_cart)),
    const BottomNavigationBarItem(icon: Icon(CupertinoIcons.square_grid_2x2)),
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          items: bottomNavigationItems,
          activeColor: Colors.black45,
          inactiveColor: Colors.black45,
          iconSize: 20,
        ),
        tabBuilder: (context, index) {
          switch (index) {
            case 0:
              return FriendsListScreen();
            case 1:
              return ChatListScreen();
            case 2:
              return Container();
            case 3:
              return Container();
          }
          return Container();
        }
    );
  }
}
