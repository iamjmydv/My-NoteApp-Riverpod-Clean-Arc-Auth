// The single source of truth for navigation. Built with go_router and exposed
// via Riverpod so any widget can read it with `ref.watch(goRouterProvider)`.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/core/providers/auth_providers.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/core/router/app_routes.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/auth/presentation/login/login_page.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/auth/presentation/sign_up/sign_up_page.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/note/domain/entities/note_entity.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/note/presentation/homepage_list_page.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/note/presentation/note_edit_page.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/auth/domain/entities/user_details_entity.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/profile/presentation/edit_profile_page.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/profile/presentation/user_profile_page.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authLocal = ref.watch(authLocalDataSourceProvider);

  return GoRouter(
    // Launch straight into the notes when a session is remembered, otherwise
    // start at the login page.
    initialLocation: authLocal.isLoggedIn()
        ? AppRoutes.notes
        : AppRoutes.login,
    // Guard every navigation against the persisted session flag:
    //  - signed out users can only reach the login / sign up pages;
    //  - signed in users are kept out of the login / sign up pages.
    redirect: (context, state) {
      final loggedIn = authLocal.isLoggedIn();
      final location = state.matchedLocation;
      final onAuthPage =
          location == AppRoutes.login || location == AppRoutes.signUp;

      if (!loggedIn) return onAuthPage ? null : AppRoutes.login;
      if (onAuthPage) return AppRoutes.notes;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        name: 'signUp',
        builder: (context, state) => const SignUpPage(),
      ),
      GoRoute(
        path: AppRoutes.notes,
        name: 'notes',
        builder: (context, state) => const HomepageListPage(),
      ),
      GoRoute(
        path: AppRoutes.noteCreate,
        name: 'noteCreate',
        builder: (context, state) => const NoteEditPage(),
      ),
      GoRoute(
        path: AppRoutes.noteEdit,
        name: 'noteEdit',
        builder: (context, state) =>
            NoteEditPage(note: state.extra as NoteEntity?),
      ),
      GoRoute(
        path: AppRoutes.userProfile,
        name: 'userProfile',
        builder: (context, state) => const UserProfilePage(),
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        name: 'editProfile',
        builder: (context, state) =>
            EditProfilePage(profile: state.extra as UserDetailsEntity?),
      ),
    ],
  );
});
