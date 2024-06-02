import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await enableFirestorePersistence();
  runApp(Home());
}

Future<void> enableFirestorePersistence() async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  firestore.settings = Settings(persistenceEnabled: true);
}
