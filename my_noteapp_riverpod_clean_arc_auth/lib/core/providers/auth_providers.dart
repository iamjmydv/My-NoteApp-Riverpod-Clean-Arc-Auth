import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


//-------------------- Firebase Auth -----------------------------------------------------------------------------------
final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance
);

//-------------------- Firebase Firestore -------------------------------------------------------------------------------
final firestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance
);