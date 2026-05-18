import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:project_aether/services/raid_service.dart';

void main() {
  group('RaidService Concurrency Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late RaidService raidService;

    setUp(() async {
      fakeFirestore = FakeFirebaseFirestore();
      raidService = RaidService(firestore: fakeFirestore);

      // Initialize the document
      await fakeFirestore.collection('events').doc('dragon_raid').set({
        'slots_filled': 0,
        'max_slots': 15,
      });
    });

    test(
      'Multiple concurrent joins should correctly update slot count',
      () async {
        // simulate 10 users joining at once
        final List<Future<bool>> joinRequests = List.generate(
          10,
          (i) => raidService.joinRaid(userId: 'user_$i'),
        );

        final List<bool> results = await Future.wait(joinRequests);

        // All should succeed as 10 < 15
        expect(results.every((success) => success), isTrue);

        // Verify the final count in Firestore
        final snapshot = await fakeFirestore
            .collection('events')
            .doc('dragon_raid')
            .get();
        expect(snapshot.data()?['slots_filled'], 10);
      },
    );

    test('Should not exceed max slots', () async {
      // Fill up the raid to 14
      await fakeFirestore.collection('events').doc('dragon_raid').update({
        'slots_filled': 14,
      });

      // Try 3 concurrent joins (only one should succeed)
      final List<Future<bool>> joinRequests = List.generate(
        3,
        (i) => raidService.joinRaid(userId: 'extra_user_$i'),
      );

      final List<bool> results = await Future.wait(joinRequests);

      // Exactly one should have worked
      final successCount = results.where((r) => r).length;
      expect(successCount, 1);

      // Final count should be exactly 15
      final snapshot = await fakeFirestore
          .collection('events')
          .doc('dragon_raid')
          .get();
      expect(snapshot.data()?['slots_filled'], 15);
    });
  });
}
