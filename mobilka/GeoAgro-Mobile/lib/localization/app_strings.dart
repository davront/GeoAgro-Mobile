/// Centralized strings for the application (Uzbek language)
/// All UI text should be referenced from here
class AppStrings {
  AppStrings._();

  // ===== AUTH =====
  static const String login = "Kirish";
  static const String username = "Foydalanuvchi nomi";
  static const String password = "Parol";
  static const String loginError = "Bunday foydalanuvchi yo'q.";
  static const String serverError = "Server ochib qolgan bo'lishi mumkin.";
  static const String networkError = "Internet yoki server bilan muammo yuz berdi.";
  static const String loginRequired = "Kirish kerak";

  // ===== PLANTATION TYPES =====
  static const String plantationType = "Plantatsiya turi";
  static const String bog = "Bog`";
  static const String uzumzor = "Uzumzor";
  static const String issiqxona = "Issiqxona";
  
  // Bog types
  static const String bogIntensiv = "Intensiv";
  static const String bogMahalliy = "Mahalliy";
  
  // Bog subtypes
  static const String bogPakana = "Pakana";
  static const String bogYarimPakana = "Yarim pakana";
  
  // Uzum types
  static const String uzumXoraki = "Xo`raki";
  static const String uzumKishmish = "Kishmish bop";
  static const String uzumSanoat = "Sanoat bop (vino bop)";
  
  // Issiqxona types
  static const String issiqxonaMahalliy = "Mahalliy";
  static const String issiqxonaZamonaviy = "Zamonaviy";

  // ===== LAND TYPES =====
  static const String yerTuri = "Yer turi";
  static const String yerLalmi = "Lalmi";
  static const String yerTogoldi = "Tog`oldi";
  static const String yerAdir = "Adir";
  static const String yerSuvli = "Suvli maydon";

  // ===== SUBSIDY TYPES =====
  static const String subsidiyaTomchilatib = "Tomchilatib sug'orish tizimlari uchun";
  static const String subsidiyaQuduq = "Quduq/nasos stantsiyalari uchun";
  static const String subsidiyaKochat = "Ko'chat uchun";
  static const String subsidiyaShpalier = "Shpalier uchun";
  static const String subsidiyaLimon = "Limon uchun";
  static const String subsidiyaMuqobilenergiya = "Muqobil energiya uchun";

  // ===== REGIONS =====
  static const String regionTashkent = "Toshkent";
  static const String regionAndijan = "Andijon";
  static const String regionBukhara = "Buxoro";
  static const String regionFergana = "Farg'ona";
  static const String regionJizzakh = "Jizzax";
  static const String regionKashkadarya = "Qashqadaryo";
  static const String regionNavoi = "Navoiy";
  static const String regionNamangan = "Namangan";
  static const String regionSamarkand = "Samarqand";
  static const String regionSirdarya = "Sirdaryo";
  static const String regionSurkhandarya = "Surxondaryo";
  static const String regionKarakalpakstan = "Qoraqalpog'iston";
  static const String regionKhorezm = "Xorazm";

  // ===== VALIDATION ERRORS =====
  static const String errorRequired = "Bu maydon majburiy";
  static const String errorTimeNotSelected = "Vaqt tanlanmagan, vaqtni to`ldiring";
  static const String errorPlantationTypeNotSelected = "Plantatsiya turi tanlanmagan, tanlovni bajaring";
  static const String errorBogTypeNotSelected = "Bog turi tanlanmagan, tanlovni bajaring";
  static const String errorUzumTypeNotSelected = "Uzum turi tanlanmagan, tanlovni bajaring";
  static const String errorIssiqxonaTypeNotSelected = "Issiqxona turi tanlanmagan, tanlovni bajaring";
  static const String errorYerTypeNotSelected = "Yer turi tanlanmagan, tanlovni bajaring";
  static const String errorNotUsableAreaInvalid = "Foydalanishga yaroqsiz yerlar noto'g'ri yoki bo'sh, to'ldiring";
  static const String errorNotUsableAreaNegative = "Foydalanishga yaroqsiz maydon manfiy bo'lishi mumkin emas";
  static const String errorEmptyAreaInvalid = "Ochiq maydon noto'g'ri yoki bo'sh, to'ldiring";
  static const String errorEmptyAreaNegative = "Ochiq maydon manfiy bo'lishi mumkin emas";

