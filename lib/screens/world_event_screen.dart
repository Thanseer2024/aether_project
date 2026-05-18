import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/raid_service.dart';
import '../widgets/countdown_timer.dart';
import '../widgets/raid_card.dart';
import '../widgets/chat_card.dart';

class WorldEventScreen extends StatelessWidget {
  const WorldEventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final RaidService raidService = RaidService(firestore: FirebaseFirestore.instance);
    const String userId = 'local_user_123';

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF10102A),
        centerTitle: true,
        title: const Text(
          '⚔️  PROJECT AETHER',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: <Widget>[
            const CountdownTimer(),
            const SizedBox(height: 12),
            RaidCard(
              raidService: raidService,
              userId: userId,
            ),
            const SizedBox(height: 12),
            const Expanded(child: ChatCard()),
          ],
        ),
      ),
    );
  }
}
