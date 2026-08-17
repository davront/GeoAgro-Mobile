import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:geolocator/geolocator.dart';
import 'package:agro_employee_public/src/data/model/plantation/edit_plantation.dart';
import 'package:agro_employee_public/src/data/repository/app_repository_impl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../view/widget/edit_fruit_bottom_shit.dart';

import '../../../core/setting/setup.dart';
import '../../../../design_system/tokens/colors.dart' as design_colors;
import 'package:agro_employee_public/design_system/tokens/adaptive_colors.dart';
import '../../../data/model/fruits/fruit_model.dart';
import '../../../data/model/fruits/fruit_rootstocks_model.dart';
import '../../../data/model/fruits/fruit_verity_modell.dart';
import '../../../core/utils/geo_utils.dart';
import '../../../core/utils/thousands_separator_input_formatter.dart';
import '../../../core/storage/app_storage.dart';
import '../../../core/storage/draft_store.dart';
import '../../../core/storage/upload_queue_store.dart';
import '../../../core/queue/upload_queue_provider.dart';
import '../../../core/utils/api_error_parser.dart';
import '../../../core/utils/network_error_utils.dart';
import '../../../core/utils/network_utils.dart';
import '../../../core/utils/sanitization_utils.dart';
import '../../../core/utils/utils.dart';

final editVm = ChangeNotifierProvider.autoDispose<EditVM>((ref) {
  return EditVM();
});
final switchInvestmentXorjiy = StateProvider<bool>((ref) => false);
final switchInvestmentMahhalliy = StateProvider<bool>((ref) => false);
final switchTomchi = StateProvider<bool>((ref) => false);
final switchTrellisBeton = StateProvider<bool>((ref) => false);
final switchTrellisTemir = StateProvider<bool>((ref) => false);
final switchTrellis = StateProvider<bool>((ref) => false);
final switchReservoirs = StateProvider<bool>((ref) => false);
final switchReservoirsBeton = StateProvider<bool>((ref) => false);
final switchReservoirsQoplamali = StateProvider<bool>((ref) => false);
final switchFenced = StateProvider<bool>((ref) => false);
final switchIsFertile = StateProvider<bool>((ref) => false);
final switchSubsidiya = StateProvider<bool>((ref) => false);
final switchEfficiency = StateProvider<bool>((ref) => false);

class EditVM extends ChangeNotifier {
  final AppRepositoryImpl _appRepositoryImpl = AppRepositoryImpl();

  // Вспомогательная функция для форматирования чисел без .0
  String formatNumber(dynamic value) {
    if (value == null) return "0";
    if (value is double) {
      return value == value.toInt().toDouble()
          ? value.toInt().toString()
          : value.toString();
    }
    if (value is int) {
      return value.toString();
    }
    return value.toString();
  }

  // Вспомогательные функции для нормализации строк
  // ignore: unused_element
  String _norm(String v) => v.replaceAll(',', '.');

  // Получить все изображения (существующие + новые)
  List<String> getAllImages() {
    List<String> allImages = [];

    // Добавляем существующие изображения
    allImages.addAll(images);

    // Добавляем новые изображения
    for (var mapEntry in _imageFiles.entries) {
      if (mapEntry.value != null) {
        allImages.add(mapEntry.value!.path);
      }
    }
    return allImages;
  }

  late double unumdorlikValue;
  TextEditingController notUsableArea = TextEditingController();
  TextEditingController emptyArea = TextEditingController();
  TextEditingController dealNumberController = TextEditingController();
  TextEditingController resolutionNumberController = TextEditingController();
  TextEditingController investmentXorijiyAmount = TextEditingController();
  TextEditingController investmentMahhalliyAmount = TextEditingController();
  TextEditingController irrigationAreaController = TextEditingController();
  TextEditingController irrigationSystemsCount = TextEditingController();
  TextEditingController subsidiyaYear = TextEditingController();
  TextEditingController subsidiyaContract = TextEditingController();
  TextEditingController subsidiyaAmount = TextEditingController();
  TextEditingController trellisTemirInstalledArea = TextEditingController();
  TextEditingController trellisTemirCount = TextEditingController();
  TextEditingController trellisBetonInstalledArea = TextEditingController();
  TextEditingController trellisBetonCount = TextEditingController();
  // Списки для хранения нескольких резервуаров каждого типа
  final List<TextEditingController> reservoirsBetonliVolumes = [];
  final List<TextEditingController> reservoirsQoplamaliVolumes = [];

  // Старые контроллеры для обратной совместимости
  late final TextEditingController reservoirsBetonliVolume =
      TextEditingController();
  late final TextEditingController reservoirsQoplamaliVolume =
      TextEditingController();

  // Инициализация: добавляем один контроллер по умолчанию
  void initializeReservoirs() {
    if (reservoirsBetonliVolumes.isEmpty) {
      reservoirsBetonliVolumes.add(reservoirsBetonliVolume);
    }
    if (reservoirsQoplamaliVolumes.isEmpty) {
      reservoirsQoplamaliVolumes.add(reservoirsQoplamaliVolume);
    }
  }

  // Методы для управления списками резервуаров
  void addBetonReservoir() {
    reservoirsBetonliVolumes.add(TextEditingController());
    notifyListeners();
  }

  void removeBetonReservoir(int index) {
    // Всегда оставляем хотя бы один контроллер
    if (index >= 0 &&
        index < reservoirsBetonliVolumes.length &&
        reservoirsBetonliVolumes.length > 1) {
      final controller = reservoirsBetonliVolumes[index];
      // Если это основной контроллер, заменяем его на следующий
      if (controller == reservoirsBetonliVolume) {
        if (reservoirsBetonliVolumes.length > 1) {
          final nextController = reservoirsBetonliVolumes[1];
          // Копируем значение из следующего контроллера
          reservoirsBetonliVolume.text = nextController.text;
          // Удаляем следующий контроллер вместо основного
          nextController.dispose();
          reservoirsBetonliVolumes.removeAt(1);
        }
      } else {
        // Удаляем дополнительный контроллер
        controller.dispose();
        reservoirsBetonliVolumes.removeAt(index);
      }
      notifyListeners();
    }
  }

  void addQoplamaliReservoir() {
    reservoirsQoplamaliVolumes.add(TextEditingController());
    notifyListeners();
  }

  void removeQoplamaliReservoir(int index) {
    // Всегда оставляем хотя бы один контроллер
    if (index >= 0 &&
        index < reservoirsQoplamaliVolumes.length &&
        reservoirsQoplamaliVolumes.length > 1) {
      final controller = reservoirsQoplamaliVolumes[index];
      // Если это основной контроллер, заменяем его на следующий
      if (controller == reservoirsQoplamaliVolume) {
        if (reservoirsQoplamaliVolumes.length > 1) {
          final nextController = reservoirsQoplamaliVolumes[1];
          // Копируем значение из следующего контроллера
          reservoirsQoplamaliVolume.text = nextController.text;
          // Удаляем следующий контроллер вместо основного
          nextController.dispose();
          reservoirsQoplamaliVolumes.removeAt(1);
        }
      } else {
        // Удаляем дополнительный контроллер
        controller.dispose();
        reservoirsQoplamaliVolumes.removeAt(index);
      }
      notifyListeners();
    }
  }

  TextEditingController cultivatedArea = TextEditingController();
  TextEditingController sxema1 = TextEditingController();
  TextEditingController sxema2 = TextEditingController();
  TextEditingController konturInputController = TextEditingController();
  TextEditingController commentsController = TextEditingController();

  /// Упрощённый черновик текстовых полей (не switches/фото — фото уже
  /// не теряются: либо аплоаднуты online, либо стоят в офлайн-очереди
  /// per-photo, см. pickImage). Открытие EditPage само по себе требует
  /// сети (getPlantationDetail), поэтому полный restore менее критичен,
  /// чем в create-flow — эта защита нужна только на случай paused/kill
  /// посреди редактирования уже загруженной формы.
  Future<void> saveDraftSnapshot(WidgetRef ref, int plantationId) async {
    try {
      final data = <String, dynamic>{
        "controllers": {
          "notUsableArea": notUsableArea.text,
          "emptyArea": emptyArea.text,
          "investmentXorijiyAmount": investmentXorijiyAmount.text,
          "investmentMahhalliyAmount": investmentMahhalliyAmount.text,
          "irrigationAreaController": irrigationAreaController.text,
          "irrigationSystemsCount": irrigationSystemsCount.text,
          "subsidiyaYear": subsidiyaYear.text,
          "subsidiyaContract": subsidiyaContract.text,
          "subsidiyaAmount": subsidiyaAmount.text,
          "trellisTemirInstalledArea": trellisTemirInstalledArea.text,
          "trellisTemirCount": trellisTemirCount.text,
          "trellisBetonInstalledArea": trellisBetonInstalledArea.text,
          "trellisBetonCount": trellisBetonCount.text,
          "cultivatedArea": cultivatedArea.text,
          "sxema1": sxema1.text,
          "sxema2": sxema2.text,
          "commentsController": commentsController.text,
        },
        "kontur_numbers": konturNumbers,
        "saved_at": DateTime.now().toIso8601String(),
      };
      await DraftStore.instance.writeEditDraft(plantationId, data);
    } catch (e) {
      debugPrint("EditVM: saveDraftSnapshot failed: $e");
    }
  }

  List<String> konturNumbers = [];
  int direction = 0;
  List<Subsidy> selectedEditSubsidy = [];
  final Map<int, File?> _imageFiles = {};
  final ImagePicker _picker = ImagePicker();
  // image_picker кидает PlatformException("already_active") при повторном
  // вызове pickImage() пока первый ещё не завершился — случается при
  // быстром двойном тапе на кнопку выбора фото, необрабатываемо через
  // обычный try/catch вокруг await (всплывает как fatal).
  bool _isPickerActive = false;
  bool _isSpecialUser = false; // Флаг специального пользователя
  bool get isSpecialUser =>
      _isSpecialUser; // Геттер для проверки специального пользователя
  File? getImageFile(int cardId) => _imageFiles[cardId];
  int? _uploadingIndex;
  bool _isUploadingImage = false;
  bool isUploadingAt(int index) =>
      _isUploadingImage && _uploadingIndex == index;

