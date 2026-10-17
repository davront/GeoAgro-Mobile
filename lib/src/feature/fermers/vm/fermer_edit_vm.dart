import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../core/server/api/orginfo_service.dart';
import '../../../core/utils/dio_error_utils.dart';
import '../../../core/utils/network_utils.dart';
import '../../../core/utils/sanitization_utils.dart';
import '../../../core/utils/validation_utils.dart';
import '../../../data/model/farmer/farmer_list_model.dart';
import '../../../data/repository/app_repository_impl.dart';

/// Редактирование существующего фермера. ИНН — read-only (никогда не
/// отправляется на изменение); остальные поля дублируют валидацию
/// [FermerCreateVm] — единого места для этих валидаторов в кодовой базе
/// нет, дублирование соответствует существующему стилю.
class FermerEditVm extends ChangeNotifier {
  final int farmerId;

  FermerEditVm({required this.farmerId}) {
    _init();
  }

  final AppRepositoryImpl _appRepositoryImpl = AppRepositoryImpl();

  bool isLoadingInitial = true;
  String? loadError;

  bool isOrgInfoLoading = false;
  String? orgInfoError;

  bool isUpdating = false;
  String? errorMessage;

  TextEditingController name = TextEditingController();
  TextEditingController founderName = TextEditingController();
  TextEditingController directorName = TextEditingController();
  TextEditingController phoneNumber = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController inn = TextEditingController();
  TextEditingController establishedYear = TextEditingController();

  String? nameError;
  String? founderNameError;
  String? directorNameError;
  String? phoneNumberError;
  String? addressError;
  String? establishedYearError;

  Future<void> _init() async {
    try {
      final farmerData = await _appRepositoryImpl.getFarmerById(farmerId);
      if (farmerData == null) {
        loadError = "Fermer ma'lumotlari topilmadi";
        isLoadingInitial = false;
        notifyListeners();
        return;
      }

      final model = FarmerModel.fromJson(jsonDecode(farmerData));
      name.text = model.name ?? '';
      founderName.text = model.founderName ?? '';
      directorName.text = model.directorName ?? '';
      address.text = model.address ?? '';
      establishedYear.text = model.establishedYear?.toString() ?? '';
      inn.text = model.inn?.toString() ?? '';
      phoneNumber.text =
          (model.phoneNumber != null && model.phoneNumber!.isNotEmpty)
              ? '+998${model.phoneNumber}'
              : '+998';

      // Слушатели навешиваем только после того как контроллеры заполнены
      // начальными данными — иначе первая же простановка .text вызовет
      // валидацию с пустой строкой и мигнёт ошибками на загрузке.
      name.addListener(_validateName);
      founderName.addListener(_validateFounderName);
      directorName.addListener(_validateDirectorName);
      phoneNumber.addListener(_validatePhoneNumber);
      address.addListener(_validateAddress);
      establishedYear.addListener(_validateEstablishedYear);

      isLoadingInitial = false;
      notifyListeners();
    } catch (e) {
      loadError = DioErrorUtils.messageFromAny(e);
      isLoadingInitial = false;
      notifyListeners();
    }
  }

  String _sanitizeInput(String input) => SanitizationUtils.sanitizeInput(input);

  void _validateName() {
    final value = _sanitizeInput(name.text);
    if (value.isEmpty) {
      nameError = "Tashkilot nomi bo'sh bo'lmasligi zarur";
    } else if (value.length < 2) {
      nameError = "Tashkilot nomi kamida 2 ta belgidan iborat bo'lishi kerak";
    } else if (value.length > 100) {
      nameError = "Tashkilot nomi 100 ta belgidan oshmasligi kerak";
    } else if (!ValidationUtils.nameCharsetValidator.hasMatch(value)) {
      nameError =
          "Tashkilot nomi faqat harflar, raqamlar va ' \" / belgilaridan iborat bo'lishi kerak";
    } else {
      nameError = null;
    }
    notifyListeners();
  }

