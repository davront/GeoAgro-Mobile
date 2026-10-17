# GeoJSON Service Usage Guide

Руководство по использованию сервиса загрузки границ областей Узбекистана.

## Описание

`GeoJsonService` предоставляет удобный способ загрузки GeoJSON файлов с границами областей.

### Основные возможности:
- ✅ Автоматическая JWT аутентификация
- ✅ Локальное кеширование для офлайн доступа
- ✅ Автоматическое определение области по региону пользователя
- ✅ Защита доступа - пользователь может загружать только свою область

## API

### Основные методы

#### 1. `loadOblastBoundaries`
Загружает GeoJSON для конкретной области по region ID.

```dart
final geoJsonService = GeoJsonService();

// Загрузить границы для региона 1 (Tashkent)
final boundaries = await geoJsonService.loadOblastBoundaries(
  regionId: 1,
  forceRefresh: false, // true для игнорирования кеша
);

if (boundaries != null) {
  // Обработка GeoJSON данных
  print('Features: ${boundaries['features']}');
}
```

#### 2. `loadCurrentUserBoundaries`
Автоматически определяет область пользователя и загружает её границы.

```dart
final geoJsonService = GeoJsonService();

// Загрузить границы для текущего пользователя
final boundaries = await geoJsonService.loadCurrentUserBoundaries();

if (boundaries != null) {
  // Использовать GeoJSON данные
}
```

#### 3. `clearCache` / `clearAllCache`
Очищает кешированные данные.

```dart
final geoJsonService = GeoJsonService();

// Очистить кеш для конкретного региона
await geoJsonService.clearCache(1);

// Очистить весь кеш
await geoJsonService.clearAllCache();
```

## Примеры использования

### Пример 1: Отображение границ на карте

```dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../core/services/geojson_service.dart';

class MapWithBoundaries extends StatefulWidget {
  @override
  _MapWithBoundariesState createState() => _MapWithBoundariesState();
}

class _MapWithBoundariesState extends State<MapWithBoundaries> {
  final GeoJsonService _geoJsonService = GeoJsonService();
  GoogleMapController? _mapController;
  Set<Polygon> _polygons = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBoundaries();
  }

  Future<void> _loadBoundaries() async {
    setState(() => _isLoading = true);

    final geoJson = await _geoJsonService.loadCurrentUserBoundaries();

    if (geoJson != null) {
      final polygons = _parseGeoJsonToPolygons(geoJson);
      setState(() {
        _polygons = polygons;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось загрузить границы области')),
      );
    }
  }

  Set<Polygon> _parseGeoJsonToPolygons(Map<String, dynamic> geoJson) {
    final polygons = <Polygon>{};
    final features = geoJson['features'] as List?;

    if (features == null) return polygons;

    for (var i = 0; i < features.length; i++) {
      final feature = features[i] as Map<String, dynamic>;
      final geometry = feature['geometry'] as Map<String, dynamic>?;

      if (geometry?['type'] == 'Polygon') {
        final coordinates = geometry!['coordinates'] as List;
        final points = (coordinates[0] as List)
            .map((coord) => LatLng(coord[1] as double, coord[0] as double))
            .toList();

        polygons.add(
          Polygon(
            polygonId: PolygonId('boundary_$i'),
            points: points,
            strokeColor: Colors.blue,
            strokeWidth: 2,
            fillColor: Colors.blue.withOpacity(0.1),
          ),
        );
      }
    }

    return polygons;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Границы области')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(41.2995, 69.2401), // Tashkent
                zoom: 8,
              ),
              polygons: _polygons,
              onMapCreated: (controller) => _mapController = controller,
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadBoundaries,
        child: Icon(Icons.refresh),
        tooltip: 'Обновить границы',
      ),
    );
  }
}
```

### Пример 2: Использование в ViewModel

```dart
import 'package:flutter/foundation.dart';
import '../core/services/geojson_service.dart';

class MapViewModel extends ChangeNotifier {
  final GeoJsonService _geoJsonService = GeoJsonService();
  
  Map<String, dynamic>? _boundariesData;
  bool _isLoading = false;
  String? _errorMessage;

  Map<String, dynamic>? get boundariesData => _boundariesData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadBoundaries({bool forceRefresh = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _geoJsonService.loadCurrentUserBoundaries(
        forceRefresh: forceRefresh,
      );

      if (data != null) {
        _boundariesData = data;
        debugPrint('✅ Границы загружены: ${data['features']?.length ?? 0} features');
      } else {
        _errorMessage = 'Не удалось загрузить границы области';
      }
    } catch (e) {
      _errorMessage = 'Ошибка загрузки: $e';
      debugPrint('❌ Error loading boundaries: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearCache() async {
    await _geoJsonService.clearAllCache();
    _boundariesData = null;
    notifyListeners();
  }
}
```

### Пример 3: Проверка нахождения точки внутри границ

