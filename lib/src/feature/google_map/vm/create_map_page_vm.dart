// create_map_page_vm.dart
import 'dart:math';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:agro_employee_public/design_system/tokens/colors.dart'
    as design_colors;
import '../../../core/utils/geo_utils.dart';
import '../../../core/utils/marker_icon_utils.dart';
import '../../../data/model/plantation/new_plantation_model.dart';
import '../../../data/model/plantation/nearby_plantations_model.dart';
import '../../../data/model/plantation/forme_map_model.dart';
import '../../../data/repository/app_repository_impl.dart';
import '../../../core/storage/app_storage.dart';
import '../../../core/services/district_boundary_service.dart';
import 'dart:convert';

List<LatLng> polygoneCoordinates = [];

class CreateMapPageVm extends ChangeNotifier {
  final AppRepositoryImpl _appRepositoryImpl = AppRepositoryImpl();

  GoogleMapController? mapController;
  final List<LatLng> polylineCoordinates = [];
  final LatLng uzbLatLng =
      const LatLng(41.311081, 69.240562); // Default location

  bool isLoading = false; // Ma'lumot yuklanayotgan holat
  LatLng? currentLocation; // Foydalanuvchi turgan joy
  bool isLocationPermissionGranted = false; // Lokatsiya ruxsatlari

  // Geolocator.Position.isMocked — true, agar joylashuv mock location
  // provider (Developer Options yoki fake GPS ilova) orqali berilgan
  // bo'lsa. GPS antifraud (limit_km tekshiruvi) faqat haqiqiy koordinata
  // uchun ma'noga ega — mock bo'lsa, foydalanuvchi istalgan nuqtani
  // "haqiqiy joylashuv" sifatida yubora oladi.
  bool isMockedLocation = false;

  final Set<Polyline> polylines = {};
  final Set<Polygon> polygons = {};
  final Set<Marker> markers = {};
  final Set<Polygon> nearbyPolygons = {}; // Polygons for nearby plantations
  final Set<Polygon> regionBoundaries = {}; // Границы области пользователя

  BitmapDescriptor? userArrowIcon;
  double userHeading = 0.0;
  StreamSubscription<Position>? _positionStreamSub;

  List<NearbyPlantation> nearbyPlantations = [];
  List<FormeMapPlantation> userPlantations = [];
  bool isLoadingNearby = false;

  // Лимит координат в метрах (дефолт 1000м = 1км)
  double _limitKm = 1.0;
  double get limitKm => _limitKm;

  // Cluster manager (native google_maps_flutter)
  static const String _plantationClusterId = 'plantations_cluster';
  late final Set<ClusterManager> clusterManagers = {
    ClusterManager(
      clusterManagerId: const ClusterManagerId(_plantationClusterId),
      onClusterTap: onClusterTap,
    ),
  };
  double _currentZoom = 10.0;
  static const double _polygonVisibilityZoom = 13.0;
  bool get arePolygonsVisible => _currentZoom >= _polygonVisibilityZoom;

  // Состояние для диалога с информацией о плантации
  FormeMapPlantation? selectedPlantation;
  bool showPlantationDialog = false;

  // Состояние точечного рисования
  bool isDrawingMode = false;
  bool isPolygonComplete = false;
  List<LatLng> drawingPoints = [];
  List<double> segmentDistances = []; // Расстояния между точками
  LatLng? centerPoint; // Центральная точка для рисования

  // Состояние линейки для рисования
  BitmapDescriptor? rulerIcon; // Иконка линейки

  // Кэш номерованных иконок вершин полигона (ключ — номер точки, 1-based).
  // Генерация PNG на каждый drag была бы расточительна — точка меняет
  // позицию, не номер, поэтому одна и та же иконка переиспользуется.
  final Map<int, BitmapDescriptor> _vertexIconCache = {};

  double calculateDistance(LatLng start, LatLng end) =>
      GeoUtils.haversineMeters(
          start.latitude, start.longitude, end.latitude, end.longitude);

  double findMinimumDistance(
          List<LatLng> coordinates, LatLng currentLocation) =>
      GeoUtils.minDistanceToPolygon(
        currentLocation.latitude,
        currentLocation.longitude,
        coordinates.map((p) => (p.latitude, p.longitude)).toList(),
      );

