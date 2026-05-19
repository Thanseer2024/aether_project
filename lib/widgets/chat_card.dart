import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';

class ChatCard extends StatefulWidget {
  const ChatCard({super.key});

  @override
  State<ChatCard> createState() => _ChatCardState();
}

class _ChatCardState extends State<ChatCard> {
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // SYSTEM LOGIC: Using a limited stream to avoid catastrophic read costs
  // with 10,000 concurrent players. We only listen to the last 50 messages.
  late final Stream<List<ChatMessage>> _chatStream = _firestore
      .collection('chat')
      .orderBy('time', descending: true)
      .limit(50)
      .snapshots()
      .map(
        (QuerySnapshot<Map<String, dynamic>> snapshot) => snapshot.docs
            .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => ChatMessage.fromMap(doc.data()))
            .toList()
            .reversed
            .toList(),
      );

  @override
  void dispose() {
    _chatController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final String text = _chatController.text.trim();
    if (text.isEmpty) return;

    final ChatMessage message = ChatMessage(
      user: 'You',
      text: text,
      time: DateTime.now(),
    );

    _chatController.clear();

    try {
      // SYSTEM LOGIC: Decoupled write to avoid UI blocking.
      // Firestore handles offline persistence and eventual consistency.
      await _firestore.collection('chat').add(message.toMap());
      _scrollToBottom();
    } catch (e) {
      // SILENT FAIL (or handle as per mission)
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF10102A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Column(
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Row(
              children: <Widget>[
                Icon(Icons.chat_bubble_outline, color: Colors.blueAccent, size: 16),
                SizedBox(width: 8),
                Text(
                  'GLOBAL CHAT',
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    fontSize: 12,
                  ),
                ),
                Spacer(),
                CircleAvatar(radius: 4, backgroundColor: Colors.greenAccent),
                SizedBox(width: 6),
                Text(
                  'LIVE',
                  style: TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 10,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white12, height: 1),
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: _chatStream,
              builder: (BuildContext context, AsyncSnapshot<List<ChatMessage>> snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading chat', style: TextStyle(color: Colors.redAccent)));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final List<ChatMessage> messages = snapshot.data!;
                
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: messages.length,
                  itemBuilder: (BuildContext context, int index) {
                    final ChatMessage msg = messages[index];
                    final bool isSystem = msg.user == 'System';
                    final bool isMe = msg.user == 'You';
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: RichText(
                        text: TextSpan(
                          children: <TextSpan>[
                            TextSpan(
                              text: '[${msg.user}]  ',
                              style: TextStyle(
                                color: isSystem ? Colors.orangeAccent : (isMe ? Colors.greenAccent : Colors.blueAccent),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            TextSpan(text: msg.text, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const Divider(color: Colors.white12, height: 1),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    onSubmitted: (_) => unawaited(_sendMessage()),
                    decoration: InputDecoration(
                      hintText: 'Say something to the world...',
                      hintStyle: const TextStyle(color: Colors.white24),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.05),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle),
                  child: IconButton(
                    onPressed: () => unawaited(_sendMessage()),
                    icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
