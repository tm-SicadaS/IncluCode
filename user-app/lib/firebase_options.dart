import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;


class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return android; // Force android config for this MVP
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAu_ucV0hJoCXwDkO0qQLbsMiQ_HYqmavo',
    appId: '1:454893761761:web:8b98280776555812d4f3a0',
    messagingSenderId: '454893761761',
    projectId: 'buscue',
    databaseURL: 'https://buscue-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'buscue.firebasestorage.app',
  );
}
