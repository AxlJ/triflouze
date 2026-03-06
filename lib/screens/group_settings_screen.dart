import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triflouze/l10n/app_localizations.dart';
import '../models/category.dart';
import '../services/user_service.dart';
import '../services/firestore_service.dart';
import '../theme/triflouze_theme.dart';

class GroupSettingsScreen extends StatefulWidget {
  final User user;
  final String currentGroupId;
  final String primaryGroupId;
  final void Function(String groupId) onSwitchGroup;

  const GroupSettingsScreen({
    super.key,
    required this.user,
    required this.currentGroupId,
    required this.primaryGroupId,
    required this.onSwitchGroup,
  });

  @override
  State<GroupSettingsScreen> createState() => _GroupSettingsScreenState();
}

class _GroupSettingsScreenState extends State<GroupSettingsScreen> {
  final _groupNameController = TextEditingController();
  final _groupCodeController = TextEditingController();
  bool _creating = false;
  bool _joining = false;
  String? _error;

  late String _primaryGroupId;

  @override
  void initState() {
    super.initState();
    _primaryGroupId = widget.primaryGroupId;
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    _groupCodeController.dispose();
    super.dispose();
  }

  final _defaultCategories = [
    Category(id: '1',  name: 'Alimentation', icon: '🛒'),
    Category(id: '13', name: 'Courses',       icon: '🛍️'),
    Category(id: '9',  name: 'Transport',     icon: '🚗'),
    Category(id: '3',  name: 'Santé',         icon: '💊'),
    Category(id: '4',  name: 'Loisirs',       icon: '🎮'),
    Category(id: '5',  name: 'Restaurant',    icon: '🍽️'),
    Category(id: '7',  name: 'Vêtements',     icon: '👕'),
    Category(id: '8',  name: 'Café',          icon: '☕'),
    Category(id: '2',  name: 'Logement',      icon: '🏠'),
    Category(id: '10', name: 'Abonnement',    icon: '🔄'),
    Category(id: '11', name: 'Voyage',        icon: '✈️'),
    Category(id: '12', name: 'Facture',       icon: '🧾'),
    Category(id: '6',  name: 'Autre',         icon: '📦'),
  ];

