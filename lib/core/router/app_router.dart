import 'package:go_router/go_router.dart';

import '../../presentation/pages/splash/splash_page.dart';
import '../../presentation/pages/home/home_page.dart';
import '../../presentation/pages/map/han_map_page.dart';
import '../../presentation/pages/map/widgets/location_detail_page.dart';
import '../../presentation/pages/browse/zhou_list_page.dart';
import '../../presentation/pages/browse/jun_list_page.dart';
import '../../presentation/pages/browse/xian_list_page.dart';
import '../../presentation/pages/search/search_page.dart';
import '../../presentation/pages/figures/figures_list_page.dart';
import '../../presentation/pages/figures/figure_detail_page.dart';
import '../../presentation/pages/routes/routes_list_page.dart';
import '../../presentation/pages/routes/route_detail_page.dart';
import '../../presentation/pages/routes/create_route_page.dart';
import '../../presentation/pages/daily_history/daily_history_page.dart';
import '../../presentation/pages/favorites/favorites_page.dart';
import '../../presentation/pages/favorites/browse_history_page.dart';
import '../../domain/entities/ancient_location.dart';

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
      builder: (context, state) {
        return const HanMapPage();
      },
    ),
    GoRoute(
      path: '/location/:id',
      builder: (context, state) {
        final location = state.extra as AncientLocation;
        return LocationDetailPage(location: location);
      },
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
    GoRoute(
      path: '/figures',
      builder: (context, state) => const FiguresListPage(),
      routes: [
        GoRoute(
          path: ':id',
          builder: (context, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
            return FigureDetailPage(figureId: id);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/routes',
      builder: (context, state) => const RoutesListPage(),
      routes: [
        GoRoute(
          path: ':id',
          builder: (context, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
            return RouteDetailPage(routeId: id);
          },
        ),
        GoRoute(
          path: 'create',
          builder: (context, state) => const CreateRoutePage(),
        ),
      ],
    ),
    GoRoute(
      path: '/daily-history',
      builder: (context, state) => const DailyHistoryPage(),
    ),
    GoRoute(
      path: '/favorites',
      builder: (context, state) => const FavoritesPage(),
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const BrowseHistoryPage(),
    ),
  ],
);
