import 'package:flutter/material.dart';

import '../../../../../AppColors.dart';

class DateNotification extends StatelessWidget {
  final String message;

  DateNotification({required this.message});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.delayed(const Duration(milliseconds: 1200)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return message.isEmpty
              ? Container()
              : Container(
                  margin: const EdgeInsets.only(top: 20),
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  decoration: BoxDecoration(
                    color: AppColors.color_8E000000,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    message,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
