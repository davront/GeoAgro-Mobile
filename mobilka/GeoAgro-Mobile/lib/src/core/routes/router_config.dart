import 'package:agro_employee_public/src/feature/home/view/pages/natification_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../feature/fermers/view/pages/farmer_plantations_page.dart';
import '../../feature/fermers/view/pages/test_plantations_page.dart';
import '../../feature/edit/view/page/edit_page.dart';
import '../../feature/edit/view/page/edit_remote_page.dart';
import '../setting/setup.dart';
import '../../feature/page/blocked_page.dart';
import '../../feature/home/view/pages/home_page.dart';
import '../../feature/home/view/pages/recheck_page.dart';
import '../../feature/home/view/pages/approved_page.dart';
import '../../feature/home/view/pages/plantation_view_page.dart';
import '../../feature/home/view/pages/pending_page.dart';
import '../../feature/auth/view/pages/login_page.dart';
import '../../feature/fermers/view/pages/fermers_page.dart';
// import '../../feature/home/view/pages/description_page.dart';
import '../../feature/detail_page/view/pages/detail_page.dart';
import '../../feature/fermers/view/pages/fermer_create_page.dart';
import '../../feature/fermers/view/pages/fermer_edit_page.dart';
import '../../feature/google_map/view/pages/create_map_page.dart';
import '../../feature/google_map/view/pages/plantation_map_view_page.dart';
import '../../feature/fermers/view/pages/farmers_statistics_page.dart';
import '../../feature/profile/view/pages/devices_page.dart';
import '../../feature/queue/view/pages/queue_screen.dart';
import 'app_route_names.dart';
import '../../../dev/dev_menu_page.dart';

GlobalKey<NavigatorState> parentNavigatorKey = GlobalKey<NavigatorState>();