  void _validateFounderName() {
    final value = _sanitizeInput(founderName.text);
    if (value.isEmpty) {
      founderNameError = "Asoschi ismi bo'sh bo'lmasligi zarur";
    } else if (value.length < 2) {
      founderNameError =
          "Asoschi ismi kamida 2 ta belgidan iborat bo'lishi kerak";
    } else if (value.length > 100) {
      founderNameError = "Asoschi ismi 100 ta belgidan oshmasligi kerak";
    } else if (!ValidationUtils.nameCharsetValidator.hasMatch(value)) {
      founderNameError =
          "Asoschi ismi faqat harflar, raqamlar va ' \" / belgilaridan iborat bo'lishi kerak";
    } else {
      founderNameError = null;
    }
    notifyListeners();
  }

  void _validateDirectorName() {
    final value = _sanitizeInput(directorName.text);
    if (value.isEmpty) {
      directorNameError = "Rahbar ismi bo'sh bo'lmasligi zarur";
    } else if (value.length < 2) {
      directorNameError =
          "Rahbar ismi kamida 2 ta belgidan iborat bo'lishi kerak";
    } else if (value.length > 100) {
      directorNameError = "Rahbar ismi 100 ta belgidan oshmasligi kerak";
    } else if (!ValidationUtils.nameCharsetValidator.hasMatch(value)) {
      directorNameError =
          "Rahbar ismi faqat harflar, raqamlar va ' \" / belgilaridan iborat bo'lishi kerak";
    } else {
      directorNameError = null;
    }
    notifyListeners();
  }

  void _validatePhoneNumber() {
    final value = phoneNumber.text.trim();
    if (value.isEmpty) {
      phoneNumberError = "Telefon raqam bo'sh bo'lmasligi zarur";
    } else if (!value.startsWith('+998')) {
      phoneNumberError = "Telefon raqam +998 bilan boshlanishi kerak";
    } else {
      final phoneDigits = NetworkUtils.stripCountryCode(value);

      if (phoneDigits.length != 9) {
        phoneNumberError =
            "Telefon raqam +998 xx xxx-xx-xx formatida bo'lishi kerak";
      } else if (!RegExp(r'^[0-9]{9}$').hasMatch(phoneDigits)) {
        phoneNumberError =
            "Telefon raqam faqat raqamlardan iborat bo'lishi kerak";
      } else {
        phoneNumberError = null;
      }
    }
    notifyListeners();
  }

  void _validateAddress() {
    final value = _sanitizeInput(address.text);
    if (value.isEmpty) {
      addressError = "Manzil bo'sh bo'lmasligi zarur";
    } else if (value.length < 5) {
      addressError = "Manzil kamida 5 ta belgidan iborat bo'lishi kerak";
    } else if (value.length > 200) {
      addressError = "Manzil 200 ta belgidan oshmasligi kerak";
    } else if (!ValidationUtils.addressCharsetValidator.hasMatch(value)) {
      addressError =
          "Manzil faqat harflar, raqamlar va belgilardan iborat bo'lishi kerak";
    } else {
      addressError = null;
    }
    notifyListeners();
  }

  void _validateEstablishedYear() {
    final value = establishedYear.text.trim();
    if (value.isEmpty) {
      establishedYearError = "Yaratilgan yil bo'sh bo'lmasligi zarur";
    } else if (!RegExp(r'^\d{4}$').hasMatch(value)) {
      establishedYearError =
          "Yaratilgan yil 4 ta raqamdan iborat bo'lishi zarur";
    } else {
      try {
        final year = int.parse(value);
        final currentYear = DateTime.now().year;
        if (year > currentYear) {
          establishedYearError =
              "Yaratilgan yil $currentYear yoki undan kichik bo'lishi kerak";
        } else if (year < 1900) {
          establishedYearError =
              "Yaratilgan yil 1900 yoki undan katta bo'lishi kerak";
        } else {
          establishedYearError = null;
        }
      } catch (e) {
        establishedYearError = "Noto'g'ri yil formati";
      }
    }
    notifyListeners();
  }

