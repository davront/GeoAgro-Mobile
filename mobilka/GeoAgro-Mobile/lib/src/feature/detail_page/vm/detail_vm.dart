import 'dart:async';
import 'dart:convert';
import 'dart:developer' as p;
import 'dart:io';

import 'package:agro_employee_public/src/core/setting/setup.dart';
import 'package:agro_employee_public/src/data/model/fruits/fruit_model.dart';
import 'package:agro_employee_public/src/data/model/fruits/fruit_rootstocks_model.dart';
import 'package:agro_employee_public/src/data/model/fruits/fruit_verity_modell.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:l/l.dart';

import '../../../data/model/plantation/new_plantation_model.dart';
import '../../../data/repository/app_repository_impl.dart';
import '../../../core/storage/app_storage.dart';
import '../../../core/storage/draft_store.dart';
import '../../../core/storage/upload_queue_store.dart';
import '../../../core/queue/upload_queue_provider.dart';
import '../../../core/utils/api_error_parser.dart';
import '../../../core/utils/network_error_utils.dart';
import '../../../core/utils/network_utils.dart';
import '../../../core/utils/sanitization_utils.dart';
import '../../../core/utils/utils.dart';
import '../../../../design_system/theme/colors.dart' as design_colors;

final detailVM = ChangeNotifierProvider.autoDispose<DetailVM>((ref) {
  return DetailVM();
});

class DetailVM extends ChangeNotifier {
  bool postLoading = false;
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

  String _norm(String v) => v.replaceAll(',', '.');
  String _onlyDigitsDot(String v) => v.replaceAll(RegExp(r'[^0-9.]'), '');
  String _onlyAlphaNum(String v) => v.replaceAll(RegExp(r'[^0-9a-zA-Z]'), '');

  TextEditingController notUsableArea = TextEditingController();
  TextEditingController emptyArea = TextEditingController();
  TextEditingController konturInputController = TextEditingController();
  TextEditingController tomchiSystemsArea = TextEditingController();
  TextEditingController tomchiSystemsCount = TextEditingController();
  TextEditingController investmentMahhalliyAmount = TextEditingController();
  TextEditingController investmentXorijiyAmount = TextEditingController();
  TextEditingController subsidiyaContract = TextEditingController();
  TextEditingController subsidiyaAmount = TextEditingController();
  TextEditingController trellisTemirInstalledArea = TextEditingController();
  TextEditingController trellisTemirCount = TextEditingController();
  TextEditingController trellisBetonInstalledArea = TextEditingController();
  TextEditingController trellisBetonCount = TextEditingController();
  TextEditingController reservoirsQoplamaliVolume = TextEditingController();
  TextEditingController reservoirsBetonliVolume = TextEditingController();

  // Списки для хранения нескольких резервуаров каждого типа
  final List<TextEditingController> reservoirsBetonliVolumes = [];
  final List<TextEditingController> reservoirsQoplamaliVolumes = [];

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

  // Имя поля (ключ бэка, напр. "plantation_type"), к которому относится
  // последняя ошибка сервера — используется UI для подсветки конкретного
  // инпута и автоскролла к нему, вместо общей error-снекбар без указания,
  // что именно чинить.
  String? erroredField;

  TextEditingController cultivatedArea = TextEditingController();
  TextEditingController sxema1 = TextEditingController();
  TextEditingController sxema2 = TextEditingController();
  double unumdorlikValue = 50;
  DateTime? _selectedDate;
  DateTime? _selectedDate2;
  DateTime? _selectedDate3;
  List<FruitModel> fruitList = [];
  List<FruitVarietyModel> fruitVerityList = [];
  List<FruitRootstocksModel> fruitRootList = [];
  FruitModel? selectedFruit;
  FruitVarietyModel? selectedFruitVariety;
  FruitRootstocksModel? selectedFruitRoot;
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
  final switchTomchi = StateProvider<bool>((ref) => false);
  final switchFenced = StateProvider<bool>((ref) => false);
  final switchIsFertile = StateProvider<bool>((ref) => false);
  final switchSubsidiya = StateProvider<bool>((ref) => false);
  final switchEfficiency = StateProvider<bool>((ref) => false);
  final switchTrellis = StateProvider<bool>((ref) => false);
  final switchTrellisBeton = StateProvider<bool>((ref) => false);
  final switchTrellisTemir = StateProvider<bool>((ref) => false);
  final switchReservoir = StateProvider<bool>((ref) => false);
  final switchReservoirsBeton = StateProvider<bool>((ref) => false);
  final switchReservoirsQoplamali = StateProvider<bool>((ref) => false);
  final switchInvestmentXorjiy = StateProvider<bool>((ref) => false);
  final switchInvestmentMahhalliy = StateProvider<bool>((ref) => false);
  final switchIqtisodiy = StateProvider<bool>((ref) => false);
  TextEditingController economicInefficientAreaController =
      TextEditingController();
  DateTime? get selectedDate => _selectedDate;
  DateTime? get selectedDate2 => _selectedDate2;
  DateTime? get selectedDate3 => _selectedDate3;
  File? getImageFile(int cardId) => _imageFiles[cardId];

  /// Удаляет изображение по индексу
  void removeImage(int cardId) {
    _imageFiles.remove(cardId);
    notifyListeners();
  }

  bool isLoading = false;
  bool isLoading2 = false;
  List<FruitArea> selectedDetails = [];
  List<FruitArea> selectedFruitVerityRoot = [];
  List<Subsidy> selectedSubsidy = [];
  List<String> konturNumbers = [];
  int farmerId = 0;
  int direction = 0;
  List<Coordinate> coordinates = [];
  double? polygonArea; // Площадь полигона в гектарах
  /// GPS-точка пользователя для user_location. null — точка недоступна,
  /// в этом случае на сервер ничего не отправляем (фейковые координаты
  /// портят историю точек).
  Map<String, double>? userLocation;

  /// Момент, когда GPS-точка была реально зафиксирована (рисование
  /// полигона), а не момент финального сабмита формы — тот может
  /// случиться много позже. Используется как collectedAt в QueueItem.
  DateTime? _collectedAt;
  TextEditingController tonnaController = TextEditingController();
  TextEditingController commentsController = TextEditingController();

  String? errorMessage;

  // ===== Draft persistence =====