  // ===== FORM LABELS =====
  static const String labelYerTuri = "Yer turi";
  static const String labelNotUsableArea = "Foydalanishga yaroqsiz maydon";
  static const String hintYerTuriNotSelected = "yer turi tanlanmagan";
  static const String hintYerTuriNotSelectedAlt = "yer turini tanlanmagan";
  static const String hintIssiqxonaTypeNotSelected = "issiqxona turi tanlanmagan";
  static const String hintUzumTypeNotSelected = "uzumzor turi tanlanmagan";
  static const String hintNotUsableArea = "yaroqsiz maydon kiritilmagan";

  // ===== BUTTONS =====
  static const String buttonAdd = "Qo'shish";
  static const String buttonSave = "Saqlash";
  static const String buttonCancel = "Bekor qilish";
  static const String buttonDelete = "O'chirish";
  static const String buttonEdit = "Tahrirlash";
  static const String buttonSearch = "Qidirish";
  static const String buttonTryAgain = "Qayta urinib ko'ring";

  // ===== MESSAGES =====
  static const String messageUnexpectedError = "Kutilmagan xatolik";
  static const String messageDataProcessingError = "Ma'lumotlarni qayta ishlashda xatolik yuz berdi.";
  static const String messageDeleteRequest = "O'chirish so'rovi";

  // ===== HOME PAGE =====
  static const String homeTitle = "GEO Agro";
  static const String approved = "Tasdiqlangan";
  static const String pending = "Ko'rib chiqilmoqda";
  static const String recheck = "Qayta ko'rib chiqish";

  // ===== PLANTATION FIELDS =====
  static const String fieldHudud = "Hudud";
  static const String fieldFermer = "Fermer";
  static const String fieldYerTuriField = "Yer turi";
  static const String fieldYerMaydoni = "Yer maydoni";
  static const String fieldId = "ID";
  static const String fieldBogTashkilTopganYil = "Bog tashkil topgan yil";
  static const String fieldQoshilganVaqt = "Qo'shilgan vaqt";
  static const String fieldYil = "yil";
  static const String fieldGa = "ga";

  // ===== PLANTATION DATA =====
  static String plantationYear(int year) => "$year ${AppStrings.fieldYil}";

  // ===== MAPS =====
  static const String mapCreatePlantation = "Plantatsiya yaratish";
  static const String mapViewPlantation = "Plantatsiyani ko'rish";

  // ===== FARMERS =====
  static const String farmers = "Fermerlar";
  static const String farmerCreate = "Fermer yaratish";
  static const String farmerSearch = "Fermer qidirish";
  static const String farmerPlantations = "Fermer plantatsiyalari";
  static const String farmerStatistics = "Fermerlar statistikasi";

  // ===== NOTIFICATIONS =====
  static const String notifications = "Xabarnomalar";
  static const String notificationUnread = "O'qilmagan xabarnomalar";

