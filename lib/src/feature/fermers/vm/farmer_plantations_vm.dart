import 'package:flutter/material.dart';
import '../../../data/model/farmer/farmer_plantation_model.dart';
import '../../../data/repository/app_repository_impl.dart';
import 'dart:convert';

class FarmerPlantationsVm extends ChangeNotifier {
  final AppRepositoryImpl _appRepositoryImpl = AppRepositoryImpl();
  
  List<FarmerPlantation> _plantations = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _farmerInn = 0;
  bool _isDisposed = false;

  List<FarmerPlantation> get plantations => _plantations;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get farmerInn => _farmerInn;

  void _safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  Future<void> getFarmerPlantations({required int farmerInn}) async {
    if (_isDisposed) {
      debugPrint('FarmerPlantationsVm: Attempted to load plantations after dispose');
      return;
    }

    _farmerInn = farmerInn;
    _isLoading = true;
    _errorMessage = null;
    _safeNotifyListeners();

    debugPrint('FarmerPlantationsVm: Loading plantations for farmer INN: $farmerInn');

    try {
      final response = await _appRepositoryImpl.getFarmerPlantations(farmerInn: farmerInn);
      
      if (_isDisposed) {
        debugPrint('FarmerPlantationsVm: Disposed during API call, ignoring response');
        return;
      }
      
      debugPrint('FarmerPlantationsVm: API response received: ${response != null ? 'success' : 'null'}');
      
      if (response != null) {
        // Проверяем на ошибку 403 (Forbidden)
        if (response == "FORBIDDEN_403") {
          _errorMessage = "Sizga ruxsat berilmagan";
          debugPrint('FarmerPlantationsVm: Access forbidden (403)');
          _isLoading = false;
          _safeNotifyListeners();
          return;
        }
        
        final data = jsonDecode(response);
        debugPrint('FarmerPlantationsVm: Parsed data: $data');
        final farmerPlantationResponse = FarmerPlantationResponse.fromJson(data);
        _plantations = farmerPlantationResponse.results;
        debugPrint('FarmerPlantationsVm: Loaded ${_plantations.length} plantations');
      } else {
        _errorMessage = "Ma'lumotlar yuklanmadi";
        debugPrint('FarmerPlantationsVm: No data received from API');
      }
    } catch (e) {
      if (_isDisposed) {
        debugPrint('FarmerPlantationsVm: Disposed during error handling, ignoring');
        return;
      }
      _errorMessage = "Xatolik yuz berdi: ${e.toString()}";
      debugPrint('FarmerPlantationsVm: Error loading plantations: $e');
    } finally {
      if (!_isDisposed) {
        _isLoading = false;
        _safeNotifyListeners();
      }
    }
  }

  void clearPlantations() {
    if (_isDisposed) return;
    _plantations.clear();
    _errorMessage = null;
    _safeNotifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