  bool validateAll() {
    _validateName();
    _validateFounderName();
    _validateDirectorName();
    _validatePhoneNumber();
    _validateAddress();
    _validateEstablishedYear();

    return nameError == null &&
        founderNameError == null &&
        directorNameError == null &&
        phoneNumberError == null &&
        addressError == null &&
        establishedYearError == null;
  }

  /// Пере-запрашивает orginfo.uz по уже известному (read-only) ИНН и
  /// обновляет поля тем же правилом, что и создание: перезаписываем
  /// только там, где источник реально что-то вернул.
  Future<void> refetchOrgInfo() async {
    final innValue = inn.text.trim();
    if (innValue.isEmpty) return;

    isOrgInfoLoading = true;
    orgInfoError = null;
    notifyListeners();

    try {
      final result = await OrginfoService.lookupByInn(innValue);
      if (result == null) {
        orgInfoError = "Bu INN bo'yicha tashkilot topilmadi";
      } else {
        if (result.name.isNotEmpty) name.text = result.name;
        if (result.address.isNotEmpty) address.text = result.address;
        if (result.founderName?.isNotEmpty ?? false) {
          founderName.text = result.founderName!;
        }
        if (result.directorName?.isNotEmpty ?? false) {
          directorName.text = result.directorName!;
        }
        // Телефон намеренно не автозаполняется — orginfo.uz отдаёт
        // контактный номер организации, не обязательно фермера, вводившего
        // ИНН; автоподстановка перетирала бы уже введённый юзером номер.
      }
    } on OrginfoParseException {
      orgInfoError =
          "Avtomatik qidiruv vaqtincha ishlamayapti. Ma'lumotlarni qo'lda kiriting";
    } catch (e) {
      orgInfoError = "Ma'lumotlarni olishda xatolik yuz berdi";
    } finally {
      isOrgInfoLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveChanges() async {
    isUpdating = true;
    errorMessage = null;
    notifyListeners();

    try {
      // Свежий фетч прямо перед сохранением — не переиспользуем данные с
      // открытия страницы, чтобы не перетереть чужие правки, сделанные
      // пока эта страница была открыта (тот же trade-off, что уже принят
      // в FermerVm.updateFarmerName).
      final farmerData = await _appRepositoryImpl.getFarmerById(farmerId);
      if (farmerData == null) {
        errorMessage = "Fermer ma'lumotlari topilmadi";
        return false;
      }

      final model = FarmerModel.fromJson(jsonDecode(farmerData));
      final updateData = model.toJson();

      final cleanPhone = NetworkUtils.stripCountryCode(phoneNumber.text);

      updateData["name"] = _sanitizeInput(name.text);
      updateData["founder_name"] = _sanitizeInput(founderName.text);
      updateData["director_name"] = _sanitizeInput(directorName.text);
      updateData["phone_number"] = cleanPhone;
      updateData["address"] = _sanitizeInput(address.text);
      updateData["established_year"] = int.parse(establishedYear.text.trim());
      // inn/district/id/email/created_by остаются как пришли со свежего фетча

      final response = await _appRepositoryImpl.updateFarmer(
        id: farmerId,
        data: updateData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }

      errorMessage = DioErrorUtils.messageFromAny(
        Exception(response.data?.toString() ?? 'HTTP ${response.statusCode}'),
      );
      return false;
    } catch (e) {
      errorMessage = DioErrorUtils.messageFromAny(e);
      return false;
    } finally {
      isUpdating = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    name.removeListener(_validateName);
    founderName.removeListener(_validateFounderName);
    directorName.removeListener(_validateDirectorName);
    phoneNumber.removeListener(_validatePhoneNumber);
    address.removeListener(_validateAddress);
    establishedYear.removeListener(_validateEstablishedYear);

    super.dispose();
    name.dispose();
    founderName.dispose();
    directorName.dispose();
    address.dispose();
    phoneNumber.dispose();
    inn.dispose();
    establishedYear.dispose();
  }
}
