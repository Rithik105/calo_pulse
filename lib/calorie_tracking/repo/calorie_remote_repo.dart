import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/calorie_entry.dart';

class CalorieRemmoteRepo {
  static const String _collectionName = 'calorie_entries';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _getCollection(String uid) =>
      _firestore.collection('users').doc(uid).collection(_collectionName);

  Stream<QuerySnapshot<Map<String, dynamic>>> getEntryStream(String uid) =>
      _getCollection(uid).snapshots();

  Future<void> upsertEntry(String uid, CalorieEntry entry) async {
    return _getCollection(uid).doc(entry.id).set(entry.toJson());
  }

  Future<void> softDelete(String uid, String entryId) {
    return _getCollection(uid).doc(entryId).update({
      'isDeleted': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
