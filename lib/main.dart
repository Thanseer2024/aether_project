import 'package:flutter/material.dart';
import 'screens/world_event_screen.dart';

void main() {
  runApp(const AetherApp());
}

class AetherApp extends StatelessWidget {
  const AetherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project Aether',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const WorldEventScreen(),
    );
  }
}
