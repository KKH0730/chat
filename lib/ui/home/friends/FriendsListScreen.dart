import 'package:chat/ui/home/friends/component/FriendsListContainer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';

import '../../../AppColors.dart';

class FriendsListScreen extends StatelessWidget {

  FriendsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _friendsListHeader(),
        const SizedBox(height: 10),
        FriendsListContainer()
      ],
    );
  }

  Widget _friendsListHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Text(
        'friends_list_header'.tr(),
        style: const TextStyle(
            color: AppColors.color_FF000000,
            fontSize: 20,
            fontWeight: FontWeight.w700),
      ),
    );
  }
}