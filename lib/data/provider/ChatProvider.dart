import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as network;
import 'package:http/http.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';

import '../model/ChatMessage.dart';
import '../model/Result.dart';

class ChatProvider {
  final CHAT_GPT_API_KEY = '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';
  final DatabaseReference databaseReference = FirebaseDatabase.instance.refFromURL('https://chat-module-3187e-default-rtdb.firebaseio.com/');

  void fetchMessageToChatGPT(String inputText, PublishSubject<ChatMessage> chatGPTMessagePublisher) async {
    final response = await network.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer $CHAT_GPT_API_KEY',
      },
      body: json.encode({
        'model': 'gpt-3.5-turbo',
        'messages': [{'role': 'user', 'content': inputText}],
        'max_tokens': 200,
        'temperature': 0.5,
        'n': 1
      }),
    );

    Map<String, dynamic> responseData = json.decode(utf8.decode(response.bodyBytes));
    print('kkhedv 11 :${json.decode(utf8.decode(response.bodyBytes))}');
    List<dynamic> list = responseData['choices'];
    print('kkhedv 22 :${list[0]['message']['content']}');
  }

  StreamSubscription observeOtherConnectionState(PublishSubject<bool> otherConnectionPublisher, String myUid, String otherUid) {
    final DatabaseReference ref = FirebaseDatabase.instance.refFromURL('https://chat-module-3187e-default-rtdb.firebaseio.com/');
    StreamSubscription subscription = ref.child('connections')
        .child(otherUid)
        .onValue
        .listen((event) {
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> map = event.snapshot.value as Map<dynamic, dynamic>;
        otherConnectionPublisher.sink.add(map['isConnected']);
      }
    });
    return subscription;
  }

  StreamSubscription reqChatMessages(PublishSubject<ChatMessage> addedChatMessagePublisher, String myUid,
      String otherUid, String myProfileUri, String otherProfileUri, int lastTimeStamp) {
    StreamSubscription subscription = databaseReference
        .child('chat_rooms')
        .child(myUid)
        .child('${myUid}_$otherUid')
        .orderByChild('timestamp')
        .startAfter(lastTimeStamp)
        .onChildAdded
        .listen((event) {
          ChatMessage chatMessage = ChatMessage.fromJson(
              event.snapshot.key!,
              Map.from(event.snapshot.value as Map<dynamic, dynamic>)
          );
          chatMessage.myProfileUri = myProfileUri;
          chatMessage.otherProfileUri = otherProfileUri;

          addedChatMessagePublisher.sink.add(chatMessage);
        });

    return subscription;
  }

  Future<List<ChatMessage>> reqPreviousMessage(String myUid, String otherUid, String myProfileUri, String otherProfileUri, int lastTimestamp, String msg) async {
    DatabaseEvent event = await databaseReference
        .child('chat_rooms')
        .child(myUid)
        .child('${myUid}_$otherUid')
        .orderByChild('timestamp')
        .endBefore(lastTimestamp)
        .limitToLast(20)
        .once();

    List<ChatMessage> chatMessages = [];
    for (var element in event.snapshot.children) {
      if (element.key == 'unCheckedMessageCount') {
        continue;
      }
      ChatMessage chatMessage = ChatMessage.fromJson(element.key!, Map.from(element.value as Map<dynamic, dynamic>));

      chatMessage.myProfileUri = myProfileUri;
      chatMessage.otherProfileUri = otherProfileUri;
      chatMessages.add(chatMessage);
    }

    return chatMessages;
  }
  Future<Result<bool>> fetchChatMessage(
      String message,
      String myName,
      String myUid,
      String otherName,
      String otherUid,
      int timeMillisecond
  ) async {
    try {
      var map = {
        'isSender': true,
        'timestamp': timeMillisecond,
        'message': message,
        'myName': myName,
        'myUid': myUid,
        'otherName': otherName,
        'otherUid': otherUid
      };
      await databaseReference
          .child('chat_rooms')
          .child(myUid)
          .child('${myUid}_$otherUid')
          .child(timeMillisecond.toString())
          .update(map);

      map['isSender'] = false;
      map['myName'] = otherName;
      map['myUid'] = otherUid;
      map['otherName'] = myName;
      map['otherUid'] = myUid;

      var otherDatabaseRef = databaseReference.child('chat_rooms')
          .child(otherUid)
          .child('${otherUid}_$myUid');

      await otherDatabaseRef.runTransaction((Object? transaction) {
        if (transaction == null) {
          print('kkhdev 111');
          return Transaction.abort();
        }
        Map<String, dynamic> chatMessagesMap = Map<String, dynamic>.from(transaction as Map);
        chatMessagesMap['unCheckedMessageCount'] = (chatMessagesMap['unCheckedMessageCount'] ?? 0) + 1;
        return Transaction.success(chatMessagesMap);
      });

      await otherDatabaseRef.child(timeMillisecond.toString()).update(map);


      return Result(success: true);
    } catch (e) {
      print(e);
      return Result(success: false);
    }
  }

  void fetchUnCheckedMessageCountZero(String myUid, String otherUid) {
    databaseReference
        .child('chat_rooms')
        .child(myUid)
        .child('${myUid}_$otherUid')
        .update({ 'unCheckedMessageCount': 0 });
  }
}