  /// Плоский снапшот UI-state для восстановления формы после kill
  /// процесса/paused. Не переиспользует Garden.toJson() — тот формат уже
  /// "схлопывает" switches в конкретные значения и однозначно не
  /// восстанавливается обратно в переключатели.
  Future<void> saveDraftSnapshot(WidgetRef ref) async {
    try {
      final data = <String, dynamic>{
        "farmer_id": farmerId,
        "coordinates": coordinates
            .map((c) => {"latitude": c.latitude, "longitude": c.longitude})
            .toList(),
        "user_location": userLocation,
        "collected_at": _collectedAt?.toIso8601String(),
        "polygon_area": polygonArea,
        "kontur_numbers": konturNumbers,
        "controllers": {
          "notUsableArea": notUsableArea.text,
          "emptyArea": emptyArea.text,
          "tomchiSystemsArea": tomchiSystemsArea.text,
          "tomchiSystemsCount": tomchiSystemsCount.text,
          "investmentMahhalliyAmount": investmentMahhalliyAmount.text,
          "investmentXorijiyAmount": investmentXorijiyAmount.text,
          "subsidiyaContract": subsidiyaContract.text,
          "subsidiyaAmount": subsidiyaAmount.text,
          "trellisTemirInstalledArea": trellisTemirInstalledArea.text,
          "trellisTemirCount": trellisTemirCount.text,
          "trellisBetonInstalledArea": trellisBetonInstalledArea.text,
          "trellisBetonCount": trellisBetonCount.text,
          "cultivatedArea": cultivatedArea.text,
          "sxema1": sxema1.text,
          "sxema2": sxema2.text,
          "economicInefficientAreaController":
              economicInefficientAreaController.text,
          "tonnaController": tonnaController.text,
          "commentsController": commentsController.text,
        },
        "reservoirsBetonliVolumes":
            reservoirsBetonliVolumes.map((c) => c.text).toList(),
        "reservoirsQoplamaliVolumes":
            reservoirsQoplamaliVolumes.map((c) => c.text).toList(),
        "switches": {
          "switchTomchi": ref.read(switchTomchi),
          "switchFenced": ref.read(switchFenced),
          "switchIsFertile": ref.read(switchIsFertile),
          "switchSubsidiya": ref.read(switchSubsidiya),
          "switchEfficiency": ref.read(switchEfficiency),
          "switchTrellis": ref.read(switchTrellis),
          "switchTrellisBeton": ref.read(switchTrellisBeton),
          "switchTrellisTemir": ref.read(switchTrellisTemir),
          "switchReservoir": ref.read(switchReservoir),
          "switchReservoirsBeton": ref.read(switchReservoirsBeton),
          "switchReservoirsQoplamali": ref.read(switchReservoirsQoplamali),
          "switchInvestmentXorjiy": ref.read(switchInvestmentXorjiy),
          "switchInvestmentMahhalliy": ref.read(switchInvestmentMahhalliy),
          "switchIqtisodiy": ref.read(switchIqtisodiy),
        },
        "unumdorlik_value": unumdorlikValue,
        "selected_plantation_type": _selectedPlantationType,
        "selected_bog_type": _selectedBogType,
        "selected_issiqxona_type": _selectedIssiqxonaType,
        "selected_uzum_type": _selectedUzumType,
        "selected_bog_subtype": _selectedBogSubtype,
        "selected_yer_type": _selectedYerType,
        "image_files": _imageFiles.map(
          (cardId, file) => MapEntry(cardId.toString(), file?.path),
        ),
        "saved_at": DateTime.now().toIso8601String(),
      };
      await DraftStore.instance.writeCreateDraft(data);
    } catch (e) {
      p.log("DetailVM: saveDraftSnapshot failed: $e");
    }
  }

  /// Восстанавливает черновик, если он есть. Вызывается один раз при
  /// первом открытии формы (см. DetailPage _hasLoadedData guard) —
  /// НЕ перезаписывает уже переданные из карты farmerId/coordinates,
  /// если черновик relate к другому фермеру/участку.
  Future<bool> restoreDraftIfExists() async {
    try {
      final data = await DraftStore.instance.readCreateDraft();
      if (data == null) return false;
      if ((data["farmer_id"] as int?) != farmerId) return false;

      // farmerId один и тот же не значит один и тот же участок — юзер
      // может создавать несколько плантаций подряд одному фермеру.
      // Сверяем нарисованный полигон черновика с текущим, иначе draft
      // от прошлой (уже сохранённой или брошенной) плантации подставится
      // в форму для совсем нового участка.
      final draftCoords = (data["coordinates"] as List<dynamic>? ?? [])
          .map((c) => c as Map<String, dynamic>)
          .toList();
      final sameArea = draftCoords.length == coordinates.length &&
          List.generate(coordinates.length, (i) {
            final lat = (draftCoords[i]["latitude"] as num).toDouble();
            final lng = (draftCoords[i]["longitude"] as num).toDouble();
            return lat == coordinates[i].latitude &&
                lng == coordinates[i].longitude;
          }).every((match) => match);
      if (!sameArea) {
        await _clearDraft();
        return false;
      }

      final controllers =
          Map<String, dynamic>.from(data["controllers"] as Map? ?? {});
      notUsableArea.text = controllers["notUsableArea"] as String? ?? "";
      emptyArea.text = controllers["emptyArea"] as String? ?? "";
      tomchiSystemsArea.text =
          controllers["tomchiSystemsArea"] as String? ?? "";
      tomchiSystemsCount.text =
          controllers["tomchiSystemsCount"] as String? ?? "";
      investmentMahhalliyAmount.text =
          controllers["investmentMahhalliyAmount"] as String? ?? "";
      investmentXorijiyAmount.text =
          controllers["investmentXorijiyAmount"] as String? ?? "";
      subsidiyaContract.text =
          controllers["subsidiyaContract"] as String? ?? "";
      subsidiyaAmount.text = controllers["subsidiyaAmount"] as String? ?? "";
      trellisTemirInstalledArea.text =
          controllers["trellisTemirInstalledArea"] as String? ?? "";
      trellisTemirCount.text =
          controllers["trellisTemirCount"] as String? ?? "";
      trellisBetonInstalledArea.text =
          controllers["trellisBetonInstalledArea"] as String? ?? "";
      trellisBetonCount.text =
          controllers["trellisBetonCount"] as String? ?? "";
      cultivatedArea.text = controllers["cultivatedArea"] as String? ?? "";
      sxema1.text = controllers["sxema1"] as String? ?? "";
      sxema2.text = controllers["sxema2"] as String? ?? "";
      economicInefficientAreaController.text =
          controllers["economicInefficientAreaController"] as String? ?? "";
      tonnaController.text = controllers["tonnaController"] as String? ?? "";
      commentsController.text =
          controllers["commentsController"] as String? ?? "";

      final betonVolumes =
          (data["reservoirsBetonliVolumes"] as List<dynamic>? ?? [])
              .cast<String>();
      for (var i = 0; i < betonVolumes.length; i++) {
        if (i >= reservoirsBetonliVolumes.length) addBetonReservoir();
        reservoirsBetonliVolumes[i].text = betonVolumes[i];
      }
      final qoplamaliVolumes =
          (data["reservoirsQoplamaliVolumes"] as List<dynamic>? ?? [])
              .cast<String>();
      for (var i = 0; i < qoplamaliVolumes.length; i++) {
        if (i >= reservoirsQoplamaliVolumes.length) addQoplamaliReservoir();
        reservoirsQoplamaliVolumes[i].text = qoplamaliVolumes[i];
      }

      unumdorlikValue = (data["unumdorlik_value"] as num?)?.toDouble() ?? 50;
      _selectedPlantationType = data["selected_plantation_type"] as int?;
      _selectedBogType = data["selected_bog_type"] as int?;
      _selectedIssiqxonaType = data["selected_issiqxona_type"] as int?;
      _selectedUzumType = data["selected_uzum_type"] as int?;
      _selectedBogSubtype = data["selected_bog_subtype"] as int?;
      _selectedYerType = data["selected_yer_type"] as int?;
      konturNumbers =
          (data["kontur_numbers"] as List<dynamic>? ?? []).cast<String>();

      final imageFilesMap =
          Map<String, dynamic>.from(data["image_files"] as Map? ?? {});
      for (final entry in imageFilesMap.entries) {
        final path = entry.value as String?;
        if (path != null && await File(path).exists()) {
          _imageFiles[int.parse(entry.key)] = File(path);
        }
      }

      notifyListeners();
      return true;
    } catch (e) {
      p.log("DetailVM: restoreDraftIfExists failed: $e");
      return false;
    }
  }

