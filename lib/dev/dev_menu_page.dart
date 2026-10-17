import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import '../src/core/routes/app_route_names.dart';

/// Dev Menu - доступен только в debug режиме
/// Позволяет быстро перейти на любую страницу приложения
class DevMenuPage extends StatelessWidget {
  const DevMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    // В production режиме показываем ошибку
    if (kReleaseMode) {
      return const Scaffold(
        body: Center(
          child: Text('Dev Menu production режимида мавжуд эмас'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('🔧 Dev Menu'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Саҳифалар бўйича тез навигация',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          
          _buildSection(
            context,
            'Автентификация',
            [
              _DevMenuItem(
                title: 'Login',
                route: AppRouteNames.login,
                icon: Icons.login,
              ),
            ],
          ),
          
          _buildSection(
            context,
            'Асосий',
            [
              _DevMenuItem(
                title: 'Home',
                route: AppRouteNames.home,
                icon: Icons.home,
              ),
              _DevMenuItem(
                title: 'Approved',
                route: '${AppRouteNames.home}/${AppRouteNames.approvedPage}',
                icon: Icons.check_circle,
              ),
              _DevMenuItem(
                title: 'Pending',
                route: '${AppRouteNames.home}/${AppRouteNames.pendingPage}',
                icon: Icons.pending,
              ),
              _DevMenuItem(
                title: 'Recheck',
                route: '${AppRouteNames.home}/${AppRouteNames.recheckPage}',
                icon: Icons.refresh,
              ),
              _DevMenuItem(
                title: 'Notifications',
                route: '${AppRouteNames.home}/${AppRouteNames.natificationPage}',
                icon: Icons.notifications,
              ),
            ],
          ),
          
          _buildSection(
            context,
            'Плантациялар',
            [
              _DevMenuItem(
                title: 'Plantation View (ID: 1)',
                route: '${AppRouteNames.home}/${AppRouteNames.plantationView}',
                icon: Icons.visibility,
                extra: 1,
              ),
              _DevMenuItem(
                title: 'Plantation Map View (ID: 1)',
                route: '${AppRouteNames.home}/${AppRouteNames.plantationMapView}',
                icon: Icons.map,
                extra: 1,
              ),
              _DevMenuItem(
                title: 'Edit Page (ID: 1)',
                route: '${AppRouteNames.home}/${AppRouteNames.editPage}',
                icon: Icons.edit,
                extra: 1,
              ),
            ],
          ),
          
          _buildSection(
            context,
            'Фермерлар',
            [
              _DevMenuItem(
                title: 'Farmers List',
                route: '${AppRouteNames.home}/${AppRouteNames.farmers}',
                icon: Icons.people,
              ),
              _DevMenuItem(
                title: 'Create Farmer',
                route: '${AppRouteNames.home}/${AppRouteNames.farmers}/${AppRouteNames.createFarmers}',
                icon: Icons.person_add,
              ),
              _DevMenuItem(
                title: 'Farmer Plantations',
                route: '${AppRouteNames.home}/${AppRouteNames.farmers}/${AppRouteNames.farmerPlantations}?inn=123456789&name=Test',
                icon: Icons.agriculture,
              ),
              _DevMenuItem(
                title: 'Farmers Statistics',
                route: '${AppRouteNames.home}/${AppRouteNames.farmers}/${AppRouteNames.farmersStatistics}',
                icon: Icons.bar_chart,
              ),
            ],
          ),
          
          _buildSection(
            context,
            'Хариталар',
            [
              _DevMenuItem(
                title: 'Create Map',
                route: '${AppRouteNames.home}/${AppRouteNames.farmers}/${AppRouteNames.googleMaps}',
                icon: Icons.map,
                extra: 1,
              ),
            ],
          ),
          
          _buildSection(
            context,
            'Тестлаш',
            [],
          ),
          
          _buildSection(
            context,
            'Бошқа',
            [
              _DevMenuItem(
                title: 'Blocked Page',
                route: '/blocRoute',
                icon: Icons.block,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<_DevMenuItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        ...items.map((item) => _buildMenuItem(context, item)),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildMenuItem(BuildContext context, _DevMenuItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(item.icon, color: Colors.blue),
        title: Text(item.title),
        subtitle: Text(item.route, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          if (item.extra != null) {
            context.go(item.route, extra: item.extra);
          } else {
            context.go(item.route);
          }
        },
      ),
    );
  }
}

class _DevMenuItem {
  final String title;
  final String route;
  final IconData icon;
  final Object? extra;

  _DevMenuItem({
    required this.title,
    required this.route,
    required this.icon,
    this.extra,
  });
}

/// Floating button для открытия Dev Menu (только в debug)
class DevMenuFloatingButton extends StatefulWidget {
  final Widget child;
  
  const DevMenuFloatingButton({
    super.key,
    required this.child,
  });

  @override
  State<DevMenuFloatingButton> createState() => _DevMenuFloatingButtonState();
}

class _DevMenuFloatingButtonState extends State<DevMenuFloatingButton> {
  int _tapCount = 0;
  DateTime? _lastTapTime;

  void _handleTap() {
    if (kReleaseMode) return;

    final now = DateTime.now();
    
    // Сбрасываем счетчик если прошло больше 2 секунд
    if (_lastTapTime == null || now.difference(_lastTapTime!) > const Duration(seconds: 2)) {
      _tapCount = 0;
    }
    
    _lastTapTime = now;
    _tapCount++;
    
    if (_tapCount >= 3) {
      _tapCount = 0;
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const DevMenuPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kReleaseMode) {
      return widget.child;
    }

    return GestureDetector(
      onTap: _handleTap,
      child: Stack(
        children: [
          widget.child,
          Positioned(
            bottom: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '🔧 Dev',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

