import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/pages/splash/splash_page.dart';
import '../../presentation/pages/home/home_page.dart';
import '../../presentation/pages/map/han_map_page.dart';
import '../../presentation/pages/browse/zhou_list_page.dart';
import '../../presentation/pages/browse/jun_list_page.dart';
import '../../presentation/pages/browse/xian_list_page.dart';
import '../../presentation/pages/search/search_page.dart';
import '../theme/app_colors.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/map',
      builder: (context, state) => const HanMapPage(),
    ),
    GoRoute(
      path: '/browse',
      builder: (context, state) => const ZhouListPage(),
      routes: [
        GoRoute(
          path: 'jun',
          builder: (context, state) {
            final parentId = state.uri.queryParameters['parentId'];
            return JunListPage(
              parentLocationId: int.tryParse(parentId ?? '') ?? 0,
            );
          },
        ),
        GoRoute(
          path: 'xian',
          builder: (context, state) {
            final parentId = state.uri.queryParameters['parentId'];
            return XianListPage(
              parentLocationId: int.tryParse(parentId ?? '') ?? 0,
            );
          },
        ),
      ],
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) => const SearchPage(),
    ),
  ],
);