```dart
import 'dart:math' as math;
import '../core/services/geojson_service.dart';

class BoundaryChecker {
  final GeoJsonService _geoJsonService = GeoJsonService();

  /// Проверяет, находится ли точка внутри границ области
  Future<bool> isPointInOblastBoundary({
    required double latitude,
    required double longitude,
    required int regionId,
  }) async {
    final geoJson = await _geoJsonService.loadOblastBoundaries(
      regionId: regionId,
    );

    if (geoJson == null) return false;

    final features = geoJson['features'] as List?;
    if (features == null) return false;

    for (final feature in features) {
      final geometry = feature['geometry'] as Map<String, dynamic>?;
      
      if (geometry?['type'] == 'Polygon') {
        final coordinates = geometry!['coordinates'] as List;
        final polygon = (coordinates[0] as List)
            .map((coord) => [coord[0] as double, coord[1] as double])
            .toList();

        if (_isPointInPolygon(latitude, longitude, polygon)) {
          return true;
        }
      }
    }

    return false;
  }

  bool _isPointInPolygon(
    double lat,
    double lon,
    List<List<double>> polygon,
  ) {
    var inside = false;
    for (var i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
      final xi = polygon[i][0];
      final yi = polygon[i][1];
      final xj = polygon[j][0];
      final yj = polygon[j][1];

      final intersect = ((yi > lat) != (yj > lat)) &&
          (lon < (xj - xi) * (lat - yi) / (yj - yi) + xi);
      
      if (intersect) inside = !inside;
    }
    return inside;
  }
}
```

## Маппинг Region ID → Oblast Slug

| Region ID | Oblast Slug     | Название области       |
|-----------|-----------------|------------------------|
| 1         | tashkent        | Ташкентская область    |
| 2         | andijan         | Андижанская область    |
| 3         | bukhara         | Бухарская область      |
| 4         | fergana         | Ферганская область     |
| 5         | jizzakh         | Джизакская область     |
| 6         | kashkadarya     | Кашкадарьинская область|
| 7         | navoi           | Навоийская область     |
| 8         | namangan        | Наманганская область   |
| 9         | samarkand       | Самаркандская область  |
| 10        | sirdarya        | Сырдарьинская область  |
| 11        | surkhandarya    | Сурхандарьинская область|
| 12        | karakalpakstan  | Каракалпакстан        |
| 13        | khorezm         | Хорезмская область     |

## Обработка ошибок

### 403 Forbidden
Возникает когда:
- Отсутствует или некорректный JWT токен
- Пользователь пытается загрузить GeoJSON чужой области

### 404 Not Found
Возникает когда:
- Запрошен несуществующий oblast slug
- Файл не найден на сервере

### Пример обработки:

```dart
try {
  final boundaries = await geoJsonService.loadOblastBoundaries(
    regionId: regionId,
  );
  
  if (boundaries == null) {
    // Обработка ошибки загрузки
    showErrorDialog('Не удалось загрузить границы области');
  }
} catch (e) {
  debugPrint('Error: $e');
  showErrorDialog('Произошла ошибка при загрузке данных');
}
```

## Кеширование

GeoJSON файлы автоматически кешируются локально после первой загрузки.

### Стратегия кеширования:
1. При первом запросе данные загружаются с сервера
2. Данные сохраняются в локальное хранилище
3. При повторных запросах используются кешированные данные
4. Используйте `forceRefresh: true` для принудительного обновления

### Управление кешем:

```dart
final geoJsonService = GeoJsonService();

// Загрузить с использованием кеша (по умолчанию)
await geoJsonService.loadOblastBoundaries(regionId: 1);

// Загрузить, игнорируя кеш
await geoJsonService.loadOblastBoundaries(
  regionId: 1,
  forceRefresh: true,
);

// Очистить кеш для региона
await geoJsonService.clearCache(1);

// Очистить весь кеш
await geoJsonService.clearAllCache();
```

## Лучшие практики

1. **Загружайте данные асинхронно**: Используйте `FutureBuilder` или ViewModel для управления состоянием загрузки

2. **Обрабатывайте ошибки**: Всегда проверяйте результат на `null` и обрабатывайте ошибки

3. **Используйте кеш**: Не используйте `forceRefresh` без необходимости

4. **Очищайте ресурсы**: Очищайте кеш при выходе пользователя из системы

```dart
// В logout методе
await geoJsonService.clearAllCache();
```

5. **Показывайте индикаторы загрузки**: Информируйте пользователя о процессе загрузки данных

## Troubleshooting

### Проблема: Данные не загружаются

**Решение:**
- Проверьте наличие JWT токена
- Убедитесь, что у пользователя есть `region_id` в профиле
- Проверьте логи на наличие ошибок 403 или 404

### Проблема: Устаревшие данные

**Решение:**
```dart
await geoJsonService.loadOblastBoundaries(
  regionId: regionId,
  forceRefresh: true,
);
```

### Проблема: Файл слишком большой

**Решение:**
GeoJSON файлы кешируются один раз и используются повторно. Размер файлов оптимизирован на сервере.
