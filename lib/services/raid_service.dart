import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:synchronized/synchronized.dart';

class RaidService {
  static const String _collection = 'events';
  static const String _document = 'dragon_raid';
  static const String _slotsField = 'slots_filled';
  static const String _maxField = 'max_slots';
  static const int defaultMaxSlots = 15;

  final FirebaseFirestore _firestore;
  final Lock _lock = Lock();

  RaidService({required FirebaseFirestore firestore}) : _firestore = firestore;

  Future<bool> joinRaid({required String userId}) async {
    return _lock.synchronized<bool>(() async {
      final DocumentReference<Map<String, dynamic>> docRef = _firestore
          .collection(_collection)
          .doc(_document);

      try {
        return await _firestore.runTransaction<bool>((Transaction tx) async {
          final DocumentSnapshot<Map<String, dynamic>> snapshot = await tx.get(docRef);

          if (!snapshot.exists) {
            tx.set(docRef, <String, dynamic>{
              _slotsField: 1,
              _maxField: defaultMaxSlots,
            });
            return true;
          }

          final Map<String, dynamic> data = snapshot.data() ?? <String, dynamic>{};
          final int currentSlots = data[_slotsField] as int? ?? 0;
          final int maxAllowed = data[_maxField] as int? ?? defaultMaxSlots;

          if (currentSlots >= maxAllowed) {
            return false;
          }

          tx.update(docRef, <String, dynamic>{_slotsField: currentSlots + 1});
          return true;
        });
      } catch (e) {
        return false;
      }
    });
  }

  Stream<int> get filledSlotsStream => _firestore
      .collection(_collection)
      .doc(_document)
      .snapshots()
      .map(
        (DocumentSnapshot<Map<String, dynamic>> snap) =>
            snap.data()?[_slotsField] as int? ?? 0,
      );
}
