import 'package:flutter/material.dart';
import '../../../core/utils/dio_error_utils.dart';
import '../../../core/utils/network_utils.dart';
import '../../../core/utils/sanitization_utils.dart';
import '../../../core/utils/validation_utils.dart';
import '../../../data/repository/app_repository_impl.dart';

import '../../../core/server/api/orginfo_service.dart';
import '../../../core/setting/setup.dart';
import '../../../data/model/farmer/create_fermer_model.dart';

class FermerCreateVm extends ChangeNotifier {
  String? errorMessage;
  bool isOrgInfoLoading = false;
  String? orgInfoError;

  final AppRepositoryImpl _appRepositoryImpl = AppRepositoryImpl();

  TextEditingController name = TextEditingController();
  TextEditingController founderName = TextEditingController();
  TextEditingController directorName = TextEditingController();
  TextEditingController phoneNumber = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController inn = TextEditingController();
  TextEditingController establishedYear = TextEditingController();

  // Ошибки валидации для каждого поля
  String? nameError;
  String? founderNameError;
  String? directorNameError;
  String? phoneNumberError;
  String? addressError;
  String? innError;
  String? establishedYearError;

  bool isLoading = false;

  FermerCreateVm() {
    // Инициализируем поле телефона с префиксом +998
    phoneNumber.text = '+998';

    // Добавляем слушатели для валидации в реальном времени
    name.addListener(_validateName);
    founderName.addListener(_validateFounderName);
    directorName.addListener(_validateDirectorName);
    phoneNumber.addListener(_validatePhoneNumber);
    address.addListener(_validateAddress);
    inn.addListener(_validateInn);
    establishedYear.addListener(_validateEstablishedYear);
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  String _sanitizeInput(String input) => SanitizationUtils.sanitizeInput(input);

  // Валидация имени организации (только латиница, цифры и пробелы)
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

  // Валидация имени основателя (только буквы и пробелы)
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

  // Валидация имени директора (только буквы и пробелы)
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

  // Валидация номера телефона
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

  // Валидация адреса (буквы, цифры, пробелы, запятые, точки, дефисы)
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

  // Валидация ИНН
  void _validateInn() {
    final value = inn.text.trim();
    if (value.isEmpty) {
      innError = "INN bo'sh bo'lmasligi zarur";
    } else if (!RegExp(r'^\d+$').hasMatch(value)) {
      innError = "INN faqat raqamlardan iborat bo'lishi kerak";
    } else if (value.length != 9) {
      innError = "INN 9 ta raqamdan iborat bo'lishi kerak";
    } else {
      innError = null;
    }
    notifyListeners();
  }

  // Валидация года создания
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

  // Поиск организации по ИНН через orginfo.uz (автозаполнение названия и адреса)
  Future<void> fetchOrgInfoByInn() async {
    _validateInn();
    if (innError != null) return;

    isOrgInfoLoading = true;
    orgInfoError = null;
    notifyListeners();

    try {
      final result = await OrginfoService.lookupByInn(inn.text.trim());
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
      // Разметка orginfo.uz поменялась либо сайт недоступен — не молчим,
      // явно говорим юзеру заполнить вручную вместо тихого no-op.
      orgInfoError =
          "Avtomatik qidiruv vaqtincha ishlamayapti. Ma'lumotlarni qo'lda kiriting";
    } catch (e) {
      orgInfoError = "Ma'lumotlarni olishda xatolik yuz berdi";
    } finally {
      isOrgInfoLoading = false;
      notifyListeners();
    }
  }

  // Проверка всей формы перед отправкой
  bool validateAll() {
    _validateName();
    _validateFounderName();
    _validateDirectorName();
    _validatePhoneNumber();
    _validateAddress();
    _validateInn();
    _validateEstablishedYear();

    return nameError == null &&
        founderNameError == null &&
        directorNameError == null &&
        phoneNumberError == null &&
        addressError == null &&
        innError == null &&
        establishedYearError == null;
  }

  Future<bool> createFermer() async {
    _setLoading(true);
    try {
      // Санитизация всех данных перед отправкой
      final sanitizedName = _sanitizeInput(name.text);
      final sanitizedFounderName = _sanitizeInput(founderName.text);
      final sanitizedDirectorName = _sanitizeInput(directorName.text);
      final sanitizedAddress = _sanitizeInput(address.text);

      final cleanPhone = NetworkUtils.stripCountryCode(phoneNumber.text);

      // Farmer Model ni yaratish
      CreateFermerModel fermerModel = CreateFermerModel(
        name: sanitizedName,
        founderName: sanitizedFounderName,
        directorName: sanitizedDirectorName,
        phoneNumber: cleanPhone,
        address: sanitizedAddress,
        inn: inn.text.trim(),
        establishedYear: int.parse(establishedYear.text.trim()),
        district: "$districtId",
      );

      // API so‘rovi yuborish
      final response =
          await _appRepositoryImpl.postNewFermer(fermer: fermerModel);
      // Agar status code 200 yoki 201 bo‘lsa
      if (response.statusCode == 200 || response.statusCode == 201) {
        errorMessage = "Yangi fermer qo'shildi";
        return true;
      }
      // Agar status code 400 bo‘lsa
      else if (response.statusCode == 400) {
        errorMessage = "Bunday INN Mavjud";
        return false;
      }
      // Boshqa holatlar (masalan, server xatosi)
      else {
        errorMessage = "Server ochib qolgan bo'lishi mumkin.";
        return false;
      }
    } catch (e) {
      errorMessage = DioErrorUtils.messageFromAny(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  @override
  void dispose() {
    // Удаляем слушатели перед dispose
    name.removeListener(_validateName);
    founderName.removeListener(_validateFounderName);
    directorName.removeListener(_validateDirectorName);
    phoneNumber.removeListener(_validatePhoneNumber);
    address.removeListener(_validateAddress);
    inn.removeListener(_validateInn);
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
