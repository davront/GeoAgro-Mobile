# 🗺️ Оптимизация расходов на Google Maps API

## 💰 Что стоит денег в Google Maps

### Основные источники расходов:
1. **Map Tiles (тайлы карты)** - каждый раз при загрузке/движении карты
2. **Satellite Imagery** - спутниковые снимки дороже обычных карт
3. **Geocoding API** - преобразование адресов в координаты (если используется)
4. **Places API** - поиск мест (если используется)

### Текущие проблемы в проекте:

#### 🔴 Критичные (стоят больше всего):
1. **Спутниковые тайлы (`MapType.satellite`)** - дороже обычных карт в 2-3 раза
2. **Постоянное обновление местоположения** - `getPositionStream()` вызывает перерисовку
3. **Нет кэширования тайлов** - каждый раз загружаются заново
4. **Нет дебаунсинга** - при движении карты загружаются тайлы сразу

#### 🟡 Важные:
5. **Загрузка всех плантаций сразу** - может быть много полигонов
6. **Нет кластеризации маркеров** - если много маркеров, все отображаются
7. **Нет ограничения видимой области** - загружаются тайлы за пределами видимости

---

## ✅ Решения для оптимизации

### 1. **Использовать обычную карту вместо спутниковой**

**Текущий код:**
```dart
GoogleMap(
  mapType: MapType.satellite, // ❌ Дорого
  ...
)
```

**Решение:**
```dart
GoogleMap(
  mapType: MapType.normal, // ✅ Дешевле
  // Или дать пользователю выбор
  ...
)
```

**Экономия:** ~60-70% от стоимости тайлов

---

### 2. **Кэширование тайлов карты**

**Проблема:** Каждый раз при открытии карты загружаются тайлы заново

**Решение:** Использовать `flutter_cache_manager` для кэширования тайлов

```dart
// Добавить в pubspec.yaml
dependencies:
  flutter_cache_manager: ^3.3.1

// Создать сервис кэширования
class MapTileCache {
  static final CacheManager _cacheManager = CacheManager(
    Config(
      'mapTiles',
      stalePeriod: const Duration(days: 30), // Кэш на 30 дней
      maxNrOfCacheObjects: 1000, // Максимум 1000 тайлов
    ),
  );
  
  static Future<File> getTile(String url) async {
    return await _cacheManager.getSingleFile(url);
  }
}
```

**Экономия:** ~80-90% повторных запросов

---

### 3. **Оптимизация обновления местоположения**

**Текущий код:**
```dart
_positionStreamSub = Geolocator.getPositionStream(
  locationSettings: LocationSettings(
    accuracy: LocationAccuracy.high, // ❌ Высокая точность = больше запросов
    distanceFilter: 0, // ❌ Обновляется при каждом движении
  ),
);
```

**Решение:**
```dart
_positionStreamSub = Geolocator.getPositionStream(
  locationSettings: LocationSettings(
    accuracy: LocationAccuracy.medium, // ✅ Средняя точность достаточно
    distanceFilter: 10, // ✅ Обновлять только при движении на 10+ метров
    timeLimit: Duration(seconds: 5), // ✅ Таймаут для экономии батареи
  ),
).throttleTime(Duration(seconds: 5)); // ✅ Дебаунсинг - не чаще раза в 5 секунд
```

**Экономия:** ~70-80% запросов на обновление местоположения

---

### 4. **Дебаунсинг обновлений карты**

**Проблема:** При движении карты (pan/zoom) сразу загружаются новые тайлы

**Решение:** Добавить дебаунсинг для `onCameraMove`

```dart
Timer? _cameraMoveTimer;

void onCameraMove(CameraPosition position) {
  // Отменяем предыдущий таймер
  _cameraMoveTimer?.cancel();
  
  // Устанавливаем новый таймер - обновление только через 500ms после остановки
  _cameraMoveTimer = Timer(Duration(milliseconds: 500), () {
    _updateMapData(position);
  });
}

void _updateMapData(CameraPosition position) {
  // Загружаем данные только после остановки движения карты
  loadNearbyPlantations();
}
```

**Экономия:** ~50-60% запросов при движении карты

---

### 5. **Ленивая загрузка плантаций**

**Текущий код:**
```dart
onMapCreated(GoogleMapController controller) {
  // Загружает все плантации сразу
  loadNearbyPlantations(); // ❌
  loadDistrictBoundaries(); // ❌
}
```

**Решение:** Загружать только видимые плантации

```dart
Future<void> loadVisiblePlantations() async {
  if (mapController == null) return;
  
  // Получаем видимую область карты
  final visibleRegion = await mapController!.getVisibleRegion();
  
  // Загружаем только плантации в видимой области
  final data = await _appRepositoryImpl.getNearbyPlantations(
    northeast: visibleRegion.northeast,
    southwest: visibleRegion.southwest,
  );
  
  // Обновляем только видимые полигоны
  _updateVisiblePolygons(data);
}
```

**Экономия:** ~40-50% запросов к API

---

### 6. **Ограничение количества маркеров**

**Проблема:** Если много плантаций, все маркеры отображаются сразу

**Решение:** Кластеризация маркеров или ограничение видимых

