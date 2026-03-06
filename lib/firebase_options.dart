// IMPORTANT: Ce fichier est généré automatiquement par FlutterFire CLI.
// Exécutez `flutterfire configure` pour le générer avec vos vraies valeurs.
//
//   dart pub global activate flutterfire_cli
//   flutterfire configure
//
// Ce fichier placeholder permet à l'app de compiler mais ne fonctionnera pas
// sans les vraies clés Firebase.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'REPLACE_WITH_YOUR_API_KEY',
    appId: 'REPLACE_WITH_YOUR_APP_ID',
    messagingSenderId: 'REPLACE_WITH_YOUR_SENDER_ID',
    projectId: 'REPLACE_WITH_YOUR_PROJECT_ID',
    authDomain: 'REPLACE_WITH_YOUR_AUTH_DOMAIN',
    storageBucket: 'REPLACE_WITH_YOUR_STORAGE_BUCKET',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB38dPB_F6KKHXP1kHWa6amFuDuSEJK3HY',
    appId: '1:257139882035:android:712d1b5ec009a2d6df8b46',
    messagingSenderId: '257139882035',
    projectId: 'ourexpenses-d23d2',
    storageBucket: 'ourexpenses-d23d2.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDI74-EaQNoioGGtEqnVk68DI_bzg9yJvk',
    appId: '1:257139882035:ios:1c953d855810c73adf8b46',
    messagingSenderId: '257139882035',
    projectId: 'ourexpenses-d23d2',
    storageBucket: 'ourexpenses-d23d2.firebasestorage.app',
    iosBundleId: 'com.triflouze.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'REPLACE_WITH_YOUR_API_KEY',
    appId: 'REPLACE_WITH_YOUR_APP_ID',
    messagingSenderId: 'REPLACE_WITH_YOUR_SENDER_ID',
    projectId: 'REPLACE_WITH_YOUR_PROJECT_ID',
    storageBucket: 'REPLACE_WITH_YOUR_STORAGE_BUCKET',
    iosBundleId: 'REPLACE_WITH_YOUR_BUNDLE_ID',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'REPLACE_WITH_YOUR_API_KEY',
    appId: 'REPLACE_WITH_YOUR_APP_ID',
    messagingSenderId: 'REPLACE_WITH_YOUR_SENDER_ID',
    projectId: 'REPLACE_WITH_YOUR_PROJECT_ID',
    authDomain: 'REPLACE_WITH_YOUR_AUTH_DOMAIN',
    storageBucket: 'REPLACE_WITH_YOUR_STORAGE_BUCKET',
  );
}