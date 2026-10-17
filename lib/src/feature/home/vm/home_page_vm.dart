import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';

import '../../../core/utils/dio_error_utils.dart';
import '../../../data/model/plantation/plantations_list_model.dart';
import '../../../data/repository/app_repository_impl.dart';

class HomePageVm extends ChangeNotifier {
  final AppRepositoryImpl _appRepositoryImpl;
  final List<Result> plantationsList = [];
  final List<Result> approvedList = [];
  final List<Result> pendingList = [];
  final List<Result> recheckList = [];
  final List<Result> rejectedList = [];

  bool _isLoading = false;
  bool _isFetchingMore = false;
  bool _isDeleting = false;
  String? errorMessage;
  String? deletMessage;
  int currentPage = 1;
  bool canLoadNext = true;
  String? _searchQuery;

  HomePageVm(this._appRepositoryImpl);

  bool get isLoading => _isLoading;
  bool get isFetchingMore => _isFetchingMore;
  bool get isDeleting => _isDeleting;
  bool get isSearching => (_searchQuery?.isNotEmpty ?? false);

  List<Result> get recheckPlantations => plantationsList
      .where((e) =>
          (e.isChecked == false) &&
          ((e.moderationComments?.isNotEmpty ?? false)))
      .toList();

  void _setLoading(bool value) {
    if (!_isLoading && value) {
      _isLoading = value;
      _safeNotifyListeners();
    } else if (_isLoading && !value) {
      _isLoading = value;
      _safeNotifyListeners();
    }
  }

  void _setFetchingMore(bool value) {
    if (!_isFetchingMore && value) {
      _isFetchingMore = value;
      _safeNotifyListeners();
    } else if (_isFetchingMore && !value) {
      _isFetchingMore = value;
      _safeNotifyListeners();
    }
  }

  void _setDeleting(bool value) {
    if (!_isDeleting && value) {
      _isDeleting = value;
      _safeNotifyListeners();
    } else if (_isDeleting && !value) {
      _isDeleting = value;
      _safeNotifyListeners();
    }
  }

  void _safeNotifyListeners() {
    try {
      if (!_disposed) {
        notifyListeners();
      }
    } catch (e) {
      // VM was disposed, ignore
    }
  }

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> getPlantationsModel(
      {bool isLoadMore = false, String? search}) async {
    if ((!canLoadNext && isLoadMore) || (isLoadMore && isFetchingMore)) return;

    if (search != _searchQuery && !isLoadMore) {
      _searchQuery = search;
    }

    try {
      errorMessage = null;
      if (!isLoadMore) {
        currentPage = 1;
        canLoadNext = true;
        plantationsList.clear();
        _setLoading(true);
      } else {
        _setFetchingMore(true);
      }

      final data = await _appRepositoryImpl.getPlantationsList(
        page: currentPage,
        search: _searchQuery,
      );

      if (data == null) {
        errorMessage = AppRepositoryImpl.lastErrorMessage ??
            "Server bilan bog'liq xatolik yuzaga keldi.";
      } else {
        try {
          log("Received data length: ${data.length}");
          final model = plantationsListModelFromJson(data);
          log("Parsed ${model.results?.length ?? 0} plantations for page $currentPage");

          final incomingItems = model.results ?? [];
          plantationsList.addAll(incomingItems);

          log("HOME PAGE $currentPage: Added ${incomingItems.length} plantations (search: $_searchQuery)");
          log("Total plantations: ${plantationsList.length}");

          currentPage++;
          canLoadNext = model.next != null;
        } catch (jsonError, stackTrace) {
          log("Json Parsing Error: $jsonError");
          log("Stack trace: $stackTrace");
          errorMessage = "Ma'lumotlarni qayta ishlashda xatolik yuz berdi.";
        }
      }
    } catch (e, stackTrace) {
      log("Error in getPlantationsModel: $e");
      log("Stack trace: $stackTrace");
      errorMessage = DioErrorUtils.messageFromAny(e);
    } finally {
      _setFetchingMore(false);
      _setLoading(false);
    }
  }

