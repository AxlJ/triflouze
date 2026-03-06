import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String?> getPrimaryGroupId(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data()?['primaryGroupId'] as String?;
  }

  Future<void> setPrimaryGroupId(String uid, String groupId) {
    return _db.collection('users').doc(uid).set(
      {'primaryGroupId': groupId},
      SetOptions(merge: true),
    );
  }
}
