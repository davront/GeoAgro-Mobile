import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';

/// Сервис для загрузки и отображения границ района пользователя
class DistrictBoundaryService {
  static const String _regionsGeoJsonPath = 'assets/uzb-geojson/regions.geojson';
  
  /// Маппинг region_id -> название GeoJSON файла области
  static const Map<int, String> _regionToGeoJsonFile = {
    1: 'toshkent',
    2: 'andijon',
    3: 'buxoro',
    4: 'fargona',
    5: 'jizzax',
    6: 'qashqadaryo',
    7: 'navoiy',
    8: 'namangan',
    9: 'samarqand',
    10: 'sirdaryo',
    11: 'surxondaryo',
    12: 'qoraqalpogiston',
    13: 'xorazm',
  };

  /// Загружает GeoJSON границы района по district_id из assets
  /// Использует region_id для определения области, затем загружает границы области
  /// Примечание: В assets есть только файлы областей, поэтому загружаются границы области
  static Future<List<Polygon>> loadDistrictBoundaries(int districtId, {int? regionId}) async {
    try {
      debugPrint('📊 DistrictBoundaryService: Loading boundaries for district_id: $districtId, region_id: $regionId');
      
      // Используем region_id для загрузки границ области из assets
      // В assets есть только файлы областей, поэтому загружаем границы области
      if (regionId != null) {
        debugPrint('📁 DistrictBoundaryService: Loading region boundaries from assets for region_id: $regionId');
        return await loadRegionBoundaries(regionId);
      }

      debugPrint('❌ DistrictBoundaryService: Cannot load boundaries - no regionId provided');
      return [];
    } catch (e) {
      debugPrint('❌ DistrictBoundaryService: Error loading district boundaries: $e');
      return [];
    }
  }

  /// Загружает GeoJSON границы области по region_id (fallback метод)
  /// Возвращает список полигонов для отображения на карте
  static Future<List<Polygon>> loadRegionBoundaries(int regionId) async {
    try {
      // Получаем название файла по region_id
      final geoJsonFileName = _regionToGeoJsonFile[regionId];
      if (geoJsonFileName == null) {
        debugPrint('❌ DistrictBoundaryService: Unknown region_id: $regionId');
        return [];
      }

      // Загружаем GeoJSON файл из assets
      final geoJsonPath = 'assets/uzb-geojson/$geoJsonFileName.geojson';
      final String geoJsonString = await rootBundle.loadString(geoJsonPath);
      final Map<String, dynamic> geoJson = jsonDecode(geoJsonString);

      return _parseGeoJsonToPolygons(geoJson);
    } catch (e) {
      debugPrint('❌ DistrictBoundaryService: Error loading boundaries: $e');
      return [];
    }
  }

  /// Парсит GeoJSON и преобразует в полигоны для Google Maps
  static List<Polygon> _parseGeoJsonToPolygons(Map<String, dynamic> geoJson) {
    final List<Polygon> polygons = [];

    if (geoJson['type'] == 'FeatureCollection') {
      final features = geoJson['features'] as List<dynamic>?;
      if (features == null) return polygons;

      for (int i = 0; i < features.length; i++) {
        final feature = features[i] as Map<String, dynamic>;
        final geometry = feature['geometry'] as Map<String, dynamic>?;
        if (geometry == null) continue;

        final geometryType = geometry['type'] as String?;
        final coordinates = geometry['coordinates'] as dynamic;

        if (geometryType == 'Polygon' && coordinates != null) {
          final polygon = _createPolygonFromCoordinates(coordinates, 'polygon_$i');
          if (polygon != null) {
            polygons.add(polygon);
          }
        } else if (geometryType == 'MultiPolygon' && coordinates != null) {
          // MultiPolygon содержит массив полигонов
          final multiPolygon = coordinates as List<dynamic>;
          for (int j = 0; j < multiPolygon.length; j++) {
            final polygon = _createPolygonFromCoordinates(multiPolygon[j], 'multipolygon_${i}_$j');
            if (polygon != null) {
              polygons.add(polygon);
            }
          }
        }
      }
    }

    debugPrint('✅ DistrictBoundaryService: Parsed ${polygons.length} polygons');
    return polygons;
  }

