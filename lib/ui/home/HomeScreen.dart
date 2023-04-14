import 'package:chat/data/bloc/ChatListBloc.dart';
import 'package:chat/data/bloc/HomeBloc.dart';
import 'package:chat/ui/home/chat_list/ChatListScreen.dart';
import 'package:chat/ui/home/friends/FriendsListScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  HomeBloc homeBloc = Get.find<HomeBloc>();
  ChatListBloc chatListBloc = Get.find<ChatListBloc>();
  HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() => _HomeScreenState(homeBloc: homeBloc, chatListBloc: chatListBloc);
}

class _HomeScreenState extends State<HomeScreen> {
  HomeBloc homeBloc;
  ChatListBloc chatListBloc;
  int chatBadgeCount = 0;

  _HomeScreenState({ required this.homeBloc, required this.chatListBloc });

  @override
  void initState() {
    super.initState();
    chatListBloc.reqChatList();
    chatListBloc.checkMessageCountPublisher.listen((unCheckMessageCount) => homeBloc.fetchChatBadgeCount(unCheckMessageCount));
  }

  @override
  void dispose() {
    homeBloc.chatBadgeCountPublisher.close();
    chatListBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          items: [
            const BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.person),
              activeIcon: Icon(CupertinoIcons.person_alt_circle),
            ),
            _BadgeBottomNavigationBarItem(CupertinoIcons.chat_bubble_fill, CupertinoIcons.chat_bubble),
            const BottomNavigationBarItem(icon: Icon(CupertinoIcons.cart)),
            const BottomNavigationBarItem(icon: Icon(CupertinoIcons.square_grid_2x2))
          ],
          activeColor: Colors.black45,
          inactiveColor: Colors.black45,
          iconSize: 20,
        ),
        tabBuilder: (context, index) {
          switch (index) {
            case 0:
              return FriendsListScreen();
            case 1:
              return ChatListScreen(chatListBloc: chatListBloc);
            case 2:
              return Container();
            case 3:
              return Container();
          }
          return Container();
        }
    );
  }

  BottomNavigationBarItem _BadgeBottomNavigationBarItem(IconData activeIconData, IconData inActiveIconData) {
    return BottomNavigationBarItem(
      icon: StreamBuilder(
        stream: homeBloc.chatBadgeCountPublisher.stream,
        builder: (context, snapshot) {
          int chatBadgeCount = snapshot.data ?? 0;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(inActiveIconData),
              Positioned(
                right: -5,
                top: -5,
                child: Badge(
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  smallSize: 10,
                  largeSize: 15,
                  textStyle: const TextStyle(fontSize: 10),
                  label: Text(chatBadgeCount.toString()),
                  isLabelVisible: chatBadgeCount != 0 ? true : false,
                ),
              ),
            ],
          );
        },
      ),
      activeIcon: StreamBuilder(
        stream: homeBloc.chatBadgeCountPublisher.stream,
        builder: (context, snapshot) {
          int chatBadgeCount = snapshot.data ?? 0;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(activeIconData),
              Positioned(
                right: -5,
                top: -5,
                child: Badge(
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  smallSize: 10,
                  largeSize: 15,
                  textStyle: const TextStyle(fontSize: 10),
                  label: Text(chatBadgeCount.toString()),
                  isLabelVisible: chatBadgeCount != 0 ? true : false,
                ),
              ),
            ],
          );
        },
      )
    );
  }
}
