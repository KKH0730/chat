import 'package:rxdart/rxdart.dart';

class HomeBloc {
  PublishSubject<int> chatBadgeCountPublisher = PublishSubject();

  void fetchChatBadgeCount(int unCheckedMessageCount) {
    chatBadgeCountPublisher.sink.add(unCheckedMessageCount);
  }
}