  // Функция для расчёта площади полигона в квадратных метрах
  double calculatePolygonArea(List<LatLng> points) {
    if (points.length < 3) return 0.0;

    // Используем формулу площади Гаусса для сферических координат
    double area = 0.0;
    int n = points.length;

    // Если полигон замкнут (последняя точка = первой), убираем дублирующую точку
    List<LatLng> cleanPoints = List<LatLng>.from(points);
    if (cleanPoints.length > 3 &&
        cleanPoints.first.latitude == cleanPoints.last.latitude &&
        cleanPoints.first.longitude == cleanPoints.last.longitude) {
      cleanPoints.removeLast();
      n = cleanPoints.length;
    }

    for (int i = 0; i < n; i++) {
      int j = (i + 1) % n;
      area += cleanPoints[i].longitude * cleanPoints[j].latitude;
      area -= cleanPoints[j].longitude * cleanPoints[i].latitude;
    }
    area = area.abs() / 2.0;

    // Переводим квадратные градусы в квадратные метры
    double avgLat =
        cleanPoints.map((p) => p.latitude).reduce((a, b) => a + b) / n;
    double meterPerDegreeLat = 111320.0; // метры на градус широты
    double meterPerDegreeLng =
        111320.0 * cos(avgLat * pi / 180); // метры на градус долготы

    area = area * meterPerDegreeLat * meterPerDegreeLng;
    return area;
  }

  // Получить площадь полигона в гектарах
  double get polygonAreaHectares {
    return calculatePolygonArea(polylineCoordinates) / 10000.0;
  }

  void _setLoading(bool value) {
    isLoading = value;
    _safeNotifyListeners();
  }

  Future<void> loadUserArrowIcon() async {
    if (userArrowIcon != null) {
      return;
    }

    try {
      // Генерируем стрелку canvas'ом (MarkerIconUtils.createUserArrowIcon),
      // не грузим из assets/images/user_arrow.png — тот файл оказался
      // битым (1 байт, не валидный PNG), из-за чего декодирование не
      // падало на Dart-стороне (BitmapDescriptor.bytes не валидирует
      // содержимое), а крашило всё приложение глубоко в нативном слое
      // Google Maps при рендере маркера, необрабатываемо из этого catch.
      userArrowIcon = await MarkerIconUtils.createUserArrowIcon();
    } catch (e) {
      debugPrint('Failed to load custom user arrow icon: $e');
      userArrowIcon =
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
    }
  }

