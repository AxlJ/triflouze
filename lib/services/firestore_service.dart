import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense.dart';
import '../models/category.dart';

class FirestoreService {
  final String groupId;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  FirestoreService(this.groupId);

  CollectionReference<Map<String, dynamic>> get _expensesRef =>
      _db.collection('groups').doc(groupId).collection('expenses');

  CollectionReference<Map<String, dynamic>> get _categoriesRef =>
      _db.collection('groups').doc(groupId).collection('categories');

  String generateExpenseId() => _expensesRef.doc().id;

  String generateCategoryId() => _categoriesRef.doc().id;

  Stream<List<Expense>> watchExpenses() {
    return _expensesRef
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(_expenseFromDoc).toList());
  }

  Stream<List<Category>> watchCategories() {
    return _categoriesRef
        .orderBy('order')
        .snapshots()
        .map((snap) => snap.docs.map(_categoryFromDoc).toList());
  }

  Future<void> addExpense(Expense expense) {
    return _expensesRef.doc(expense.id).set(_expenseToMap(expense));
  }

  Future<void> updateExpense(Expense expense) {
    return _expensesRef.doc(expense.id).update(_expenseToMap(expense));
  }

  Future<void> deleteExpense(String id) {
    return _expensesRef.doc(id).delete();
  }

  Future<void> deleteCategory(String id) {
    return _categoriesRef.doc(id).delete();
  }

  Future<void> deleteForMember(String name) {
    return _db.collection('groups').doc(groupId).update({
      'forMembers': FieldValue.arrayRemove([name]),
    });
  }

  /// Corrige le displayName de l'utilisateur courant dans le document groupe
  /// si ce qui est stocké en Firestore diffère du vrai displayName Auth.
  Future<void> ensureMemberDisplayName(String uid, String displayName) async {
    if (displayName.isEmpty) return;
    final docRef = _db.collection('groups').doc(groupId);
    final doc = await docRef.get();
    if (!doc.exists) return;

    final rawMembers = (doc.data()!['members'] as List<dynamic>)
        .map((m) => Map<String, dynamic>.from(m as Map))
        .toList();

    final idx = rawMembers.indexWhere((m) => m['uid'] == uid);
    if (idx < 0) return;

    final storedName = rawMembers[idx]['displayName'] as String? ?? '';
    if (storedName == displayName) return; // déjà correct

    rawMembers[idx] = {...rawMembers[idx], 'displayName': displayName};

    // Corriger members array + forMembers en deux passes (arrayRemove/arrayUnion
    // ne peuvent pas être combinés dans le même update avec un champ ordinaire)
    await docRef.update({
      'members': rawMembers,
      if (storedName.isNotEmpty) 'forMembers': FieldValue.arrayRemove([storedName]),
    });
    await docRef.update({
      'forMembers': FieldValue.arrayUnion([displayName]),
    });
  }

  // ── Gestion du groupe ────────────────────────────────────────────────────────

  /// Supprime le groupe et toutes ses sous-collections (dépenses + catégories).
  Future<void> deleteGroup() async {
    final groupRef = _db.collection('groups').doc(groupId);
    final expenses = await groupRef.collection('expenses').get();
    final categories = await groupRef.collection('categories').get();
    final allDocs = [...expenses.docs, ...categories.docs];

    // Firestore batch : max 500 écritures
    for (var i = 0; i < allDocs.length; i += 499) {
      final batch = _db.batch();
      for (final doc in allDocs.skip(i).take(499)) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
    await groupRef.delete();
  }

  /// Retire l'utilisateur du groupe.
  /// Si c'était l'admin, le plus ancien membre restant devient admin.
  Future<void> leaveGroup(String uid, String displayName) async {
    final groupRef = _db.collection('groups').doc(groupId);
    final snap = await groupRef.get();
    if (!snap.exists) return;

    final data = snap.data()!;
    final members = (data['members'] as List<dynamic>)
        .map((m) => Map<String, dynamic>.from(m as Map))
        .toList();

    final remaining = members.where((m) => m['uid'] != uid).toList();

    final currentAdminUid =
        data['adminUid'] as String? ?? data['createdBy'] as String? ?? '';

    final updates = <String, dynamic>{
      'members': remaining,
      'memberUids': FieldValue.arrayRemove([uid]),
      'forMembers': FieldValue.arrayRemove([displayName]),
    };

    if (currentAdminUid == uid && remaining.isNotEmpty) {
      // Trier par joinedAt croissant → le premier est le plus ancien
      remaining.sort((a, b) {
        final aTs = a['joinedAt'];
        final bTs = b['joinedAt'];
        final aTime = aTs is Timestamp ? aTs.millisecondsSinceEpoch : 0;
        final bTime = bTs is Timestamp ? bTs.millisecondsSinceEpoch : 0;
        return aTime.compareTo(bTime);
      });
      updates['adminUid'] = remaining.first['uid'];
    }

    await groupRef.update(updates);
  }

  /// Transfère le rôle d'administrateur à un autre membre.
  Future<void> transferAdmin(String newAdminUid) {
    return _db.collection('groups').doc(groupId).update({
      'adminUid': newAdminUid,
    });
  }

  /// Retire un membre authentifié du groupe (kick).
  /// Il reste dans forMembers et devient simple bénéficiaire.
  Future<void> removeMemberFromGroup(String uid) async {
    final groupRef = _db.collection('groups').doc(groupId);
    final snap = await groupRef.get();
    if (!snap.exists) return;

    final data = snap.data()!;
    final members = (data['members'] as List<dynamic>)
        .map((m) => Map<String, dynamic>.from(m as Map))
        .toList();

    final newMembers = members.where((m) => m['uid'] != uid).toList();

    await groupRef.update({
      'members': newMembers,
      'memberUids': FieldValue.arrayRemove([uid]),
      // forMembers intentionnellement non modifié : le membre devient bénéficiaire
    });
  }

  /// Supprime un bénéficiaire du groupe ET le retire de toutes les dépenses.
  /// Une dépense peut ainsi se retrouver avec 0 bénéficiaires.
  Future<void> removeBeneficiary(String name) async {
    final groupRef = _db.collection('groups').doc(groupId);

    // 1. Retirer du groupe
    await groupRef.update({
      'forMembers': FieldValue.arrayRemove([name]),
    });

    // 2. Retirer de toutes les dépenses qui le mentionnent
    final snap = await _expensesRef
        .where('forMembers', arrayContains: name)
        .get();

    if (snap.docs.isEmpty) return;

    for (var i = 0; i < snap.docs.length; i += 499) {
      final batch = _db.batch();
      for (final doc in snap.docs.skip(i).take(499)) {
        batch.update(doc.reference, {
          'forMembers': FieldValue.arrayRemove([name]),
        });
      }
      await batch.commit();
    }
  }

  Future<void> addForMember(String name) {
    return _db.collection('groups').doc(groupId).update({
      'forMembers': FieldValue.arrayUnion([name]),
    });
  }

  Future<void> addCategory(Category category, {int order = 0}) {
    return _categoriesRef.doc(category.id).set({
      'id': category.id,
      'name': category.name,
      'icon': category.icon,
      'order': order,
    });
  }

  Map<String, dynamic> _expenseToMap(Expense e) => {
    'id': e.id,
    'title': e.title,
    'amount': e.amount,
    'currency': e.currency,
    'category': e.category,
    'forMembers': e.forMembers,
    'date': Timestamp.fromDate(e.date),
    'tags': e.tags,
    'comment': e.comment,
    'addedBy': e.addedBy,
    'updatedAt': FieldValue.serverTimestamp(),
  };

  Expense _expenseFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final m = doc.data();
    return Expense(
      id: m['id'] as String,
      title: m['title'] as String,
      amount: (m['amount'] as num).toDouble(),
      currency: m['currency'] as String,
      category: m['category'] as String,
      forMembers: List<String>.from(m['forMembers'] as List),
      date: (m['date'] as Timestamp).toDate(),
      tags: List<String>.from(m['tags'] as List),
      comment: m['comment'] as String? ?? '',
      addedBy: m['addedBy'] as String? ?? '',
    );
  }

  Category _categoryFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final m = doc.data();
    return Category(
      id: m['id'] as String,
      name: m['name'] as String,
      icon: m['icon'] as String,
    );
  }
}