  Future<void> _clearDraft() async {
    await DraftStore.instance.clearCreateDraft();
  }

  Future<bool> createPt(WidgetRef ref) async {
    // Защита от множественных вызовов
    if (postLoading) {
      debugPrint('createPt: Already in progress, ignoring duplicate call');
      return false;
    }

    postLoading = true;
    erroredField = null;
    notifyListeners();
    late String tomchiArea;
    late String tomchiCount;
    late String investmentMahhalliy;
    late String investmentXorjiy;
    List<Subsidy> mockSubsidies = [];
    List<Trellis> mockTrellises = [];
    List<Reservoir> mockReservoir = [];
    List<Investment> mockInvestments = [];
    List<FruitArea> mockFruitArea = [];
    final bool isTomchilab = ref.watch(switchTomchi);
    final bool isUnumdormi = ref.watch(switchIsFertile);
    final bool isInvestmentMahhalliy = ref.watch(switchInvestmentMahhalliy);
    final bool isInvestmentXorijiy = ref.watch(switchInvestmentXorjiy);
    final bool isSubsidiya = ref.watch(switchSubsidiya);
    final bool isSubsidiyaSamaradormi = ref.watch(switchEfficiency);
    final bool isShpaller = ref.watch(switchTrellis);
    final bool isShpallerTemir = ref.watch(switchTrellisTemir);
    final bool isShpallerBeton = ref.watch(switchTrellisBeton);
    final bool hovuz = ref.watch(switchReservoir);
    final bool hovuzBeton = ref.watch(switchReservoirsBeton);
    final bool hovuzQoplamali = ref.watch(switchReservoirsQoplamali);

    // Tomchi tizimi
    if (isTomchilab) {
      tomchiArea = tomchiSystemsArea.text.trim();
      tomchiCount = tomchiSystemsCount.text.trim();
    } else {
      tomchiArea = "0";
      tomchiCount = "0";
    }
    // Investitsiya qiymatlari: butun sonlar, maskani olib tashlaymiz
    String digitsOnly(String v) => v.replaceAll(RegExp(r'[^0-9]'), '');
    investmentMahhalliy = isInvestmentMahhalliy
        ? digitsOnly(investmentMahhalliyAmount.text.trim())
        : "0";
    investmentXorjiy = isInvestmentXorijiy
        ? digitsOnly(investmentXorijiyAmount.text.trim())
        : "0";
    mockInvestments = [
      if (isInvestmentMahhalliy)
        Investment(
          investType: "1",
          investmentAmount: (int.tryParse(investmentMahhalliy) ?? 0).toDouble(),
        ),
      if (isInvestmentXorijiy)
        Investment(
          investType: "2",
          investmentAmount: (int.tryParse(investmentXorjiy) ?? 0).toDouble(),
        ),
    ];
    // Subsidiya ro'yxati
    if (isSubsidiya) {
      mockSubsidies = selectedSubsidy.map((dateil) {
        return Subsidy(
          year: dateil.year,
          contractNumber: dateil.contractNumber,
          direction: dateil.direction,
          amount: dateil.amount,
          efficiency: isSubsidiyaSamaradormi,
        );
      }).toList();
    }

    // Shpaller logikasi
    if (isShpaller) {
      if (isShpallerTemir) {
        mockTrellises.add(
          Trellis(
            trellisType: 1,
            trellisCount: int.tryParse(trellisTemirCount.text.trim()) ?? 0,
            trellisInstalledArea:
                double.tryParse(trellisTemirInstalledArea.text.trim()) ?? 0.0,
          ),
        );
      }
      if (isShpallerBeton) {
        mockTrellises.add(
          Trellis(
            trellisType: 2,
            trellisCount: int.tryParse(trellisBetonCount.text.trim()) ?? 0,
            trellisInstalledArea:
                double.tryParse(trellisBetonInstalledArea.text.trim()) ?? 0.0,
          ),
        );
      }
    }
    // Hovuz logikasi - используем списки для поддержки нескольких резервуаров
    if (hovuz) {
      if (hovuzBeton) {
        // Инициализируем список, если он пуст
        if (reservoirsBetonliVolumes.isEmpty) {
          initializeReservoirs();
        }
        // Добавляем все бетонные резервуары
        for (final controller in reservoirsBetonliVolumes) {
          final volume = int.tryParse(controller.text.trim()) ?? 0;
          if (volume > 0) {
            mockReservoir.add(Reservoir(
              reservoirType: "1",
              reservoirVolume: volume,
            ));
          }
        }
      }
      if (hovuzQoplamali) {
        // Инициализируем список, если он пуст
        if (reservoirsQoplamaliVolumes.isEmpty) {
          initializeReservoirs();
        }
        // Добавляем все покрытые резервуары
        for (final controller in reservoirsQoplamaliVolumes) {
          final volume = int.tryParse(controller.text.trim()) ?? 0;
          if (volume > 0) {
            mockReservoir.add(
              Reservoir(
                reservoirType: "2",
                reservoirVolume: volume,
              ),
            );
          }
        }
      }
    }

    mockFruitArea = selectedDetails.where((d) => d.fruit != null).map((detail) {
      return FruitArea(
        fruit: detail.fruit,
        variety: detail.variety,
        rootstock: detail.rootstock,
        plantedYear: detail.plantedYear,
        area: detail.area,
        schema: detail.schema,
        weight: detail.weight,
        fenced: detail.fenced,
        iqtisodiysamarasiz: detail.iqtisodiysamarasiz,
        economicInefficientArea: detail.economicInefficientArea,
      );
    }).toList();

    var mockGarden = Garden(
      gardenEstablishedYear: "${_selectedDate?.year.toString() ?? 0}",
      district: "$districtId",
      farmer: "$farmerId",
      emptyArea: _onlyDigitsDot(_norm(emptyArea.text.trim())),
      irrigationArea: tomchiArea,
      fertilityScore: unumdorlikValue.toString(),
      landType: selectedYerType.toString(),
      notUsableArea: _onlyDigitsDot(_norm(notUsableArea.text.trim())),
      irrigationSystemsCount: tomchiCount,
      isFertile: isUnumdormi,
      types: Types(
        plantationType: selectedPlantationType,
        typeChoice: selectedPlantationType == 1
            ? selectedBogType
            : selectedPlantationType == 2
                ? selectedUzumType
                : selectedPlantationType == 3
                    ? selectedIssiqxonaType
                    : null,
        subtype: selectedPlantationType == 1 ? selectedBogSubtype : null,
      ),
      investments: mockInvestments,
      coordinates: coordinates,
      subsidies: mockSubsidies,
      trellises: mockTrellises,
      reservoirs: mockReservoir,
      fruitAreas: mockFruitArea,
    );
    final jsonData = mockGarden.toJson();
    // Send kontur numbers as-is (alphanumeric), already sanitized by input formatter
    jsonData['kontur_number'] = konturNumbers;
    // Убеждаемся, что comments не отправляется в теле запроса создания плантации
    // Комментарий будет отправлен отдельным запросом после создания
    jsonData.remove('comments');
    jsonData.remove('moderation_comment');
    // user_location НЕ кладём в multipart: create-endpoint игнорирует
    // bracket-нотацию (проверено: 201, но user_locations пуст). Точка
    // досылается отдельным JSON PATCH после успешного создания.
    List<String> images = [];
    for (var mapEntry in _imageFiles.entries) {
      images.add(mapEntry.value!.path);
    }

    try {
      p.log("📦 DetailVM: Full JSON body before sending:");
      p.log("📦 DetailVM: ${jsonEncode(jsonData)}");

      // Нет сети — не пытаемся отправить, сразу кладём в офлайн-очередь.
      // GPS/antifraud-проверка уже прошла раньше, на этапе рисования
      // полигона (validateCoordinatesWithLimit) — здесь userLocation уже
      // готов, повторной проверки не требуется.
      final isOnline = await NetworkUtils.hasInternetConnection();
      if (!isOnline) {
        return _enqueueAndReportOffline(ref, jsonData, images);
      }

      final response = await _appRepositoryImpl.postCreatePlantationWithImages(
          body: jsonData, image: images);
      if (response.statusCode == 200 || response.statusCode == 201) {
        // ID созданной плантации нужен и для user_location, и для комментария
        dynamic responseData = response.data;
        if (responseData is String) {
          try {
            responseData = jsonDecode(responseData);
          } catch (e) {
            p.log("⚠️ DetailVM: Failed to parse responseData as JSON: $e");
          }
        }
        final int? createdId = responseData is Map<String, dynamic>
            ? responseData['id'] as int?
            : null;

        // Досылаем GPS-точку отдельным JSON PATCH: create-endpoint принимает
        // только multipart и теряет user_location. Best-effort — ошибка
        // отправки точки не должна ломать основной флоу.
        final loc = userLocation;
        if (createdId != null && loc != null) {
          unawaited(_appRepositoryImpl.sendUserLocation(
            plantationId: createdId,
            latitude: loc['latitude']!,
            longitude: loc['longitude']!,
          ));
        }

        // Если был введен комментарий, добавляем его после создания плантации
        final rawCommentsText = commentsController.text.trim();
        if (rawCommentsText.isNotEmpty) {
          // Санитизация комментария для защиты от XSS
          final commentsText =
              SanitizationUtils.sanitizeComment(rawCommentsText);
          try {
            final plantationId = createdId;

            if (plantationId != null) {
              p.log(
                  "✅ DetailVM: Extracted plantation ID: $plantationId, adding comment...");
              p.log("📤 DetailVM: Sending comment with isModeration: false");
              p.log("📤 DetailVM: Comment text: $commentsText");
              final commentResponse =
                  await _appRepositoryImpl.addPlantationComment(
                plantationId: plantationId,
                body: commentsText,
                isModeration:
                    false, // Явно указываем, что это обычный комментарий при создании
              );
              p.log(
                  "📥 DetailVM: Comment response status: ${commentResponse.statusCode}");
              p.log(
                  "📥 DetailVM: Comment response data: ${commentResponse.data}");
              if (commentResponse.statusCode != 200 &&
                  commentResponse.statusCode != 201) {
                p.log(
                    "⚠️ DetailVM: Failed to add comment (status: ${commentResponse.statusCode}), but plantation was created");
              } else {
                p.log("✅ DetailVM: Comment added successfully");
                // Проверяем, не дублируется ли комментарий в moderation_comment
                if (commentResponse.data is Map<String, dynamic>) {
                  final responseData =
                      commentResponse.data as Map<String, dynamic>;
                  if (responseData.containsKey('moderation_comment')) {
                    final modComments = responseData['moderation_comment'];
                    if (modComments is List && modComments.isNotEmpty) {
                      p.log(
                          "⚠️ DetailVM: WARNING - Comment was duplicated in moderation_comment by server!");
                      p.log(
                          "⚠️ DetailVM: This is a server-side issue - server automatically syncs comments to moderation_comment");
                    }
                  }
                }
              }
            } else {
              p.log(
                  "⚠️ DetailVM: Could not extract plantation ID from response to add comment. Response data: $responseData");
            }
          } catch (e, stackTrace) {
            p.log("⚠️ DetailVM: Error adding comment: $e");
            p.log("⚠️ DetailVM: Stack trace: $stackTrace");
            // Не прерываем процесс, плантация уже создана
          }
        }
        errorMessage = 'Muvaffaqiyatli yaratildi';
        await _clearDraft();
        return true;
      } else {
        // Единый парсер покрывает все известные форматы ошибок с бэка
        // (error/message/non_field_errors/__all__/field-level) — раньше
        // 400 и остальные статусы (включая 500) разбирались отдельными
        // копипаст-ветками, каждая покрывала свой неполный набор
        // форматов; __all__ (реальный формат "Для данного типа нет
        // подтипов") не парсился нигде, юзер видел только generic текст.
        p.log("Response Data: ${response.data}");

        // subsidies — специфичная для create-формы ошибка с отдельным
        // UX-текстом, не generic полем ошибки.
        final data = response.data;
        if (data is Map && data['subsidies'] != null) {
          errorMessage =
              "Subsidiya raqamlari notog`ri yoki oldin ro'yxatdan o'tgan";
          return false;
        }

        errorMessage = ApiErrorParser.parse(
          response.data,
          fallback: response.statusCode == 400
              ? "Yaratishda xatolik yuz berdi"
              : "Server bilan bog'liq muammo yuz berdi",
        );
        erroredField = ApiErrorParser.parseFieldName(response.data);
        p.log(
            "Something went wrong: ${response.statusCode}, error: $errorMessage, field: $erroredField");
        return false;
      }
    } catch (e) {
      // Обрыв сети посреди запроса — тоже кладём в очередь, не теряем
      // уже заполненную форму и фото.
      if (isNetworkError(e)) {
        try {
          return await _enqueueAndReportOffline(ref, jsonData, images);
        } catch (enqueueError) {
          p.log("Failed to enqueue after network error: $enqueueError");
        }
      }
      errorMessage = "Internet bilan bog'liq muammo yuzaga keldi.";
      p.log("Error: ${e.toString()}");
      return false;
    } finally {
      postLoading = false;
      notifyListeners();
    }
  }