  /// cardId фото, снятых офлайн и стоящих в очереди на отправку (см.
  /// pickImage offline-branch) — UI показывает по ним "ожидает отправки"
  /// вместо обычного превью.
  final Set<int> _pendingOfflineImageCardIds = {};
  bool isPendingOffline(int cardId) =>
      _pendingOfflineImageCardIds.contains(cardId);
  List<FruitArea> selectedDetails = [];
  List<FruitArea> selectedFruitVerityRoot = [];
  final TextEditingController selectedDateController = TextEditingController();
  TextEditingController tonnaController = TextEditingController();
  final switchIqtisodiy = StateProvider<bool>((ref) => false);
  TextEditingController economicInefficientAreaController =
      TextEditingController();
  bool isLoading = true;
  bool isLoading2 = false;
  String? errorMessage;
  // Имя поля (ключ бэка), к которому относится последняя ошибка сервера —
  // используется UI для подсветки конкретного инпута и автоскролла к
  // нему. Тот же паттерн, что и DetailVM.erroredField при create.
  String? erroredField;
  List<String> images = [];
  List<int> imageIds = [];
  List<String> _originalImages =
      []; // Оригинальный список изображений для отмены изменений
  List<int> _originalImageIds =
      []; // Оригинальный список ID изображений для отмены изменений
  final List<int> _imagesToDelete =
      []; // ID изображений, помеченных для удаления
  late EditPlantationModel plantationModel;
  bool isSaving = false;
  late EditPlantationModel originalPlantationModel;
  FruitModel? selectedFruit;
  FruitVarietyModel? selectedFruitVariety;
  FruitRootstocksModel? selectedFruitRoot;
  List<FruitVarietyModel> fruitVerityList = [];
  List<FruitRootstocksModel> fruitRootList = [];

  // --- Missing state fields ---
  DateTime? _selectedDate;
  DateTime? _selectedDate2;
  DateTime? get selectedDate => _selectedDate;
  DateTime? get selectedDate2 => _selectedDate2;

  int? _selectedYerTuriMap;
  int? get selectedYerTuri => _selectedYerTuriMap;

  int? _selectedEnergy;
  int? get selectedEnergy => _selectedEnergy;

  // -------- Helpers: change detection for minimal PATCH --------

  Map<String, dynamic>? _currentTypesMap() {
    if (_selectedPlantationType == null) return null;
    final map = <String, dynamic>{
      "plantation_type": _selectedPlantationType,
    };
    if (_selectedPlantationType == 1) {
      map["type_choice"] = _selectedBogType;
      map["subtype"] = _selectedBogSubtype;
    } else if (_selectedPlantationType == 2) {
      map["type_choice"] = _selectedUzumType;
    } else if (_selectedPlantationType == 3) {
      map["type_choice"] = _selectedIssiqxonaType;
    }
    return map;
  }

  Map<String, dynamic>? _originalTypesMap() {
    final originalType = originalPlantationModel.types?.plantationType ??
        originalPlantationModel.plantationType;
    if (originalType == null) return null;
    final map = <String, dynamic>{
      "plantation_type": originalType,
    };
    if (originalType == 1) {
      map["type_choice"] = originalPlantationModel.types?.typeChoice;
      map["subtype"] = originalPlantationModel.types?.subtype;
    } else if (originalType == 2) {
      map["type_choice"] = originalPlantationModel.types?.typeChoice;
    } else if (originalType == 3) {
      map["type_choice"] = originalPlantationModel.types?.typeChoice;
    }
    return map;
  }

  List<Map<String, dynamic>> _currentInvestments(WidgetRef ref) {
    final list = <Map<String, dynamic>>[];
    // 1: Mahalliy
    final mah = ref.watch(switchInvestmentMahhalliy)
        ? (int.tryParse(investmentMahhalliyAmount.text
                    .replaceAll(RegExp(r'[^0-9]'), ''))
                ?.toDouble() ??
            0.0)
        : 0.0;
    list.add({"invest_type": 1, "investment_amount": mah});
    // 2: Xorijiy
    final xor = ref.watch(switchInvestmentXorjiy)
        ? (int.tryParse(investmentXorijiyAmount.text
                    .replaceAll(RegExp(r'[^0-9]'), ''))
                ?.toDouble() ??
            0.0)
        : 0.0;
    list.add({"invest_type": 2, "investment_amount": xor});
    return list;
  }

  List<Map<String, dynamic>> _currentTrellises(WidgetRef ref) {
    // Если общий переключатель выключен — ничего не отправляем
    if (!ref.read(switchTrellis)) return [];

    final List<Map<String, dynamic>> t = [];

    // Beton (type 2)
    if (ref.read(switchTrellisBeton)) {
      final betonArea = double.tryParse(trellisBetonInstalledArea.text) ?? 0.0;
      final betonCount = int.tryParse(trellisBetonCount.text) ?? 0;
      if (betonArea > 0 || betonCount > 0) {
        t.add({
          "trellis_type": 2,
          "trellis_installed_area": betonArea,
          "trellis_count": betonCount
        });
      }
    }

    // Temir (type 1)
    if (ref.read(switchTrellisTemir)) {
      final temirArea = double.tryParse(trellisTemirInstalledArea.text) ?? 0.0;
      final temirCount = int.tryParse(trellisTemirCount.text) ?? 0;
      if (temirArea > 0 || temirCount > 0) {
        t.add({
          "trellis_type": 1,
          "trellis_installed_area": temirArea,
          "trellis_count": temirCount
        });
      }
    }

    return t;
  }

  List<Map<String, dynamic>> _currentReservoirs(WidgetRef ref) {
    if (!ref.read(switchReservoirs)) return [];

    final List<Map<String, dynamic>> res = [];

    // Бетонные резервуары (тип 1) - может быть несколько элементов
    if (ref.read(switchReservoirsBeton)) {
      for (final controller in reservoirsBetonliVolumes) {
        final beton = double.tryParse(controller.text) ?? 0.0;
        if (beton > 0) {
          res.add({
            "reservoir_type": 1,
            "reservoir_volume":
                beton.toStringAsFixed(1), // Строка, как ожидает бэкенд
          });
        }
      }
    }

    // Копламали резервуары (тип 2) - может быть несколько элементов
    if (ref.read(switchReservoirsQoplamali)) {
      for (final controller in reservoirsQoplamaliVolumes) {
        final qop = double.tryParse(controller.text) ?? 0.0;
        if (qop > 0) {
          res.add({
            "reservoir_type": 2,
            "reservoir_volume":
                qop.toStringAsFixed(1), // Строка, как ожидает бэкенд
          });
        }
      }
    }

    return res;
  }

  List<Map<String, dynamic>> _currentSubsidies() =>
      selectedEditSubsidy.map((e) => e.toJson()).toList();

  List<Map<String, dynamic>> _currentFruitAreas() => selectedDetails
      .where((e) => e.fruit != null)
      .map((e) => e.toJson())
      .toList();

  Map<String, dynamic> _buildPatchBody(WidgetRef ref) {
    final body = <String, dynamic>{};

    // garden_established_year
    final currentYear =
        _selectedDate?.year ?? originalPlantationModel.gardenEstablishedYear;
    if (_intChanged(
        currentYear, originalPlantationModel.gardenEstablishedYear)) {
      body["garden_established_year"] = currentYear;
    }

    // types
    final curTypes = _currentTypesMap();
    final origTypes = _originalTypesMap();
    if (jsonEncode(curTypes) != jsonEncode(origTypes)) {
      if (curTypes != null) body["types"] = curTypes;
    }

    // total_area — НЕ отправляем, вычисляется автоматически на бэкенде

    // empty_area — include only if actually changed
    final parsedEmpty = emptyArea.text.isNotEmpty
        ? double.tryParse(emptyArea.text.replaceAll(',', '.'))
        : null;
    if (_doubleChanged(parsedEmpty, originalPlantationModel.emptyArea)) {
      if (parsedEmpty != null) {
        body["empty_area"] = parsedEmpty;
      }
    }

    // land_type
    if (_selectedYerTuriMap != null) {
      body["land_type"] = _selectedYerTuriMap;
    }

    // fertility_score
    body["fertility_score"] = unumdorlikValue;

    // not_usable_area — include only if actually changed (treat 1.0 == 1)
    final parsedNotUsable = notUsableArea.text.isNotEmpty
        ? double.tryParse(notUsableArea.text.replaceAll(',', '.'))
        : null;
    if (_doubleChanged(
        parsedNotUsable, originalPlantationModel.notUsableArea)) {
      if (parsedNotUsable != null) {
        body["not_usable_area"] = parsedNotUsable;
      }
    }

    // deal_number / resolution_number — include only if actually changed.
    // deal_file/resolution_file are not sent here: mobile-update accepts
    // JSON only, no multipart, and no separate upload endpoint exists yet
    // for those files.
    if (_stringChanged(
        dealNumberController.text, originalPlantationModel.dealNumber)) {
      body["deal_number"] = dealNumberController.text.trim();
    }
    if (_stringChanged(resolutionNumberController.text,
        originalPlantationModel.resolutionNumber)) {
      body["resolution_number"] = resolutionNumberController.text.trim();
    }

    // is_fertile
    body["is_fertile"] = ref.read(switchIsFertile);

    // investments
    final curInv = _currentInvestments(ref);
    body["investments"] = curInv;

    // irrigation
    final curIrrArea = ref.watch(switchTomchi)
        ? (double.tryParse(irrigationAreaController.text) ?? 0.0)
        : 0.0;
    body["irrigation_area"] = curIrrArea;

    final curIrrCount = ref.watch(switchTomchi)
        ? (int.tryParse(irrigationSystemsCount.text) ?? 0)
        : 0;
    body["irrigation_systems_count"] = curIrrCount;

    // trellises
    final curTrellis = _currentTrellises(ref);
    if (curTrellis.isNotEmpty) body["trellises"] = curTrellis;

    // reservoirs - всегда отправляем текущее состояние
    final curRes = _currentReservoirs(ref);
    final origRes = (originalPlantationModel.reservoirs ?? [])
        .map((r) => {
              "reservoir_type": r.reservoirType,
              "reservoir_volume": r.reservoirVolume != null
                  ? r.reservoirVolume.toString()
                  : "0.0",
            })
        .toList();

    // Отправляем резервуары, если:
    // 1. Переключатель включен (даже если список пустой - для очистки на сервере)
    // 2. Или текущие резервуары отличаются от оригинальных
    final reservoirsChanged = jsonEncode(curRes) != jsonEncode(origRes);
    if (ref.read(switchReservoirs) || reservoirsChanged) {
      body["reservoirs"] = curRes;
    }

    // kontur numbers
    if (konturNumbers.isNotEmpty) {
      body["kontur_number"] = konturNumbers;
    }

    // subsidies
    final curSubs = _currentSubsidies();
    body["subsidies"] = curSubs;

    // fruit_areas
    final curFruit = _currentFruitAreas();
    if (curFruit.isNotEmpty) {
      body["fruit_areas"] = curFruit;
    }

    return body;
  }