```dart
// Ограничить количество отображаемых маркеров
void _updateMarkers() {
  markers.clear();
  
  // Показывать только первые 50 маркеров
  final visiblePlantations = userPlantations.take(50).toList();
  
  for (final plantation in visiblePlantations) {
    markers.add(
      Marker(
        markerId: MarkerId('plantation_${plantation.id}'),
        position: plantation.center,
        // ...
      ),
    );
  }
}
```

**Экономия:** Меньше перерисовок = меньше запросов тайлов

---

### 7. **Использовать статические карты для превью**

**Для списков плантаций:** Вместо интерактивной карты использовать статическое изображение

```dart
// Для карточек в списке - статическое изображение
Image.network(
  'https://maps.googleapis.com/maps/api/staticmap?'
  'center=${lat},${lng}&'
  'zoom=15&'
  'size=400x200&'
  'markers=color:red|${lat},${lng}&'
  'key=$apiKey',
)
```

**Экономия:** Статические карты дешевле интерактивных

---

### 8. **Оптимизация загрузки границ района**

**Текущий код:**
```dart
loadDistrictBoundaries(); // Загружается каждый раз
```

**Решение:** Кэшировать границы локально

```dart
Future<void> loadDistrictBoundaries() async {
  // Проверяем кэш
  final cached = await _getCachedBoundaries(districtId);
  if (cached != null) {
    districtBoundaries.addAll(cached);
    notifyListeners();
    return; // ✅ Используем кэш
  }
  
  // Загружаем только если нет в кэше
  final boundaries = await _geoJsonService.getDistrictBoundaries(districtId);
  await _saveCachedBoundaries(districtId, boundaries);
  // ...
}
```

**Экономия:** Границы не меняются - можно кэшировать навсегда

---

### 9. **Настройка Google Maps для экономии**

**В `AndroidManifest.xml` и `Info.plist`:**

```xml
<!-- Использовать кэширование тайлов -->
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY"/>
    
<!-- Включить кэширование -->
<meta-data
    android:name="com.google.android.maps.v2.USE_GOOGLE_PLAY_SERVICES"
    android:value="true"/>
```

---

### 10. **Мониторинг расходов**

**Добавить логирование запросов:**

```dart
class MapUsageTracker {
  static int _tileLoads = 0;
  static DateTime? _lastReset;
  
  static void trackTileLoad() {
    _tileLoads++;
    if (_lastReset == null || 
        DateTime.now().difference(_lastReset!) > Duration(days: 1)) {
      _resetCounter();
    }
  }
  
  static void _resetCounter() {
    debugPrint('📊 Map tiles loaded today: $_tileLoads');
    _tileLoads = 0;
    _lastReset = DateTime.now();
  }
}
```

---

## 📊 Ожидаемая экономия

| Оптимизация | Экономия | Приоритет |
|------------|----------|-----------|
| Обычная карта вместо спутниковой | 60-70% | 🔴 Высокий |
| Кэширование тайлов | 80-90% | 🔴 Высокий |
| Дебаунсинг обновлений | 50-60% | 🔴 Высокий |
| Оптимизация геолокации | 70-80% | 🟡 Средний |
| Ленивая загрузка плантаций | 40-50% | 🟡 Средний |
| Кэширование границ | 100% (после первого раза) | 🟡 Средний |
| Ограничение маркеров | 30-40% | 🟢 Низкий |

**Общая экономия:** ~70-85% от текущих расходов

---

## 🚀 План внедрения

### Фаза 1 (Быстрые победы - 1-2 дня):
1. ✅ Переключить на обычную карту (или дать выбор)
2. ✅ Добавить дебаунсинг для обновлений карты
3. ✅ Оптимизировать обновление геолокации

### Фаза 2 (Средний приоритет - 3-5 дней):
4. ✅ Добавить кэширование тайлов
5. ✅ Кэшировать границы района
6. ✅ Ленивая загрузка плантаций

### Фаза 3 (Долгосрочные - 1-2 недели):
7. ✅ Кластеризация маркеров
8. ✅ Статические карты для превью
9. ✅ Мониторинг расходов

---

## 💡 Дополнительные рекомендации

### Альтернативные решения:

1. **Использовать OpenStreetMap** (бесплатно):
   - `flutter_map` вместо `google_maps_flutter`
   - Полностью бесплатно, но требует собственный сервер тайлов

2. **Гибридный подход**:
   - OpenStreetMap для базовой карты
   - Google Maps только для спутниковых снимков (когда нужно)

3. **Ограничение использования**:
   - Показывать карту только при необходимости
   - Использовать статические изображения в списках
   - Загружать интерактивную карту по требованию

---

## 📝 Пример реализации

Создать файл `lib/src/core/services/map_optimization_service.dart`:

```dart
class MapOptimizationService {
  static Timer? _cameraMoveTimer;
  static final Map<String, dynamic> _boundariesCache = {};
  
  // Дебаунсинг для обновлений карты
  static void onCameraMove(VoidCallback callback) {
    _cameraMoveTimer?.cancel();
    _cameraMoveTimer = Timer(Duration(milliseconds: 500), callback);
  }
  
  // Кэширование границ
  static Future<List<List<LatLng>>> getCachedBoundaries(int districtId) async {
    final key = 'boundaries_$districtId';
    if (_boundariesCache.containsKey(key)) {
      return _boundariesCache[key];
    }
    // Загрузить и кэшировать
    return [];
  }
}
```

---

**Важно:** Начните с Фазы 1 - это даст максимальную экономию при минимальных изменениях кода.

