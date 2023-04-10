import 'package:flutter/cupertino.dart';

import '../../AppColors.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: const Text(
        '에러 발생!!!',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.color_FF0000FF),
      ),
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: const Text(
        '로딩중!!!',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.color_FF000000),
      ),
    );
  }
}
