// import 'dart:developer';

// import 'package:flutter/material.dart';
import '../../../core/utils/dio_error_utils.dart';
import '../../../data/repository/app_repository_impl.dart';
// import 'package:agro_employee_public/src/data/model/farmer/farmer_list_model.dart';

// // import '../../../data/model/farmer/fermer_model.dart';
// import '../../../data/repository/app_repository_impl.dart';

// class FermerVm extends ChangeNotifier {
//   bool isLoading = true;
//   bool canLoad = true;
//   bool isFetchingMore = false;

//   int currentPage = 1;
//   String? errorMessage;
//   List<FermerModel> fermersList = [];

//   final AppRepositoryImpl _appRepositoryImpl = AppRepositoryImpl();

//   FermerVm() {
//     getFermers();
//   }

//   void _setLoading(bool value) {
//     isLoading = value;
//     notifyListeners();
//   }

//   void _setFetchingMore(bool value) {
//     isFetchingMore = value;
//     notifyListeners();
//   }

//   Future<void> getFermers({bool isLoadMore = false}) async {
//     if (!canLoad || (isLoadMore && isFetchingMore)) return; // Agar yuklash mumkin bo'lmasa, qaytib chiq
//     errorMessage = null;

//     if (!isLoadMore) {
//       currentPage = 1; // Sahifa raqamini boshidan boshlash
//       canLoad = true; // Qaytadan yuklash imkonini yoqish
//       fermersList.clear(); // Roʻyxatni tozalash
//       _setLoading(true);
//     } else {
//       _setFetchingMore(true);
//     }

//     try {
//       final data = await _appRepositoryImpl.getFermersList(page: currentPage);

//       if (data == null) {
//         errorMessage = AppRepositoryImpl.lastErrorMessage ?? "Server bilan bog'liq xatolik yuzaga keldi.";
//         canLoad = true;
//       } else {
//         try {
//           final model = farmerListModelFromJson(data);
//           fermersList.addAll(model.results ?? []);
//           currentPage++;
//           canLoad = model.next != null; // Agar `next` mavjud bo'lmasa, yuklashni to'xtatish
//         } catch (jsonError) {
//           log("Json Parsing Error $jsonError");
//           errorMessage = "Ma'lumotlarni qayta ishlashda xatolik yuz berdi.";
//           canLoad = false;
//         }
//       }
//     } catch (e) {
//       errorMessage = DioErrorUtils.messageFromAny(e);
//       canLoad = true;
//     } finally {
//       if (isLoadMore) {
//         _setFetchingMore(false);
//       } else {
//         _setLoading(false);
//       }
//     }
//   }
// }

import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:agro_employee_public/src/data/model/farmer/farmer_list_model.dart';

class FermerVm extends ChangeNotifier {
  bool isLoading = false; // Umumiy yuklanish holati
  bool canLoad = true; // Qo'shimcha yuklashga ruxsat flagi
  bool isFetchingMore = false; // Cheksiz skroll uchun yuklanish flagi

  int currentPage = 1; // Joriy sahifa
  String? errorMessage; // Xatolik xabari
  List<FarmerModel> fermersList = []; // Fermerlar ro'yxati

  final AppRepositoryImpl _appRepositoryImpl = AppRepositoryImpl();

  bool _isInitialized = false;

  // Search functionality
  final TextEditingController searchInnController = TextEditingController();
  bool isSearching = false;
  List<FarmerModel>? searchResults;
  String? searchErrorMessage;

  FermerVm() {
    // Инициализация будет выполнена при первом обращении
  }