  /// Кладёт уже собранный body/фото в офлайн-очередь и возвращает `true`
  /// (трактуется как успех с UI-меткой "поставлено в очередь"). Общий
  /// путь для pre-flight (нет сети до попытки) и catch (сеть оборвалась
  /// во время запроса) веток — оба ведут к одному и тому же результату.
  Future<bool> _enqueueAndReportOffline(
    WidgetRef ref,
    Map<String, dynamic> jsonData,
    List<String> images,
  ) async {
    await ref.read(uploadQueueServiceProvider).enqueueCreate(
          farmerId: farmerId,
          requestBody: jsonData,
          userLocation: userLocation,
          imagePaths: images,
          collectedAt: _collectedAt,
        );
    await _clearDraft();
    errorMessage = "Tarmoq yo'q — navbatga qo'yildi, ulanish "
        "tiklanganda avtomatik yuboriladi";
    return true;
  }

  void addKonturNumber() {
    final value = _onlyAlphaNum(konturInputController.text.trim());
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

  String? validateFields(WidgetRef ref) {
    final isTomchiEnabled = ref.watch(switchTomchi);
    final isSubsidiya = ref.watch(switchSubsidiya);
    final isShpaller = ref.watch(switchTrellis);
    final isShpallerTemir = ref.watch(switchTrellisTemir);
    final isShpallerBeton = ref.watch(switchTrellisBeton);
    final isReservoir = ref.watch(switchReservoir);
    final isReservoirBeton = ref.watch(switchReservoirsBeton);
    final isReservoirQoplamali = ref.watch(switchReservoirsQoplamali);
    final isInvitsitsiyaXorijiy = ref.watch(switchInvestmentXorjiy);
    final isInvitsitsiyaMaxalliy = ref.watch(switchInvestmentMahhalliy);

    if (_selectedDate == null) {
      return 'Vaqt tanlanmagan, vaqtni to`ldiring';
    }

    if (selectedPlantationType == null) {
      return 'Plantatsiya turi tanlanmagan, tanlovni bajaring';
    }
    if (selectedPlantationType == 1) {
      if (selectedBogType == null) {
        return 'Bog turi tanlanmagan, tanlovni bajaring';
      }
    }
    if (selectedPlantationType == 2) {
      if (selectedUzumType == null) {
        return 'Uzum turi tanlanmagan, tanlovni bajaring';
      }
    }
    if (selectedPlantationType == 3) {
      if (selectedIssiqxonaType == null) {
        return 'Issiqxona turi tanlanmagan, tanlovni bajaring';
      }
    }
    if (selectedYerType == null) {
      return 'Yer turi tanlanmagan, tanlovni bajaring';
    }

    if (notUsableArea.text.trim().isEmpty ||
        double.tryParse(_norm(notUsableArea.text.trim())) == null) {
      return 'Foydalanishga yaroqsiz yerlar noto‘g‘ri yoki bo‘sh, to‘ldiring';
    }
    if ((double.tryParse(_norm(notUsableArea.text.trim())) ?? 0) < 0) {
      return 'Foydalanishga yaroqsiz maydon manfiy bo\'lishi mumkin emas';
    }

    if (emptyArea.text.trim().isEmpty ||
        double.tryParse(_norm(emptyArea.text.trim())) == null) {
      return "Ochiq maydon noto'g'ri yoki bo'sh, to'ldiring";
    }
    if ((double.tryParse(_norm(emptyArea.text.trim())) ?? 0) < 0) {
      return "Ochiq maydon manfiy bo'lishi mumkin emas";
    }
    // Kontur raqami majburiy: kamida bitta qiymat (harflar/raqamlar) bo'lishi shart
    final konturForValidation =
        konturNumbers.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    if (konturForValidation.isEmpty) {
      return 'Kontur raqami kamida bittasi kiritilishi shart';
    }
    if (isInvitsitsiyaXorijiy) {
      if (investmentXorijiyAmount.text.trim().isEmpty ||
          int.tryParse(investmentXorijiyAmount.text
                  .trim()
                  .replaceAll(RegExp(r'[^0-9]'), '')) ==
              null) {
        return 'Xorjiy ajratilgan investitsiyani noto‘g‘ri yoki bo‘sh, to‘ldiring';
      }
    }
    if (isInvitsitsiyaMaxalliy) {
      if (investmentMahhalliyAmount.text.trim().isEmpty ||
          int.tryParse(investmentMahhalliyAmount.text
                  .trim()
                  .replaceAll(RegExp(r'[^0-9]'), '')) ==
              null) {
        return 'Maxalliy ajratilgan investitsiyani noto‘g‘ri yoki bo‘sh, to‘ldiring';
      }
    }
    if (!isInvitsitsiyaXorijiy && !isInvitsitsiyaMaxalliy) {
      return 'Investitsiya turini tanlash majburiy';
    }
    if (isTomchiEnabled) {
      if (tomchiSystemsCount.text.trim().isEmpty ||
          int.tryParse(tomchiSystemsCount.text.trim()) == null &&
              tomchiSystemsArea.text.trim().isEmpty ||
          double.tryParse(tomchiSystemsArea.text.trim()) == null) {
        return 'Tomchilab sug‘orish tizimlari soni yoki maydoni noto‘g‘ri yoki bo‘sh, to‘ldiring';
      }
    }

    if (isSubsidiya) {
      if (selectedSubsidy.isEmpty) {
        return 'Subsidiya ma`lumotlari noto‘g‘ri yoki bo‘sh, to‘ldiring';
      }
    }
    if (isShpaller) {
      if (isShpallerTemir) {
        if (trellisTemirInstalledArea.text.trim().isEmpty ||
            double.tryParse(trellisTemirInstalledArea.text.trim()) == null ||
            trellisTemirCount.text.trim().isEmpty ||
            int.tryParse(trellisTemirCount.text.trim()) == null) {
          return 'Temir shpaller soni yoki maydoni noto‘g‘ri yoki bo‘sh, to‘ldiring';
        }
      }
      if (isShpallerBeton) {
        if (trellisBetonInstalledArea.text.trim().isEmpty ||
            double.tryParse(trellisBetonInstalledArea.text.trim()) == null ||
            trellisBetonCount.text.trim().isEmpty ||
            int.tryParse(trellisBetonCount.text.trim()) == null) {
          return 'Beton shpaller soni  yoki maydoni noto‘g‘ri yoki bo‘sh, to‘ldiring';
        }
      }
      if (!isShpallerBeton && !isShpallerTemir) {
        return 'Shpaller turi tanlanmagan, tanlovni bajaring';
      }
    }
    if (isReservoir) {
      if (!isReservoirBeton && !isReservoirQoplamali) {
        return 'Suv havzasining turi tanlanmagan, tanlovni bajaring';
      }
      if (isReservoirBeton) {
        // Инициализируем список, если он пуст
        if (reservoirsBetonliVolumes.isEmpty) {
          initializeReservoirs();
        }
        // Проверяем все бетонные резервуары
        for (int i = 0; i < reservoirsBetonliVolumes.length; i++) {
          final controller = reservoirsBetonliVolumes[i];
          if (controller.text.trim().isEmpty ||
              double.tryParse(controller.text.trim()) == null) {
            return "Beton suv havzasi hajmi (${i + 1}) noto'g'ri yoki bo'sh, to'ldiring";
          }
        }
      }
      if (isReservoirQoplamali) {
        // Инициализируем список, если он пуст
        if (reservoirsQoplamaliVolumes.isEmpty) {
          initializeReservoirs();
        }
        // Проверяем все покрытые резервуары
        for (int i = 0; i < reservoirsQoplamaliVolumes.length; i++) {
          final controller = reservoirsQoplamaliVolumes[i];
          if (controller.text.trim().isEmpty ||
              double.tryParse(controller.text.trim()) == null) {
            return "Qoplamali suv havzasi hajmi (${i + 1}) noto'g'ri yoki bo'sh, to'ldiring";
          }
        }
      }
    }
    if (selectedDetails.isEmpty) {
      return 'Meva maydoni tanlanmagan, tanlovni bajaring';
    }

    // Проверка разницы между площадью полигона и общей площадью плантации (не более 15%)
    if (polygonArea != null && polygonArea! > 0) {
      final totalArea = getTotalArea(ref);
      if (totalArea > 0) {
        // Вычисляем разницу в процентах
        final difference =
            ((polygonArea! - totalArea).abs() / polygonArea!) * 100;
        p.log(
            "🔍 DetailVM validateFields: polygonArea = $polygonArea, totalArea = $totalArea, difference = ${difference.toStringAsFixed(2)}%");

        if (difference > 15.0) {
          return 'Poligon maydoni va kiritilgan maydon o\'rtasidagi farq 15% dan oshib ketdi. Farq: ${difference.toStringAsFixed(1)}%. Iltimos, ma\'lumotlarni tekshiring.';
        }
      }
    }

    // Динамическая проверка количества фотографий
    final minPhotosRequired = calculateMinimumPhotosRequired(ref);
    final uploadedImagesCount =
        _imageFiles.values.where((file) => file != null).length;

    if (uploadedImagesCount < minPhotosRequired) {
      return 'Kamida $minPhotosRequired ta rasm yuklash kerak. Hozir: $uploadedImagesCount ta.\n${getPhotoRequirementDetails(ref)}';
    }

    return null;
  }

  void addSelectedDetail(WidgetRef ref) {
    final isIqtisodiy = ref.read(switchIqtisodiy);
    p.log('[detail] addSelectedDetail: isIqtisodiy = $isIqtisodiy');
    // print('[detail] addSelectedDetail: isIqtisodiy = $isIqtisodiy');

    if (selectedFruit == null || selectedFruitVariety == null) {
      // print('[detail] addSelectedDetail: selectedFruit or selectedFruitVariety is null');
      return;
    }

    // Экономически неэффективная площадь
    if (isIqtisodiy) {
      // print('[detail] addSelectedDetail: Processing iqtisodiy mode');
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
        iqtisodiysamarasiz: true,
        economicInefficientArea: econ,
      );
      p.log('[detail] addSelectedDetail (iqtisodiy=true): ${fa.toJson()}');
      selectedFruitVerityRoot.add(fa);
      selectedDetails.add(fa);
      _resetFieldsInternal();
      notifyListeners();
      return;
    }

    // Обычная посадка
    // print('[detail] addSelectedDetail: Processing normal mode');
    if (selectedDate2 != null &&
        cultivatedArea.text.isNotEmpty &&
        sxema1.text.isNotEmpty &&
        sxema2.text.isNotEmpty) {
      // print('[detail] addSelectedDetail: Normal mode validation passed');
      final year = selectedDate2!.year.toString();
      final fa = FruitArea(
        fruit: selectedFruit?.id,
        variety: selectedFruitVariety?.id,
        rootstock: selectedFruitRoot?.id,
        fruitName: selectedFruit?.name,
        varietyName: selectedFruitVariety?.name,
        rootstockName: selectedFruitRoot?.name,
        plantedYear: year,
        area:
            double.tryParse(cultivatedArea.text.trim().replaceAll(',', '.')) ??
                0.0,
        schema: "${sxema1.text}X${sxema2.text}",
        weight: tonnaController.text.trim().isEmpty
            ? null
            : double.tryParse(
                    tonnaController.text.trim().replaceAll(',', '.')) ??
                0.0,
        fenced: ref.read(switchFenced),
        iqtisodiysamarasiz: false,
      );
      p.log('[detail] addSelectedDetail (iqtisodiy=false): ${fa.toJson()}');
      selectedFruitVerityRoot.add(fa);
      selectedDetails.add(fa);
      _resetFieldsInternal();
      notifyListeners();
    } else {
      // print('[detail] addSelectedDetail: Normal mode validation failed');
    }
  }

