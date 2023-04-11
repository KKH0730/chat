import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/data/model/UserInfo.dart' as userInfo;
import 'package:chat/ui/common/CommonComponent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../AppColors.dart';
import '../../../../data/bloc/FriendsBloc.dart';

class FriendsListContainer extends StatefulWidget {
  FriendsBloc friendsBloc = Get.find<FriendsBloc>();

  FriendsListContainer({super.key});

  @override
  State<StatefulWidget> createState() => _FriendsListState(friendsBloc: friendsBloc);
}

class _FriendsListState extends State<FriendsListContainer> {
  FriendsBloc friendsBloc;
  final Future<SharedPreferences> prefs = SharedPreferences.getInstance();

  _FriendsListState({ required this.friendsBloc });

  @override
  void initState() {
    super.initState();

    prefs.then((prefs) => friendsBloc.getFriendsUserInfoList(prefs.getString('myUid') ?? ''));

    friendsBloc.chatMessagesFetcher.listen((friendInfo) {

      Navigator.pushNamed(context, '/ChatScreen', arguments: { 'otherUserInfo': friendInfo.item1, 'chatMessages': friendInfo.item2 });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: StreamBuilder(
            stream: friendsBloc.friendsUidListFetcher.stream,
            builder: (context, snapshot) {
              if(snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingScreen();
              } else if (snapshot.hasError) {
                return const ErrorScreen();
              } else if (!snapshot.hasData || snapshot.data?.isEmpty == true) {
                return const NoDataScreen();
              } else {
                final userInfoList = snapshot.data!;
                return ListView.builder(
                    itemCount: userInfoList.length,
                    itemBuilder: (context, index) {
                      return _friendListUnit(userInfoList[index]);
                    });
              }
            }
        ),
      ),
    );
  }

  Widget _friendListUnit(userInfo.UserInfo userInfo) {
    return GestureDetector(
      onTap: () {
        prefs.then((prefs) async {
          friendsBloc.getChatMessages(prefs.getString('myUid')!, userInfo);
        });
      },
      child: Container(
          height: 75,
          color: Colors.transparent,
          alignment: Alignment.center,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: 50, height: 50, child: _profileImage(userInfo.profileUri)),
              const SizedBox(width: 20),
              Expanded(
                  child: Text(
                    userInfo.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.color_FF000000),
                  )
              )
            ],
          )
      ),
    );
  }

  Widget _profileImage(String profileUri) {
    return CircleAvatar(
      backgroundColor: Colors.transparent,
      backgroundImage: profileUri.isNotEmpty
          ? CachedNetworkImageProvider(
        profileUri,
        cacheManager: DefaultCacheManager(),
      )
          : Image.asset('assets/images/ic_user_default.png').image,
    );
  }
}