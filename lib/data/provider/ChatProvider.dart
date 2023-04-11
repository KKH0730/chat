import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as network;
import 'package:firebase_database/firebase_database.dart';
import 'package:rxdart/rxdart.dart';

import '../model/ChatMessage.dart';

class ChatProvider {
  final DatabaseReference databaseReference = FirebaseDatabase.instance.refFromURL('https://chat-module-3187e-default-rtdb.firebaseio.com/');
  String openai_api_key = '';

  StreamSubscription reqChatMessages(PublishSubject<ChatMessage> addedChatMessagePublisher, String myUid,
      String otherUid, String myProfileUri, String otherProfileUri, int lastTimeStamp, bool isChatWithChatGPT) {
    StreamSubscription subscription = databaseReference
        .child(isChatWithChatGPT ? 'chat_gpt_rooms' : 'chat_rooms')
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
  void fetchChatMessage(
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

      await databaseReference.child('chat_rooms')
          .child(otherUid)
          .child('${otherUid}_$myUid')
          .child(timeMillisecond.toString())
          .update(map);

      databaseReference.child('chat_rooms')
          .child(otherUid)
          .child('${otherUid}_$myUid')
          .child('unCheckedMessageCount')
          .once()
          .then((value) {
            int currentCount = value.snapshot.value as int? ?? 0;

            databaseReference.child('chat_rooms')
                .child(otherUid)
                .child('${otherUid}_$myUid')
                .update({'unCheckedMessageCount': currentCount + 1});
        });
    } catch (e) {
      print('error : $e');
    }
  }

  void fetchUnCheckedMessageCountZero(String myUid, String otherUid) {
    databaseReference
        .child('chat_rooms')
        .child(myUid)
        .child('${myUid}_$otherUid')
        .update({'unCheckedMessageCount': 0 });
  }

  void fetchMessageToChatGPT(String myUid, String myName, String inputText, PublishSubject<String> chatGPTMessagePublisher) async {
    if (openai_api_key.isEmpty) {
      DatabaseEvent event = await databaseReference.child('key').once();
      var keyMap = Map.from(event.snapshot.value as Map<dynamic, dynamic>);
      openai_api_key = keyMap['openai_api_key'];
    }

    if (openai_api_key.isEmpty) {
      return;
    }

    final response = await network.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer $openai_api_key'
      },
      body: json.encode({
        'model': 'gpt-3.5-turbo',
        'messages': [{'role': 'user', 'content': inputText}],
        'max_tokens': 200,
        'temperature': 0.5,
        'n': 5,
      }),
    );

    Map<String, dynamic> responseData = json.decode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200) {
      List<dynamic> list = responseData['choices'];
      String content = list[0]['message']['content'] ?? '';
      if (content.isNotEmpty) {
        chatGPTMessagePublisher.sink.add(content);
      }
    } else {
      String errorMessage = responseData['error']['message'] ?? '';
      if (errorMessage.isNotEmpty) {
        chatGPTMessagePublisher.sink.add(errorMessage);
      }
    }
  }

  Future<void> fetchChatMessageWithChatGPT(
      String message,
      String myName,
      String myUid,
      String otherName,
      String otherUid,
      int timeMillisecond,
      bool isSendToChatGTP
  ) async {
    try {
      var map = {
        'isSender': isSendToChatGTP ? true : false,
        'timestamp': timeMillisecond,
        'message': message,
        'myName': myName,
        'myUid': myUid,
        'otherName': otherName,
        'otherUid': otherUid
      };
      await databaseReference
          .child('chat_gpt_rooms')
          .child(myUid)
          .child('${myUid}_$otherUid')
          .child(timeMillisecond.toString())
          .update(map);
    } catch (e) {
      print(e);
    }
  }
}
