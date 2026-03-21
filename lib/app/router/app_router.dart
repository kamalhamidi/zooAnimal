import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/home_screen.dart';
import '../../features/guess_animal/guess_screen.dart';
import '../../features/puzzle/puzzle_screen.dart';
import '../../features/baby_mode/baby_screen.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: '/guess',
        name: 'guess',
        pageBuilder: (context, state) {
          final difficulty = state.uri.queryParameters['difficulty'] ?? 'easy';
          final isDaily = state.uri.queryParameters['daily'] == 'true';
          return CustomTransitionPage(
            key: state.pageKey,
            child: GuessScreen(
              difficulty: difficulty,
              isDaily: isDaily,
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/puzzle',
        name: 'puzzle',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const PuzzleScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/baby',
        name: 'baby',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const BabyScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return ScaleTransition(
              scale: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutBack,
              ),
              child: child,
            );
          },
        ),
      ),
    ],
  );
}
