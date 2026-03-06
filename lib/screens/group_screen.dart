import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:triflouze/l10n/app_localizations.dart';
import '../models/category.dart';
import '../services/auth_service.dart';

class GroupScreen extends StatefulWidget {
  final User user;

  const GroupScreen({super.key, required this.user});

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  final _groupNameController = TextEditingController();
  final _groupCodeController = TextEditingController();
  bool _loading = false;
  String? _error;

  final _defaultCategories = [
    Category(id: '1',  name: 'Alimentation', icon: '🛒'),
    Category(id: '13', name: 'Courses',      icon: '🛍️'),
    Category(id: '9',  name: 'Transport',    icon: '🚗'),
    Category(id: '3',  name: 'Santé',        icon: '💊'),
    Category(id: '4',  name: 'Loisirs',      icon: '🎮'),
    Category(id: '5',  name: 'Restaurant',   icon: '🍽️'),
    Category(id: '7',  name: 'Vêtements',    icon: '👕'),
    Category(id: '8',  name: 'Café',         icon: '☕'),
    Category(id: '2',  name: 'Logement',     icon: '🏠'),
    Category(id: '10', name: 'Abonnement',   icon: '🔄'),
    Category(id: '11', name: 'Voyage',       icon: '✈️'),
    Category(id: '12', name: 'Facture',      icon: '🧾'),
    Category(id: '6',  name: 'Autre',        icon: '📦'),
  ];

  String _generateCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = Random.secure();
    return List.generate(6, (_) => chars[rnd.nextInt(chars.length)]).join();
  }

  Future<void> _createGroup() async {
    final l10n = AppLocalizations.of(context)!;
    final name = _groupNameController.text.trim();
    if (name.isEmpty) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final db = FirebaseFirestore.instance;
      final code = _generateCode();
      final groupRef = db.collection('groups').doc();
      final user = widget.user;
      final displayName = user.displayName ?? user.email ?? l10n.user;

      final batch = db.batch();

      batch.set(groupRef, {
        'name': name,
        'code': code,
        'createdBy': user.uid,
        'adminUid': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'members': [
          {
            'uid': user.uid,
            'displayName': displayName,
            'joinedAt': Timestamp.now(),
          },
        ],
        'memberUids': [user.uid],
        'forMembers': [displayName],
      });

      for (var i = 0; i < _defaultCategories.length; i++) {
        final cat = _defaultCategories[i];
        final catRef = groupRef.collection('categories').doc(cat.id);
        final order = cat.name == 'Autre' ? 9999 : i;
        batch.set(catRef, {
          'id': cat.id,
          'name': cat.name,
          'icon': cat.icon,
          'order': order,
        });
      }

      await batch.commit();
    } catch (e) {
      if (mounted) setState(() => _error = l10n.errorGroupCreation(e.toString()));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _joinGroup() async {
    final l10n = AppLocalizations.of(context)!;
    final code = _groupCodeController.text.trim().toUpperCase();
    if (code.isEmpty) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final db = FirebaseFirestore.instance;
      final snap = await db
          .collection('groups')
          .where('code', isEqualTo: code)
          .limit(1)
          .get();

      if (snap.docs.isEmpty) {
        if (mounted) setState(() => _error = l10n.errorInvalidCode);
        return;
      }

      final groupRef = snap.docs.first.reference;
      final user = widget.user;
      final displayName = user.displayName ?? user.email ?? l10n.user;

      await groupRef.update({
        'members': FieldValue.arrayUnion([
          {
            'uid': user.uid,
            'displayName': displayName,
            'joinedAt': Timestamp.now(),
          },
        ]),
        'memberUids': FieldValue.arrayUnion([user.uid]),
        'forMembers': FieldValue.arrayUnion([displayName]),
      });
    } catch (e) {
      if (mounted) setState(() => _error = l10n.errorGroupJoin(e.toString()));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    _groupCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myGroupTitle),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: l10n.logoutTooltip,
            onPressed: () => AuthService().signOut(),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.welcomeTitle,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.welcomeSubtitle,
                    style: const TextStyle(color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 40),
                  Text(
                    l10n.createGroupTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _groupNameController,
                    decoration: InputDecoration(
                      labelText: l10n.groupNameLabel,
                      border: const OutlineInputBorder(),
                      hintText: l10n.groupNameHint,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _createGroup,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(l10n.createButton, style: const TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Divider(),
                  const SizedBox(height: 24),
                  Text(
                    l10n.joinGroupTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _groupCodeController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      labelText: l10n.groupCodeLabel,
                      border: const OutlineInputBorder(),
                      hintText: l10n.groupCodeHint,
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _joinGroup,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        l10n.joinButton,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
