import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
      final displayName = user.displayName ?? user.email ?? 'Utilisateur';

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
        // Seed 'Autre' at a high order so custom categories appear before it
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
      setState(() => _error = 'Erreur lors de la création : $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _joinGroup() async {
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
        setState(() => _error = 'Code invalide. Vérifiez et réessayez.');
        return;
      }

      final groupRef = snap.docs.first.reference;
      final user = widget.user;
      final displayName = user.displayName ?? user.email ?? 'Utilisateur';

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
      setState(() => _error = 'Erreur lors de la jonction : $e');
    } finally {
      setState(() => _loading = false);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon groupe'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Se déconnecter',
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
                  const Text(
                    'Bienvenue !',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Créez un groupe ou rejoignez-en un existant.',
                    style: TextStyle(color: Colors.black54),
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
                  const Text(
                    'Créer un groupe',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _groupNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nom du groupe',
                      border: OutlineInputBorder(),
                      hintText: 'Ex : Famille Dupont',
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _createGroup,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('Créer', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Divider(),
                  const SizedBox(height: 24),
                  const Text(
                    'Rejoindre un groupe',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _groupCodeController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: 'Code à 6 caractères',
                      border: OutlineInputBorder(),
                      hintText: 'Ex : ABC123',
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _joinGroup,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'Rejoindre',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