  void addSubsidiyaList(WidgetRef ref) {
    // Убираем пробелы-разделители тысяч из суммы перед парсингом
    final rawAmount = subsidiyaAmount.text.trim().replaceAll(' ', '');
    selectedSubsidy.add(Subsidy(
      year: _selectedDate3?.year.toString() ?? "0",
      contractNumber: subsidiyaContract.text.trim(),
      amount: double.tryParse(rawAmount) ?? 0.0,
      direction: _selectedSubsidyType,
      efficiency: ref.read(switchEfficiency),
    ));
    resetSubsudy();
    notifyListeners();
  }

  void resetSubsudy() {
    _selectedDate3 = null;
    subsidiyaContract.clear();
    subsidiyaAmount.clear();
    _selectedSubsidyType = null;
    notifyListeners();
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

  /// Загрузить информацию о пользователе (isSpecialUser) из storage
  Future<void> loadUserInfo() async {
    _isSpecialUser =
        await AppStorage.$readBool(key: StorageKey.isSpecialUser) ?? false;
    p.log('🔍 Loaded isSpecialUser: $_isSpecialUser');
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

  /// Выбрать изображение из галереи
  Future<void> pickImageFromGallery(int cardId, {BuildContext? context}) async {
    await pickImage(
        cardId: cardId, source: ImageSource.gallery, context: context);
  }

  /// Сфотографировать изображение
  Future<void> pickImageFromCamera(int cardId, {BuildContext? context}) async {
    await pickImage(
        cardId: cardId, source: ImageSource.camera, context: context);
  }

  /// Calculates minimum required photos based on plantation type, fruits count, and land type
  ///
  /// Logic:
  /// - Base: 1 photo for any plantation
  /// - +1 photo for each added fruit
  /// - +1 photo if land type is Lalmi (unirrigated/yaroqsiz)
  int calculateMinimumPhotosRequired([WidgetRef? ref]) {
    int minPhotos = 1; // Base photo for plantation

    // Add 1 photo for each fruit
    minPhotos += selectedDetails.length;

    // Add 1 photo if land type is Lalmi (1 = yaroqsiz/unirrigated)
    if (selectedYerType == 1) {
      minPhotos += 1;
    }

    // Add 1 photo if ochiq maydon (empty field) is greater than 0
    // If value is 0, no photo required. If value >= 0.1, photo is required
    final emptyAreaValue = double.tryParse(_norm(emptyArea.text.trim())) ?? 0.0;
    if (emptyAreaValue > 0) {
      minPhotos += 1;
    }

    // Add 1 photo if tomchilab sug'orish (drip irrigation) is enabled
    if (ref != null) {
      final isTomchiEnabled = ref.read(switchTomchi);
      if (isTomchiEnabled) {
        minPhotos += 1;
      }

      // Add 1 photo if shpaller (trellis) is enabled
      final isShpaller = ref.read(switchTrellis);
      if (isShpaller) {
        minPhotos += 1;
      }

      // Add 1 photo if suv havzasi (reservoir) is enabled
      final isReservoir = ref.read(switchReservoir);
      if (isReservoir) {
        minPhotos += 1;
      }

      debugPrint(
          "📸 Minimum photos required: $minPhotos (base: 1, fruits: ${selectedDetails.length}, lalmi: ${selectedYerType == 1 ? 1 : 0}, ochiq maydon: ${emptyAreaValue > 0 ? 1 : 0}, tomchi: ${isTomchiEnabled ? 1 : 0}, shpaller: ${isShpaller ? 1 : 0}, suv havzasi: ${isReservoir ? 1 : 0})");
    } else {
      debugPrint(
          "📸 Minimum photos required: $minPhotos (base: 1, fruits: ${selectedDetails.length}, lalmi: ${selectedYerType == 1 ? 1 : 0}, ochiq maydon: ${emptyAreaValue > 0 ? 1 : 0})");
    }

    return minPhotos;
  }

  /// Returns detailed explanation of photo requirements
  String getPhotoRequirementDetails([WidgetRef? ref]) {
    final details = <String>[];

    details.add("• Asosiy plantatsiya: 1 ta rasm");

    if (selectedDetails.isNotEmpty) {
      details.add(
          "• Mevalar (${selectedDetails.length} ta): ${selectedDetails.length} ta rasm");
    }

    if (selectedYerType == 1) {
      details.add("• Lalmi (yaroqsiz) maydon: 1 ta rasm");
    }

    final emptyAreaValue = double.tryParse(_norm(emptyArea.text.trim())) ?? 0.0;
    if (emptyAreaValue > 0) {
      details.add("• Ochiq maydon: 1 ta rasm");
    }

    if (ref != null) {
      final isTomchiEnabled = ref.read(switchTomchi);
      if (isTomchiEnabled) {
        details.add("• Tomchilab sug'orish: 1 ta rasm");
      }

      final isShpaller = ref.read(switchTrellis);
      if (isShpaller) {
        details.add("• Shpaller: 1 ta rasm");
      }

      final isReservoir = ref.read(switchReservoir);
      if (isReservoir) {
        details.add("• Suv havzasi: 1 ta rasm");
      }
    }

    return details.join('\n');
  }

  /// Возвращает описание того, что нужно сфотографировать для указанного индекса фото
  String getPhotoDescription(int index, [WidgetRef? ref]) {
    int currentIndex = 0;

    // Фото 0: Asosiy plantatsiya
    if (index == currentIndex) {
      return "Asosiy plantatsiya";
    }
    currentIndex++;

    // Фото 1, 2, 3...: Фрукты
    for (int i = 0; i < selectedDetails.length; i++) {
      if (index == currentIndex) {
        final fruitName = selectedDetails[i].fruitName ?? "Meva";
        return fruitName;
      }
      currentIndex++;
    }

    // Фото для Lalmi (если применимо)
    if (selectedYerType == 1) {
      if (index == currentIndex) {
        return "Lalmi maydon";
      }
      currentIndex++;
    }

    // Фото для Ochiq maydon (если применимо)
    final emptyAreaValue = double.tryParse(_norm(emptyArea.text.trim())) ?? 0.0;
    if (emptyAreaValue > 0) {
      if (index == currentIndex) {
        return "Ochiq maydon";
      }
      currentIndex++;
    }

    // Фото для Tomchi (если применимо)
    if (ref != null) {
      final isTomchiEnabled = ref.read(switchTomchi);
      if (isTomchiEnabled) {
        if (index == currentIndex) {
          return "Tomchilab sug'orish";
        }
        currentIndex++;
      }

      // Фото для Shpaller (если применимо)
      final isShpaller = ref.read(switchTrellis);
      if (isShpaller) {
        if (index == currentIndex) {
          return "Shpaller";
        }
        currentIndex++;
      }

      // Фото для Suv havzasi (если применимо)
      final isReservoir = ref.read(switchReservoir);
      if (isReservoir) {
        if (index == currentIndex) {
          return "Suv havzasi";
        }
        currentIndex++;
      }
    }

    // Если индекс выходит за пределы требуемых фото, возвращаем общее описание
    return "Qo'shimcha rasm";
  }

  /// Основной метод для выбора изображения
  Future<void> pickImage({
    required int cardId,
    required ImageSource source,
    BuildContext? context,
  }) async {
    if (_isPickerActive) return;
    _isPickerActive = true;
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      if (pickedFile == null) return;

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
        return;
      }

      // Копируем в стабильную app-owned директорию: путь image_picker
      // (особенно с камеры на некоторых Android-устройствах) не гарантированно
      // переживает paused/kill, пока юзер ходит по плантации фотографировать.
      final stablePath = await UploadQueueStore.instance
          .copyToStableDir(pickedFile.path, prefix: 'create_${cardId}_');
      _imageFiles[cardId] = File(stablePath);
      notifyListeners();
    } finally {
      _isPickerActive = false;
    }
  }

