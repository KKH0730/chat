import 'package:chat/data/bloc/HomeBloc.dart';
import 'package:chat/ui/account/sign_in/SignInScreen.dart';
import 'package:chat/ui/home/HomeScreen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization_loader/easy_localization_loader.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
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

  if (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS) {
    // 앱 빌드시 사용
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } else if (defaultTargetPlatform == TargetPlatform.macOS || defaultTargetPlatform == TargetPlatform.windows){
    // 웹 빌드 시 사용
    print('kkhdev defaultTargetPlatform : $defaultTargetPlatform');
    await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyAxN97k6ncdEsly3eu9m5N6EuUhuZix-zY",
          authDomain: "chat-module-3187e.firebaseapp.com",
          databaseURL: "https://chat-module-3187e-default-rtdb.firebaseio.com",
          projectId: "chat-module-3187e",
          storageBucket: "chat-module-3187e.appspot.com",
          messagingSenderId: "1033869949481",
          appId: "1:1033869949481:web:be91f0e9f7cd7f0e3dfa38"
      ),
    );
  }

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
  } else {
    return;
  }

  runApp(EasyLocalization(
      supportedLocales: const [
        Locale('en', 'US'), // English
        Locale('ko', 'KR'), // Korean
      ],
      path: 'assets/langs',
      fallbackLocale: const Locale("en", "US"),
      assetLoader: JsonAssetLoader(),
      child: const MyApp())
  );
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

const String initialRoute = '/SigInInScreen';
final Map<String, WidgetBuilder> routes = {
  '/HomeScreen': (BuildContext context) => HomeScreen(),
  '/SigInInScreen': (BuildContext context) => SignInScreen(),
  '/ChatScreen': (BuildContext context) => ChatScreen(),
  '/ChatGPTScreen': (BuildContext context) => ChatGPTScreen()
};
