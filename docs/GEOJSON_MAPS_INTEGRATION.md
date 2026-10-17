# Интеграция GeoJSON границ областей с Google Maps

## ✅ Что было добавлено

Границы областей Узбекистана теперь **автоматически отображаются** на всех картах Google Maps в приложении:

### 1. **Страница создания карты** (`CreateMapPage`)
- Границы области загружаются при открытии карты
- Отображаются **синими линиями** поверх спутниковой карты
- Полупрозрачные, не мешают видеть плантации

### 2. **Страница просмотра плантации** (`PlantationMapViewPage`)
- Границы области также отображаются
- Помогают понять местоположение плантации относительно области

## 🎨 Визуальное оформление

```
Границы области:
- Цвет: Синий (Blue) с прозрачностью 80%
- Толщина линии: 2 пикселя
- Заливка: Прозрачная
- Тип: Geodesic (следуют кривизне Земли)
```

## 📍 Порядок отображения слоев

**На CreateMapPage (снизу вверх):**
1. 🗺️ Спутниковая карта
2. 🔵 **Границы области** (boundaryPolygons)
3. 🟡 Соседние плантации (nearbyPolygons)
4. 🟢 Текущая рисуемая плантация (polygons)
5. 📍 Маркеры

**На PlantationMapViewPage (снизу вверх):**
1. 🗺️ Спутниковая карта
2. 🔵 **Границы области** (boundaryPolygons)
3. 🟢 Плантации (polygons)
4. 📍 Маркеры

## 🔄 Как это работает

### При открытии карты:

```dart
void onMapCreated(GoogleMapController controller) {
  mapController = controller;
  
  // ... другой код ...
  
  // 🆕 Автоматически загружаются границы области
  loadOblastBoundaries();
  
  notifyListeners();
}
```

### Процесс загрузки:

```
1. Определение региона пользователя (region_id)
   ↓
2. Загрузка GeoJSON (из кеша или с сервера)
   ↓
3. Парсинг GeoJSON features
   ↓
4. Создание Polygon объектов
   ↓
5. Отображение на карте
```

## 📊 Логи в консоли

При успешной загрузке вы увидите:

```
🗺️ Loading oblast boundaries...
✅ Oblast boundaries loaded, parsing features...
✅ Added 1 boundary polygons to map
```

При ошибке:

```
🗺️ Loading oblast boundaries...
❌ Failed to load oblast boundaries
```

или

```
❌ Error loading oblast boundaries: [описание ошибки]
```

## 🧪 Тестирование

### 1. Через реальные карты:

**CreateMapPage:**
```dart
context.go('${AppRouteNames.home}/${AppRouteNames.farmers}/${AppRouteNames.googleMaps}', extra: farmerId);
```

**PlantationMapViewPage:**
```dart
context.go('${AppRouteNames.home}/${AppRouteNames.plantationMapView}', extra: plantationId);
```

### 2. Через Dev Menu:

1. Откройте Dev Menu (`/dev-menu`)
2. Перейдите в раздел "Тестлаш"
3. Выберите "GeoJSON Test"
4. Проверьте что данные загружаются
5. Затем откройте любую карту

## ⚙️ Технические детали

### CreateMapPageVm

```dart
// Новые поля
final GeoJsonService _geoJsonService = GeoJsonService();
final Set<Polygon> boundaryPolygons = {}; // Границы области

// Новые методы
Future<void> loadOblastBoundaries()
void _addPolygonBoundary(Map<String, dynamic> geometry, int index)
void _addMultiPolygonBoundary(Map<String, dynamic> geometry, int index)
```

### PlantationMapViewVm

```dart
// Новые поля
final GeoJsonService _geoJsonService = GeoJsonService();
final Set<Polygon> boundaryPolygons = {};

// Новые методы
Future<void> loadOblastBoundaries()
void _addPolygonBoundary(Map<String, dynamic> geometry, int index)
void _addMultiPolygonBoundary(Map<String, dynamic> geometry, int index)
```

## 🎯 Что пользователь видит

**До:**
- Только плантации на карте
- Нет ориентиров границ области

**После:**
- ✅ Синие линии показывают границы области
- ✅ Видно, находится ли плантация внутри области
- ✅ Легче ориентироваться на местности
- ✅ Плантации за пределами области сразу видны

## 🔐 Безопасность

- ✅ Автоматическая JWT аутентификация
- ✅ Пользователь видит только границы своей области
- ✅ Попытка загрузить чужую область = 403 Forbidden

## 💾 Кеширование

- ✅ Первая загрузка - с сервера
- ✅ Повторные загрузки - из локального кеша
- ✅ Быстрое отображение без задержек
- ✅ Работает offline после первой загрузки

## 🎨 Настройка визуального оформления

Если хотите изменить цвет или стиль границ:

**CreateMapPageVm (line ~397):**
```dart
boundaryPolygons.add(
  Polygon(
    polygonId: PolygonId('oblast_boundary_$index'),
    points: points,
    strokeColor: Colors.blue.withOpacity(0.8), // 🎨 Цвет линии
    strokeWidth: 2,                             // 📏 Толщина
    fillColor: Colors.transparent,              // 🎨 Заливка
    geodesic: true,
  ),
);
```

**PlantationMapViewVm (line ~65):**
```dart
// Аналогично
```

## 🐛 Troubleshooting

### Границы не отображаются

1. **Проверьте логи:**
   ```
   Должно быть: ✅ Added X boundary polygons to map
   ```

2. **Проверьте JWT токен:**
   ```
   Без токена = 403 Forbidden
   ```

3. **Проверьте region_id пользователя:**
   ```
   Пользователь должен иметь валидный region_id (1-13)
   ```

4. **Очистите кеш:**
   ```dart
   final geoJsonService = GeoJsonService();
   await geoJsonService.clearAllCache();
   ```

### Границы отображаются неправильно

1. **Проверьте формат GeoJSON на сервере**
2. **Проверьте что coordinates в правильном порядке:** `[longitude, latitude]`
3. **Проверьте логи парсинга**

### Границы перекрывают плантации

Измените порядок в `polygons: {...}`:

```dart
// Сейчас:
polygons: {
  ...vm.boundaryPolygons,  // Снизу
  ...vm.nearbyPolygons,
  ...vm.polygons,          // Сверху
}

// Если нужно boundaries сверху:
polygons: {
  ...vm.nearbyPolygons,
  ...vm.polygons,
  ...vm.boundaryPolygons,  // Сверху
}
```

## 📝 Дополнительная информация

- Полная документация: `docs/GEOJSON_USAGE.md`
- Техническая документация: `docs/GEOJSON_IMPLEMENTATION.md`
- Исходный код сервиса: `lib/src/core/services/geojson_service.dart`
- ViewModel для карты: `lib/src/feature/google_map/vm/create_map_page_vm.dart`

## ✨ Готово!

Теперь при открытии любой карты Google Maps в приложении границы области будут автоматически отображаться синими линиями! 🎉
