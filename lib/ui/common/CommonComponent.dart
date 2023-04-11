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

class NoDataScreen extends StatelessWidget {
  const NoDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: const CupertinoActivityIndicator(
        animating: true,
        radius: 20.0,
      ),
    );
  }
}
