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
import '../drawing/drawing_controller.dart';
import '../drawing/polygon_validator.dart';
import '../drawing/snap_index.dart';
import 'dart:convert';

class CreateMapPageVm extends ChangeNotifier {
  final AppRepositoryImpl _appRepositoryImpl = AppRepositoryImpl();

  CreateMapPageVm() {
    drawing.addListener(_onPointsChanged);
  }

  GoogleMapController? mapController;
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

  // Рисование: точки — в DrawingController (обновляется по действию
  // агента), прицел — в ValueNotifier (обновляется каждый кадр движения
  // карты и не вызывает notifyListeners, чтобы не перестраивать GoogleMap).
  final DrawingController drawing = DrawingController();
  final ValueNotifier<Crosshair?> crosshair = ValueNotifier(null);
  SnapIndex? _snapIndex;
  List<PolygonIssue> issues = const [];
  LatLng? centerPoint; // Центральная точка для рисования

  List<LatLng> get drawingPoints => drawing.points;
  // Старое имя — его читает create_map_page при переходе на форму.
  List<LatLng> get polylineCoordinates => drawing.points;

  bool get canSubmit => issues.isEmpty;

  /// Полигон красный только из-за ошибок формы контура, не из-за GPS.
  bool get hasGeometryError => issues.any((i) =>
      i.kind == PolygonIssueKind.selfIntersection ||
      i.kind == PolygonIssueKind.overlap);

  /// Первая причина, по которой «Keyingi» неактивна.
  PolygonIssue? get blockingIssue => issues.isEmpty ? null : issues.first;

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
          isMockedLocation = position.isMocked;
          _updateUserArrowMarker();
          _revalidate();
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
    drawing.removeListener(_onPointsChanged);
    drawing.dispose();
    crosshair.dispose();
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

  // forme/map/ не зависит от местоположения (без параметров), поэтому
  // грузится один раз из onMapCreated — раньше его повторно дёргал
  // getCurrentLocation (при открытии и на каждый тап "моё
  // местоположение"), ~400 КБ впустую.
  Future<void> loadNearbyPlantations() async {
    if (isLoadingNearby) return;
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

    _snapIndex = SnapIndex(nearbyPolygons.map((p) => p.points));
    _revalidate();

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
      if (GeoUtils.isPointInPolygon(position.latitude, position.longitude,
          polygon.points.map((p) => (p.latitude, p.longitude)).toList())) {
        debugPrint('Tap detected inside polygon: ${polygon.polygonId.value}');
        onPolygonTap(polygon.polygonId);
        tappedOnPolygon = true;
        break;
      }
    }

    if (tappedOnPolygon) _safeNotifyListeners();
  }

  /// Ставит точку под прицел (или в точку прилипания к соседней границе).
  Future<void> addPointAtRulerPosition() async {
    var point = crosshair.value?.point;
    if (point == null) {
      // Камера ещё ни разу не двигалась — onCameraMove не приходил.
      final controller = mapController;
      if (controller == null) return;
      final region = await controller.getVisibleRegion();
      final center = LatLng(
        (region.northeast.latitude + region.southwest.latitude) / 2,
        (region.northeast.longitude + region.southwest.longitude) / 2,
      );
      point = _snapIndex?.query(center) ?? center;
    }
    // Тактильное подтверждение: сама точка на спутнике едва заметна.
    HapticFeedback.lightImpact();
    drawing.add(point);
  }

  void undo() {
    if (!drawing.canUndo) return;
    HapticFeedback.selectionClick();
    drawing.undo();
  }

  void redo() {
    if (!drawing.canRedo) return;
    HapticFeedback.selectionClick();
    drawing.redo();
  }

  void clearDrawing() => drawing.clear();

  void _onPointsChanged() {
    _revalidate();
    _updateDrawingElements();
    _safeNotifyListeners();
  }

  void _revalidate() {
    issues = PolygonValidator.validate(
      points: drawing.points,
      neighbours: [
        for (final p in userPlantations)
          if (p.coordinates.length >= 3)
            NeighbourPolygon(p.id,
                p.coordinates.map((c) => LatLng(c.latitude, c.longitude)).toList()),
      ],
      userLocation: currentLocation,
      isMockedLocation: isMockedLocation,
      limitKm: _limitKm,
    );
  }

  // Карта получает обновление только по изменению точек; линия к прицелу
  // и пунктир замыкания рисуются оверлеем (PreviewOverlay).
  void _updateDrawingElements() {
    polylines.clear();
    polygons.clear();
    _updatePolygonMarkers();

    final pts = drawing.points;
    final color = hasGeometryError
        ? design_colors.AppColors.error
        : design_colors.AppColors.info;
    if (pts.length >= 3) {
      polygons.add(
        Polygon(
          polygonId: const PolygonId('drawing_polygon'),
          points: List<LatLng>.from(pts),
          fillColor: color.withValues(alpha: 0.3),
          strokeColor: color,
          strokeWidth: 4,
        ),
      );
    } else if (pts.length == 2) {
      polylines.add(Polyline(
        polylineId: const PolylineId("drawing_polyline_chain"),
        points: List<LatLng>.from(pts),
        color: color,
        width: 4,
      ));
    }
  }

  // Новый метод для обновления маркеров точек полигона с поддержкой drag
  void _updatePolygonMarkers() {

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
    final drawingPoints = drawing.points;
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
                ? '${calculateDistance(drawingPoints[i - 1], point).toStringAsFixed(2)} м'
                : null,
          ),
        ),
      );

      if (cachedIcon == null) {
        _loadVertexIcon(number);
      }
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

  void _onDrawingPointDragged(int index, LatLng newPosition) =>
      drawing.moveTo(index, newPosition);

  double getPolygonArea() {
    if (drawing.points.length < 3) return 0.0;
    // Конвертируем из квадратных метров в гектары (1 га = 10,000 м²)
    return calculatePolygonArea(drawing.points) / 10000.0;
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

  /// Загрузить лимит координат из storage
  Future<void> loadLimitKm() async {
    final storedLimitKm = await AppStorage.$readDouble(key: StorageKey.limitKm);
    _limitKm = storedLimitKm ?? 1.0; // Дефолт 1 км если не установлен
    debugPrint('📍 Loaded coordinate limit: $_limitKm km');
    _revalidate();
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
    } finally {
      _revalidate();
      _setLoading(false);
      _safeNotifyListeners();
    }
  }

  // ============= CLUSTERING (native google_maps_flutter ClusterManager) =============

  void _initClusterManager() {
    // Native cluster manager auto-clusters markers that carry our
    // clusterManagerId. Nothing to wire up beyond marker creation.
  }

  /// Каждый кадр движения карты. Обновляет только [crosshair] — без
  /// notifyListeners, кроме смены видимости соседних полигонов по zoom.
  void onCameraMove(CameraPosition position) {
    final snap = _snapIndex?.query(position.target);
    if (snap != null && crosshair.value?.snapTarget == null) {
      HapticFeedback.selectionClick();
    }
    crosshair.value = Crosshair(position, snap);

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