  Future<void> getFruit() async {
    isLoading = true;
    notifyListeners();
    try {
      final data = await _appRepositoryImpl.getFruits();
      if (data == null) {
        return;
      } else {
        try {
          fruitList = fruitModelFromJson(data);
        } catch (e) {
          p.log("Ma'lumotlarni qayta ishlashda muammo yuzaga keldi: $e");
        }
      }
    } catch (e) {
      l.e("$e");
    } finally {
      isLoading = false;
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
          p.log("Malumotlarni Qayta ishlashda muammo yuzaga keldi");
        }
      }
    } catch (e) {
      l.e("$e");
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
          debugPrint("Malumotlarni Qayta ishlashda muammo yuzaga keldi");
        }
      }
    } catch (e) {
      l.e("$e");
    } finally {
      isLoading2 = false;
      notifyListeners();
    }
  }

  int? _selectedPlantationType;
  int? get selectedPlantationType => _selectedPlantationType;
  void setPlantationType(int? bogTuri) {
    _selectedPlantationType = bogTuri;
    // Type-specific dropdowns (bog/uzum/issiqxona type + bog subtype) are
    // each shown only for their matching plantationType — switching away
    // must clear all of them, otherwise a stale selection from a
    // previous type stays in the payload invisibly.
    if (bogTuri != 1) {
      _selectedBogType = null;
      _selectedBogSubtype = null;
    }
    if (bogTuri != 2) {
      _selectedUzumType = null;
    }
    if (bogTuri != 3) {
      _selectedIssiqxonaType = null;
    }
    notifyListeners();
  }

  int? _selectedBogType;
  int? get selectedBogType => _selectedBogType;
  void setBogType(int? bogType) {
    _selectedBogType = bogType;
    // Subtype-дропдаун виден в UI только при bogType == 1 (intensiv) —
    // переключение на любой другой bogType должно сбрасывать ранее
    // выбранный subtype, иначе он остаётся в payload невидимым для
    // юзера и сервер получает subtype для типа, у которого их не бывает
    // ("Для данного типа нет подтипов", 500).
    if (bogType != 1) {
      _selectedBogSubtype = null;
    }
    notifyListeners();
  }

  int? _selectedIssiqxonaType;
  int? get selectedIssiqxonaType => _selectedIssiqxonaType;
  void setIssiqxonaType(int? issiqxonaType) {
    _selectedIssiqxonaType = issiqxonaType;
    notifyListeners();
  }

  int? _selectedUzumType;
  int? get selectedUzumType => _selectedUzumType;
  void setUzumType(int? uzumType) {
    _selectedUzumType = uzumType;
    notifyListeners();
  }

  int? _selectedBogSubtype;
  int? get selectedBogSubtype => _selectedBogSubtype;
  void setBogSubtype(int? bogSubtype) {
    _selectedBogSubtype = bogSubtype;
    notifyListeners();
  }

  int? _selectedYerType;
  int? get selectedYerType => _selectedYerType;
  void setYerType(int? yerType) {
    _selectedYerType = yerType;
    notifyListeners();
  }

  int? _selectedSubsidyType;
  int? get selectedSubsidyType => _selectedSubsidyType;
  void setSubsidyType(int? subsidyType) {
    _selectedSubsidyType = subsidyType;
    notifyListeners();
  }

  /// Полный сброс формы перед началом новой плантации. `detailVM` —
  /// autoDispose и в норме пересоздаётся между заходами на DetailPage, но
  /// autoDispose снимается только когда ПОСЛЕДНИЙ слушатель отписался —
  /// быстрая навигация (карта → detail → back → карта → detail для того
  /// же фермера) может застать ещё живой инстанс с данными предыдущей
  /// плантации. Без явного сброса они утекают во вторую плантацию того же
  /// фермера (selectedFruit/selectedDetails/switches/контроллеры не
  /// трогает setValue — тот выставляет только farmerId/coordinates).
  void resetForNewPlantation(WidgetRef ref) {
    notUsableArea.clear();
    emptyArea.clear();
    konturInputController.clear();
    tomchiSystemsArea.clear();
    tomchiSystemsCount.clear();
    investmentMahhalliyAmount.clear();
    investmentXorijiyAmount.clear();
    subsidiyaContract.clear();
    subsidiyaAmount.clear();
    trellisTemirInstalledArea.clear();
    trellisTemirCount.clear();
    trellisBetonInstalledArea.clear();
    trellisBetonCount.clear();
    cultivatedArea.clear();
    sxema1.clear();
    sxema2.clear();
    economicInefficientAreaController.clear();
    tonnaController.clear();
    commentsController.clear();

    for (final c in reservoirsBetonliVolumes) {
      if (c != reservoirsBetonliVolume) c.dispose();
    }
    reservoirsBetonliVolumes
      ..clear()
      ..add(reservoirsBetonliVolume..clear());
    for (final c in reservoirsQoplamaliVolumes) {
      if (c != reservoirsQoplamaliVolume) c.dispose();
    }
    reservoirsQoplamaliVolumes
      ..clear()
      ..add(reservoirsQoplamaliVolume..clear());

    ref.read(switchTomchi.notifier).state = false;
    ref.read(switchFenced.notifier).state = false;
    ref.read(switchIsFertile.notifier).state = false;
    ref.read(switchSubsidiya.notifier).state = false;
    ref.read(switchEfficiency.notifier).state = false;
    ref.read(switchTrellis.notifier).state = false;
    ref.read(switchTrellisBeton.notifier).state = false;
    ref.read(switchTrellisTemir.notifier).state = false;
    ref.read(switchReservoir.notifier).state = false;
    ref.read(switchReservoirsBeton.notifier).state = false;
    ref.read(switchReservoirsQoplamali.notifier).state = false;
    ref.read(switchInvestmentXorjiy.notifier).state = false;
    ref.read(switchInvestmentMahhalliy.notifier).state = false;
    ref.read(switchIqtisodiy.notifier).state = false;

    unumdorlikValue = 50;
    _selectedDate = null;
    _selectedDate2 = null;
    _selectedDate3 = null;
    selectedFruit = null;
    selectedFruitVariety = null;
    selectedFruitRoot = null;
    selectedDetails = [];
    selectedFruitVerityRoot = [];
    selectedSubsidy = [];
    konturNumbers = [];
    _imageFiles.clear();
    erroredField = null;
    errorMessage = null;

    _selectedPlantationType = null;
    _selectedBogType = null;
    _selectedIssiqxonaType = null;
    _selectedUzumType = null;
    _selectedBogSubtype = null;
    _selectedYerType = null;
    _selectedSubsidyType = null;

    notifyListeners();
  }

  void setValue({
    required int id,
    required List<Coordinate> coordinate,
    Map<String, double>? userLocation,
    double? polygonArea,
    DateTime? collectedAt,
  }) {
    farmerId = id;
    coordinates = coordinate;
    this.userLocation = userLocation;
    this.polygonArea = polygonArea;
    _collectedAt = collectedAt;
    p.log("✅ DetailVM setValue: userLocation: $userLocation, "
        "polygonArea: $polygonArea");
  }

  void setTonna(String value) {
    // Простое присвоение текста — controller сам обновляет TextField,
    // notifyListeners() тут не нужен и без него не триггерит rebuild
    // всей 1000+ строчной формы на каждый нажатый символ.
    tonnaController.text = value;
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

  void removeSubsidy(int index) {
    selectedSubsidy.removeAt(index);
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

  void setFruit(FruitModel? fruit) {
    selectedFruit = fruit;
    notifyListeners();
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
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

  void setSelectedDate3(DateTime date) {
    _selectedDate3 = date;
    notifyListeners();
  }

  void setNotUsableArea(String value) {
    String cleaned = _onlyDigitsDot(_norm(value.replaceAll('-', '')));
    final dot = cleaned.indexOf('.');
    if (dot != -1) {
      final before = cleaned.substring(0, dot + 1);
      final after = cleaned.substring(dot + 1).replaceAll('.', '');
      cleaned = before + after;
    }
    notUsableArea.value = TextEditingValue(
      text: cleaned,
      selection: TextSelection.collapsed(offset: cleaned.length),
    );
    notifyListeners();
  }

  void setEmptyArea(String value) {
    String cleaned = _onlyDigitsDot(_norm(value.replaceAll('-', '')));
    final dot = cleaned.indexOf('.');
    if (dot != -1) {
      final before = cleaned.substring(0, dot + 1);
      final after = cleaned.substring(dot + 1).replaceAll('.', '');
      cleaned = before + after;
    }
    emptyArea.value = TextEditingValue(
      text: cleaned,
      selection: TextSelection.collapsed(offset: cleaned.length),
    );
    notifyListeners();
  }

  void setEconomicInefficientArea(String value) {
    String cleaned = _onlyDigitsDot(_norm(value.replaceAll('-', '')));
    final dot = cleaned.indexOf('.');
    if (dot != -1) {
      final before = cleaned.substring(0, dot + 1);
      final after = cleaned.substring(dot + 1).replaceAll('.', '');
      cleaned = before + after;
    }
    economicInefficientAreaController.value = TextEditingValue(
      text: cleaned,
      selection: TextSelection.collapsed(offset: cleaned.length),
    );
    notifyListeners();
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

  void setTomchiSystemsCount(String value) {
    tomchiSystemsCount.text = value;
  }

  void setTomchiSystemsArea(String value) {
    tomchiSystemsArea.text = value;
  }

  void setUnumdorlikValue(double value) {
    unumdorlikValue = value;
    notifyListeners();
  }

  void setSubsidiyaConract(String value) {
    subsidiyaContract.text = value;
  }

  void setSubsidiyaAmount(String value) {
    subsidiyaAmount.text = value;
  }

  void setTrellisTemirInstalledArea(String value) {
    trellisTemirInstalledArea.text = value;
  }

  void setTrellisBetonInstalledArea(String value) {
    trellisBetonInstalledArea.text = value;
  }

  void setTrellisTemirCount(String value) {
    trellisTemirCount.text = value;
  }

  void setTrellisBetonCount(String value) {
    trellisBetonCount.text = value;
  }

  void setInvestmentMahhalliyAmount(String value) {
    investmentMahhalliyAmount.text = value;
  }

  void setInvestmentXorijiyAmount(String value) {
    investmentXorijiyAmount.text = value;
  }

  void setCultivatedArea(String value) {
    cultivatedArea.text = value;
    notifyListeners();
  }

  void setSxema1(String value) {
    sxema1.text = value;
  }

  void setSxema2(String value) {
    sxema2.text = value;
  }

  void setReservoirQoplamaliVolume(String value) {
    reservoirsQoplamaliVolume.text = value;
  }

  void setReservoirsBetonliVolume(String value) {
    reservoirsBetonliVolume.text = value;
  }
}
