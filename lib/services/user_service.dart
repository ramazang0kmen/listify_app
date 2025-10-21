// lib/services/user_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

class UserService {
  UserService._();
  static final UserService instance = UserService._();

  final _db = FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _col => _db.collection('users');
  Future<String> createUser({
    required String email,
    String? displayName,
    bool isDeleted = false,
  }) async {
    final ref = await _col.add({
      'email': email,
      'displayName': displayName,
      'isDeleted': isDeleted,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await ref.set({'uid': ref.id}, SetOptions(merge: true));
    return ref.id;
  }

  AppUser _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw StateError('Kullanıcı bulunamadı: ${doc.id}');
    }

    DateTime? createdAt;

    final rawCreated = data['createdAt'];
    if (rawCreated is Timestamp) {
      createdAt = rawCreated.toDate();
    } else if (rawCreated is String) {
      createdAt = DateTime.tryParse(rawCreated);
    } else {
      createdAt = null;
    }

    return AppUser(
      uid: data['uid'] ?? doc.id,
      email: data['email'] ?? '',
      username: data['username'],
      profilePictureUrl: data['profilePictureUrl'],
      createdAt: createdAt,
      isDeleted: (data['isDeleted'] as bool?) ?? false,
    );
  }

  Future<AppUser?> getById(String docId) async {
    final doc = await _col.doc(docId).get();
    if (!doc.exists) return null;
    return _fromDoc(doc);
  }

  Future<AppUser?> getByEmail(String email) async {
    final q = await _col.where('email', isEqualTo: email).limit(1).get();
    if (q.docs.isEmpty) return null;
    return _fromDoc(q.docs.first);
  }

  Stream<AppUser?> watchById(String docId) {
    return _col.doc(docId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return _fromDoc(doc);
    });
  }

  Future<void> updateUser(
    String docId, {
    String? displayName,
    String? profilePictureUrl,
    bool? isDeleted,
  }) async {
    final data = <String, dynamic>{
      if (displayName != null) 'displayName': displayName,
      if (profilePictureUrl != null) 'profilePictureUrl': profilePictureUrl,
      if (isDeleted != null) 'isDeleted': isDeleted,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    await _col.doc(docId).set(data, SetOptions(merge: true));
  }

  Future<void> softDelete(String docId) => updateUser(docId, isDeleted: true);
}
