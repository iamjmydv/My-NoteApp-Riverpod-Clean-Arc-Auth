import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {

  //Ensures the flutter engine and widget binding are fully initialized before calling any plugin code.
  //Required whenever 'main' does have async work prior to  'runApp' (e.g Firebase setup)
  WidgetsFlutterBinding.ensureInitialized();
  // Boots the Firebase SDK using the platforms deafult configuration (google-services.json)
  await Firebase.initializeApp();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My NoteApp',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue)),
      home: const Scaffold(),
    );
  }
}

