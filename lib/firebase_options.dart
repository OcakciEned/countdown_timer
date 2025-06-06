// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyBS7iX82Btql0E3Y5LyOWpKuiJjuJT1N9E',
    appId: '1:640208226388:web:c785c2c46e0c69c45fc5c1',
    messagingSenderId: '640208226388',
    projectId: 'countdowntimer-cb736',
    authDomain: 'countdowntimer-cb736.firebaseapp.com',
    storageBucket: 'countdowntimer-cb736.firebasestorage.app',
    measurementId: 'G-FX07YCW74X',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBm1lPPCKzqD5f34QENY_p0Mc9KjNeVYDI',
    appId: '1:640208226388:android:85d3b73139277e1e5fc5c1',
    messagingSenderId: '640208226388',
    projectId: 'countdowntimer-cb736',
    storageBucket: 'countdowntimer-cb736.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBS7iX82Btql0E3Y5LyOWpKuiJjuJT1N9E',
    appId: '1:640208226388:web:c3bf75d87c66eaa55fc5c1',
    messagingSenderId: '640208226388',
    projectId: 'countdowntimer-cb736',
    authDomain: 'countdowntimer-cb736.firebaseapp.com',
    storageBucket: 'countdowntimer-cb736.firebasestorage.app',
    measurementId: 'G-3W96BPW6D3',
  );
}
