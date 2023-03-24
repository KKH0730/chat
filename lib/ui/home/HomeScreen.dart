import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../AppColors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(middle: Text('main_header'.tr())),
        child: Container(
          alignment: Alignment.center,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                minimumSize: const Size(80, 50),
                backgroundColor: Colors.white,
                side: const BorderSide(
                    color: AppColors.color_FF000000,
                    width: 2.0,
                    style: BorderStyle.solid,
                    strokeAlign: BorderSide.strokeAlignOutside)),
            onPressed: () => Navigator.pushNamed(context, '/ChatListScreen'),
            child: Text(
              'enter'.tr(),
              style: const TextStyle(
                  color: AppColors.color_FF000000,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ));
  }
}
