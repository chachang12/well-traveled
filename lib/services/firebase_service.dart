import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class FirebaseOptions {
  static Future<void> initializeFirebase() async {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      await Firebase.initializeApp();
    } catch (e) {
      print('Firebase initialization error: $e');
    }
  }
}