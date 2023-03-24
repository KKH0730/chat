import 'package:chat/ui/home/HomeScreen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'di/DIBinding.dart';
import 'ui/home/chat_list/ChatListScreen.dart';
import 'ui/home/chat_list/chat/ChatScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  // await Firebase.initializeApp();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAuth.instance.signInAnonymously();

  FlutterError.onError = (FlutterErrorDetails details) {
    print('kkhdev Uncaught error: ${details.exception}');
    FlutterError.dumpErrorToConsole(details);
  };

  var prefs = await SharedPreferences.getInstance();
  prefs.setString('myName', '마리집사');
  prefs.setString('myProfileUri',
      'https://search.pstatic.net/common/?src=http%3A%2F%2Fblogfiles.naver.net%2FMjAyMjEyMjZfNjQg%2FMDAxNjcyMDYwODAyMjY3.r03IsCV9Lph9oh2Qk7-t9PoHjWLIAku0d5ByIApqYrgg.PPTwT3TnXlUDsA6no7kVFD4hlpQZaKQK09niW8lkonog.JPEG.alrud4430%2F1672060717954.jpg&type=a340');
  prefs.setString('myUid', 'I4wUntHgIEfIPaUTzgoeAlG0UIu1');

  // prefs.setString('myName', '예티집사');
  // prefs.setString('myProfileUri',
  //     'https://search.pstatic.net/sunny/?src=https%3A%2F%2Fi.pinimg.com%2Foriginals%2F21%2Ff9%2F83%2F21f98377d0d9f9efc27dfc19323d2c95.jpg&type=sc960_832');
  // prefs.setString('myUid', 'kQ81x3QrrHQOToARYRcXmMFxVYy1');

  runApp(EasyLocalization(
      supportedLocales: const [
        Locale('en', 'US'), // English
        Locale('ko', 'KR'), // Korean
      ],
      path: 'assets/langs',
      fallbackLocale: const Locale("en", "US"),
      child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetCupertinoApp(
      builder: (context, child) => SafeArea(child: child!),
      initialBinding: DIBinding(),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      initialRoute: initialRoute,
      routes: routes,
    );
  }
}

const String initialRoute = '/';
final Map<String, WidgetBuilder> routes = {
  '/': (BuildContext context) => const HomeScreen(),
  '/ChatListScreen': (BuildContext context) => const ChatListScreen(),
  '/ChatScreen': (BuildContext context) => ChatScreen()
};
