import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:rxdart/rxdart.dart';

import '../model/ChatMessage.dart';
import '../model/Result.dart';

class ChatProvider {
  final DatabaseReference databaseReference = FirebaseDatabase.instance.refFromURL('https://chat-module-3187e-default-rtdb.firebaseio.com/');
  final PublishSubject<ChatMessage> addedChatMessageFetcher = PublishSubject();
  Client client = Get.find<Client>();

  Stream<DatabaseEvent> reqChatMessages(
      String myUid, String otherUid, String myProfileUri, String otherProfileUri, String lastMessageKey) {
    Stream<DatabaseEvent> stream = databaseReference
        .child('chat_rooms')
        .child(myUid)
        .child('${myUid}_$otherUid')
        .orderByChild('lastDate')
        .startAfter(DateTime.now().millisecondsSinceEpoch)
        .onChildAdded;
    return stream;
  }

  Future<Result<bool>> fetchChatMessage(
      String message, String myName, String myUid, String otherName, String otherUid, int timeMillisecond) async {
    try {
      var map = {
        'isSender': true,
        'lastDate': timeMillisecond,
        'message': message,
        'myName': myName,
        'myUid': myUid,
        'otherName': otherName,
        'otherUid': otherUid
      };
      // await databaseReference.child('chat_rooms').child(myUid).child('${myUid}_$otherUid').push().update(map);
      await databaseReference.child('chat_rooms').child(myUid).child('${myUid}_$otherUid').child(timeMillisecond.toString()).update(map);

      map['isSender'] = false;
      map['myName'] = otherName;
      map['myUid'] = otherUid;
      map['otherName'] = myName;
      map['otherUid'] = myUid;
      // await databaseReference.child('chat_rooms').child(otherUid).child('${otherUid}_$myUid').push().update(map);
      await databaseReference.child('chat_rooms').child(otherUid).child('${otherUid}_$myUid').child(timeMillisecond.toString()).update(map);

      return Result(success: true);
    } catch (e) {
      print(e);
      return Result(success: false);
    }
  }
}
