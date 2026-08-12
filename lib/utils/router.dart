import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/home_screen.dart';
import '../screens/group_screen.dart';
import '../screens/split_screen.dart';
import '../screens/summary_screen.dart';
import '../screens/settings_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (_, __) => const HomeScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (_, __) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/group/:groupId',
      builder: (_, state) => GroupScreen(
        groupId: state.pathParameters['groupId']!,
      ),
      routes: [
        GoRoute(
          path: 'split/:splitId',
          builder: (_, state) => SplitScreen(
            groupId: state.pathParameters['groupId']!,
            splitId: state.pathParameters['splitId']!,
          ),
          routes: [
            GoRoute(
              path: 'summary',
              builder: (_, state) => SummaryScreen(
                groupId: state.pathParameters['groupId']!,
                splitId: state.pathParameters['splitId']!,
              ),
            ),
          ],
        ),
      ],
    ),
  ],
  errorBuilder: (_, state) => Scaffold(
    body: Center(
      child: Text('Page not found: ${state.error}'),
    ),
  ),
);