  Future<bool> deletePlantation({required int id}) async {
    deletMessage = null;
    debugPrint("Delete: Starting deletion for plantation ID: $id");
    _safeNotifyListeners();

    try {
      final data =
          await _appRepositoryImpl.deletePlantationModel(id: id, model: {});
      debugPrint(
          "Delete: Received data from repository: '$data' (type: ${data.runtimeType})");
      if (data == null) {
        deletMessage = "Server bilan bog'liq xatolik yuzaga keldi.";
        _safeNotifyListeners();
        return false;
      } else {
        // Проверяем на ошибку 403 (Forbidden)
        if (data == "FORBIDDEN_403") {
          deletMessage = "Sizga ruxsat berilmagan";
          return false;
        }

        // Сначала пытаемся распарсить как JSON, чтобы проверить на наличие ошибок
        try {
          // Пытаемся распарсить строку как JSON
          // data всегда String здесь, так как deletePlantationModel возвращает String?
          final trimmedData = data.trim();
          Map<String, dynamic> jsonData;
          if (trimmedData.startsWith('{') && trimmedData.endsWith('}')) {
            jsonData = jsonDecode(trimmedData) as Map<String, dynamic>;
          } else {
            // Если это не JSON, но содержит error, все равно пытаемся распарсить
            jsonData = jsonDecode(data) as Map<String, dynamic>;
          }

          // Проверяем на наличие поля "error" в ответе
          if (jsonData.containsKey("error")) {
            final errorMessage = jsonData["error"] is String
                ? jsonData["error"] as String
                : jsonData["error"].toString();
            debugPrint("Delete error detected: $errorMessage");
            deletMessage = errorMessage;
            _safeNotifyListeners();
            return false;
          }
        } catch (parseError) {
          // Если не удалось распарсить как валидный JSON, пытаемся извлечь ошибку из строки
          debugPrint("Delete: Failed to parse as JSON: $parseError");
          final dataStr = data.toString();

          // Проверяем, содержит ли строка формат {error: ...}
          if (dataStr.contains("error:") || dataStr.contains("{error")) {
            // Пытаемся извлечь сообщение об ошибке
            try {
              final originalData = data.toString();
              String? errorMessage;

              // Вариант 1: {error: message} - с фигурными скобками
              var errorMatch =
                  RegExp(r'\{error:\s*([^}]+)\}').firstMatch(originalData);
              if (errorMatch != null) {
                errorMessage = errorMatch.group(1)?.trim();
              }

              // Вариант 2: error: message - без фигурных скобок в начале
              if (errorMessage == null || errorMessage.isEmpty) {
                errorMatch =
                    RegExp(r'error:\s*([^}]+)').firstMatch(originalData);
                if (errorMatch != null) {
                  errorMessage = errorMatch.group(1)?.trim();
                  // Убираем закрывающую скобку, если она есть в конце
                  if (errorMessage != null && errorMessage.endsWith('}')) {
                    errorMessage = errorMessage
                        .substring(0, errorMessage.length - 1)
                        .trim();
                  }
                }
              }

              // Вариант 3: просто ищем текст после "error:" до конца строки или до закрывающей скобки
              if (errorMessage == null || errorMessage.isEmpty) {
                final errorIndex = originalData.toLowerCase().indexOf('error:');
                if (errorIndex != -1) {
                  final startIndex = errorIndex + 6; // длина "error:"
                  final endIndex = originalData.indexOf('}', startIndex);
                  if (endIndex != -1) {
                    errorMessage =
                        originalData.substring(startIndex, endIndex).trim();
                  } else {
                    errorMessage = originalData.substring(startIndex).trim();
                  }
                }
              }

              if (errorMessage != null && errorMessage.isNotEmpty) {
                debugPrint("Delete: Extracted error message: $errorMessage");
                deletMessage = errorMessage;
                _safeNotifyListeners();
                return false;
              }
            } catch (e) {
              debugPrint("Delete: Failed to extract error from string: $e");
            }

            // Если не удалось извлечь, используем общее сообщение
            deletMessage = "Plantatsiya topilmadi yoki o'chirib bo'lmaydi";
            _safeNotifyListeners();
            return false;
          }

          // Если это не ошибка, продолжаем обработку
          debugPrint("Delete: Not an error format, continuing...");

          // Пытаемся распарсить еще раз
          try {
            final jsonData = jsonDecode(dataStr) as Map<String, dynamic>;

            // Проверяем на ошибку 403 в JSON ответе
            if (jsonData.containsKey("detail") &&
                jsonData["detail"] is String) {
              final detail = jsonData["detail"] as String;
              if (detail.toLowerCase().contains("forbidden") ||
                  detail.toLowerCase().contains("ruxsat") ||
                  detail.toLowerCase().contains("доступ") ||
                  detail.toLowerCase().contains("permission")) {
                deletMessage = "Sizga ruxsat berilmagan";
                _safeNotifyListeners();
                return false;
              }
            }

            // Если есть id или detail без ошибки, считаем успехом
            if (jsonData.containsKey("id") || jsonData.containsKey("detail")) {
              deletMessage = jsonData["detail"]?.toString() ??
                  "Plantatsiya muvaffaqiyatli o'chirildi";
              plantationsList.removeWhere((plantation) => plantation.id == id);
              approvedList.removeWhere((plantation) => plantation.id == id);
              pendingList.removeWhere((plantation) => plantation.id == id);
              recheckList.removeWhere((plantation) => plantation.id == id);
              rejectedList.removeWhere((plantation) => plantation.id == id);
              _safeNotifyListeners();
              return true;
            }
          } catch (_) {
            // Если не удалось распарсить как JSON, проверяем строку
          }
        }

        // Проверяем строку на наличие "success"
        if (data == "success" ||
            data.toString().toLowerCase().contains("success")) {
          deletMessage = "Plantatsiya muvaffaqiyatli o'chirildi";
          plantationsList.removeWhere((plantation) => plantation.id == id);
          approvedList.removeWhere((plantation) => plantation.id == id);
          pendingList.removeWhere((plantation) => plantation.id == id);
          recheckList.removeWhere((plantation) => plantation.id == id);
          rejectedList.removeWhere((plantation) => plantation.id == id);
          _safeNotifyListeners();
          return true;
        } else {
          // Если не JSON и не success, проверяем на ошибки в строке
          try {
            // Пытаемся распарсить как JSON еще раз для проверки на ошибки
            final jsonData = jsonDecode(data) as Map<String, dynamic>;
            if (jsonData.containsKey("error")) {
              final errorMessage = jsonData["error"] is String
                  ? jsonData["error"] as String
                  : jsonData["error"].toString();
              debugPrint(
                  "Delete error detected in string parse: $errorMessage");
              deletMessage = errorMessage;
              _safeNotifyListeners();
              return false;
            }
          } catch (parseError) {
            debugPrint(
                "Delete: Failed to parse JSON in else block: $parseError, data: $data");
            // Если не удалось распарсить JSON, проверяем строку на наличие ключевых слов ошибки
            final dataStr = data.toString().toLowerCase();

            // Проверяем на ошибку 403
            if (dataStr.contains("forbidden") ||
                dataStr.contains("ruxsat") ||
                dataStr.contains("доступ") ||
                dataStr.contains("403")) {
              deletMessage = "Sizga ruxsat berilmagan";
              _safeNotifyListeners();
              return false;
            }

            // Проверяем на другие ошибки (например, "error", "no plantation", "matches")
            if (dataStr.contains("error") ||
                dataStr.contains("no plantation") ||
                dataStr.contains("matches") ||
                dataStr.contains("not found") ||
                dataStr.contains("query")) {
              // Пытаемся извлечь сообщение об ошибке из строки
              try {
                final originalData = data.toString();
                // Если строка содержит формат {error: message}, извлекаем сообщение
                if (originalData.contains("{") && originalData.contains("}")) {
                  // Пытаемся распарсить как валидный JSON
                  try {
                    final jsonData =
                        jsonDecode(originalData) as Map<String, dynamic>;
                    if (jsonData.containsKey("error")) {
                      deletMessage = jsonData["error"] is String
                          ? jsonData["error"] as String
                          : jsonData["error"].toString();
                      _safeNotifyListeners();
                      return false;
                    }
                  } catch (_) {
                    // Если не валидный JSON, извлекаем через регулярное выражение
                    // Формат: {error: No Plantation matches the given query.}
                    // Пробуем разные варианты регулярных выражений
                    String? errorMessage;

                    // Вариант 1: {error: message}
                    var errorMatchResult = RegExp(r'\{error:\s*([^}]+)\}')
                        .firstMatch(originalData);
                    if (errorMatchResult != null) {
                      errorMessage = errorMatchResult.group(1)?.trim();
                    }

                    // Вариант 2: error: message (без фигурных скобок)
                    if (errorMessage == null) {
                      errorMatchResult =
                          RegExp(r'error:\s*([^}]+)').firstMatch(originalData);
                      if (errorMatchResult != null) {
                        errorMessage = errorMatchResult.group(1)?.trim();
                      }
                    }

                    // Вариант 3: просто ищем текст после "error:"
                    if (errorMessage == null) {
                      final errorIndex =
                          originalData.toLowerCase().indexOf('error:');
                      if (errorIndex != -1) {
                        final startIndex = errorIndex + 6; // длина "error:"
                        final endIndex = originalData.indexOf('}', startIndex);
                        if (endIndex != -1) {
                          errorMessage = originalData
                              .substring(startIndex, endIndex)
                              .trim();
                        } else {
                          errorMessage =
                              originalData.substring(startIndex).trim();
                        }
                      }
                    }

                    if (errorMessage != null && errorMessage.isNotEmpty) {
                      debugPrint(
                          "Delete: Extracted error message from invalid JSON: $errorMessage");
                      deletMessage = errorMessage;
                      _safeNotifyListeners();
                      return false;
                    }
                  }
                }

                // Если не удалось извлечь, используем общее сообщение
                deletMessage = "Plantatsiya topilmadi yoki o'chirib bo'lmaydi";
              } catch (e) {
                debugPrint("Delete: Failed to extract error message: $e");
                deletMessage = "Plantatsiya topilmadi yoki o'chirib bo'lmaydi";
              }
              _safeNotifyListeners();
              return false;
            }
          }

          // Если нет признаков ошибки, считаем успехом
          debugPrint("Delete: No error detected, treating as success");
          deletMessage = "Plantatsiya muvaffaqiyatli o'chirildi";
          plantationsList.removeWhere((plantation) => plantation.id == id);
          approvedList.removeWhere((plantation) => plantation.id == id);
          pendingList.removeWhere((plantation) => plantation.id == id);
          recheckList.removeWhere((plantation) => plantation.id == id);
          rejectedList.removeWhere((plantation) => plantation.id == id);
          _safeNotifyListeners();
          return true;
        }
      }
    } catch (e) {
      deletMessage = "Internet bilan bog'liq muammo yuzaga keldi.";
      debugPrint("Delete plantation error: $e");
      return false;
    } finally {
      _safeNotifyListeners();
    }
  }

