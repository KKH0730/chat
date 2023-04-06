import 'package:chat/ui/home/HomeScreen.dart';
import 'package:chat/ui/home/chat_list/component/ChatListContainer.dart';
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
import 'ui/home/chat_list/ChatListScreen.dart';
import 'ui/home/chat_list/chat/ChatScreen.dart';

final routeObserver = RouteObserver<ModalRoute>();
final BehaviorSubject<String> connectionPublisher = BehaviorSubject();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseDatabase.instance.setPersistenceEnabled(true);
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
  await FirebaseAuth.instance.signInAnonymously();

  FlutterError.onError = (FlutterErrorDetails details) {
    print('Uncaught error: ${details.exception}');
    FlutterError.dumpErrorToConsole(details);
  };

  var prefs = await SharedPreferences.getInstance();
  String? myUid = FirebaseAuth.instance.currentUser?.uid;
  print('kkhdev myUid : ${myUid}');
  if (myUid != null) {
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
    } else if(myUid == "UEG7B7MM8NTgidwmW1FE7v7hhjq2") {
      prefs.setString('myName', '제프집사');
      prefs.setString('myProfileUri',
          'https://mblogthumb-phinf.pstatic.net/MjAxODAxMTVfMjQg/MDAxNTE2MDA1MTI4OTk2.FXP09sHR1BHmwm6xszEG0Kw8obKdJZL7DwMEFnL_490g.HIoJkfFWiplL29ZKvumtZNiLCcCtObOkS7T6f2dsZL4g.JPEG.interpark_pet/cat_22.jpg?type=w800');
      prefs.setString('myUid', 'UEG7B7MM8NTgidwmW1FE7v7hhjq2');
    } else if(myUid == "vnkRSLdxOVgyb1duqWB2tigNEg12") {
      prefs.setString('myName', '길냥이');
      prefs.setString('myProfileUri',
          'https://t1.daumcdn.net/cfile/tistory/991011345DA7108009');
      prefs.setString('myUid', 'vnkRSLdxOVgyb1duqWB2tigNEg12');
    }
  }


  saveConnectionState();

  runApp(EasyLocalization(
      supportedLocales: const [
        Locale('en', 'US'), // English
        Locale('ko', 'KR'), // Korean
      ],
      path: 'assets/langs',
      fallbackLocale: const Locale("en", "US"),
      child: const MyApp()));
}

Future<void> saveConnectionState() async {
  String? myUid = FirebaseAuth.instance.currentUser?.uid;
  if (myUid != null) {
    final DatabaseReference myConnectionsRef = FirebaseDatabase.instance.refFromURL('https://chat-module-3187e-default-rtdb.firebaseio.com/');
    final connectedRef = FirebaseDatabase.instance.ref(".info/connected");
    connectedRef.onValue.listen((event) {
      final connected = event.snapshot.value as bool? ?? false;

      if (connected) {
        final con = myConnectionsRef.child('connections').child(myUid);
        con.update({'isConnected' : true});

        // When this device disconnects, remove it.
        con.onDisconnect().update({'isConnected' : false});
      }
    });
  }
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
  '/ChatListScreen': (BuildContext context) => const ChatListScreen(),
  '/ChatScreen': (BuildContext context) => ChatScreen()
};