  String _generateCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = Random.secure();
    return List.generate(6, (_) => chars[rnd.nextInt(chars.length)]).join();
  }

  Future<void> _createGroup() async {
    final l10n = AppLocalizations.of(context)!;
    final name = _groupNameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = l10n.errorEmptyGroupName);
      return;
    }
    setState(() { _creating = true; _error = null; });

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
          {'uid': user.uid, 'displayName': displayName, 'joinedAt': Timestamp.now()},
        ],
        'memberUids': [user.uid],
        'forMembers': [displayName],
      });

      for (var i = 0; i < _defaultCategories.length; i++) {
        final cat = _defaultCategories[i];
        final catRef = groupRef.collection('categories').doc(cat.id);
        batch.set(catRef, {
          'id': cat.id,
          'name': cat.name,
          'icon': cat.icon,
          'order': cat.name == 'Autre' ? 9999 : i,
        });
      }
      await batch.commit();
      _groupNameController.clear();
      if (mounted) setState(() => _error = null);
    } catch (e) {
      if (mounted) setState(() => _error = l10n.errorGroupCreation(e.toString()));
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  Future<void> _joinGroup() async {
    final l10n = AppLocalizations.of(context)!;
    final code = _groupCodeController.text.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() => _error = l10n.errorEmptyCode);
      return;
    }
    setState(() { _joining = true; _error = null; });

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
          {'uid': user.uid, 'displayName': displayName, 'joinedAt': Timestamp.now()},
        ]),
        'memberUids': FieldValue.arrayUnion([user.uid]),
        'forMembers': FieldValue.arrayUnion([displayName]),
      });
      _groupCodeController.clear();
    } catch (e) {
      if (mounted) setState(() => _error = l10n.errorGroupJoin(e.toString()));
    } finally {
      if (mounted) setState(() => _joining = false);
    }
  }

  Future<void> _setPrimary(String groupId) async {
    await UserService().setPrimaryGroupId(widget.user.uid, groupId);
    if (mounted) setState(() => _primaryGroupId = groupId);
  }

  void _switchGroup(String groupId) {
    widget.onSwitchGroup(groupId);
    Navigator.pop(context);
  }

  void _openManagementSheet(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ManagementSheet(
        user: widget.user,
        doc: doc,
        currentGroupId: widget.currentGroupId,
        onGroupLeft: () => Navigator.pop(context),
        onGroupDeleted: () => Navigator.pop(context),
        onAdminTransferred: () => setState(() {}),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: TriflouzeTheme.surface,
      appBar: AppBar(title: Text(l10n.groupsTitle)),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('groups')
            .where('memberUids', arrayContains: widget.user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          final docs = snapshot.data?.docs ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle(l10n.myGroupsSection),
                const SizedBox(height: 12),

                if (snapshot.connectionState == ConnectionState.waiting)
                  const Center(child: CircularProgressIndicator())
                else if (docs.isEmpty)
                  Text(l10n.noGroupsText,
                      style: GoogleFonts.nunito(color: TriflouzeTheme.textMedium))
                else
                  ...docs.map((doc) => _buildGroupTile(doc, l10n)),

                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 24),

                _sectionTitle(l10n.createGroupTitle),
                const SizedBox(height: 12),
                TextField(
                  controller: _groupNameController,
                  decoration: InputDecoration(
                    labelText: l10n.groupNameLabel,
                    hintText: l10n.groupNameHint,
                    prefixIcon: const Icon(Icons.group),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _creating ? null : _createGroup,
                    child: _creating
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(l10n.createGroupButton),
                  ),
                ),

                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 24),

                _sectionTitle(l10n.joinGroupTitle),
                const SizedBox(height: 12),
                TextField(
                  controller: _groupCodeController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    labelText: l10n.groupCodeLabel,
                    hintText: l10n.groupCodeHint,
                    prefixIcon: const Icon(Icons.link),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _joining ? null : _joinGroup,
                    child: _joining
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(l10n.joinButton),
                  ),
                ),

                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade700, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(_error!,
                              style: GoogleFonts.nunito(color: Colors.red.shade700, fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _sectionTitle(String title) => Text(
        title,
        style: GoogleFonts.nunito(
            fontSize: 16, fontWeight: FontWeight.w700, color: TriflouzeTheme.textDark),
      );

  Widget _buildGroupTile(QueryDocumentSnapshot<Map<String, dynamic>> doc, AppLocalizations l10n) {
    final data = doc.data();
    final groupId = doc.id;
    final name = data['name'] as String? ?? '(sans nom)';
    final memberCount = (data['memberUids'] as List<dynamic>?)?.length ?? 0;
    final isActive = groupId == widget.currentGroupId;
    final isPrimary = groupId == _primaryGroupId;
    final adminUid = data['adminUid'] as String? ?? data['createdBy'] as String? ?? '';
    final isAdmin = adminUid == widget.user.uid;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: isActive ? null : () => _switchGroup(groupId),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isActive ? TriflouzeTheme.primary : TriflouzeTheme.border,
              width: isActive ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
          child: Row(
            children: [
              // Icône groupe
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isActive
                      ? TriflouzeTheme.primary.withValues(alpha: 0.12)
                      : TriflouzeTheme.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.group,
                    color: isActive ? TriflouzeTheme.primary : TriflouzeTheme.textMedium,
                    size: 20),
              ),
              const SizedBox(width: 10),

              // Infos (tout ce qui peut être long → Expanded)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.nunito(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: TriflouzeTheme.textDark),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 5,
                      runSpacing: 4,
                      children: [
                        Text(
                          l10n.memberCount(memberCount),
                          style: GoogleFonts.nunito(
                              fontSize: 12, color: TriflouzeTheme.textMedium),
                        ),
                        if (isAdmin)
                          _badge(l10n.adminBadge, TriflouzeTheme.secondary),
                        if (isActive)
                          _badge(l10n.activeBadge, TriflouzeTheme.primary),
                        if (isPrimary)
                          _badge(l10n.primaryBadge, TriflouzeTheme.accent,
                              textColor: TriflouzeTheme.textDark),
                      ],
                    ),
                  ],
                ),
              ),

              // Actions — largeur fixe, jamais en overflow
              IconButton(
                icon: Icon(
                  isPrimary ? Icons.star : Icons.star_border,
                  color: isPrimary ? TriflouzeTheme.accent : TriflouzeTheme.border,
                  size: 22,
                ),
                tooltip: isPrimary ? l10n.primaryTooltip : l10n.setPrimaryTooltip,
                onPressed: isPrimary ? null : () => _setPrimary(groupId),
              ),
              IconButton(
                icon: Icon(Icons.more_vert, color: TriflouzeTheme.textMedium),
                tooltip: l10n.manageGroupTooltip,
                onPressed: () => _openManagementSheet(doc),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badge(String label, Color bg, {Color textColor = Colors.white}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
        child: Text(label,
            style: GoogleFonts.nunito(
                fontSize: 11, fontWeight: FontWeight.w700, color: textColor)),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom sheet de gestion du groupe
// ─────────────────────────────────────────────────────────────────────────────

class _ManagementSheet extends StatefulWidget {
  final User user;
  final QueryDocumentSnapshot<Map<String, dynamic>> doc;
  final String currentGroupId;
  final VoidCallback onGroupLeft;
  final VoidCallback onGroupDeleted;
  final VoidCallback onAdminTransferred;

  const _ManagementSheet({
    required this.user,
    required this.doc,
    required this.currentGroupId,
    required this.onGroupLeft,
    required this.onGroupDeleted,
    required this.onAdminTransferred,
  });

  @override
  State<_ManagementSheet> createState() => _ManagementSheetState();
}

class _ManagementSheetState extends State<_ManagementSheet> {
  bool _loading = false;

  Map<String, dynamic> get _data => widget.doc.data();
  String get _groupId => widget.doc.id;
  String get _groupName => _data['name'] as String? ?? '(sans nom)';
  String get _code => _data['code'] as String? ?? '';
  String get _adminUid =>
      _data['adminUid'] as String? ?? _data['createdBy'] as String? ?? '';
  bool get _isAdmin => _adminUid == widget.user.uid;

  List<Map<String, dynamic>> get _members {
    final raw = (_data['members'] as List<dynamic>? ?? [])
        .map((m) => Map<String, dynamic>.from(m as Map))
        .toList();
    // Admin en premier, puis par date d'adhésion
    raw.sort((a, b) {
      if (a['uid'] == _adminUid) return -1;
      if (b['uid'] == _adminUid) return 1;
      final aTs = a['joinedAt'];
      final bTs = b['joinedAt'];
      final aTime = aTs is Timestamp ? aTs.millisecondsSinceEpoch : 0;
      final bTime = bTs is Timestamp ? bTs.millisecondsSinceEpoch : 0;
      return aTime.compareTo(bTime);
    });
    return raw;
  }

  /// Bénéficiaires non-authentifiés : dans forMembers mais pas dans members.
  List<String> get _customBeneficiaries {
    final authNames = _members
        .map((m) => m['displayName'] as String? ?? '')
        .where((n) => n.isNotEmpty)
        .toSet();
    final forMembers = (_data['forMembers'] as List<dynamic>? ?? [])
        .map((m) => m as String)
        .toList();
    return (forMembers.where((n) => !authNames.contains(n)).toList()..sort());
  }

  String get _myDisplayName {
    for (final m in _members) {
      if (m['uid'] == widget.user.uid) {
        return m['displayName'] as String? ?? '';
      }
    }
    return widget.user.displayName ?? widget.user.email ?? '';
  }

  // ── Transférer l'admin ──────────────────────────────────────────────────────

  Future<void> _transferAdmin(String newAdminUid, String newAdminName) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.transferAdminTitle),
        content: Text(l10n.transferAdminMessage(newAdminName)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel)),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.transferButton)),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _loading = true);
    try {
      await FirestoreService(_groupId).transferAdmin(newAdminUid);
      if (mounted) {
        widget.onAdminTransferred();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.errorPrefix(e.toString()))));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Retirer un membre authentifié ───────────────────────────────────────────

  Future<void> _kickMember(String uid, String name) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.removeFromGroupTitle),
        content: Text(l10n.removeFromGroupMessage(name)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.removeButton, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _loading = true);
    try {
      await FirestoreService(_groupId).removeMemberFromGroup(uid);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.errorPrefix(e.toString()))));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Supprimer un bénéficiaire ────────────────────────────────────────────────

  Future<void> _removeBeneficiary(String name) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.removeBeneficiaryTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.removeBeneficiaryConfirm(name)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: Colors.orange.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.removeBeneficiaryWarning(name),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _loading = true);
    try {
      await FirestoreService(_groupId).removeBeneficiary(name);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.errorPrefix(e.toString()))));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Quitter le groupe ───────────────────────────────────────────────────────

  Future<void> _leaveGroup() async {
    final l10n = AppLocalizations.of(context)!;
    final members = _members;
    final remaining = members.where((m) => m['uid'] != widget.user.uid).toList();
    final isLastMember = remaining.isEmpty;

    String message;
    if (isLastMember) {
      message = l10n.leaveGroupLastMember;
    } else if (_isAdmin) {
      remaining.sort((a, b) {
        final aTs = a['joinedAt'];
        final bTs = b['joinedAt'];
        final aTime = aTs is Timestamp ? aTs.millisecondsSinceEpoch : 0;
        final bTime = bTs is Timestamp ? bTs.millisecondsSinceEpoch : 0;
        return aTime.compareTo(bTime);
      });
      final nextAdminName = remaining.first['displayName'] as String? ?? l10n.user;
      message = l10n.leaveGroupAdminMessage(nextAdminName);
    } else {
      message = l10n.leaveGroupConfirm(_groupName);
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.leaveGroupTitle),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              isLastMember ? l10n.delete : l10n.leaveButton,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _loading = true);
    try {
      if (isLastMember) {
        await FirestoreService(_groupId).deleteGroup();
      } else {
        await FirestoreService(_groupId).leaveGroup(widget.user.uid, _myDisplayName);
      }
      if (mounted) {
        Navigator.pop(context); // ferme le sheet
        widget.onGroupLeft();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.errorPrefix(e.toString()))));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Supprimer le groupe ─────────────────────────────────────────────────────

  Future<void> _deleteGroup() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteGroupTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.deleteGroupConfirm(_groupName)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: Colors.red.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.deleteGroupWarning,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.deletePermanentlyButton),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _loading = true);
    try {
      await FirestoreService(_groupId).deleteGroup();
      if (mounted) {
        Navigator.pop(context); // ferme le sheet
        widget.onGroupDeleted();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.errorPrefix(e.toString()))));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final members = _members;
    final beneficiaries = _customBeneficiaries;
    final maxHeight = MediaQuery.of(context).size.height * 0.85;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Poignée
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: TriflouzeTheme.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Titre + code (non-scrollable)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _groupName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunito(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: TriflouzeTheme.textDark),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: TriflouzeTheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: TriflouzeTheme.border),
                  ),
                  child: Text(
                    _code,
                    style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        letterSpacing: 2,
                        color: TriflouzeTheme.textMedium),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Contenu scrollable (membres + bénéficiaires)
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section membres authentifiés
                  _sheetSectionTitle(l10n.membersSection),
                  const SizedBox(height: 6),
                  ...members.map((m) => _memberTile(m, l10n)),

                  // Section bénéficiaires custom
                  if (beneficiaries.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _sheetSectionTitle(l10n.beneficiariesSection),
                    const SizedBox(height: 6),
                    ...beneficiaries.map((name) => _beneficiaryTile(name, l10n)),
                  ],
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          const Divider(height: 1),
          const SizedBox(height: 12),

          // Actions fixes en bas
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: CircularProgressIndicator(),
            )
          else
            Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      onPressed: _leaveGroup,
                      icon: const Icon(Icons.exit_to_app, size: 18),
                      label: Text(l10n.leaveGroupButton),
                    ),
                  ),
                  if (_isAdmin) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _deleteGroup,
                        icon: const Icon(Icons.delete_forever, size: 18),
                        label: Text(l10n.deleteGroupButton),
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _sheetSectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Text(
          title,
          style: GoogleFonts.nunito(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: TriflouzeTheme.textMedium,
              letterSpacing: 0.5),
        ),
      );

  Widget _beneficiaryTile(String name, AppLocalizations l10n) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: TriflouzeTheme.surface,
            child: Text(
              initial,
              style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: TriflouzeTheme.textMedium),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: TriflouzeTheme.textDark),
            ),
          ),
          if (_isAdmin)
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
              tooltip: l10n.deleteBeneficiaryTooltip(name),
              onPressed: () => _removeBeneficiary(name),
            ),
        ],
      ),
    );
  }

  Widget _memberTile(Map<String, dynamic> member, AppLocalizations l10n) {
    final uid = member['uid'] as String? ?? '';
    final name = member['displayName'] as String? ?? '?';
    final isThisAdmin = uid == _adminUid;
    final isMe = uid == widget.user.uid;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: isThisAdmin
                ? TriflouzeTheme.secondary.withValues(alpha: 0.15)
                : TriflouzeTheme.surface,
            child: Text(
              initial,
              style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: isThisAdmin
                      ? TriflouzeTheme.secondary
                      : TriflouzeTheme.textMedium),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$name${isMe ? ' (${l10n.meSuffix})' : ''}',
              style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: TriflouzeTheme.textDark),
            ),
          ),
          if (isThisAdmin)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: TriflouzeTheme.secondary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: TriflouzeTheme.secondary.withValues(alpha: 0.4)),
              ),
              child: Text(l10n.adminBadge,
                  style: GoogleFonts.nunito(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: TriflouzeTheme.secondary)),
            )
          else if (_isAdmin && !isMe) ...[
            // Transférer l'admin
            IconButton(
              icon: Icon(Icons.admin_panel_settings_outlined,
                  size: 20, color: TriflouzeTheme.textMedium),
              tooltip: l10n.transferTooltip(name),
              onPressed: () => _transferAdmin(uid, name),
            ),
            // Retirer du groupe (devient bénéficiaire)
            IconButton(
              icon: const Icon(Icons.person_remove_outlined,
                  size: 20, color: Colors.red),
              tooltip: l10n.kickTooltip(name),
              onPressed: () => _kickMember(uid, name),
            ),
          ],
        ],
      ),
    );
  }
}