  Future<bool> deletePlantationPermanently(
      {required int id, String? reason}) async {
    deletMessage = null;
    debugPrint(
        "Delete: Starting permanent deletion request for plantation ID: $id");

    _setDeleting(true);
    _safeNotifyListeners();

    try {
      final data =
          await _appRepositoryImpl.deletePlantation(id: id, reason: reason);

      debugPrint("Delete response: '$data' (type: ${data.runtimeType})");

      if (data == null) {
        debugPrint("Delete failed: data is null");
        deletMessage = "Server bilan bog'liq xatolik yuzaga keldi.";
        return false;
      } else {
        // Проверяем на ошибку 403 (Forbidden)
        if (data == "FORBIDDEN_403") {
          deletMessage = "Sizga ruxsat berilmagan";
          return false;
        }

        if (data == "success") {
          deletMessage = "O'chirish so'rovi moderatsiyaga yuborildi";
          plantationsList.removeWhere((plantation) => plantation.id == id);
          approvedList.removeWhere((plantation) => plantation.id == id);
          pendingList.removeWhere((plantation) => plantation.id == id);
          recheckList.removeWhere((plantation) => plantation.id == id);
          rejectedList.removeWhere((plantation) => plantation.id == id);

          _setLoading(false);
          _setFetchingMore(false);

          return true;
        }

        try {
          final jsonData = jsonDecode(data) as Map<String, dynamic>;
          debugPrint("Delete JSON parsed: $jsonData");

          // Проверяем на ошибку 403 в JSON ответе
          if (jsonData.containsKey("detail") && jsonData["detail"] is String) {
            final detail = jsonData["detail"] as String;
            final detailLower = detail.toLowerCase();
            if (detailLower.contains("forbidden") ||
                detailLower.contains("ruxsat") ||
                detailLower.contains("доступ") ||
                detailLower.contains("permission") ||
                detailLower.contains("403")) {
              debugPrint("Delete 403 error detected in detail: $detail");
              deletMessage = "Sizga ruxsat berilmagan";
              return false;
            }
          }

          if (jsonData.containsKey("error")) {
            final errorMessage = jsonData["error"] is String
                ? jsonData["error"] as String
                : jsonData["error"].toString();
            debugPrint("Delete error: $errorMessage");

            final errorLower = errorMessage.toLowerCase();
            if (errorLower.contains("forbidden") ||
                errorLower.contains("ruxsat") ||
                errorLower.contains("доступ") ||
                errorLower.contains("permission") ||
                errorLower.contains("403")) {
              debugPrint("Delete 403 error detected in error field");
              deletMessage = "Sizga ruxsat berilmagan";
              return false;
            }

            if (errorMessage.contains("аллақачон юборилган") ||
                errorMessage.contains("аллақачон ўчирилган") ||
                errorMessage.contains("уже отправлена") ||
                errorMessage.contains("уже удалена")) {
              deletMessage = "Бу плантация аллақачон ўчириш учун юборилган";
            } else {
              deletMessage = "Xatolik: $errorMessage";
            }
            return false;
          }

          if (jsonData.containsKey("detail")) {
            final detailMessage = jsonData["detail"] is String
                ? jsonData["detail"] as String
                : jsonData["detail"].toString();
            debugPrint("Delete detail message: $detailMessage");

            if (detailMessage.contains("ўчирилди") ||
                detailMessage.contains("ўчириш") ||
                detailMessage.contains("модерацияга") ||
                detailMessage.contains("юборилди") ||
                detailMessage.contains("удален") ||
                detailMessage.contains("удаление") ||
                detailMessage.contains("модерацию") ||
                detailMessage.contains("отправлен")) {
              debugPrint("Delete successful: detail message indicates success");
              deletMessage = "Ўчириш сўрови модерацияга юборилди";
              plantationsList.removeWhere((plantation) => plantation.id == id);
              approvedList.removeWhere((plantation) => plantation.id == id);
              pendingList.removeWhere((plantation) => plantation.id == id);
              recheckList.removeWhere((plantation) => plantation.id == id);
              rejectedList.removeWhere((plantation) => plantation.id == id);

              _setLoading(false);
              _setFetchingMore(false);

              return true;
            } else {
              debugPrint("Delete failed: detail message indicates failure");
              deletMessage = "O'chirishda xatolik yuz berdi";
              return false;
            }
          } else {
            debugPrint("Delete failed: no detail field in response");
            deletMessage = "O'chirishda xatolik yuz berdi";
            return false;
          }
        } catch (jsonError) {
          // Если не удалось распарсить JSON, проверяем строку на наличие ключевых слов ошибки 403
          final dataStr = data.toString().toLowerCase();
          if (dataStr.contains("forbidden") ||
              dataStr.contains("ruxsat") ||
              dataStr.contains("доступ") ||
              dataStr.contains("403")) {
            debugPrint("Delete 403 error detected in raw data");
            deletMessage = "Sizga ruxsat berilmagan";
            return false;
          }
          if (data.toString().toLowerCase().contains("success")) {
            deletMessage = "Plantatsiya muvaffaqiyatli o'chirildi";
            plantationsList.removeWhere((plantation) => plantation.id == id);
            approvedList.removeWhere((plantation) => plantation.id == id);
            pendingList.removeWhere((plantation) => plantation.id == id);
            recheckList.removeWhere((plantation) => plantation.id == id);
            rejectedList.removeWhere((plantation) => plantation.id == id);

            _setLoading(false);
            _setFetchingMore(false);

            return true;
          }
          deletMessage = "O'chirishda xatolik yuz berdi";
          return false;
        }
      }
    } catch (e) {
      deletMessage = "Internet bilan bog'liq muammo yuzaga keldi.";
      return false;
    } finally {
      _setDeleting(false);
      _safeNotifyListeners();
    }
  }
}