  void initialize() {
    debugPrint(
        "🌾 FermerVM: initialize() called, _isInitialized=$_isInitialized");
    if (!_isInitialized) {
      _isInitialized = true;
      debugPrint("🌾 FermerVM: First initialization, calling getFermers()");
      getFermers();
    } else {
      debugPrint("🌾 FermerVM: Already initialized, skipping");
    }
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void _setFetchingMore(bool value) {
    isFetchingMore = value;
    notifyListeners();
  }

  Future<void> getFermers({bool isLoadMore = false}) async {
    if ((!canLoad && isLoadMore) || (isLoadMore && isFetchingMore)) {
      debugPrint(
          "⏭️ Skipping getFermers: canLoad=$canLoad, isLoadMore=$isLoadMore, isFetchingMore=$isFetchingMore");
      return; // Yuklash mumkinligini tekshirish
    }

    debugPrint(
        "🌾 Starting getFermers: isLoadMore=$isLoadMore, currentPage=$currentPage");
    errorMessage = null;

    if (!isLoadMore) {
      currentPage = 1; // Sahifani boshidan boshlash
      canLoad = true; // Keyingi yuklash uchun ruxsat berish
      fermersList.clear(); // Ro'yxatni tozalash
      _setLoading(true);
    } else {
      _setFetchingMore(true);
    }

    try {
      // Ma'lumotlarni olish
      debugPrint("🌾 Fetching farmers from API, page: $currentPage");
      final data = await _appRepositoryImpl.getFermersList(page: currentPage);

      if (data == null) {
        debugPrint("❌ getFermers: data is null");
        errorMessage = AppRepositoryImpl.lastErrorMessage ??
            "Server bilan bog'liq xatolik yuzaga keldi.";
        canLoad = false; // Qo'shimcha yuklashni to'xtatish
        notifyListeners();
      } else {
        try {
          debugPrint("📦 Parsing farmers data, length: ${data.length}");
          final model = farmerListModelFromJson(data);

          if (model.results != null) {
            debugPrint("✅ Parsed ${model.results!.length} farmers");
            fermersList.addAll(model.results!); // Ro'yxatni to'ldirish
            currentPage++; // Sahifa raqamini oshirish
            canLoad = model.next != null; // `next` mavjudligini tekshirish
            debugPrint(
                "📊 Total farmers: ${fermersList.length}, canLoad: $canLoad, next: ${model.next}");
            notifyListeners();
          } else {
            debugPrint("⚠️ model.results is null");
            canLoad = false; // Ma'lumot yo'q bo'lsa, yuklashni to'xtatish
            notifyListeners();
          }
        } catch (jsonError) {
          debugPrint("❌ JSON Parsing Error: $jsonError");
          debugPrint(
              "❌ Data that failed to parse: ${data.substring(0, data.length > 500 ? 500 : data.length)}");
          errorMessage = "Ma'lumotlarni qayta ishlashda xatolik yuz berdi.";
          canLoad = false;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint("❌ Exception in getFermers: $e");
      errorMessage = DioErrorUtils.messageFromAny(e);
      canLoad = false; // Qo'shimcha yuklashni to'xtatish
      notifyListeners();
    } finally {
      if (isLoadMore) {
        _setFetchingMore(false); // Qo'shimcha yuklanishni o'chirish
      } else {
        _setLoading(false); // Umumiy yuklanishni o'chirish
      }
      debugPrint(
          "✅ getFermers completed: isLoading=$isLoading, isFetchingMore=$isFetchingMore, farmersCount=${fermersList.length}");
    }
  }

  Future<void> searchByInn() async {
    final innText = searchInnController.text.trim();
    if (innText.isEmpty) {
      searchErrorMessage = "INN yoki ID kiriting";
      searchResults = null;
      notifyListeners();
      return;
    }

    try {
      final number = int.tryParse(innText);
      if (number == null) {
        searchErrorMessage = "Noto'g'ri format";
        searchResults = null;
        notifyListeners();
        return;
      }

      isSearching = true;
      searchErrorMessage = null;
      notifyListeners();

      final data = await _appRepositoryImpl.searchFarmers(inn: number);

      if (data != null) {
        try {
          final model = farmerListModelFromJson(data);
          if (model.results != null && model.results!.isNotEmpty) {
            searchResults = model.results;
            searchErrorMessage = null;
            return;
          }
        } catch (jsonError) {
          log("JSON Parsing Error (INN search): $jsonError");
        }
      }

      if (innText.length < 9) {
        final idData = await _appRepositoryImpl.getFarmerById(number);
        if (idData != null) {
          try {
            final json = jsonDecode(idData);
            if (json is Map<String, dynamic> && json['id'] != null) {
              final farmer = FarmerModel.fromJson(json);
              searchResults = [farmer];
              searchErrorMessage = null;
              return;
            }
          } catch (e) {
            log("ID search parse error: $e");
          }
        }
      }

      searchErrorMessage = "Bunday INN yoki ID bo'yicha fermer topilmadi";
      searchResults = null;
    } catch (e) {
      log("Error searching: $e");
      searchErrorMessage = "Internet bilan bog'liq muammo yuzaga keldi.";
      searchResults = null;
    } finally {
      isSearching = false;
      notifyListeners();
    }
  }

  void onSearchChanged(String value) {
    notifyListeners();
  }

  void clearSearch() {
    searchInnController.clear();
    searchResults = null;
    searchErrorMessage = null;
    notifyListeners();
  }

  // Update farmer name
  bool isUpdating = false;
  String? updateErrorMessage;

  Future<bool> updateFarmerName(
      {required int id, required String newName}) async {
    isUpdating = true;
    updateErrorMessage = null;
    notifyListeners();

    try {
      log("UpdateFarmerName: Starting update for farmer $id with name: $newName");

      // Сначала получаем текущие данные фермера
      final farmerData = await _appRepositoryImpl.getFarmerById(id);
      if (farmerData == null) {
        updateErrorMessage = "Fermer ma'lumotlari topilmadi";
        isUpdating = false;
        notifyListeners();
        log("UpdateFarmerName: Farmer data not found");
        return false;
      }

      // Парсим данные фермера
      final farmerJson = jsonDecode(farmerData);
      final farmerModel = FarmerModel.fromJson(farmerJson);

      // Преобразуем в Map для отправки
      final updateData = farmerModel.toJson();
      // Обновляем только поле name
      updateData["name"] = newName;

      log("UpdateFarmerName: Sending update with all farmer data, updating name to: $newName");

      final response = await _appRepositoryImpl.updateFarmer(
        id: id,
        data: updateData,
      );

      log("UpdateFarmerName: Response status: ${response.statusCode}, data: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Обновляем название в локальном списке
        final farmerIndex = fermersList.indexWhere((f) => f.id == id);
        if (farmerIndex != -1) {
          fermersList[farmerIndex].name = newName;
        }

        // Обновляем в результатах поиска, если есть
        if (searchResults != null) {
          final searchIndex = searchResults!.indexWhere((f) => f.id == id);
          if (searchIndex != -1) {
            searchResults![searchIndex].name = newName;
          }
        }

        isUpdating = false;
        notifyListeners();
        log("UpdateFarmerName: Success");
        return true;
      } else {
        // Извлекаем сообщение об ошибке из ответа
        String errorMsg = "Xatolik yuz berdi";
        if (response.data != null) {
          try {
            if (response.data is Map) {
              final dataMap = response.data as Map<String, dynamic>;
              if (dataMap.containsKey("detail")) {
                errorMsg = dataMap["detail"].toString();
              } else if (dataMap.containsKey("message")) {
                errorMsg = dataMap["message"].toString();
              } else if (dataMap.containsKey("error")) {
                errorMsg = dataMap["error"].toString();
              } else if (dataMap.containsKey("name")) {
                // Если есть ошибки валидации для поля name
                final nameErrors = dataMap["name"];
                if (nameErrors is List && nameErrors.isNotEmpty) {
                  errorMsg = nameErrors.first.toString();
                } else if (nameErrors is String) {
                  errorMsg = nameErrors;
                }
              }
            } else if (response.data is String) {
              errorMsg = response.data as String;
            }
          } catch (e) {
            log("UpdateFarmerName: Failed to parse error message: $e");
          }
        }

        updateErrorMessage = errorMsg;
        isUpdating = false;
        notifyListeners();
        log("UpdateFarmerName: Failed with status ${response.statusCode}: $errorMsg");
        return false;
      }
    } catch (e) {
      log("UpdateFarmerName: Exception: $e");
      updateErrorMessage = "Internet bilan bog'liq muammo yuzaga keldi.";
      isUpdating = false;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    searchInnController.dispose();
    super.dispose();
  }
}
