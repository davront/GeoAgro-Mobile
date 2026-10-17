import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import '../../../core/utils/dio_error_utils.dart';
import '../../../data/repository/app_repository_impl.dart';
import '../../../../localization/app_strings.dart';

import '../../../data/model/farmer/district_area_stat_model.dart';
import '../../../data/model/farmer/farmer_statistics_model.dart';
import '../../../data/model/farmer/farmer_list_model.dart';

enum PlantationStatus { all, approved, rejected, pending }

extension PlantationStatusX on PlantationStatus {
  String get param => name;

  String get labelUz {
    switch (this) {
      case PlantationStatus.all:
        return "Barchasi";
      case PlantationStatus.approved:
        return "Tasdiqlangan";
      case PlantationStatus.rejected:
        return "Rad etilgan";
      case PlantationStatus.pending:
        return "Ko'rib chiqilmoqda";
    }
  }
}

class FarmersStatisticsVm extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
  List<FarmerData>? statistics;
  int? districtId;
  int? regionId;
  int? _defaultDistrictId;
  int? _defaultRegionId;
  PlantationStatus selectedStatus = PlantationStatus.all;

  final TextEditingController searchInnController = TextEditingController();
  bool isSearching = false;
  List<FarmerModel>? searchResults;
  String? searchErrorMessage;

  /// Статистика только по своему району (не по всему региону) — сервер
  /// отдаёт разбивку по всем районам региона, здесь оставляем только тот,
  /// что совпадает с districtId юзера.
  DistrictAreaStat? myDistrictStat;
  bool isLoadingDistrictStat = false;

  final AppRepositoryImpl _appRepositoryImpl = AppRepositoryImpl();
  bool _isDisposed = false;

  FarmersStatisticsVm();

  void _safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  Map<int, String> get regions => AppLocalizedMaps.regions;

  void setStatus(PlantationStatus status) {
    selectedStatus = status;
    fetchStatistics();
  }

  void setRegion(int? id) {
    if (id == null) {
      regionId = _defaultRegionId;
      districtId = _defaultDistrictId;
    } else {
      regionId = id;
      districtId = null;
    }
    fetchStatistics();
  }

  /// Инициализация (вызывается вручную при открытии страницы)
  Future<void> initialize() async {
    if (_isDisposed) {
      debugPrint(
          "📊 FarmersStatisticsVM: initialize() called but already disposed");
      return;
    }

    debugPrint("📊 FarmersStatisticsVM: initialize() called");
    if (districtId != null && statistics != null) {
      debugPrint("📊 FarmersStatisticsVM: Already initialized, skipping");
      return;
    }
    isLoading = true;
    _safeNotifyListeners();
    debugPrint("📊 FarmersStatisticsVM: Getting district/region IDs...");
    await _getDistrictAndRegionIds();

    if (_isDisposed) {
      debugPrint(
          "📊 FarmersStatisticsVM: Disposed after _getDistrictId, aborting");
      return;
    }

    if (districtId != null || regionId != null) {
      debugPrint(
          "📊 FarmersStatisticsVM: IDs found: districtId=$districtId, regionId=$regionId");
      await fetchStatistics();
      unawaited(fetchMyDistrictStat());
    } else {
      debugPrint("❌ FarmersStatisticsVM: District/Region IDs not found");
      if (!_isDisposed) {
        errorMessage = "Hudud ma'lumoti topilmadi";
        isLoading = false;
        _safeNotifyListeners();
      }
    }
  }

  Future<void> _getDistrictAndRegionIds() async {
    try {
      debugPrint("📊 FarmersStatisticsVM: Calling getUserInfo API...");
      final userInfoData = await _appRepositoryImpl.getUserInfo();
      if (userInfoData != null) {
        debugPrint("📊 FarmersStatisticsVM: getUserInfo response received");
        final userInfo = jsonDecode(userInfoData);
        districtId = userInfo['district_id'];
        regionId = userInfo['region_id'];
        _defaultDistrictId = districtId;
        _defaultRegionId = regionId;
        debugPrint(
            "📊 FarmersStatisticsVM: District ID extracted: $districtId");
        debugPrint("📊 FarmersStatisticsVM: Region ID extracted: $regionId");
      } else {
        debugPrint("❌ FarmersStatisticsVM: getUserInfo returned null");
      }
    } catch (e) {
      debugPrint(
          "❌ FarmersStatisticsVM: Error getting district/region IDs: $e");
    }
  }

  Future<void> fetchStatistics() async {
    if (_isDisposed) {
      debugPrint(
          "📊 FarmersStatisticsVM: fetchStatistics() called but already disposed");
      return;
    }

    if (districtId == null && regionId == null) {
      debugPrint(
          "❌ FarmersStatisticsVM: Cannot fetch statistics - both districtId and regionId are null");
      return;
    }

    errorMessage = null;
    isLoading = true;
    _safeNotifyListeners();

    try {
      debugPrint(
          "📊 FarmersStatisticsVM: Fetching statistics for districtId=$districtId, regionId=$regionId, status=${selectedStatus.param}");
      final data = await _appRepositoryImpl.getFarmersStatistics(
        districtId: districtId,
        regionId: regionId,
        status: selectedStatus.param,
      );

      if (_isDisposed) {
        debugPrint(
            "📊 FarmersStatisticsVM: Disposed after getFarmersStatistics, aborting");
        return;
      }

      if (data == null) {
        debugPrint("❌ FarmersStatisticsVM: getFarmersStatistics returned null");
        if (!_isDisposed) {
          errorMessage = AppRepositoryImpl.lastErrorMessage ??
              "Server bilan bog'liq xatolik yuzaga keldi.";
        }
      } else {
        debugPrint("✅ FarmersStatisticsVM: Statistics data received");
        try {
          final jsonData = jsonDecode(data);
          if (jsonData is Map<String, dynamic> && jsonData['results'] != null) {
            final resultsJson = jsonEncode(jsonData['results']);
            statistics = farmerStatisticsModelFromJson(resultsJson);
            debugPrint(
                "✅ FarmersStatisticsVM: Parsed ${statistics?.length ?? 0} farmers");
          } else {
            statistics = farmerStatisticsModelFromJson(data);
            debugPrint(
                "✅ FarmersStatisticsVM: Parsed ${statistics?.length ?? 0} farmers (direct)");
          }
        } catch (jsonError) {
          debugPrint("❌ FarmersStatisticsVM: JSON Parsing Error: $jsonError");
          debugPrint("Raw data: $data");
          if (!_isDisposed) {
            errorMessage = "Ma'lumotlarni qayta ishlashda xatolik yuz berdi.";
          }
        }
      }
    } catch (e) {
      debugPrint("❌ FarmersStatisticsVM: Error fetching statistics: $e");
      if (!_isDisposed) {
        errorMessage = DioErrorUtils.messageFromAny(e);
      }
    } finally {
      if (!_isDisposed) {
        isLoading = false;
        _safeNotifyListeners();
        debugPrint("📊 FarmersStatisticsVM: fetchStatistics completed");
      }
    }
  }

  /// Загружает разбивку по районам региона и оставляет только строку
  /// district_id юзера — сервер не даёт эндпоинт "статистика одного
  /// района", только "весь регион", фильтруем на клиенте.
  Future<void> fetchMyDistrictStat() async {
    if (_isDisposed || regionId == null || districtId == null) return;

    isLoadingDistrictStat = true;
    _safeNotifyListeners();

    try {
      final data =
          await _appRepositoryImpl.getRegionDistrictsStatistics(regionId!);
      if (_isDisposed || data == null) return;

      final decoded = jsonDecode(data);
      if (decoded is! List) return;
      final all = districtAreaStatsFromJson(decoded);
      DistrictAreaStat? found;
      for (final d in all) {
        if (d.districtId == districtId) {
          found = d;
          break;
        }
      }
      myDistrictStat = found;
    } catch (e) {
      debugPrint("❌ FarmersStatisticsVM: fetchMyDistrictStat failed: $e");
    } finally {
      if (!_isDisposed) {
        isLoadingDistrictStat = false;
        _safeNotifyListeners();
      }
    }
  }

  Future<void> refresh() async {
    await fetchStatistics();
    unawaited(fetchMyDistrictStat());
  }

  Future<void> searchByInn() async {
    if (_isDisposed) return;

    final innText = searchInnController.text.trim();
    if (innText.isEmpty) {
      searchErrorMessage = "INN kiriting";
      searchResults = null;
      _safeNotifyListeners();
      return;
    }

    try {
      final inn = int.tryParse(innText);
      if (inn == null) {
        searchErrorMessage = "Noto'g'ri INN formati";
        searchResults = null;
        _safeNotifyListeners();
        return;
      }

      isSearching = true;
      searchErrorMessage = null;
      _safeNotifyListeners();

      final data = await _appRepositoryImpl.searchFarmers(inn: inn);

      if (_isDisposed) return;

      if (data == null) {
        searchErrorMessage = "Server bilan bog'liq xatolik yuzaga keldi.";
        searchResults = null;
      } else {
        try {
          final model = farmerListModelFromJson(data);
          if (model.results != null && model.results!.isNotEmpty) {
            searchResults = model.results;
            searchErrorMessage = null;
          } else {
            searchErrorMessage = "Bunday INN bo'yicha fermer topilmadi";
            searchResults = null;
          }
        } catch (jsonError) {
          log("JSON Parsing Error: $jsonError");
          log("Raw data: $data");
          searchErrorMessage =
              "Ma'lumotlarni qayta ishlashda xatolik yuz berdi.";
          searchResults = null;
        }
      }
    } catch (e) {
      log("Error searching by INN: $e");
      if (!_isDisposed) {
        searchErrorMessage = "Internet bilan bog'liq muammo yuzaga keldi.";
        searchResults = null;
      }
    } finally {
      if (!_isDisposed) {
        isSearching = false;
        _safeNotifyListeners();
      }
    }
  }

  void onSearchChanged(String value) {
    _safeNotifyListeners();
  }

  void clearSearch() {
    if (_isDisposed) return;
    searchInnController.clear();
    searchResults = null;
    searchErrorMessage = null;
    _safeNotifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    searchInnController.dispose();
    super.dispose();
  }
}