Page<dynamic> customEachTransitionAnimation(
    BuildContext context, GoRouterState state, Widget child) {
  return CustomTransitionPage<Object>(
    transitionsBuilder: (
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
    ) {
      var begin = const Offset(1.0, 0.0); // From right
      var end = Offset.zero;
      var tween = Tween(begin: begin, end: end);
      var offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
    child: child,
  );
}

@immutable
final class RouterConfigService {
  const RouterConfigService._();

  static final GoRouter blocRouter = GoRouter(
    navigatorKey: parentNavigatorKey,
    initialLocation: AppRouteNames.blocRoute,
    routes: [
      GoRoute(
        path: AppRouteNames.blocRoute,
        builder: (context, state) => const BlockedPage(),
      ),
    ],
  );

  /// Определяет начальный маршрут: нет токена → логин, иначе домой.
  static String get _initialLocation {
    if (accessToken == null) return AppRouteNames.login;
    return AppRouteNames.home;
  }

  static final GoRouter router = GoRouter(
    // debugLogDiagnostics: true,
    navigatorKey: parentNavigatorKey,
    initialLocation: _initialLocation,
    routes: <RouteBase>[
      // Dev Menu (only in debug mode)
      GoRoute(
        path: '/dev-menu',
        builder: (context, state) => const DevMenuPage(),
      ),

      // Login
      GoRoute(
        path: AppRouteNames.login,
        builder: (context, state) => const LoginPage(),
      ),

      // Home
      GoRoute(
        path: AppRouteNames.home,
        builder: (context, state) => const HomePage(),
        routes: [
          // Approved Plantations Page
          GoRoute(
            path: AppRouteNames.approvedPage,
            pageBuilder: (context, state) => customEachTransitionAnimation(
              context,
              state,
              const ApprovedPage(),
            ),
          ),
          // Pending (Ko'rib chiqilmoqda) Plantations Page
          GoRoute(
            path: AppRouteNames.pendingPage,
            pageBuilder: (context, state) => customEachTransitionAnimation(
              context,
              state,
              const PendingPage(),
            ),
          ),
          GoRoute(
            path: AppRouteNames.plantationView,
            pageBuilder: (context, state) => customEachTransitionAnimation(
              context,
              state,
              PlantationViewPage(id: state.extra as int),
            ),
          ),
          GoRoute(
            path: AppRouteNames.plantationMapView,
            pageBuilder: (context, state) => customEachTransitionAnimation(
              context,
              state,
              PlantationMapViewPage(plantationId: state.extra as int),
            ),
          ),
          // Recheck (Rejected) Plantations Page
          GoRoute(
            path: AppRouteNames.recheckPage,
            pageBuilder: (context, state) => customEachTransitionAnimation(
              context,
              state,
              const RecheckPage(),
            ),
          ),
          // Natifications
          GoRoute(
            path: AppRouteNames.natificationPage,
            pageBuilder: (context, state) => customEachTransitionAnimation(
                context, state, NatificationPage()),
          ),

          // Farmer List Page
          GoRoute(
            path: AppRouteNames.farmers,
            pageBuilder: (context, state) =>
                customEachTransitionAnimation(context, state, FermersPage()),
            routes: [
              // Create Farmer page
              GoRoute(
                path: AppRouteNames.createFarmers,
                pageBuilder: (context, state) => customEachTransitionAnimation(
                    context, state, FermerCreatePage()),
              ),

              // Edit Farmer page
              GoRoute(
                path: AppRouteNames.editFarmer,
                pageBuilder: (context, state) => customEachTransitionAnimation(
                    context,
                    state,
                    FermerEditPage(farmerId: state.extra as int)),
              ),

              // Farmer Plantations page
              GoRoute(
                path: AppRouteNames.farmerPlantations,
                pageBuilder: (context, state) {
                  final farmerId =
                      int.tryParse(state.uri.queryParameters['id'] ?? '0') ?? 0;
                  final farmerInn =
                      int.tryParse(state.uri.queryParameters['inn'] ?? '0') ??
                          0;
                  final farmerName =
                      state.uri.queryParameters['name'] ?? 'Fermer';
                  return customEachTransitionAnimation(
                    context,
                    state,
                    FarmerPlantationsPage(
                      farmerId:
                          farmerId, // Сохраняем для отображения, но не используем в API
                      farmerInn: farmerInn,
                      farmerName: farmerName,
                    ),
                  );
                },
              ),

              // Test Plantations page
              GoRoute(
                path: AppRouteNames.testPlantations,
                pageBuilder: (context, state) {
                  final farmerInn =
                      int.tryParse(state.uri.queryParameters['inn'] ?? '0') ??
                          0;
                  final farmerName =
                      state.uri.queryParameters['name'] ?? 'Fermer';
                  return customEachTransitionAnimation(
                    context,
                    state,
                    TestPlantationsPage(
                      farmerInn: farmerInn,
                      farmerName: farmerName,
                    ),
                  );
                },
              ),

              // Farmers Statistics page
              GoRoute(
                path: AppRouteNames.farmersStatistics,
                pageBuilder: (context, state) => customEachTransitionAnimation(
                    context, state, const FarmersStatisticsPage()),
              ),

              // Connected devices page
              GoRoute(
                path: AppRouteNames.devices,
                pageBuilder: (context, state) => customEachTransitionAnimation(
                    context, state, const DevicesPage()),
              ),

              // Google Map
              GoRoute(
                path: AppRouteNames.googleMaps,
                pageBuilder: (context, state) => customEachTransitionAnimation(
                    context,
                    state,
                    CreateMapPage(farmerId: state.extra as int)),
                routes: [
                  GoRoute(
                    path: AppRouteNames.detailPage,
                    pageBuilder: (context, state) =>
                        customEachTransitionAnimation(
                            context,
                            state,
                            DetailPage(
                                model: state.extra as Map<String, dynamic>)),
                  ),
                ],
              ),
            ],
          ),

          // Plantation Description page
          // GoRoute(
          //   path: AppRouteNames.descriptionPage,
          //   pageBuilder: (context, state) => customEachTransitionAnimation(context, state, DescriptionPage(id: state.extra as int)),
          // ),

          // Plantation Edit page
          GoRoute(
            path: AppRouteNames.editPage,
            pageBuilder: (context, state) => customEachTransitionAnimation(
                context,
                state,
                EditPage(
                  id: state.extra as int,
                )),
          ),

          // Plantation Remote Edit page (без GPS, только административные поля)
          GoRoute(
            path: AppRouteNames.editRemotePage,
            pageBuilder: (context, state) => customEachTransitionAnimation(
                context,
                state,
                EditRemotePage(
                  id: state.extra as int,
                )),
          ),

          // Offline upload queue
          GoRoute(
            path: AppRouteNames.uploadQueue,
            pageBuilder: (context, state) => customEachTransitionAnimation(
                context, state, const QueueScreen()),
          ),
        ],
      ),
    ],
  );
}