  bool _intChanged(int? a, int? b) => a != b;
  bool _doubleChanged(double? a, double? b) {
    if (a == null && b == null) return false;
    if (a == null || b == null) return true;
    return (a - b).abs() > 1e-9;
  }

  bool _stringChanged(String? a, String? b) =>
      (a?.trim().isEmpty ?? true ? null : a?.trim()) !=
      (b?.trim().isEmpty ?? true ? null : b?.trim());

  bool _isLoadingDetail = false;

  Future<void> getPlantationDetail(WidgetRef ref, int id) async {
    // Предотвращаем повторную загрузку, если уже идет загрузка
    if (_isLoadingDetail) {
      debugPrint(
          '[edit] getPlantationDetail: Already loading, skipping duplicate call');
      return;
    }

    _isLoadingDetail = true;
    errorMessage = null;
    isLoading = true;
    notifyListeners();
    try {
      final data = await _appRepositoryImpl.getPlantationDetail(id: id);
      if (data != null) {
        final jsonData = jsonDecode(data);
        plantationModel = EditPlantationModel.fromJson(jsonData);
        originalPlantationModel = EditPlantationModel.fromJson(jsonData);
        unumdorlikValue = plantationModel.fertilityScore?.toDouble() ?? 0;

        // Логируем для отладки
        debugPrint(
            '[edit] getPlantationDetail: totalArea=${plantationModel.totalArea}');
        // Prefill core fields (format 2.0 -> 2, keep decimals like 2.02)
        notUsableArea.text = DecimalInputFormatter.formatBackendNumber(
          plantationModel.notUsableArea,
          thousandsSeparator: '',
        );
        emptyArea.text = DecimalInputFormatter.formatBackendNumber(
          plantationModel.emptyArea,
          thousandsSeparator: '',
        );
        dealNumberController.text = plantationModel.dealNumber ?? '';
        resolutionNumberController.text =
            plantationModel.resolutionNumber ?? '';
        selectedDetails = plantationModel.fruitAreas ?? [];
        // Бэк иногда возвращает "fruit"/"variety"/"rootstock" как имя-строку
        // вместо id или {id,name}-объекта (напр. "fruit": "Olcha") —
        // FruitArea.fromJson тогда не может распарсить id, оставляет null.
        // Нетронутый юзером fruit_area с fruit==null молча выпадал из PATCH
        // на _currentFruitAreas() (.where((e) => e.fruit != null)), из-за
        // чего уже сохранённый фрукт пропадал при следующем сохранении,
        // если юзер добавлял только новый и не трогал старый. Ждём резолв
        // здесь (не unawaited) — иначе юзер может нажать "Сохранить"
        // раньше, чем id доподставится, и получить тот же баг заново.
        await _resolveUnresolvedFruitAreas();
        images = plantationModel.images ?? images;
        // Сохраняем оригинальный список изображений для отмены изменений
        _originalImages = List<String>.from(images);
        _imagesToDelete.clear();
        // Загружаем imageIds при первоначальной загрузке
        await refreshDetailImages();
        _originalImageIds = List<int>.from(imageIds);
        // Prefill year
        if (plantationModel.gardenEstablishedYear != null) {
          _selectedDate = DateTime(plantationModel.gardenEstablishedYear!);
          selectedDateController.text =
              DateFormat('yyyy-MM-dd').format(_selectedDate!);
        }
        // Prefill types
        _selectedPlantationType = plantationModel.types?.plantationType ??
            plantationModel.plantationType;
        if (_selectedPlantationType == 1) {
          _selectedBogType = plantationModel.types?.typeChoice;
          _selectedBogSubtype = plantationModel.types?.subtype;
        } else if (_selectedPlantationType == 2) {
          _selectedUzumType = plantationModel.types?.typeChoice;
        } else if (_selectedPlantationType == 3) {
          _selectedIssiqxonaType = plantationModel.types?.typeChoice;
        }
        // Prefill land type
        _selectedYerTuriMap = plantationModel.landType;

        // Fertility
        ref.read(switchIsFertile.notifier).state =
            plantationModel.isFertile ?? false;

        // Prefill investments switches and amounts
        double mah = 0.0;
        double xor = 0.0;
        for (final inv in plantationModel.investments ?? []) {
          if (inv.investType == 1) {
            final v = inv.investmentAmount;
            if (v != null) {
              mah = (v is num) ? v.toDouble() : double.tryParse('$v') ?? 0.0;
            }
          } else if (inv.investType == 2) {
            final v = inv.investmentAmount;
            if (v != null) {
              xor = (v is num) ? v.toDouble() : double.tryParse('$v') ?? 0.0;
            }
          }
        }
        ref.read(switchInvestmentMahhalliy.notifier).state = mah > 0;
        ref.read(switchInvestmentXorjiy.notifier).state = xor > 0;
        investmentMahhalliyAmount.text = mah > 0
            ? ThousandsSeparatorInputFormatter.formatDigits(
                mah.toStringAsFixed(0))
            : '';
        investmentXorijiyAmount.text = xor > 0
            ? ThousandsSeparatorInputFormatter.formatDigits(
                xor.toStringAsFixed(0))
            : '';

        // Prefill irrigation (Tomchi)
        final hasIrr = (plantationModel.irrigationArea != null &&
                plantationModel.irrigationArea! > 0) ||
            (plantationModel.irrigationSystemsCount != null &&
                plantationModel.irrigationSystemsCount! > 0);
        ref.read(switchTomchi.notifier).state = hasIrr;
        irrigationAreaController.text =
            (plantationModel.irrigationArea ?? 0).toString();
        irrigationSystemsCount.text =
            (plantationModel.irrigationSystemsCount ?? 0).toString();

        // Prefill trellises
        bool hasAnyTrellis = false;
        ref.read(switchTrellisBeton.notifier).state = false;
        ref.read(switchTrellisTemir.notifier).state = false;
        trellisBetonInstalledArea.clear();
        trellisBetonCount.clear();
        trellisTemirInstalledArea.clear();
        trellisTemirCount.clear();
        for (final tr in plantationModel.trellises ?? []) {
          final type = tr.trellisType;
          final area = tr.trellisInstalledArea ?? 0.0;
          final count = tr.trellisCount ?? 0;
          if (type == 2 && (area > 0 || count > 0)) {
            hasAnyTrellis = true;
            ref.read(switchTrellisBeton.notifier).state = true;
            trellisBetonInstalledArea.text = area.toString();
            trellisBetonCount.text = count.toString();
          } else if (type == 1 && (area > 0 || count > 0)) {
            hasAnyTrellis = true;
            ref.read(switchTrellisTemir.notifier).state = true;
            trellisTemirInstalledArea.text = area.toString();
            trellisTemirCount.text = count.toString();
          }
        }
        ref.read(switchTrellis.notifier).state = hasAnyTrellis;

        // Prefill reservoirs - загружаем все резервуары каждого типа
        initializeReservoirs();
        reservoirsBetonliVolumes.clear();
        reservoirsQoplamaliVolumes.clear();

        // Группируем резервуары по типам
        final List<double> betonVolumes = [];
        final List<double> qopVolumes = [];

        for (final r in plantationModel.reservoirs ?? []) {
          if (r.reservoirType == 1) {
            final v = r.reservoirVolume;
            if (v != null) {
              final vol =
                  (v is num) ? v.toDouble() : double.tryParse('$v') ?? 0.0;
              if (vol > 0) betonVolumes.add(vol);
            }
          } else if (r.reservoirType == 2) {
            final v = r.reservoirVolume;
            if (v != null) {
              final vol =
                  (v is num) ? v.toDouble() : double.tryParse('$v') ?? 0.0;
              if (vol > 0) qopVolumes.add(vol);
            }
          }
        }

        // Заполняем списки контроллеров
        if (betonVolumes.isEmpty) {
          reservoirsBetonliVolumes.add(reservoirsBetonliVolume);
        } else {
          for (int i = 0; i < betonVolumes.length; i++) {
            if (i == 0) {
              reservoirsBetonliVolume.text = betonVolumes[i].toStringAsFixed(0);
              reservoirsBetonliVolumes.add(reservoirsBetonliVolume);
            } else {
              final controller = TextEditingController(
                  text: betonVolumes[i].toStringAsFixed(0));
              reservoirsBetonliVolumes.add(controller);
            }
          }
        }

        if (qopVolumes.isEmpty) {
          reservoirsQoplamaliVolumes.add(reservoirsQoplamaliVolume);
        } else {
          for (int i = 0; i < qopVolumes.length; i++) {
            if (i == 0) {
              reservoirsQoplamaliVolume.text = qopVolumes[i].toStringAsFixed(0);
              reservoirsQoplamaliVolumes.add(reservoirsQoplamaliVolume);
            } else {
              final controller =
                  TextEditingController(text: qopVolumes[i].toStringAsFixed(0));
              reservoirsQoplamaliVolumes.add(controller);
            }
          }
        }

        ref.read(switchReservoirsBeton.notifier).state =
            betonVolumes.isNotEmpty;
        ref.read(switchReservoirsQoplamali.notifier).state =
            qopVolumes.isNotEmpty;
        ref.read(switchReservoirs.notifier).state =
            (betonVolumes.isNotEmpty || qopVolumes.isNotEmpty);

        // Prefill subsidies
        selectedEditSubsidy = (plantationModel.subsidies ?? []).toList();
        final hasSubsidies = selectedEditSubsidy.isNotEmpty;
        ref.read(switchSubsidiya.notifier).state = hasSubsidies;
        if (hasSubsidies) {
          final hasEfficiency = selectedEditSubsidy.any(
            (s) => s.efficiency == true,
          );
          ref.read(switchEfficiency.notifier).state = hasEfficiency;
        }

        // Prefill kontur numbers
        try {
          final imgs = (jsonData is Map<String, dynamic>)
              ? jsonData['kontur_number']
              : null;
          konturNumbers = [];
          if (imgs is List) {
            for (final e in imgs) {
              final v = e?.toString();
              if (v != null && v.isNotEmpty) konturNumbers.add(v);
            }
          }
        } catch (e) {
          debugPrint('⚠️ EditVM.loadDetail: konturNumbers parse error: $e');
        }
      } else {
        errorMessage = "Ma'lumotni olishda xatolik";
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      _isLoadingDetail = false;
      isLoading = false;
      notifyListeners();
    }
  }

  String? validateFields(WidgetRef ref) {
    // 1) Bog`ning barpo etilgan vaqti
    if (_selectedDate == null &&
        originalPlantationModel.gardenEstablishedYear == null) {
      return "Bog`ning barpo etilgan vaqti tanlanmagan";
    }
    // 2) Plantatsiya turi
    if (_selectedPlantationType == null) {
      return "Plantatsiya turi tanlanmagan";
    }
    // 2.1) Majburiy quyi turlar
    if (_selectedPlantationType == 1) {
      if (_selectedBogType == null) {
        return "Bog' turi tanlanmagan";
      }
      if (_selectedBogType == 1 && _selectedBogSubtype == null) {
        return "Intensiv bog' turi tanlanmagan";
      }
    } else if (_selectedPlantationType == 2) {
      if (_selectedUzumType == null) {
        return "Uzumzor turi tanlanmagan";
      }
    } else if (_selectedPlantationType == 3) {
      if (_selectedIssiqxonaType == null) {
        return "Issiqxona turi tanlanmagan";
      }
    }
    // 4) Yer turi
    if (_selectedYerTuriMap == null) {
      return "Yer turi tanlanmagan";
    }
    // 5) Foydalanishga yaroqsiz maydon
    if (notUsableArea.text.isEmpty) {
      return "Foydalanishga yaroqsiz maydon kiritilmagan";
    }
    // 6) Kontur raqami (majburiy kamida bittasi)
    if (konturNumbers.isEmpty) {
      return "Kamida bitta kontur raqamini kiriting";
    }
    // 7) Инвестиции: хотя бы одна
    final mahOn = ref.read(switchInvestmentMahhalliy);
    final xorOn = ref.read(switchInvestmentXorjiy);
    double mah = 0.0, xor = 0.0;
    if (mahOn) {
      mah = (int.tryParse(investmentMahhalliyAmount.text
                  .replaceAll(RegExp(r'[^0-9]'), ''))
              ?.toDouble() ??
          0.0);
    }
    if (xorOn) {
      xor = (int.tryParse(investmentXorijiyAmount.text
                  .replaceAll(RegExp(r'[^0-9]'), ''))
              ?.toDouble() ??
          0.0);
    }
    if ((mahOn && mah <= 0) && (xorOn && xor <= 0) || (!mahOn && !xorOn)) {
      return "Kamida bitta investitsiya miqdorini kiriting (Mahalliy yoki Xorijiy)";
    }
    // 8) Rasm - динамическая проверка количества фотографий
    // TODO: Disabled for edit page — photo count validation is only required on create page
    // final minPhotosRequired = calculateMinimumPhotosRequired(ref);
    // final totalImages = images.length + _imageFiles.values.where((f) => f != null).length;
    // if (totalImages < minPhotosRequired) {
    //   return "Kamida $minPhotosRequired ta rasm yuklash kerak. Hozir: $totalImages ta.\n${getPhotoRequirementDetails(ref)}";
    // }
    // 9) Meva maydonlari
    if (selectedDetails.isEmpty) {
      return "Kamida bitta meva maydoni qo'shing";
    }

    // 10) Проверка разницы между площадью полигона (chegaraArea) и общей площадью плантации (не более 15%)
    final polygonArea =
        plantationModel.chegaraArea ?? originalPlantationModel.chegaraArea;
    if (polygonArea != null && polygonArea > 0) {
      final totalArea = getTotalArea(ref);
      if (totalArea > 0) {
        // Вычисляем разницу в процентах
        final difference =
            ((polygonArea - totalArea).abs() / polygonArea) * 100;
        debugPrint(
            '[edit] validateFields: polygonArea (chegaraArea) = $polygonArea, totalArea = $totalArea, difference = ${difference.toStringAsFixed(2)}%');

        if (difference > 15.0) {
          return 'Poligon maydoni va kiritilgan maydon o\'rtasidagi farq 15% dan oshib ketdi. Farq: ${difference.toStringAsFixed(1)}%. Iltimos, ma\'lumotlarni tekshiring.';
        }
      }
    }

    return null;
  }

  int calculateMinimumPhotosRequired(WidgetRef ref) {
    int minPhotos = 1;
    minPhotos += selectedDetails.length;
    if (_selectedYerTuriMap == 1) minPhotos += 1;
    final emptyAreaValue = double.tryParse(_norm(emptyArea.text.trim())) ?? 0.0;
    if (emptyAreaValue > 0) minPhotos += 1;
    if (ref.read(switchTomchi)) minPhotos += 1;
    if (ref.read(switchTrellis)) minPhotos += 1;
    if (ref.read(switchReservoirs)) minPhotos += 1;
    return minPhotos;
  }
  //
  // /// Returns detailed explanation of photo requirements
  // String getPhotoRequirementDetails(WidgetRef ref) {
  //   final details = <String>[];
  //   details.add("• Asosiy plantatsiya: 1 ta rasm");
  //   if (selectedDetails.isNotEmpty) {
  //     details.add("• Mevalar (${selectedDetails.length} ta): ${selectedDetails.length} ta rasm");
  //   }
  //   if (_selectedYerTuriMap == 1) {
  //     details.add("• Lalmi (yaroqsiz) maydon: 1 ta rasm");
  //   }
  //   final emptyAreaValue = double.tryParse(_norm(emptyArea.text.trim())) ?? 0.0;
  //   if (emptyAreaValue > 0) {
  //     details.add("• Ochiq maydon: 1 ta rasm");
  //   }
  //   final isTomchiEnabled = ref.read(switchTomchi);
  //   if (isTomchiEnabled) {
  //     details.add("• Tomchilab sug'orish: 1 ta rasm");
  //   }
  //   final isShpaller = ref.read(switchTrellis);
  //   if (isShpaller) {
  //     details.add("• Shpaller: 1 ta rasm");
  //   }
  //   final isReservoir = ref.read(switchReservoirs);
  //   if (isReservoir) {
  //     details.add("• Suv havzasi: 1 ta rasm");
  //   }
  //   return details.join('\n');
  // }

  /// Текущая GPS-точка для user_location. null — нет разрешения или не
  /// удалось получить за отведённое время; в этом случае поле не шлём.
  Future<Map<String, double>?> _currentUserLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) {
        return null;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 5),
        ),
      );
      // Mock location (Developer Options / fake GPS ilova) — soxta
      // koordinata, limit_km tekshiruvi uni haqiqiy deb qabul qilmasin.
      if (pos.isMocked) return null;
      return {"latitude": pos.latitude, "longitude": pos.longitude};
    } catch (e) {
      debugPrint('EditVM: user_location unavailable: $e');
      return null;
    }
  }

  /// Проверяет, что редактирующий физически находится внутри полигона
  /// плантации либо в радиусе limit_km от неё — та же логика, что уже
  /// применяется при создании (create_map_page_vm.dart, через общий
  /// GeoUtils). При редактировании полигон не перерисовывается, так что
  /// сверяем текущий GPS с уже сохранёнными координатами плантации.
  ///
  /// Принимает уже полученную точку (см. [_currentUserLocation]) вместо
  /// того чтобы запрашивать GPS ещё раз — иначе каждое сохранение ждало бы
  /// два отдельных GPS-фикса подряд (до 5с каждый).
  ///
  /// Возвращает сообщение об ошибке, если далеко или локацию не удалось
  /// получить (fail-closed: без подтверждённого GPS сохранение блокируем,
  /// иначе проверку можно обойти просто выключив геолокацию); null — если
  /// можно сохранять.
  Future<String?> _checkLocationLimit(Map<String, double>? userLoc) async {
    final rawPolygon = originalPlantationModel.coordinates;
    if (rawPolygon == null || rawPolygon.length < 3) return null;

    final polygon = rawPolygon
        .where((p) => p.latitude != null && p.longitude != null)
        .map((p) => (p.latitude!, p.longitude!))
        .toList();
    if (polygon.length < 3) return null;

    if (userLoc == null) {
      return "Joylashuvni aniqlab bo'lmadi. GPS yoqilganligini tekshiring va "
          "qayta urinib ko'ring";
    }

    final lat = userLoc["latitude"]!;
    final lng = userLoc["longitude"]!;

    if (GeoUtils.isPointInPolygon(lat, lng, polygon)) return null;

    final minDistance = GeoUtils.minDistanceToPolygon(lat, lng, polygon);

    final limitKm =
        await AppStorage.$readDouble(key: StorageKey.limitKm) ?? 1.0;
    final limitMeters = limitKm * 1000;

    if (minDistance > limitMeters) {
      final limitLabel = limitKm.truncateToDouble() == limitKm
          ? limitKm.toStringAsFixed(0)
          : limitKm.toStringAsFixed(1);
      return "Siz plantatsiyaning $limitLabel km radiusida emassiz. Tahrirlash uchun yaqinroq boring";
    }
    return null;
  }

  Future<bool> editPlantation(WidgetRef ref, int id) async {
    // Защита от множественных вызовов
    if (isSaving) {
      debugPrint(
          'editPlantation: Already in progress, ignoring duplicate call');
      return false;
    }

    errorMessage = null;
    erroredField = null;
    isSaving = true;
    notifyListeners();

    // Один GPS-фикс переиспользуется и для проверки лимита, и для
    // user_location — раньше оба запрашивались отдельно, удваивая
    // время ожидания GPS на сохранение.
    final userLoc = await _currentUserLocation();
    final locationError = await _checkLocationLimit(userLoc);
    if (locationError != null) {
      errorMessage = locationError;
      isSaving = false;
      notifyListeners();
      return false;
    }

    final body = _buildPatchBody(ref);
    try {
      debugPrint('[edit] PATCH body => ${jsonEncode(body)}');
    } catch (e) {
      debugPrint('⚠️ EditVM: PATCH body debug print failed: $e');
    }

    if (body.isEmpty) {
      // Нечего отправлять — изменений нет
      isSaving = false;
      notifyListeners();
      return true;
    }

    // Пишем ту же GPS-точку в историю user_locations вместе с обновлением
    if (userLoc != null) {
      body["user_location"] = userLoc;
    }

    // Нет сети — не пытаемся отправить PATCH, кладём уже собранный (и
    // уже прошедший fail-closed geo-проверку) body в офлайн-очередь.
    // GPS не запрашивается повторно ни здесь, ни на dequeue.
    final isOnline = await NetworkUtils.hasInternetConnection();
    if (!isOnline) {
      try {
        await ref.read(uploadQueueServiceProvider).enqueueEdit(
              plantationId: id,
              // EditPlantationModel не хранит farmerId — поле нужно только
              // для отображения в QueueScreen, plantationId/requestBody
              // достаточно для самой отправки.
              farmerId: 0,
              displayLabel: "Plantatsiya #$id",
              requestBody: body,
              userLocation: userLoc,
            );
        errorMessage = "Tarmoq yo'q — navbatga qo'yildi, ulanish "
            "tiklanganda avtomatik yuboriladi";
        isSaving = false;
        notifyListeners();
        return true;
      } catch (e) {
        debugPrint('editPlantation: enqueue (offline) failed: $e');
        errorMessage = "Internet bilan bog'liq muammo yuzaga keldi.";
        isSaving = false;
        notifyListeners();
        return false;
      }
    }

    try {
      final response =
          await _appRepositoryImpl.editPlantation(id: id, body: body);

      // Проверяем на ошибку 403 (Forbidden)
      if (response.statusCode == 403) {
        errorMessage = "Sizga ruxsat berilmagan";
        return false;
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        debugPrint('[edit] Error response data: ${response.data}');
        errorMessage = ApiErrorParser.parse(response.data);
        erroredField = ApiErrorParser.parseFieldName(response.data);
        debugPrint(
            '[edit] Final error message: $errorMessage, field: $erroredField');
        return false;
      }
    } catch (e) {
      if (isNetworkError(e)) {
        // Обрыв сети посреди PATCH — тоже кладём в очередь, не теряем
        // уже собранный и провалидированный body.
        try {
          await ref.read(uploadQueueServiceProvider).enqueueEdit(
                plantationId: id,
                // EditPlantationModel не хранит farmerId — поле нужно только
                // для отображения в QueueScreen, plantationId/requestBody
                // достаточно для самой отправки.
                farmerId: 0,
                requestBody: body,
                userLocation: userLoc,
              );
          errorMessage = "Tarmoq uzildi — navbatga qo'yildi, ulanish "
              "tiklanganda avtomatik yuboriladi";
          return true;
        } catch (enqueueError) {
          debugPrint(
              'editPlantation: enqueue after network error failed: $enqueueError');
        }
        errorMessage = e.toString().contains('TimeoutException')
            ? "Серверга уланиш вақти тугади"
            : "Интернет алокасида хатолик юз берди";
      } else {
        errorMessage = "Xatolik yuz berdi: ${e.toString()}";
      }
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  void addSubsidiyaList(WidgetRef ref) {
    // Убираем пробелы-разделители тысяч из суммы перед парсингом
    final rawAmount = subsidiyaAmount.text.trim().replaceAll(' ', '');
    final year = int.tryParse(subsidiyaYear.text.trim()) ?? 0;
    final contractNum = subsidiyaContract.text.trim();

    final existingSubsidyIndex = selectedEditSubsidy.indexWhere((subsidy) =>
        subsidy.year == year && subsidy.contractNumber == contractNum);

    if (existingSubsidyIndex != -1) {
      // Update existing subsidy
      selectedEditSubsidy[existingSubsidyIndex] = Subsidy(
        year: year,
        contractNumber: contractNum,
        amount: double.tryParse(rawAmount) ?? 0.0,
        direction: _selectedEnergy,
        efficiency: ref.read(switchEfficiency),
      );
    } else {
      // Add new subsidy
      selectedEditSubsidy.add(Subsidy(
        year: year,
        contractNumber: contractNum,
        amount: double.tryParse(rawAmount) ?? 0.0,
        direction: _selectedEnergy,
        efficiency: ref.read(switchEfficiency),
      ));
    }
    resetSubsudy();
    notifyListeners();
  }

  void removeSubsidy(int index) {
    selectedEditSubsidy.removeAt(index);
    notifyListeners();
  }

  Future<bool> uploadImage() async {
    // Загружаем только новые изображения
    List<String> newImages = [];
    for (var mapEntry in _imageFiles.entries) {
      if (mapEntry.value != null) {
        newImages.add(mapEntry.value!.path);
      }
    }

    // Если нет новых изображений, пропускаем загрузку
    if (newImages.isEmpty) {
      return true;
    }

    try {
      for (final path in newImages) {
        final resp = await _appRepositoryImpl.postPlantationImage(
            id: plantationModel.id!, filePath: path);
        // Если новый эндпоинт недоступен, пробуем легаси одним запросом
        if (resp.statusCode == 405) {
          final legacy = await _appRepositoryImpl.editImage(
              id: plantationModel.id!, images: newImages);
          if (legacy == null) {
            return false;
          }
          break;
        }
        if (resp.statusCode != 200 && resp.statusCode != 201) {
          return false;
        }
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> saveAllChanges(WidgetRef ref, int id) async {
    // Фронт-валидация площадей (+ общая валидация)
    final requiredError = validateFields(ref);
    if (requiredError != null) {
      errorMessage = requiredError;
      notifyListeners();
      return false;
    }

    // Если родительский переключатель включён, но ни один подтип не заполнен — выключаем
    if (ref.read(switchTrellis) && _currentTrellises(ref).isEmpty) {
      ref.read(switchTrellis.notifier).state = false;
    }
    // НЕ выключаем переключатель резервуаров здесь, чтобы не потерять данные при сохранении
    // Переключатель будет выключен только если пользователь явно его выключит

    // Сначала обновляем данные плантации
    bool plantationSuccess = await editPlantation(ref, id);
    if (!plantationSuccess) {
      return false;
    }

    // Удаляем помеченные изображения
    for (final imageId in _imagesToDelete) {
      try {
        await _appRepositoryImpl.deletePlantationImage(
            plantationId: id, imageId: imageId);
      } catch (_) {
        // Игнорируем ошибки удаления отдельных изображений
      }
    }
    _imagesToDelete.clear();

    // Затем загружаем новые изображения
    bool imagesSuccess = await uploadImage();

    // Обновляем оригинальный список изображений после успешного сохранения
    _originalImages = List<String>.from(images);
    _originalImageIds = List<int>.from(imageIds);

    // Если был введен комментарий, добавляем его после успешного обновления плантации
    final rawCommentsText = commentsController.text.trim();
    if (rawCommentsText.isNotEmpty) {
      // Санитизация комментария для защиты от XSS
      final commentsText = SanitizationUtils.sanitizeComment(rawCommentsText);
      try {
        debugPrint("✅ EditVM: Adding comment after successful update...");
        debugPrint("📤 EditVM: Sending comment with isModeration: false");
        debugPrint("📤 EditVM: Comment text: $commentsText");
        final commentResponse = await _appRepositoryImpl.addPlantationComment(
          plantationId: id,
          body: commentsText,
          isModeration:
              false, // Явно указываем, что это обычный комментарий при редактировании
        );
        debugPrint(
            "📥 EditVM: Comment response status: ${commentResponse.statusCode}");
        debugPrint("📥 EditVM: Comment response data: ${commentResponse.data}");
        if (commentResponse.statusCode != 200 &&
            commentResponse.statusCode != 201) {
          debugPrint(
              "⚠️ EditVM: Failed to add comment (status: ${commentResponse.statusCode}), but plantation was updated");
        } else {
          debugPrint("✅ EditVM: Comment added successfully");
        }
      } catch (e, stackTrace) {
        debugPrint("⚠️ EditVM: Error adding comment: $e");
        debugPrint("⚠️ EditVM: Stack trace: $stackTrace");
        // Не прерываем процесс, плантация уже обновлена
      }
    }

    return plantationSuccess && imagesSuccess;
  }

  Future<bool> editPlantationWithImages(
      WidgetRef ref, int id, List<String> newImages) async {
    // Защита от множественных вызовов
    if (isSaving) {
      debugPrint(
          'editPlantationWithImages: Already in progress, ignoring duplicate call');
      return false;
    }

    errorMessage = null;
    erroredField = null;
    isSaving = true;
    notifyListeners();

    // Один GPS-фикс переиспользуется и для проверки лимита, и для
    // user_location — раньше оба запрашивались отдельно, удваивая
    // время ожидания GPS на сохранение.
    final userLoc = await _currentUserLocation();
    final locationError = await _checkLocationLimit(userLoc);
    if (locationError != null) {
      errorMessage = locationError;
      isSaving = false;
      notifyListeners();
      return false;
    }

    final body = <String, dynamic>{};

    // Garden established year - всегда отправляем текущее значение
    if (_selectedDate != null) {
      body["garden_established_year"] = _selectedDate!.year;
    } else if (originalPlantationModel.gardenEstablishedYear != null) {
      body["garden_established_year"] =
          originalPlantationModel.gardenEstablishedYear;
    }

    // Plantation types - всегда отправляем текущие значения
    if (_selectedPlantationType != null) {
      final types = {
        "plantation_type": _selectedPlantationType,
      };
      if (_selectedPlantationType == 1) {
        types["type_choice"] = _selectedBogType;
        types["subtype"] = _selectedBogSubtype;
      } else if (_selectedPlantationType == 2) {
        types["type_choice"] = _selectedUzumType;
      } else if (_selectedPlantationType == 3) {
        types["type_choice"] = _selectedIssiqxonaType;
      }
      body["types"] = types;
    }

    // Total area - не отправляем (автоматически вычисляется бэкендом)

    // Land type - всегда отправляем текущее значение
    if (_selectedYerTuriMap != null) {
      body["land_type"] = _selectedYerTuriMap;
    }

    // Fertility score - всегда отправляем текущее значение
    body["fertility_score"] = unumdorlikValue;

    // Not usable area - всегда отправляем текущее значение
    if (notUsableArea.text.isNotEmpty) {
      body["not_usable_area"] =
          int.tryParse(notUsableArea.text.replaceAll(RegExp(r'[^0-9]'), ''))
                  ?.toDouble() ??
              0.0;
    } else if (originalPlantationModel.notUsableArea != null) {
      body["not_usable_area"] = originalPlantationModel.notUsableArea;
    }

    // Empty area - всегда отправляем текущее значение
    if (emptyArea.text.isNotEmpty) {
      body["empty_area"] =
          double.tryParse(emptyArea.text.replaceAll(',', '.')) ?? 0.0;
    } else if (originalPlantationModel.emptyArea != null) {
      body["empty_area"] = originalPlantationModel.emptyArea;
    }

    // is_fertile - всегда отправляем
    body["is_fertile"] = ref.read(switchIsFertile);

    // investments - всегда отправляем
    final curInv = _currentInvestments(ref);
    body["investments"] = curInv;

    // irrigation - всегда отправляем
    final curIrrArea = ref.watch(switchTomchi)
        ? (double.tryParse(irrigationAreaController.text) ?? 0.0)
        : 0.0;
    body["irrigation_area"] = curIrrArea;

    final curIrrCount = ref.watch(switchTomchi)
        ? (int.tryParse(irrigationSystemsCount.text) ?? 0)
        : 0;
    body["irrigation_systems_count"] = curIrrCount;

    // trellises - всегда отправляем
    final curTrellis = _currentTrellises(ref);
    body["trellises"] = curTrellis;

    // reservoirs - всегда отправляем
    final curRes = _currentReservoirs(ref);
    body["reservoirs"] = curRes;

    // subsidies - всегда отправляем
    final curSubs = _currentSubsidies();
    body["subsidies"] = curSubs;

    // fruit_areas - всегда отправляем если есть
    final curFruit = _currentFruitAreas();
    if (curFruit.isNotEmpty) {
      body["fruit_areas"] = curFruit;
    }

    // Пишем ту же GPS-точку в историю user_locations вместе с обновлением
    if (userLoc != null) {
      body["user_location"] = userLoc;
    }

    try {
      final response =
          await _appRepositoryImpl.editPlantation(id: id, body: body);
      if (response.statusCode != 200 && response.statusCode != 201) {
        debugPrint('[editWithImages] Error response data: ${response.data}');
        errorMessage = ApiErrorParser.parse(response.data);
        erroredField = ApiErrorParser.parseFieldName(response.data);
        return false;
      }
      for (final path in newImages) {
        final resp = await _appRepositoryImpl.postPlantationImage(
            id: plantationModel.id!, filePath: path);
        if (resp.statusCode != 200 && resp.statusCode != 201) {
          errorMessage = resp.data.toString();
          return false;
        }
      }
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  /// Загрузить информацию о пользователе (isSpecialUser) из storage
  Future<void> loadUserInfo() async {
    _isSpecialUser =
        await AppStorage.$readBool(key: StorageKey.isSpecialUser) ?? false;
  }

  /// Показать диалог выбора источника изображения (Camera/Gallery)
  Future<void> showImagePicker(BuildContext context, int cardId) async {
    // Загружаем информацию о пользователе перед показом диалога
    await loadUserInfo();

    if (!context.mounted) return;

    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              // Показываем опцию Gallery только для специальных пользователей
              if (_isSpecialUser) ...[
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Gallery'),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
              ],
            ],
          ),
        );
      },
    );

    if (source != null && context.mounted) {
      await pickImage(cardId: cardId, source: source, context: context);
    }
  }

  /// Основной метод для загрузки изображения (используется после выбора source)
  Future<String?> pickImage({
    required int cardId,
    required ImageSource source,
    BuildContext? context,
  }) async {
    if (_isPickerActive) return null;
    _isPickerActive = true;
    try {
      return await _pickImageImpl(
          cardId: cardId, source: source, context: context);
    } finally {
      _isPickerActive = false;
    }
  }

  Future<String?> _pickImageImpl({
    required int cardId,
    required ImageSource source,
    BuildContext? context,
  }) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 70,
      maxWidth: 1920,
      maxHeight: 1920,
    );
    if (pickedFile == null) return null;

    // Валидация формата изображения
    if (!Utils.isValidImageFormat(pickedFile.path)) {
      final mountedContext = context;
      if (mountedContext != null && mountedContext.mounted) {
        Utils.fireTopSnackBar(
          "Faqat JPEG yoki JPG formatidagi rasmlar qabul qilinadi",
          design_colors.AppColors.error,
          mountedContext,
        );
      }
      return null;
    }
    final int plantationId = plantationModel.id!;

    // Нет сети — не пытаемся аплоадить сразу, копируем в стабильную
    // директорию и кладём отдельной лёгкой записью в офлайн-очередь.
    // Не трогаем _imageFiles/finally-cleanup обычного (online) пути —
    // фото остаётся видимым в форме с явной пометкой "ожидает отправки".
    final isOnline = await NetworkUtils.hasInternetConnection();
    if (!isOnline) {
      try {
        final destPath = await UploadQueueStore.instance
            .copyToStableDir(pickedFile.path, prefix: 'edit_${cardId}_');
        _imageFiles[cardId] = File(destPath);
        _pendingOfflineImageCardIds.add(cardId);
        notifyListeners();

        final mountedContext = context;
        if (mountedContext != null && mountedContext.mounted) {
          final container = ProviderScope.containerOf(mountedContext);
          await container.read(uploadQueueServiceProvider).enqueuePhotoOnly(
                plantationId: plantationId,
                farmerId: 0,
                displayLabel: "Plantatsiya #$plantationId",
                imagePath: destPath,
                cardId: cardId,
              );
        }
        return "Tarmoq yo'q — rasm navbatga qo'yildi";
      } catch (e) {
        errorMessage = e.toString();
        return errorMessage;
      }
    }

    // Set loader state for this slot
    _uploadingIndex = cardId;
    _isUploadingImage = true;
    // Put temporary preview
    _imageFiles[cardId] = File(pickedFile.path);
    notifyListeners();

    try {
      // Try modern endpoint
      final resp = await _appRepositoryImpl.postPlantationImage(
          id: plantationId, filePath: pickedFile.path);
      if (resp.statusCode == 200 || resp.statusCode == 201) {
        // Refresh images and ids
        await refreshDetailImages();
        return (resp.data is Map && resp.data['message'] is String)
            ? resp.data['message'] as String
            : 'Rasm muvaffaqiyatli yuklandi';
      }
      // Fallback to legacy batch
      if (resp.statusCode == 405) {
        final legacy = await _appRepositoryImpl
            .editImage(id: plantationId, images: [pickedFile.path]);
        if (legacy != null) {
          await refreshDetailImages();
          return 'Rasm muvaffaqiyatli yuklandi';
        }
      }
      errorMessage = (resp.data is Map && resp.data['message'] is String)
          ? resp.data['message'] as String
          : 'Rasm yuklashda xatolik';
      return errorMessage;
    } catch (e) {
      errorMessage = e.toString();
      return errorMessage;
    } finally {
      // Clear temp and loader
      _imageFiles.remove(cardId);
      _uploadingIndex = null;
      _isUploadingImage = false;
      notifyListeners();
    }
  }

  /// Старый метод для обратной совместимости
  Future<String?> pickImageFromCamera(int cardId,
      {BuildContext? context}) async {
    return await pickImage(
        cardId: cardId, source: ImageSource.camera, context: context);
  }

  // ===== deal_file / resolution_file (PDF) =====
  //
  // Оба поля грузятся через один и тот же endpoint, что и весь остальной
  // PUT/PATCH на плантацию (apiPlantationFiles = /api/plantations/{id}/),
  // но mobile-update (обычный save-путь этой формы) — JSON-only и не может
  // принять файл. Поэтому загрузка идёт сразу при выборе файла, отдельным
  // запросом — как фото плантации, не откладывается до "Сохранить".
  bool isUploadingDealFile = false;
  bool isUploadingResolutionFile = false;

  Future<String?> pickAndUploadDocFile({required bool isDeal}) async {
    final plantationId = plantationModel.id;
    if (plantationId == null) return null;

    PlatformFile? picked;
    try {
      picked = await FilePicker.pickFile(
          type: FileType.custom, allowedExtensions: ['pdf']);
    } catch (e) {
      return e.toString();
    }
    final path = picked?.path;
    if (path == null) return null;

    if (isDeal) {
      isUploadingDealFile = true;
    } else {
      isUploadingResolutionFile = true;
    }
    notifyListeners();

    try {
      final resp = await _appRepositoryImpl.uploadPlantationDocFile(
        id: plantationId,
        fieldName: isDeal ? 'deal_file' : 'resolution_file',
        filePath: path,
      );
      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final data = resp.data;
        if (data is Map<String, dynamic>) {
          if (isDeal) {
            plantationModel.dealFile = data['deal_file']?.toString();
          } else {
            plantationModel.resolutionFile =
                data['resolution_file']?.toString();
          }
        }
        return null;
      }
      return (resp.data is Map && resp.data['message'] is String)
          ? resp.data['message'] as String
          : 'Faylni yuklashda xatolik';
    } catch (e) {
      return e.toString();
    } finally {
      if (isDeal) {
        isUploadingDealFile = false;
      } else {
        isUploadingResolutionFile = false;
      }
      notifyListeners();
    }
  }

  Future<void> getFruit() async {
    isLoading2 = true;
    notifyListeners();
    try {
      final data = await _appRepositoryImpl.getFruits();
      if (data == null) {
        return;
      } else {
        try {
          fruitList = fruitModelFromJson(data);
        } catch (e) {
          // log("Ma'lumotlarni qayta ishlashda muammo yuzaga keldi: $e"); // Removed log
        }
      }
    } catch (e) {
      // log("$e"); // Removed log
    } finally {
      isLoading2 = false;
      notifyListeners();
    }
  }

  Future<void> getFruitVerity({required String verity}) async {
    isLoading2 = true;
    notifyListeners();
    try {
      final data = await _appRepositoryImpl.getFruitsVerity(verity: verity);
      if (data == null) {
        return;
      } else {
        try {
          fruitVerityList = fruitVarietyModelFromJson(data);
        } catch (e) {
          // log("Malumotlarni Qayta ishlashda muammo yuzaga keldi"); // Removed log
        }
      }
    } catch (e) {
      // log("$e"); // Removed log
    } finally {
      isLoading2 = false;
      notifyListeners();
    }
  }

  Future<void> getFruitRootstocks({required String rootstocks}) async {
    isLoading2 = true;
    notifyListeners();
    try {
      final data =
          await _appRepositoryImpl.getFruitsRootstocks(rootstocks: rootstocks);
      if (data == null) {
        return;
      } else {
        // print("Fruit Rootstocks: $data _____");
        try {
          fruitRootList = fruitRootstocksModelFromJson(data);
        } catch (e) {
          // debugPrint("Malumotlarni Qayta ishlashda muammo yuzaga keldi"); // Removed debugPrint
        }
      }
    } catch (e) {
      // log("$e"); // Removed log
    } finally {
      isLoading2 = false;
      notifyListeners();
    }
  }

  /// Резолвит fruit/variety/rootstock id для fruit_areas, полученных из
  /// GET с fruit/variety/rootstock как имя-строка (fruit==null после
  /// FruitArea.fromJson). Ищет id по имени через справочники — без этого
  /// такие записи отфильтровываются в _currentFruitAreas() и теряются
  /// при следующем PATCH.
  Future<void> _resolveUnresolvedFruitAreas() async {
    final unresolved =
        selectedDetails.where((d) => d.fruit == null && d.fruitName != null);
    if (unresolved.isEmpty) return;

    if (fruitList.isEmpty) {
      final data = await _appRepositoryImpl.getFruits();
      if (data == null) return;
      try {
        fruitList = fruitModelFromJson(data);
      } catch (_) {
        return;
      }
    }

    for (final detail in unresolved) {
      final fruit = fruitList
          .where((f) => f.name == detail.fruitName)
          .cast<FruitModel?>()
          .firstOrNull;
      if (fruit == null) continue;
      detail.fruit = fruit.id;

      if (detail.variety == null && detail.varietyName != null) {
        final varietyData = await _appRepositoryImpl.getFruitsVerity(
            verity: fruit.id.toString());
        if (varietyData != null) {
          try {
            final varieties = fruitVarietyModelFromJson(varietyData);
            final variety = varieties
                .where((v) => v.name == detail.varietyName)
                .cast<FruitVarietyModel?>()
                .firstOrNull;
            if (variety != null) detail.variety = variety.id;
          } catch (_) {}
        }
      }

      if (detail.rootstock == null && detail.rootstockName != null) {
        final rootstockData = await _appRepositoryImpl.getFruitsRootstocks(
            rootstocks: fruit.name);
        if (rootstockData != null) {
          try {
            final rootstocks = fruitRootstocksModelFromJson(rootstockData);
            final rootstock = rootstocks
                .where((r) => r.name == detail.rootstockName)
                .cast<FruitRootstocksModel?>()
                .firstOrNull;
            if (rootstock != null) detail.rootstock = rootstock.id;
          } catch (_) {}
        }
      }
    }
    notifyListeners();
  }

  void resetSubsudy() {
    subsidiyaYear.clear();
    subsidiyaContract.clear();
    subsidiyaAmount.clear();
    _selectedEnergy = null;
    notifyListeners();
  }

  void editDetailAt(int index, WidgetRef ref, BuildContext context) async {
    if (index >= 0 && index < selectedDetails.length) {
      final fruitArea = selectedDetails[index];

      // Заполняем поля данными существующего фрукта
      selectedFruit = fruitList.firstWhere(
        (fruit) => fruit.id == fruitArea.fruit,
        orElse: () => fruitList.first,
      );

      // Устанавливаем switcher в зависимости от типа фрукта
      ref.read(switchIqtisodiy.notifier).state =
          fruitArea.iqtisodiysamarasiz ?? false;

      if (fruitArea.iqtisodiysamarasiz == true) {
        // Экономически неэффективная площадь
        economicInefficientAreaController.text =
            fruitArea.economicInefficientArea?.toString() ?? "0.0";
      } else {
        // Обычная посадка
        selectedFruitRoot = fruitRootList.firstWhere(
          (root) => root.id == fruitArea.rootstock,
          orElse: () => fruitRootList.first,
        );

        if (fruitArea.plantedYear != null) {
          _selectedDate2 = DateTime(fruitArea.plantedYear!);
        }

        cultivatedArea.text = fruitArea.area?.toString() ?? "0.0";
        tonnaController.text = fruitArea.weight?.toString() ?? "";

        if (fruitArea.schema != null && fruitArea.schema!.contains('X')) {
          final parts = fruitArea.schema!.split('X');
          if (parts.length == 2) {
            sxema1.text = parts[0];
            sxema2.text = parts[1];
          }
        }

        ref.read(switchFenced.notifier).state = fruitArea.fenced ?? false;
      }

      // Удаляем фрукт из списка (будет добавлен заново после редактирования)
      selectedDetails.removeAt(index);
      selectedFruitVerityRoot.removeAt(index);

      // Загружаем данные фруктов
      await getFruit();

      // Открываем модальное окно для редактирования
      if (context.mounted) {
        await showModalBottomSheet(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(16.r),
            ),
          ),
          backgroundColor: context.colors.surface,
          context: context,
          isScrollControlled: true,
          builder: (context) {
            return FractionallySizedBox(
                heightFactor: 0.9,
                child: EditFruitBottomShit(viewModelm: this));
          },
        );

        // Если модальное окно закрыто, очищаем поля
        ref.read(switchFenced.notifier).state = false;
        resetFields(ref);
      }

      notifyListeners();
    }
  }

  void removeDetailAt(int index) {
    if (index < selectedDetails.length) {
      selectedDetails.removeAt(index);
    }
    if (index < selectedFruitVerityRoot.length) {
      selectedFruitVerityRoot.removeAt(index);
    }
    notifyListeners();
  }

  void addSelectedDetail(WidgetRef ref) {
    final isIqtisodiy = ref.read(switchIqtisodiy);

    if (selectedFruit == null || selectedFruitVariety == null) {
      return;
    }

    // Экономически неэффективная площадь
    if (isIqtisodiy) {
      final econ = double.tryParse(economicInefficientAreaController.text
              .trim()
              .replaceAll(',', '.')) ??
          0.0;

      final fa = FruitArea(
        fruit: selectedFruit?.id,
        variety: selectedFruitVariety?.id,
        rootstock: null, // Всегда null для iqtisodiy=true (поле скрыто в UI)
        fruitName: selectedFruit?.name,
        varietyName: selectedFruitVariety?.name,
        rootstockName: null,
        plantedYear: null,
        area: 0.0,
        schema: null,
        weight: null,
        fenced: null,
        hundredweight: null,
        kochatSoni: null,
        iqtisodiysamarasiz: true,
        economicInefficientArea: econ,
      );
      selectedFruitVerityRoot.add(fa);
      selectedDetails.add(fa);
      _resetFieldsInternal();
      notifyListeners();
      return;
    }

    // Обычная посадка
    if (selectedDate2 != null &&
        cultivatedArea.text.isNotEmpty &&
        sxema1.text.isNotEmpty &&
        sxema2.text.isNotEmpty) {
      final year = selectedDate2!.year.toString();
      final areaVal =
          double.tryParse(cultivatedArea.text.trim().replaceAll(',', '.')) ??
              0.0;

      final fa = FruitArea(
        fruit: selectedFruit?.id,
        variety: selectedFruitVariety?.id,
        rootstock: selectedFruitRoot?.id,
        fruitName: selectedFruit?.name,
        varietyName: selectedFruitVariety?.name,
        rootstockName: selectedFruitRoot?.name,
        plantedYear: int.tryParse(year) ?? 0,
        area: areaVal,
        schema: "${sxema1.text}X${sxema2.text}",
        weight: tonnaController.text.trim().isEmpty
            ? null
            : double.tryParse(
                    tonnaController.text.trim().replaceAll(',', '.')) ??
                0.0,
        fenced: ref.read(switchFenced),
        hundredweight: null,
        kochatSoni: null,
        iqtisodiysamarasiz: false,
      );

      selectedFruitVerityRoot.add(fa);
      selectedDetails.add(fa);
      _resetFieldsInternal();
      notifyListeners();
    }
  }

  void _resetFieldsInternal() {
    selectedFruit = null;
    selectedFruitVariety = null;
    selectedFruitRoot = null;
    _selectedDate2 = null;
    cultivatedArea.clear();
    sxema1.clear();
    sxema2.clear();
    tonnaController.clear();
    economicInefficientAreaController.clear();
    notifyListeners();
  }

  void resetFields(WidgetRef ref) {
    _resetFieldsInternal();
    ref.read(switchIqtisodiy.notifier).state = false;
    ref.read(switchFenced.notifier).state = false;
  }

  int? _selectedPlantationType;
  int? get selectedPlantationType => _selectedPlantationType;
  void setPlantationType(int? value) {
    _selectedPlantationType = value;
    // Type-specific dropdowns (bog/uzum/issiqxona type + bog subtype) are
    // each shown only for their matching plantationType — switching away
    // must clear all of them, otherwise a stale selection from a
    // previous type stays in the payload invisibly and the backend
    // rejects it ("Для данного типа нет подтипов").
    if (value != 1) {
      _selectedBogType = null;
      _selectedBogSubtype = null;
    }
    if (value != 2) {
      _selectedUzumType = null;
    }
    if (value != 3) {
      _selectedIssiqxonaType = null;
    }
    notifyListeners();
  }

  int? _selectedBogType;
  int? get selectedBogType => _selectedBogType;
  void setBogType(int? value) {
    _selectedBogType = value;
    // Subtype-дропдаун виден только при bogType == 1 (intensiv).
    if (value != 1) {
      _selectedBogSubtype = null;
    }
    notifyListeners();
  }

  int? _selectedBogSubtype;
  int? get selectedBogSubtype => _selectedBogSubtype;
  void setBogSubtype(int? value) {
    _selectedBogSubtype = value;
    notifyListeners();
  }

  int? _selectedUzumType;
  int? get selectedUzumType => _selectedUzumType;
  void setUzumType(int? value) {
    _selectedUzumType = value;
    notifyListeners();
  }

  int? _selectedIssiqxonaType;
  int? get selectedIssiqxonaType => _selectedIssiqxonaType;
  void setIssiqxonaType(int? value) {
    _selectedIssiqxonaType = value;
    notifyListeners();
  }

  // --- Fruit area operations ---
  void removeDetail(int index) {
    if (index < selectedDetails.length) {
      selectedDetails.removeAt(index);
      notifyListeners();
    }
  }

  void addDetail(FruitArea fruitArea) {
    selectedDetails.add(fruitArea);
    notifyListeners();
  }

  // Kontur operations
  void addKonturNumber() {
    final value = konturInputController.text.trim();
    if (value.isEmpty) return;
    konturNumbers.add(value);
    konturInputController.clear();
    notifyListeners();
  }

  void removeKonturAt(int index) {
    if (index < 0 || index >= konturNumbers.length) return;
    konturNumbers.removeAt(index);
    notifyListeners();
  }

  // ======== Setters used by UI ========
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    plantationModel.gardenEstablishedYear = date.year;
    selectedDateController.text = DateFormat('yyyy-MM-dd').format(date);
    notifyListeners();
  }

  void setSelectedDate2(DateTime date) {
    _selectedDate2 = date;
    notifyListeners();
  }

  void clearSelectedDate2() {
    _selectedDate2 = null;
    notifyListeners();
  }

  void setYerTuri(int? yerTuri) {
    _selectedYerTuriMap = yerTuri;
    notifyListeners();
  }

  void setEnergy(int? energy) {
    _selectedEnergy = energy;
    notifyListeners();
  }

  void setUnumdorlikValue(double value) {
    unumdorlikValue = value;
    notifyListeners();
  }

  void setNotUsableArea(String v) {
    String cleaned = v.replaceAll(',', '.');
    cleaned = cleaned.replaceAll(RegExp(r'[^0-9.]'), '');
    final firstDot = cleaned.indexOf('.');
    if (firstDot != -1) {
      final before = cleaned.substring(0, firstDot + 1);
      final after = cleaned.substring(firstDot + 1).replaceAll('.', '');
      cleaned = before + after;
    }
    notUsableArea.value = TextEditingValue(
      text: cleaned,
      selection: TextSelection.collapsed(offset: cleaned.length),
    );
    // Оптимизация: уменьшаем частоту обновлений
    Future.microtask(() => notifyListeners());
  }

  void setEmptyArea(String v) {
    String cleaned = v.replaceAll(',', '.');
    cleaned = cleaned.replaceAll(RegExp(r'[^0-9.]'), '');
    final firstDot = cleaned.indexOf('.');
    if (firstDot != -1) {
      final before = cleaned.substring(0, firstDot + 1);
      final after = cleaned.substring(firstDot + 1).replaceAll('.', '');
      cleaned = before + after;
    }
    emptyArea.value = TextEditingValue(
      text: cleaned,
      selection: TextSelection.collapsed(offset: cleaned.length),
    );
    // Оптимизация: уменьшаем частоту обновлений
    Future.microtask(() => notifyListeners());
  }

  void setEconomicInefficientArea(String v) {
    String cleaned = v.replaceAll(',', '.');
    cleaned = cleaned.replaceAll(RegExp(r'[^0-9.]'), '');
    final firstDot = cleaned.indexOf('.');
    if (firstDot != -1) {
      final before = cleaned.substring(0, firstDot + 1);
      final after = cleaned.substring(firstDot + 1).replaceAll('.', '');
      cleaned = before + after;
    }
    economicInefficientAreaController.value = TextEditingValue(
      text: cleaned,
      selection: TextSelection.collapsed(offset: cleaned.length),
    );
    // Оптимизация: уменьшаем частоту обновлений
    Future.microtask(() => notifyListeners());
  }

  double getTotalArea(WidgetRef ref) {
    // empty_area
    final empty = double.tryParse(emptyArea.text.replaceAll(',', '.')) ?? 0.0;

    // not_usable_area
    final notUsable =
        double.tryParse(notUsableArea.text.replaceAll(',', '.')) ?? 0.0;

    // economic_inefficient_area (сумма всех экономически неэффективных площадей)
    double economicInefficient = 0.0;
    for (final fruitArea in selectedDetails) {
      if (fruitArea.iqtisodiysamarasiz == true) {
        economicInefficient += fruitArea.economicInefficientArea ?? 0.0;
      }
    }

    // planted_area (сумма всех обычных площадей)
    double planted = 0.0;
    for (final fruitArea in selectedDetails) {
      if (fruitArea.iqtisodiysamarasiz == false) {
        planted += fruitArea.area ?? 0.0;
      }
    }

    // Добавляем текущий фрукт, если он заполняется
    final isIqtisodiy = ref.read(switchIqtisodiy);
    if (isIqtisodiy) {
      economicInefficient += double.tryParse(
              economicInefficientAreaController.text.replaceAll(',', '.')) ??
          0.0;
    } else {
      planted +=
          double.tryParse(cultivatedArea.text.replaceAll(',', '.')) ?? 0.0;
    }

    return empty + notUsable + economicInefficient + planted;
  }

  void setInvestmentMahhalliyAmount(String value) {
    investmentMahhalliyAmount.text = value;
  }

  void setInvestmentXorijiyAmount(String value) {
    investmentXorijiyAmount.text = value;
  }

  void setIrrigationArea(String value) {
    irrigationAreaController.text = value;
  }

  void setIrrigationSystemsCount(String value) {
    irrigationSystemsCount.text = value;
  }

  void setSubsidiya(String value) {
    subsidiyaYear.text = value;
  }

  void setSubsidiyaContract(String value) {
    subsidiyaContract.text = value;
  }

  void setSubsidiyaAmount(String value) {
    subsidiyaAmount.text = value;
  }

  void setTrellisTemirInstalledArea(String value) {
    trellisTemirInstalledArea.text = value;
  }

  void setTrellisTemirCount(String value) {
    trellisTemirCount.text = value;
  }

  void setTrellisBetonInstalledArea(String value) {
    trellisBetonInstalledArea.text = value;
  }

  void setTrellisBetonCount(String value) {
    trellisBetonCount.text = value;
  }

  void setReservoirQoplamaliVolume(String value) {
    reservoirsQoplamaliVolume.text = value;
  }

  void setReservoirBetonliVolume(String value) {
    reservoirsBetonliVolume.text = value;
  }

  void setCultivatedArea(String value) {
    cultivatedArea.text = value;
    notifyListeners();
  }

  void setSxema1(String value) {
    sxema1.text = value;
    notifyListeners();
  }

  void setSxema2(String value) {
    sxema2.text = value;
    notifyListeners();
  }

  void setTonna(String value) {
    tonnaController.text = value;
  }

  void setFruit(FruitModel? fruit) {
    selectedFruit = fruit;
    notifyListeners();
  }

  void setFruitVariety(FruitVarietyModel? fruitVariety) {
    selectedFruitVariety = fruitVariety;
    notifyListeners();
  }

  void setFruitRoot(FruitRootstocksModel? fruitRoot) {
    selectedFruitRoot = fruitRoot;
    notifyListeners();
  }

  // ======== Image helpers used by UI ========
  List<String> get existingImages => images;

  Future<void> refreshDetailImages() async {
    try {
      final id = plantationModel.id;
      if (id == null) return;
      final data = await _appRepositoryImpl.getPlantationDetail(id: id);
      if (data == null) {
        debugPrint('❌ EditVM.refreshDetailImages: detail returned null');
        return;
      }
      final decoded = jsonDecode(data);
      try {
        final model = EditPlantationModel.fromJson(decoded);
        images = model.images ?? images;
        try {
          final imgs =
              (decoded is Map<String, dynamic>) ? decoded['images'] : null;
          if (imgs is List) {
            imageIds = [];
            for (final e in imgs) {
              if (e is Map<String, dynamic>) {
                final imgId = e['id'];
                if (imgId is int) imageIds.add(imgId);
              }
            }
          }
        } catch (e) {
          debugPrint(
              '⚠️ EditVM.refreshDetailImages: image IDs parse error: $e');
        }
      } catch (e) {
        debugPrint('❌ EditVM.refreshDetailImages: model parse error: $e');
      }
      notifyListeners();
    } catch (e) {
      debugPrint('❌ EditVM.refreshDetailImages: network error: $e');
      errorMessage = "Rasmlarni yangilashda xatolik yuz berdi";
      notifyListeners();
    }
  }

  Future<String?> removeExistingImage(int index) async {
    if (index >= images.length) return null;

    // Не удаляем сразу на сервере, только помечаем для удаления
    // Удаление произойдет только при сохранении
    if (index < imageIds.length) {
      // Сохраняем ID изображения для удаления при сохранении
      _imagesToDelete.add(imageIds[index]);
    }

    // Локально убираем из списка (только для отображения)
    images.removeAt(index);
    if (index < imageIds.length) {
      imageIds.removeAt(index);
    }
    notifyListeners();
    return "Rasm o'chirildi";
  }

  /// Восстановить оригинальный список изображений (при отмене изменений)
  void restoreOriginalImages() {
    images = List<String>.from(_originalImages);
    imageIds = List<int>.from(_originalImageIds);
    _imagesToDelete.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    notUsableArea.dispose();
    emptyArea.dispose();
    dealNumberController.dispose();
    resolutionNumberController.dispose();
    investmentXorijiyAmount.dispose();
    investmentMahhalliyAmount.dispose();
    irrigationAreaController.dispose();
    irrigationSystemsCount.dispose();
    subsidiyaYear.dispose();
    subsidiyaContract.dispose();
    subsidiyaAmount.dispose();
    trellisTemirInstalledArea.dispose();
    trellisTemirCount.dispose();
    trellisBetonInstalledArea.dispose();
    trellisBetonCount.dispose();
    cultivatedArea.dispose();
    sxema1.dispose();
    sxema2.dispose();
    konturInputController.dispose();
    commentsController.dispose();
    selectedDateController.dispose();
    tonnaController.dispose();
    economicInefficientAreaController.dispose();
    // Dispose динамических контроллеров резервуаров
    // (основные reservoirsBetonliVolume/reservoirsQoplamaliVolume уже в списках)
    for (final c in reservoirsBetonliVolumes) {
      c.dispose();
    }
    for (final c in reservoirsQoplamaliVolumes) {
      c.dispose();
    }
    super.dispose();
  }
}