  /// Создает Polygon из координат GeoJSON
  static Polygon? _createPolygonFromCoordinates(dynamic coordinates, String id) {
    try {
      // coordinates для Polygon: [[[lng, lat], [lng, lat], ...]]
      // Первый элемент - внешнее кольцо
      final ring = coordinates as List<dynamic>;
      if (ring.isEmpty) return null;

      final outerRing = ring[0] as List<dynamic>;
      final points = <LatLng>[];

      for (final coord in outerRing) {
        if (coord is List && coord.length >= 2) {
          final lng = (coord[0] as num).toDouble();
          final lat = (coord[1] as num).toDouble();
          points.add(LatLng(lat, lng));
        }
      }

      if (points.isEmpty) return null;

      return Polygon(
        polygonId: PolygonId(id),
        points: points,
        strokeColor: Colors.white,
        strokeWidth: 2,
        fillColor: Colors.white.withValues(alpha: 0.05),
      );
    } catch (e) {
      debugPrint('❌ DistrictBoundaryService: Error creating polygon: $e');
      return null;
    }
  }

  /// Загружает границы области из regions.geojson по region_id
  /// Использует regions.geojson для поиска конкретной области
  static Future<List<Polygon>> loadRegionBoundariesFromRegionsFile(int regionId) async {
    try {
      final String geoJsonString = await rootBundle.loadString(_regionsGeoJsonPath);
      final Map<String, dynamic> geoJson = jsonDecode(geoJsonString);

      if (geoJson['type'] == 'FeatureCollection') {
        final features = geoJson['features'] as List<dynamic>?;
        if (features == null) return [];

        // Ищем feature с нужным region_id
        // В regions.geojson нужно найти feature по region_id
        // Но в файле может не быть прямого region_id, используем маппинг по названию
        final regionName = _getRegionNameById(regionId);
        if (regionName == null) {
          debugPrint('❌ DistrictBoundaryService: Unknown region_id: $regionId');
          return [];
        }

        for (int i = 0; i < features.length; i++) {
          final feature = features[i] as Map<String, dynamic>;
          final properties = feature['properties'] as Map<String, dynamic>?;
          
          if (properties != null) {
            final name = properties['name']?.toString().toLowerCase() ?? '';
            final id = properties['id']?.toString().toLowerCase() ?? '';
            
            // Проверяем совпадение по названию или id
            if (name.contains(regionName.toLowerCase()) || 
                id.contains(regionName.toLowerCase())) {
              final geometry = feature['geometry'] as Map<String, dynamic>?;
              if (geometry != null) {
                return _parseGeometryToPolygons(geometry, 'region_$regionId');
              }
            }
          }
        }
      }

      debugPrint('❌ DistrictBoundaryService: Region not found in regions.geojson');
      return [];
    } catch (e) {
      debugPrint('❌ DistrictBoundaryService: Error loading from regions.geojson: $e');
      return [];
    }
  }

  /// Парсит geometry объект в полигоны
  static List<Polygon> _parseGeometryToPolygons(Map<String, dynamic> geometry, String baseId) {
    final List<Polygon> polygons = [];
    final geometryType = geometry['type'] as String?;
    final coordinates = geometry['coordinates'] as dynamic;

    if (geometryType == 'Polygon' && coordinates != null) {
      final polygon = _createPolygonFromCoordinates(coordinates, '${baseId}_0');
      if (polygon != null) {
        polygons.add(polygon);
      }
    } else if (geometryType == 'MultiPolygon' && coordinates != null) {
      final multiPolygon = coordinates as List<dynamic>;
      for (int j = 0; j < multiPolygon.length; j++) {
        final polygon = _createPolygonFromCoordinates(multiPolygon[j], '${baseId}_$j');
        if (polygon != null) {
          polygons.add(polygon);
        }
      }
    }

    return polygons;
  }

  /// Получает название области по region_id
  static String? _getRegionNameById(int regionId) {
    const Map<int, String> regionNames = {
      1: 'toshkent',
      2: 'andijon',
      3: 'buxoro',
      4: 'fargona',
      5: 'jizzax',
      6: 'qashqadaryo',
      7: 'navoiy',
      8: 'namangan',
      9: 'samarqand',
      10: 'sirdaryo',
      11: 'surxondaryo',
      12: 'qoraqalpogiston',
      13: 'xorazm',
    };
    return regionNames[regionId];
  }
}