  Future<void> loadRulerIcon() async {
    if (rulerIcon != null) {
      return;
    }

    try {
      rulerIcon = await MarkerIconUtils.createRulerIcon();
    } catch (e) {
      debugPrint('Error loading ruler icon: $e');
      // Используем дефолтную иконку если не удалось создать кастомную
      rulerIcon =
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan);
    }
  }

  Future<void> startUserHeadingUpdates() async {
    try {
      await loadUserArrowIcon();

      _positionStreamSub?.cancel();
      _positionStreamSub = Geolocator.getPositionStream(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.best),
      ).listen(
        (position) {
          if (position.heading >= 0) {
            userHeading = position.heading;
          }
          currentLocation = LatLng(position.latitude, position.longitude);
          _updateUserArrowMarker();
          _safeNotifyListeners();
        },
        onError: (e) {
          debugPrint('Position stream error: $e');
          _positionStreamSub?.cancel();
          _positionStreamSub = null;
        },
        cancelOnError: true,
      );
    } catch (e) {
      // Если не удалось запустить поток местоположения, используем разовое получение
      await getCurrentLocation();
    }
  }

  LatLng? _lastArrowMarkerPosition;
  double? _lastArrowMarkerHeading;

  void _updateUserArrowMarker() {
    if (currentLocation == null || userArrowIcon == null) {
      return;
    }

    // GPS-стрим на LocationAccuracy.best может тикать по многу раз в
    // секунду — пересоздавать маркер (removeWhere+add с тем же markerId)
    // на каждый tick создаёт гонку с открытым InfoWindow этого же
    // маркера: google_maps_flutter внутренне зовёт hideInfoWindow на уже
    // удалённый экземпляр и падает с "Invalid markerId" глубоко в
    // нативном слое, необрабатываемо из Dart. Пересоздаём только когда
    // позиция/поворот реально заметно изменились.
    final last = _lastArrowMarkerPosition;
    final headingChanged = _lastArrowMarkerHeading == null ||
        (userHeading - _lastArrowMarkerHeading!).abs() > 3;
    final positionChanged = last == null ||
        GeoUtils.haversineMeters(last.latitude, last.longitude,
                currentLocation!.latitude, currentLocation!.longitude) >
            1;
    if (!headingChanged && !positionChanged) {
      return;
    }
    _lastArrowMarkerPosition = currentLocation;
    _lastArrowMarkerHeading = userHeading;

    markers
        .removeWhere((marker) => marker.markerId.value == 'current_location');
    markers.add(
      Marker(
        markerId: const MarkerId('current_location'),
        position: currentLocation!,
        icon: userArrowIcon!,
        rotation: userHeading,
        anchor: const Offset(0.5, 0.5),
        infoWindow: const InfoWindow(title: 'Сиз бу ерда'),
      ),
    );
  }

  bool _isDisposed = false;

  /// Безопасный вызов notifyListeners — не вызывает после dispose
  void _safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _positionStreamSub?.cancel();
    super.dispose();
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;

    // Очищаем список плантаций
    nearbyPolygons.clear();
    nearbyPlantations.clear();
    userPlantations.clear();

    // Устанавливаем центральную точку на текущее местоположение или дефолтное
    if (currentLocation != null) {
      centerPoint = currentLocation;
    } else {
      centerPoint = uzbLatLng;
    }

    // Инициализируем маркеры
    _updatePolygonMarkers();

    // Запускаем обновление местоположения пользователя
    startUserHeadingUpdates();

    // Загружаем плантации пользователя
    loadNearbyPlantations();

    // Загружаем границы области пользователя
    loadRegionBoundaries();

    _safeNotifyListeners();
  }

  /// Загружает границы района пользователя на основе его district_id
  Future<void> loadRegionBoundaries() async {
    try {
      // Получаем district_id и region_id из API
      final userInfoData = await _appRepositoryImpl.getUserInfo();
      if (userInfoData == null) {
        debugPrint('❌ CreateMapPageVm: getUserInfo returned null');
        return;
      }

      final userInfo = jsonDecode(userInfoData);
      final districtId = userInfo['district_id'] as int?;
      final regionId = userInfo['region_id'] as int?;

      if (districtId == null || districtId <= 0) {
        debugPrint('❌ CreateMapPageVm: Invalid district_id: $districtId');
        return;
      }

      debugPrint(
          '📊 CreateMapPageVm: Loading boundaries for district_id: $districtId, region_id: $regionId');

      // Загружаем границы района (с fallback на область, если API не вернул данные)
      final boundaries = await DistrictBoundaryService.loadDistrictBoundaries(
        districtId,
        regionId: regionId,
      );

      if (boundaries.isNotEmpty) {
        regionBoundaries.clear();
        regionBoundaries.addAll(boundaries);
        debugPrint(
            '✅ CreateMapPageVm: Loaded ${boundaries.length} boundary polygons');
        _safeNotifyListeners();
      } else {
        debugPrint(
            '⚠️ CreateMapPageVm: No boundaries loaded for district_id: $districtId');
      }
    } catch (e) {
      debugPrint('❌ CreateMapPageVm: Error loading district boundaries: $e');
    }
  }

  Future<void> loadNearbyPlantations() async {
    isLoadingNearby = true;
    _safeNotifyListeners();

    try {
      final data = await _appRepositoryImpl.getUserPlantationsForMap();

      if (data != null && data.isNotEmpty) {
        try {
          userPlantations = formeMapModelFromJson(data);
          debugPrint('Loaded ${userPlantations.length} plantations');

          _updateUserPlantationsPolygons();
        } catch (jsonError) {
          debugPrint('JSON parsing error: $jsonError');
          debugPrint('Raw data: $data');
          userPlantations = [];

          // Попробуем альтернативный способ загрузки через обычный список плантаций
          debugPrint('Trying alternative loading method...');
          await _loadPlantationsAlternative();
        }
      } else {
        debugPrint(
            'No data received from user plantations API or empty response');
        userPlantations = [];

        // Попробуем альтернативный способ загрузки
        debugPrint('Trying alternative loading method...');
        await _loadPlantationsAlternative();
      }
    } catch (e) {
      debugPrint('Error loading user plantations: $e');
      userPlantations = [];

      // Попробуем альтернативный способ загрузки
      debugPrint('Trying alternative loading method...');
      await _loadPlantationsAlternative();
    } finally {
      isLoadingNearby = false;
      _safeNotifyListeners();
    }
  }

  Future<void> _loadPlantationsAlternative() async {
    try {
      debugPrint('Loading plantations using alternative method...');
      final data = await _appRepositoryImpl.getPlantationsList();

      if (data != null) {
        debugPrint(
            'Alternative API returned data, but may not have coordinates for map display');
        // Обычный список плантаций не содержит координат для карты
        userPlantations = [];
      }
    } catch (e) {
      debugPrint('Alternative loading method also failed: $e');
      userPlantations = [];
    }
  }

  void _updateUserPlantationsPolygons() {
    nearbyPolygons.clear();
    // Remove existing tooltip markers for plantations
    markers.removeWhere(
      (marker) => marker.markerId.value.startsWith('plantation_info_'),
    );
    debugPrint(
        'Updating user plantations polygons for ${userPlantations.length} plantations');

    for (final plantation in userPlantations) {
      if (plantation.coordinates.isNotEmpty) {
        final coordinates = plantation.coordinates
            .map((coord) => LatLng(coord.latitude, coord.longitude))
            .toList();

        // Проверяем, что полигон замкнут
        if (coordinates.length >= 3) {
          // Если полигон не замкнут, замыкаем его
          if (coordinates.first.latitude != coordinates.last.latitude ||
              coordinates.first.longitude != coordinates.last.longitude) {
            coordinates.add(coordinates.first);
          }

          // Определяем цвет в зависимости от статуса проверки — те же
          // токены, что и в plantation_map_view_vm, иначе palette
          // расходится между экранами (raw Colors.green/orange здесь
          // отличались оттенком от design_colors.AppColors.success/warning).
          final color = plantation.isChecked
              ? design_colors.AppColors.success
              : design_colors.AppColors.warning;

          // Добавляем полигон
          nearbyPolygons.add(
            Polygon(
              polygonId: PolygonId('user_plantation_${plantation.id}'),
              points: coordinates,
              fillColor: color.withValues(alpha: 0.3),
              strokeColor: color,
              strokeWidth: 3,
              consumeTapEvents: true,
              onTap: () =>
                  onPolygonTap(PolygonId('user_plantation_${plantation.id}')),
            ),
          );

          _addPlantationTooltipMarker(
            plantation: plantation,
            coordinates: coordinates,
          );
        }
      }
    }

    // Init/update cluster manager
    _initClusterManager();
    // Уведомляем UI об обновлении
    _safeNotifyListeners();
  }

  void _addPlantationTooltipMarker({
    required FormeMapPlantation plantation,
    required List<LatLng> coordinates,
  }) {
    if (coordinates.isEmpty) return;

    final centroid = _calculatePolygonCentroid(coordinates);
    final markerId = MarkerId('plantation_info_${plantation.id}');
    final statusLabel =
        plantation.isChecked ? 'Tasdiqlangan' : "Ko'rib chiqilmagan";
    final markerColor = plantation.isChecked
        ? BitmapDescriptor.hueGreen
        : BitmapDescriptor.hueOrange;

    markers.add(
      Marker(
        markerId: markerId,
        position: centroid,
        icon: BitmapDescriptor.defaultMarkerWithHue(markerColor),
        // Подключаем к нативному ClusterManager — при большом числе
        // плантаций (десятки-сотни в одном районе) маркеры автоматически
        // группируются в кластеры на низком zoom вместо захламления
        // экрана десятками наложенных друг на друга пинов.
        clusterManagerId: const ClusterManagerId(_plantationClusterId),
        infoWindow: InfoWindow(
          title: plantation.getDisplayFarmerName(),
          snippet:
              'ID: ${plantation.id} • ${plantation.getDisplayArea()} • $statusLabel',
          onTap: () => _handlePlantationInfoTap(plantation),
        ),
        onTap: () {
          // Также показываем всплывающее окно при прямом тапе по маркеру
          selectedPlantation = plantation;
          showPlantationDialog = true;
          _safeNotifyListeners();
        },
      ),
    );
  }

  LatLng _calculatePolygonCentroid(List<LatLng> points) {
    if (points.isEmpty) {
      return centerPoint ?? uzbLatLng;
    }

    double latitudeSum = 0;
    double longitudeSum = 0;

    final uniquePoints = List<LatLng>.from(points);
    if (uniquePoints.length > 1 &&
        uniquePoints.first.latitude == uniquePoints.last.latitude &&
        uniquePoints.first.longitude == uniquePoints.last.longitude) {
      uniquePoints.removeLast();
    }

    for (final point in uniquePoints) {
      latitudeSum += point.latitude;
      longitudeSum += point.longitude;
    }

    return LatLng(
      latitudeSum / uniquePoints.length,
      longitudeSum / uniquePoints.length,
    );
  }

  void _handlePlantationInfoTap(FormeMapPlantation plantation) {
    selectedPlantation = plantation;
    showPlantationDialog = true;
    _safeNotifyListeners();
  }

  void onPolygonTap(PolygonId polygonId) {
    debugPrint('Polygon tapped: ${polygonId.value}');

    // Найти плантацию по ID полигона
    final plantationId = polygonId.value.replaceFirst('user_plantation_', '');
    final plantationIndex = userPlantations.indexWhere(
      (p) => p.id.toString() == plantationId,
    );

    if (plantationIndex == -1) {
      debugPrint('Plantation not found for polygon: ${polygonId.value}');
      return;
    }

    final plantation = userPlantations[plantationIndex];

    debugPrint('Selected plantation: ${plantation.id}');
    debugPrint('Farmer: ${plantation.getDisplayFarmerName()}');
    debugPrint('Area: ${plantation.getDisplayArea()}');
    debugPrint('Status: ${plantation.isChecked ? 'Checked' : 'Not Checked'}');
    debugPrint('Kontur numbers: ${plantation.getDisplayKonturNumbers()}');

    // Устанавливаем выбранную плантацию и показываем диалог
    selectedPlantation = plantation;
    showPlantationDialog = true;
    final markerId = MarkerId('plantation_info_${plantation.id}');
    if (mapController != null) {
      mapController!.showMarkerInfoWindow(markerId);
    }
    _safeNotifyListeners();
  }

  void closePlantationDialog() {
    if (selectedPlantation != null && mapController != null) {
      mapController!.hideMarkerInfoWindow(
        MarkerId('plantation_info_${selectedPlantation!.id}'),
      );
    }
    selectedPlantation = null;
    showPlantationDialog = false;
    _safeNotifyListeners();
  }

  void onTap(LatLng position) {
    debugPrint('Map tapped at: ${position.latitude}, ${position.longitude}');

    // Проверяем, был ли клик по полигону
    bool tappedOnPolygon = false;
    for (final polygon in nearbyPolygons) {
      if (_isPointInPolygon(position, polygon.points)) {
        debugPrint('Tap detected inside polygon: ${polygon.polygonId.value}');
        onPolygonTap(polygon.polygonId);
        tappedOnPolygon = true;
        break;
      }
    }

    // Если клик не по полигону, обрабатываем как обычный клик по карте
    if (!tappedOnPolygon) {
      // При тапе обновляем элементы рисования для обновления предварительной линии
      _updateDrawingElements();
    }

    _safeNotifyListeners();
  }

  // Проверяет, находится ли точка внутри полигона
  bool _isPointInPolygon(LatLng point, List<LatLng> polygon) =>
      GeoUtils.isPointInPolygon(
        point.latitude,
        point.longitude,
        polygon.map((p) => (p.latitude, p.longitude)).toList(),
      );

  // Порог прилипания к границе соседнего полигона, в метрах — точнее,
  // чем closing-hint (это точная привязка границы, не просто визуальный
  // сигнал), чтобы не срабатывать случайно на любой точке рядом с чужим
  // участком.
  static const double _snapToEdgeThresholdMeters = 3.0;

  // Метод для добавления точки в центре карты
  void addPointAtRulerPosition() async {
    if (mapController == null) return;

    // Получаем центр карты
    final center = await mapController!.getVisibleRegion();
    final centerLat =
        (center.northeast.latitude + center.southwest.latitude) / 2;
    final centerLng =
        (center.northeast.longitude + center.southwest.longitude) / 2;
    LatLng centerPosition = LatLng(centerLat, centerLng);

    // Snap-to-edge: если крестик рядом с границей уже существующего
    // соседнего участка — прилипаем к ней, чтобы не оставлять узкую
    // полоску незанятой земли между двумя смежными плантациями из-за
    // ручной неточности постановки точки.
    var bestSnapDistance = double.infinity;
    (double, double)? bestSnapPoint;
    for (final polygon in nearbyPolygons) {
      final polygonCoords =
          polygon.points.map((p) => (p.latitude, p.longitude)).toList();
      final (snapPoint, distance) = GeoUtils.nearestPointOnPolygonEdge(
        centerPosition.latitude,
        centerPosition.longitude,
        polygonCoords,
      );
      if (distance < bestSnapDistance) {
        bestSnapDistance = distance;
        bestSnapPoint = snapPoint;
      }
    }
    if (bestSnapPoint != null &&
        bestSnapDistance <= _snapToEdgeThresholdMeters) {
      final (snapLat, snapLng) = bestSnapPoint;
      centerPosition = LatLng(snapLat, snapLng);
    }

    // Тактильное подтверждение — единственный визуальный отклик на тап
    // "+" это крохотная точка где-то на карте, легко не заметить сам
    // факт, что точка встала.
    HapticFeedback.lightImpact();

    // Добавляем точку в центре карты
    drawingPoints.add(centerPosition);

    // Также обновляем polylineCoordinates для совместимости с существующей логикой
    polylineCoordinates.add(centerPosition);

    // Рассчитываем расстояние до предыдущей точки
    if (drawingPoints.length > 1) {
      final distance = calculateDistance(
          drawingPoints[drawingPoints.length - 2],
          drawingPoints[drawingPoints.length - 1]);
      segmentDistances.add(distance);
    }

    _updateDrawingElements();
    _safeNotifyListeners();
  }

  void _updateDrawingElements() async {
    // Очищаем все элементы рисования
    polylines.clear();
    polygons.clear();

    // Всегда обновляем маркеры, даже если точек нет
    _updatePolygonMarkers();

    // Если есть точки, рисуем линии и полигон
    if (drawingPoints.isNotEmpty) {
      // Получаем центр карты для непрерывной линии
      LatLng? centerPosition;
      if (mapController != null) {
        try {
          final center = await mapController!.getVisibleRegion();
          final centerLat =
              (center.northeast.latitude + center.southwest.latitude) / 2;
          final centerLng =
              (center.northeast.longitude + center.southwest.longitude) / 2;
          centerPosition = LatLng(centerLat, centerLng);
        } catch (e) {
          debugPrint('Error getting map center: $e');
        }
      }

      // Если есть минимум 3 точки, весь уже отмеченный контур рисуется
      // обводкой полигона (Polygon.strokeColor) — раньше та же линия
      // ЕЩЁ РАЗ дублировалась отдельным Polyline (width 4) поверх
      // Polygon.strokeWidth (2), из-за чего сегменты между уже
      // поставленными точками визуально были толще, чем последний
      // "прицельный" сегмент до центра карты, который рисуется только
      // как Polyline. Теперь Polyline — только этот последний сегмент.
      if (drawingPoints.length >= 3) {
        polygons.add(
          Polygon(
            polygonId: const PolygonId('drawing_polygon'),
            points: List<LatLng>.from(drawingPoints),
            fillColor: design_colors.AppColors.info.withValues(alpha: 0.3),
            strokeColor: design_colors.AppColors.info,
            strokeWidth: 4,
          ),
        );
      }

      // Линия-прицел от последней поставленной точки до центра карты —
      // показывает, куда встанет следующая точка.
      if (centerPosition != null && drawingPoints.isNotEmpty) {
        polylines.add(Polyline(
          polylineId: const PolylineId("drawing_polyline"),
          points: [drawingPoints.last, centerPosition],
          color: design_colors.AppColors.info,
          width: 4,
          patterns: [], // Сплошная линия
        ));
      }

      // Меньше 3 точек — полигон ещё не сформирован, просто рисуем
      // цепочку уже поставленных точек одной линией.
      if (drawingPoints.length >= 2 && drawingPoints.length < 3) {
        polylines.add(Polyline(
          polylineId: const PolylineId("drawing_polyline_chain"),
          points: List<LatLng>.from(drawingPoints),
          color: design_colors.AppColors.info,
          width: 4,
          patterns: [],
        ));
      }
    }
  }

  // Новый метод для обновления маркеров точек полигона с поддержкой drag
  void _updatePolygonMarkers() {
    debugPrint(
        '_updatePolygonMarkers called: drawingPoints.length = ${drawingPoints.length}, isDrawingMode = $isDrawingMode');

    // Удаляем только маркеры точек рисования пользователя, оставляем маркер локации
    markers.removeWhere((marker) =>
        marker.markerId.value.startsWith('drawing_point_') ||
        marker.markerId.value == 'current_location' ||
        marker.markerId.value == 'ruler_marker');

    // Восстанавливаем маркер текущей локации если есть
    if (userArrowIcon != null && currentLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: currentLocation!,
          icon: userArrowIcon!,
          rotation: userHeading,
          anchor: const Offset(0.5, 0.5),
          infoWindow: const InfoWindow(title: 'Сиз бу ерда'),
        ),
      );
      debugPrint('Added current location marker');
    }

    // Центральная точка больше не нужна, так как есть линейка в центре экрана

    // Добавляем маркеры для каждой точки рисования — кастомная
    // номерованная иконка (createPolygonVertexIcon) вместо родовой жёлтой
    // Google-капли, согласована по цвету с info-синей линией/полигоном
    // рисования. Пока номер ещё не в кэше — временный fallback-маркер,
    // подменяется на кастомный асинхронно без блокировки текущего кадра.
    for (int i = 0; i < drawingPoints.length; i++) {
      final point = drawingPoints[i];
      final number = i + 1;
      final cachedIcon = _vertexIconCache[number];

      markers.add(
        Marker(
          markerId: MarkerId('drawing_point_$i'),
          position: point,
          icon: cachedIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          anchor: const Offset(0.5, 0.5),
          draggable: true,
          onDragEnd: (newPosition) => _onDrawingPointDragged(i, newPosition),
          infoWindow: InfoWindow(
            title: 'Нуқта $number',
            snippet: i > 0
                ? '${segmentDistances[i - 1].toStringAsFixed(2)} м'
                : null,
          ),
        ),
      );

      if (cachedIcon == null) {
        _loadVertexIcon(number);
      }
    }

    // Добавляем белую круглую линейку в центре карты если в режиме рисования
    if (isDrawingMode && rulerIcon != null) {
      // Линейка будет отображаться через виджет, а не через маркер
      // Это обеспечит её фиксацию в центре экрана
    }

    debugPrint('Total markers: ${markers.length}');
  }

  final Set<int> _pendingVertexIcons = {};

  Future<void> _loadVertexIcon(int number) async {
    if (_vertexIconCache.containsKey(number) ||
        _pendingVertexIcons.contains(number)) {
      return;
    }
    _pendingVertexIcons.add(number);
    try {
      _vertexIconCache[number] =
          await MarkerIconUtils.createPolygonVertexIcon(number);
      _updatePolygonMarkers();
      _safeNotifyListeners();
    } catch (e) {
      debugPrint('Failed to load polygon vertex icon $number: $e');
    } finally {
      _pendingVertexIcons.remove(number);
    }
  }

  // Обработчик перемещения точки рисования
  void _onDrawingPointDragged(int index, LatLng newPosition) {
    if (index < 0 || index >= drawingPoints.length) return;
    drawingPoints[index] = newPosition;

    // Также обновляем polylineCoordinates для совместимости
    if (index < polylineCoordinates.length) {
      polylineCoordinates[index] = newPosition;
    }

    // Пересчитываем расстояния
    if (index > 0) {
      segmentDistances[index - 1] =
          calculateDistance(drawingPoints[index - 1], drawingPoints[index]);
    }
    if (index < drawingPoints.length - 1) {
      segmentDistances[index] =
          calculateDistance(drawingPoints[index], drawingPoints[index + 1]);
    }

    _updateDrawingElements();
    _safeNotifyListeners();
  }

  void removeLastPoint() {
    if (drawingPoints.isNotEmpty) {
      HapticFeedback.selectionClick();
      drawingPoints.removeLast();
      // Также удаляем из polylineCoordinates для совместимости
      if (polylineCoordinates.isNotEmpty) {
        polylineCoordinates.removeLast();
      }
      if (segmentDistances.isNotEmpty) {
        segmentDistances.removeLast();
      }
      _updateDrawingElements();
      _safeNotifyListeners();
    }
  }

  void removeAllPoint() {
    clearDrawing();
  }

  void clearDrawing() {
    drawingPoints.clear();
    polylineCoordinates.clear(); // Также очищаем polylineCoordinates
    segmentDistances.clear();
    isPolygonComplete = false;
    _updateDrawingElements();
    _safeNotifyListeners();
  }

  double getPolygonArea() {
    if (drawingPoints.length < 3) return 0.0;
    // Конвертируем из квадратных метров в гектары (1 га = 10,000 м²)
    return calculatePolygonArea(drawingPoints) / 10000.0;
  }

  Future<void> requestLocationPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    isLocationPermissionGranted = permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;

    _safeNotifyListeners();
  }

  List<Coordinate> cordinatesConverter() {
    List<Coordinate> coordinates = polylineCoordinates.map((point) {
      return Coordinate(
        latitude: point.latitude,
        longitude: point.longitude,
      );
    }).toList();

    return coordinates;
  }

  // Проверка пересечения двух полигонов
  bool doPolygonsIntersect(List<LatLng> polygon1, List<LatLng> polygon2) {
    // Проверяем, пересекаются ли стороны полигонов
    for (int i = 0; i < polygon1.length; i++) {
      int next1 = (i + 1) % polygon1.length;
      for (int j = 0; j < polygon2.length; j++) {
        int next2 = (j + 1) % polygon2.length;
        if (_doSegmentsIntersect(
            polygon1[i], polygon1[next1], polygon2[j], polygon2[next2])) {
          return true;
        }
      }
    }

    // Проверяем, находится ли один полигон внутри другого
    if (polygon1.isNotEmpty && polygon2.isNotEmpty) {
      if (_isPointInPolygon(polygon1[0], polygon2)) {
        return true;
      }
      if (_isPointInPolygon(polygon2[0], polygon1)) {
        return true;
      }
    }

    return false;
  }

  // Проверка пересечения двух отрезков
  bool _doSegmentsIntersect(LatLng p1, LatLng p2, LatLng p3, LatLng p4) {
    double d1 = _direction(p3, p4, p1);
    double d2 = _direction(p3, p4, p2);
    double d3 = _direction(p1, p2, p3);
    double d4 = _direction(p1, p2, p4);

    if (((d1 > 0 && d2 < 0) || (d1 < 0 && d2 > 0)) &&
        ((d3 > 0 && d4 < 0) || (d3 < 0 && d4 > 0))) {
      return true;
    }

    if (d1 == 0 && _onSegment(p3, p4, p1)) return true;
    if (d2 == 0 && _onSegment(p3, p4, p2)) return true;
    if (d3 == 0 && _onSegment(p1, p2, p3)) return true;
    if (d4 == 0 && _onSegment(p1, p2, p4)) return true;

    return false;
  }

  // Вычисление направления для проверки пересечения
  double _direction(LatLng p1, LatLng p2, LatLng p3) {
    return (p3.longitude - p1.longitude) * (p2.latitude - p1.latitude) -
        (p2.longitude - p1.longitude) * (p3.latitude - p1.latitude);
  }

  // Проверка, находится ли точка на отрезке
  bool _onSegment(LatLng p1, LatLng p2, LatLng p) {
    return p.latitude <= max(p1.latitude, p2.latitude) &&
        p.latitude >= min(p1.latitude, p2.latitude) &&
        p.longitude <= max(p1.longitude, p2.longitude) &&
        p.longitude >= min(p1.longitude, p2.longitude);
  }

  // Проверка пересечения нового полигона с существующими плантациями
  bool checkPolygonOverlap() {
    if (drawingPoints.length < 3) {
      return false;
    }

    // Проверяем пересечение с каждой существующей плантацией
    for (final plantation in userPlantations) {
      if (plantation.coordinates.isEmpty || plantation.coordinates.length < 3) {
        continue;
      }

      // Конвертируем координаты плантации в LatLng
      List<LatLng> plantationCoords = plantation.coordinates
          .map((coord) => LatLng(coord.latitude, coord.longitude))
          .toList();

      // Проверяем пересечение
      if (doPolygonsIntersect(drawingPoints, plantationCoords)) {
        debugPrint('Overlap detected with plantation ${plantation.id}');
        return true;
      }
    }

    return false;
  }

  /// Загрузить лимит координат из storage
  Future<void> loadLimitKm() async {
    final storedLimitKm = await AppStorage.$readDouble(key: StorageKey.limitKm);
    _limitKm = storedLimitKm ?? 1.0; // Дефолт 1 км если не установлен
    debugPrint('📍 Loaded coordinate limit: $_limitKm km');
  }

  /// Валидировать координаты с учетом лимита
  /// Возвращает null если валидно, иначе сообщение об ошибке
  String? validateCoordinatesWithLimit(
      List<LatLng> coordinates, LatLng? currentLocation) {
    if (currentLocation == null) {
      return "Foydalanuvchi joylashuvi aniqlanmadi";
    }

    if (isMockedLocation) {
      return "Aniqlangan joylashuv soxta (mock location). Fake GPS dasturlarini "
          "o'chiring va qayta urinib ko'ring";
    }

    if (coordinates.length < 3) {
      return "Madyon to'gri kiritilmadi";
    }

    // Проверяем, находится ли пользователь внутри полигона
    final isInside = _isPointInPolygon(currentLocation, coordinates);

    // Если не внутри, проверяем минимальное расстояние
    if (!isInside) {
      final minDistance = findMinimumDistance(coordinates, currentLocation);
      final limitMeters = _limitKm * 1000; // Конвертируем км в метры

      if (minDistance > limitMeters) {
        return "Foydalanuvchi kiritilgan maydonning ${_limitKm.toStringAsFixed(_limitKm.truncateToDouble() == _limitKm ? 0 : 1)} km radiusida emas";
      }
    }

    return null; // Валидно
  }

  Future<void> getCurrentLocation() async {
    if (!isLocationPermissionGranted) {
      await requestLocationPermission();
    }

    // Загружаем лимит координат при инициализации
    await loadLimitKm();

    _setLoading(true);
    try {
      if (isLocationPermissionGranted) {
        final position = await Geolocator.getCurrentPosition(
            locationSettings:
                const LocationSettings(accuracy: LocationAccuracy.high));
        isMockedLocation = position.isMocked;
        currentLocation = LatLng(position.latitude, position.longitude);
        centerPoint = currentLocation; // Обновляем центральную точку
        debugPrint(
            'Got real location: ${currentLocation!.latitude}, ${currentLocation!.longitude}');
      } else {
        // Используем дефолтное местоположение если нет разрешения
        currentLocation = uzbLatLng;
        centerPoint = currentLocation; // Обновляем центральную точку
        debugPrint(
            'Using default location: ${currentLocation!.latitude}, ${currentLocation!.longitude}');
      }

      // Загружаем иконку пользователя
      await loadUserArrowIcon();

      // Добавляем маркер текущего местоположения только если иконка загружена
      if (userArrowIcon != null) {
        markers.removeWhere(
            (marker) => marker.markerId.value == 'current_location');
        markers.add(
          Marker(
            markerId: const MarkerId('current_location'),
            position: currentLocation!,
            icon: userArrowIcon!,
            rotation: userHeading,
            anchor: const Offset(0.5, 0.5),
            infoWindow: const InfoWindow(title: 'Сиз бу ерда'),
          ),
        );
      }

      // Загружаем соседние плантации после получения местоположения
      loadNearbyPlantations();

      if (mapController != null && currentLocation != null) {
        mapController!.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: currentLocation!, zoom: 18),
        ));
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
      // В случае ошибки используем дефолтное местоположение
      currentLocation = uzbLatLng;
      debugPrint(
          'Using default location due to error: ${currentLocation!.latitude}, ${currentLocation!.longitude}');

      // Загружаем иконку пользователя
      await loadUserArrowIcon();

      // Загружаем соседние плантации
      loadNearbyPlantations();
    } finally {
      _setLoading(false);
      _safeNotifyListeners();
    }
  }

  // ============= CLUSTERING (native google_maps_flutter ClusterManager) =============

  void _initClusterManager() {
    // Native cluster manager auto-clusters markers that carry our
    // clusterManagerId. Nothing to wire up beyond marker creation.
  }

  void onClusterCameraMove(CameraPosition position) {
    if (position.zoom == _currentZoom) return;
    final wasVisible = arePolygonsVisible;
    _currentZoom = position.zoom;
    if (wasVisible != arePolygonsVisible) {
      _safeNotifyListeners();
    }
  }

  Future<void> onClusterTap(Cluster cluster) async {
    if (mapController == null) return;
    final targetZoom = (_currentZoom + 2).clamp(10.0, 18.0);
    await mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: cluster.position, zoom: targetZoom),
      ),
    );
  }
}
