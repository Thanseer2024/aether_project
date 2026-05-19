import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String user;
  final String text;
  final DateTime time;

  const ChatMessage({
    required this.user,
    required this.text,
    required this.time,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      user: map['user'] as String? ?? 'Unknown',
      text: map['text'] as String? ?? '',
      time: (map['time'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'user': user,
      'text': text,
      'time': Timestamp.fromDate(time),
    };
  }
}
