import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/core/router/app_router.dart';

void main() async {
  // Ensures the flutter engine and widget binding are fully initialized before
  // calling any plugin code. Required whenever 'main' does async work prior to
  // 'runApp' (e.g. Firebase setup).
  WidgetsFlutterBinding.ensureInitialized();

  // Boots the Firebase SDK using the platform's default configuration
  // (google-services.json).
  await Firebase.initializeApp();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    return MaterialApp.router(
      title: 'My NoteApp',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
