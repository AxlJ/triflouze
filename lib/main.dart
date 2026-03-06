import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:triflouze/l10n/app_localizations.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'services/user_service.dart';
import 'screens/login_screen.dart';
import 'screens/group_screen.dart';
import 'screens/home_screen.dart';
import 'theme/triflouze_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Triflouze',
      theme: TriflouzeTheme.light,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr'),
        Locale('en'),
      ],
      home: StreamBuilder<User?>(
        stream: AuthService().authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          final user = snapshot.data;
          if (user == null) return const LoginScreen();
          NotificationService.init(user.uid);
          return _GroupRouter(user: user);
        },
      ),
    );
  }
}

class _GroupRouter extends StatefulWidget {
  final User user;

  const _GroupRouter({required this.user});

  @override
  State<_GroupRouter> createState() => _GroupRouterState();
}

class _GroupRouterState extends State<_GroupRouter> {
  /// Groupe actuellement affiché (session). null = pas encore chargé.
  String? _activeGroupId;
  bool _loadingPrefs = true;

  @override
  void initState() {
    super.initState();
    UserService().getPrimaryGroupId(widget.user.uid).then((id) {
      if (mounted) {
        setState(() {
          _activeGroupId = id; // peut être null → fallback docs.first
          _loadingPrefs = false;
        });
      }
    });
  }

  void _switchToGroup(String groupId) {
    setState(() => _activeGroupId = groupId);
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingPrefs) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('groups')
          .where('memberUids', arrayContains: widget.user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return GroupScreen(user: widget.user);
        }

        // Sélectionne le groupe actif; fallback sur docs.first si invalide
        QueryDocumentSnapshot<Map<String, dynamic>> doc;
        if (_activeGroupId != null) {
          final matching = docs.where((d) => d.id == _activeGroupId).toList();
          if (matching.isNotEmpty) {
            doc = matching.first;
          } else {
            // activeGroupId invalide (groupe supprimé / accès révoqué) → reset
            doc = docs.first;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() => _activeGroupId = docs.first.id);
            });
          }
        } else {
          doc = docs.first;
          // Premier chargement sans primaryGroupId : on mémorise docs.first
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _activeGroupId = docs.first.id);
          });
        }

        final data = doc.data();
        final memberUids = data['memberUids'] != null
            ? List<String>.from(data['memberUids'] as List)
            : <String>[];

        final currentDisplayName =
            widget.user.displayName?.isNotEmpty == true
                ? widget.user.displayName!
                : widget.user.email ?? '';

        final members = (data['members'] as List<dynamic>).map((m) {
          final memberData = m as Map<String, dynamic>;
          if (memberData['uid'] == widget.user.uid) return currentDisplayName;
          return (memberData['displayName'] as String?) ?? '';
        }).where((n) => n.isNotEmpty).toList();

        final storedForMembers = data['forMembers'] != null
            ? List<String>.from(data['forMembers'] as List)
            : <String>[];
        final forMembersSet = <String>{...members};
        for (final m in storedForMembers) {
          if (m.isNotEmpty) forMembersSet.add(m);
        }

        // Calcul du groupe principal courant (pour le passer à HomeScreen)
        // On utilise _activeGroupId ou docs.first comme fallback
        final currentGroupId = doc.id;

        return HomeScreen(
          user: widget.user,
          groupId: currentGroupId,
          groupName: data['name'] as String,
          groupCode: data['code'] as String,
          members: members,
          forMembers: forMembersSet.toList(),
          memberUids: memberUids,
          onSwitchGroup: _switchToGroup,
        );
      },
    );
  }
}
