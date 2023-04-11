import 'package:rxdart/rxdart.dart';

class HomeBloc {
  BehaviorSubject<int> chatBadgeCountPublisher = BehaviorSubject();

  void fetchChatBadgeCount(int unCheckedMessageCount) {
    chatBadgeCountPublisher.sink.add(unCheckedMessageCount);
  }
}