  // ===== TASKS =====
  static const String tasks = "Vazifalar";
  static const String taskTitle = "Vazifa";
  static const String taskNotFound = "Vazifa topilmadi.";
  static const String taskLoadFailed = "Vazifani yuklab bo'lmadi.";
  static const String taskStatusUpdated = "Vazifa holati yangilandi";
  static const String taskStatusChangeFailed =
      "Vazifa holatini o'zgartirib bo'lmadi.";
  static const String taskNoPermission = "Bu amal uchun ruxsat yo'q.";
  static const String tasksEmpty = "Sizga biriktirilgan vazifa yo'q";
  static const String tasksEmptyFiltered =
      "Tanlangan filtr bo'yicha vazifa yo'q";
  static const String tasksClearFilter = "Filtrni tozalash";
  static const String pullToRefresh =
      "Ma'lumotlarni yangilash uchun pastga torting";
  static const String taskOverdue = "Muddati o'tgan";
  static const String taskDeadline = "Muddat";
  static const String taskAssignedBy = "Topshirdi";
  static const String taskDistrict = "Tuman";
  static const String taskCreatedAt = "Yaratilgan";
  static const String taskStartedAt = "Boshlangan";
  static const String taskCompletedAt = "Topshirilgan";
  static const String taskReviewedAt = "Tekshirilgan";
  static const String taskDescription = "Topshiriq";
  static const String taskResultComment = "Bajaruvchi izohi";
  static const String taskReviewComment = "Tekshiruvchi izohi";
  static const String taskFile = "Ilova qilingan fayl";
  static const String taskFileOpen = "Ochish";
  static const String taskFileOpenFailed = "Faylni ochib bo'lmadi";
  static const String taskComment = "Izoh";
  static const String taskCommentRequired = "Izoh *";
  static const String taskCommentHint = "Nima qilinganini yozing";
  static const String taskCommentEmptyError = "Bajarilgan ish haqida yozing.";
  static const String taskCommentSend = "Yuborish";
  static const String taskPlantationArea = "Maydon";
  static const String taskPlantationModeration = "Moderatsiya";
  static String taskPlantationNumber(int id) => "Plantatsiya № $id";

  // Task statuses
  static const String taskStatusNew = "Yangi";
  static const String taskStatusInProgress = "Ishda";
  static const String taskStatusDone = "Bajarildi, tekshirilmoqda";
  static const String taskStatusAccepted = "Qabul qilindi";
  static const String taskStatusRejected = "Qaytarildi";

  // Task actions
  static const String taskActionStart = "Ishni boshlash";
  static const String taskActionSubmit = "Topshirish";
  static const String taskActionResume = "Ishni davom ettirish";

  // ===== EMPTY STATES =====
  static const String emptyStateNoData = "Ma'lumot topilmadi";
  static const String emptyStateNoResults = "Natijalar topilmadi";
}

/// Helper class for getting localized values from maps
class AppLocalizedMaps {
  AppLocalizedMaps._();

  static Map<int, String> get plantationTypes => {
    1: AppStrings.bog,
    2: AppStrings.uzumzor,
    3: AppStrings.issiqxona,
  };

  static Map<int, String> get issiqxonaTypes => {
    1: AppStrings.issiqxonaMahalliy,
    2: AppStrings.issiqxonaZamonaviy,
  };

  static Map<int, String> get uzumTypes => {
    1: AppStrings.uzumXoraki,
    2: AppStrings.uzumKishmish,
    3: AppStrings.uzumSanoat,
  };

  static Map<int, String> get bogTypes => {
    1: AppStrings.bogIntensiv,
    2: AppStrings.bogMahalliy,
  };

  static Map<int, String> get bogSubtypes => {
    1: AppStrings.bogPakana,
    2: AppStrings.bogYarimPakana,
  };

  static Map<int, String> get yerTuri => {
    1: AppStrings.yerLalmi,
    2: AppStrings.yerTogoldi,
    3: AppStrings.yerAdir,
    4: AppStrings.yerSuvli,
  };

  static Map<int, String> get subsidyTypes => {
    1: AppStrings.subsidiyaTomchilatib,
    2: AppStrings.subsidiyaQuduq,
    3: AppStrings.subsidiyaKochat,
    4: AppStrings.subsidiyaShpalier,
    5: AppStrings.subsidiyaLimon,
    6: AppStrings.subsidiyaMuqobilenergiya,
  };

  static Map<int, String> get regions => {
    1: AppStrings.regionTashkent,
    2: AppStrings.regionAndijan,
    3: AppStrings.regionBukhara,
    4: AppStrings.regionFergana,
    5: AppStrings.regionJizzakh,
    6: AppStrings.regionKashkadarya,
    7: AppStrings.regionNavoi,
    8: AppStrings.regionNamangan,
    9: AppStrings.regionSamarkand,
    10: AppStrings.regionSirdarya,
    11: AppStrings.regionSurkhandarya,
    12: AppStrings.regionKarakalpakstan,
    13: AppStrings.regionKhorezm,
  };
}

