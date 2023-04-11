import 'package:chat/data/bloc/HomeBloc.dart';
import 'package:chat/ui/home/HomeScreen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'di/DIBinding.dart';
import 'ui/home/chat_list/chat/ChatScreen.dart';
import 'ui/home/chat_list/chat_gpt/ChatGPTScreen.dart';

final routeObserver = RouteObserver<ModalRoute>();
final BehaviorSubject<String> connectionPublisher = BehaviorSubject();


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // 앱 빌드시 사용
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // 웹 빌드 시 사용
  // await Firebase.initializeApp(
  //   options: const FirebaseOptions(
  //       apiKey: "AIzaSyAxN97k6ncdEsly3eu9m5N6EuUhuZix-zY",
  //       authDomain: "chat-module-3187e.firebaseapp.com",
  //       databaseURL: "https://chat-module-3187e-default-rtdb.firebaseio.com",
  //       projectId: "chat-module-3187e",
  //       storageBucket: "chat-module-3187e.appspot.com",
  //       messagingSenderId: "1033869949481",
  //       appId: "1:1033869949481:web:be91f0e9f7cd7f0e3dfa38"
  //   ),
  // );
  // FirebaseDatabase.instance.setPersistenceEnabled(false);
  await FirebaseAuth.instance.signInAnonymously();

  FlutterError.onError = (FlutterErrorDetails details) {
    print('Uncaught error: ${details.exception}');
    FlutterError.dumpErrorToConsole(details);
  };

  var prefs = await SharedPreferences.getInstance();
  String? myUid = FirebaseAuth.instance.currentUser?.uid;
  if (myUid != null) {
    prefs.setString('myUid', myUid);
    print('kkhdev myUid : $myUid');

    if (myUid == "sIBodRy6FjMnEdTF3pz8Xs9Q7Th2") {
      prefs.setString('myName', '마리집사');
      prefs.setString('myProfileUri',
          'https://search.pstatic.net/common/?src=http%3A%2F%2Fblogfiles.naver.net%2FMjAyMjEyMjZfNjQg%2FMDAxNjcyMDYwODAyMjY3.r03IsCV9Lph9oh2Qk7-t9PoHjWLIAku0d5ByIApqYrgg.PPTwT3TnXlUDsA6no7kVFD4hlpQZaKQK09niW8lkonog.JPEG.alrud4430%2F1672060717954.jpg&type=a340');
      prefs.setString('myUid', 'sIBodRy6FjMnEdTF3pz8Xs9Q7Th2');
    } else if(myUid == "kQ81x3QrrHQOToARYRcXmMFxVYy1") {
      prefs.setString('myName', '예티집사');
      prefs.setString('myProfileUri',
          'https://search.pstatic.net/sunny/?src=https%3A%2F%2Fi.pinimg.com%2Foriginals%2F21%2Ff9%2F83%2F21f98377d0d9f9efc27dfc19323d2c95.jpg&type=sc960_832');
      prefs.setString('myUid', 'kQ81x3QrrHQOToARYRcXmMFxVYy1');
    } else if(myUid == "3oC5Sq8BmLeWa1FqAjOqQriWUKq1") {
      prefs.setString('myName', '길냥이');
      prefs.setString('myProfileUri',
          'https://t1.daumcdn.net/cfile/tistory/991011345DA7108009');
      prefs.setString('myUid', '3oC5Sq8BmLeWa1FqAjOqQriWUKq1');
    }
  }

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
      navigatorObservers: [routeObserver],
      routes: routes,
    );
  }
}

const String initialRoute = '/';
final Map<String, WidgetBuilder> routes = {
  '/': (BuildContext context) => HomeScreen(),
  '/ChatScreen': (BuildContext context) => ChatScreen(),
  '/ChatGPTScreen': (BuildContext context) => ChatGPTScreen()
};
