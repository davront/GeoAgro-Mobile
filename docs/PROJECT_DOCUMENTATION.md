# 📚 Полная документация проекта GeoAgro Mobile

## 📋 Содержание
1. [Общая информация](#общая-информация)
2. [Страницы приложения](#страницы-приложения)
3. [API Endpoints](#api-endpoints)
4. [Функции и методы](#функции-и-методы)
5. [Модели данных](#модели-данных)

---

## 🔧 Общая информация

**Название проекта:** GeoAgro Mobile  
**Версия:** 3.0.1+301  
**Base URL:** `https://luxa.uz`  
**Технологии:** Flutter, Dart, Riverpod, Google Maps, Dio

---

## 📱 Страницы приложения

### 1. Страница входа (Login Page)

**Путь:** `/login`  
**Файл:** `lib/src/feature/auth/view/pages/login_page.dart`  
**ViewModel:** `lib/src/feature/auth/vm/login_vm.dart`

#### API:
- **POST** `/api/login/`
  - **Параметры:**
    - `username` (String) - Имя пользователя
    - `password` (String) - Пароль
  - **Ответ:** 
    - `200/201` - Успешный вход
      ```json
      {
        "access": "token",
        "refresh": "refresh_token"
      }
      ```
    - `401` - Неверные учетные данные

#### Функции:
- `login()` - Выполняет вход пользователя
  - Валидирует форму
  - Отправляет запрос на сервер
  - Сохраняет токены в хранилище
  - Получает информацию о пользователе
  - Сохраняет `districtId`, `userId`, `isSpecialUser`, `limitKm`
- `_putTokensToStorage()` - Сохраняет access и refresh токены
- `_fetchAndStoreUserInfo()` - Получает и сохраняет информацию о пользователе

#### Поля формы:
- `userNameC` - Контроллер для имени пользователя
- `passwordC` - Контроллер для пароля

---

### 2. Главная страница (Home Page)

**Путь:** `/`  
**Файл:** `lib/src/feature/home/view/pages/home_page.dart`  
**ViewModel:** `lib/src/feature/home/vm/home_page_vm.dart`

#### API:
- **GET** `/api/plantations/forme/`
  - **Параметры:**
    - `page` (int, optional) - Номер страницы
    - `search` (String, optional) - Поисковый запрос
  - **Ответ:** Список плантаций пользователя с пагинацией

#### Функции:
- `getPlantationsModel({bool isLoadMore, String? search})` - Загружает список плантаций
  - Поддерживает пагинацию
  - Поддерживает поиск
  - Фильтрует по статусам
- `deletePlantation({required int id})` - Удаляет неподтвержденную плантацию
  - **API:** `DELETE /api/plantations/{id}/`
- `deletePlantationPermanently({required int id, String? reason})` - Отправляет плантацию на удаление в модерацию
  - **API:** `PATCH /api/plantations/{id}/delete/`
  - **Body:** `{"moderation_comment": [{"text": reason, "image": null}]}`

#### Фильтры плантаций:
- `rejectedPlantations` - Отклоненные (isChecked == false, есть комментарии)
- `approvedPlantations` - Одобренные (isChecked == true)
- `pendingPlantations` - Ожидающие (isChecked != true, нет комментариев)
- `recheckPlantations` - На перепроверку (isChecked == false, есть комментарии)

#### Состояния:
- `isLoading` - Загрузка данных
- `isFetchingMore` - Загрузка следующей страницы
- `isDeleting` - Процесс удаления
- `currentPage` - Текущая страница
- `canLoadNext` - Можно ли загрузить следующую страницу

---

### 3. Страница деталей плантации (Detail Page)

**Путь:** `/farmers/googleMaps/detailPage`  
**Файл:** `lib/src/feature/detail_page/view/pages/detail_page.dart`  
**ViewModel:** `lib/src/feature/detail_page/vm/detail_vm.dart`

#### API:
- **POST** `/api/plantations/create/` (multipart/form-data)
  - **Body:** См. раздел "Создание плантации"
  - **Ответ:** 
    - `200/201` - Плантация создана
    - `400` - Ошибка валидации

#### Функции:
- `setValue({required int id, required List<Coordinate> coordinate, double? polygonArea, required Map<String, double> userLocation})` - Устанавливает начальные значения
  - Сохраняет ID фермера
  - Сохраняет координаты полигона
  - Сохраняет площадь полигона
  - Сохраняет местоположение пользователя
- `createPt(WidgetRef ref)` - Создает новую плантацию
  - Собирает данные из всех полей формы
  - Валидирует данные
  - Формирует JSON для отправки
  - Отправляет multipart запрос с изображениями
  - Обрабатывает ответ сервера
- `getFruits()` - Загружает список фруктов
  - **API:** `GET /api/fruits`
- `getFruitsVerity({required String verity})` - Загружает сорта фрукта
  - **API:** `GET /api/variety/?fruit={verity}`
- `getFruitsRootstocks({required String rootstocks})` - Загружает подвои
  - **API:** `GET /api/rootstocks/?fruit={rootstocks}`
- `pickImage({required int cardId, required ImageSource source})` - Выбирает изображение
  - Поддерживает камеру и галерею
  - Сохраняет файл для загрузки
- `showImagePicker(BuildContext context, int cardId)` - Показывает диалог выбора источника
- `removeDetailAt(int index)` - Удаляет область фруктов из списка
- `addFruitArea()` - Добавляет новую область фруктов
- `addSubsidy()` - Добавляет новую субсидию
- `removeSubsidyAt(int index)` - Удаляет субсидию

#### Поля формы:
- **Основные:**
  - `notUsableArea` - Непригодная площадь
  - `emptyArea` - Пустая площадь
  - `konturInputController` - Номера контуров
  - `tonnaController` - Ожидаемый урожай (тонны)
  
- **Инвестиции:**
  - `investmentMahhalliyAmount` - Местные инвестиции
  - `investmentXorijiyAmount` - Иностранные инвестиции
  
- **Орошение:**
  - `tomchiSystemsArea` - Площадь капельного орошения
  - `tomchiSystemsCount` - Количество систем
  
- **Шпалеры:**
  - `trellisTemirInstalledArea` - Площадь железных шпалер
  - `trellisTemirCount` - Количество железных шпалер
  - `trellisBetonInstalledArea` - Площадь бетонных шпалер
  - `trellisBetonCount` - Количество бетонных шпалер
  
- **Резервуары:**
  - `reservoirsQoplamaliVolume` - Объем покрытых резервуаров
  - `reservoirsBetonliVolume` - Объем бетонных резервуаров
  
- **Субсидии:**
  - `subsidiyaContract` - Номер договора
  - `subsidiyaAmount` - Сумма субсидии
  
- **Прочее:**
  - `cultivatedArea` - Обрабатываемая площадь
  - `sxema1`, `sxema2` - Схемы посадки
  - `economicInefficientAreaController` - Площадь экономически неэффективной зоны

#### Переключатели (Switches):
- `switchTomchi` - Капельное орошение
- `switchIsFertile` - Плодородность
- `switchInvestmentMahhalliy` - Местные инвестиции
- `switchInvestmentXorjiy` - Иностранные инвестиции
- `switchSubsidiya` - Субсидии
- `switchEfficiency` - Эффективность субсидий
- `switchTrellis` - Шпалеры
- `switchTrellisTemir` - Железные шпалеры
- `switchTrellisBeton` - Бетонные шпалеры
- `switchReservoir` - Резервуары
- `switchReservoirsBeton` - Бетонные резервуары
- `switchReservoirsQoplamali` - Покрытые резервуары
- `switchIqtisodiy` - Экономически неэффективная зона
- `switchFenced` - Ограждение

#### Структура данных для создания:
```dart
{
  "district": int,
  "land_type": int,
  "total_area": double,
  "not_usable_area": double,
  "empty_area": double,
  "coordinates": [
    {"latitude": double, "longitude": double}
  ],
  "user_location": [
    {"latitude": double, "longitude": double}
  ],
  "fruit_areas": [
    {
      "fruit": int,
      "variety": int,
      "rootstock": int,
      "planted_year": int,
      "area": double,
      "schema": String,
      "fenced": bool,
      "weight": double?,
      "iqtisodiysamarasiz": bool?,
      "economic_inefficient_area": double?
    }
  ],
  "investments": [
    {
      "invest_type": String, // "1" - местные, "2" - иностранные
      "investment_amount": double
    }
  ],
  "trellises": [
    {
      "trellis_type": int, // 1 - бетон, 2 - железо
      "trellis_count": int,
      "trellis_installed_area": double
    }
  ],
  "reservoirs": [
    {
      "reservoir_type": int, // 1 - бетон, 2 - покрытый
      "reservoir_volume": double
    }
  ],
  "subsidies": [
    {
      "year": int,
      "contract_number": String,
      "direction": int,
      "amount": double,
      "efficiency": bool
    }
  ],
  "kontur_number": [String],
  "images": [File]
}
```

---

### 4. Страница редактирования плантации (Edit Page)

**Путь:** `/editPage`  
**Файл:** `lib/src/feature/edit/view/page/edit_page.dart`  
**ViewModel:** `lib/src/feature/edit/vm/edit_vm.dart`

#### API:
- **GET** `/api/plantations/{id}/mobile` - Получает данные плантации для редактирования
- **PATCH** `/api/plantations/{id}/mobile-update/` - Обновляет плантацию
- **GET** `/api/plantations/{id}/images/` - Получает изображения плантации
- **POST** `/api/plantations/{id}/images/` - Добавляет изображение
- **DELETE** `/api/plantations/{plantationId}/images/{imageId}/` - Удаляет изображение

#### Функции:
- `loadPlantationData(int id)` - Загружает данные плантации
  - Загружает основную информацию
  - Загружает изображения
  - Заполняет форму данными
- `updatePlantation(WidgetRef ref)` - Обновляет плантацию
  - Собирает измененные данные
  - Отправляет PATCH запрос
  - Обрабатывает ответ
- `pickImage({required int cardId, required ImageSource source})` - Выбирает изображение
- `removeExistingImage(int index)` - Удаляет существующее изображение
- `getAllImages()` - Получает все изображения (существующие + новые)

#### Особенности:
- Отслеживает изменения полей
- Отправляет только измененные данные (минимальный PATCH)
- Поддерживает добавление и удаление изображений
- Валидирует данные перед отправкой

---

### 5. Страница карты создания плантации (Create Map Page)

**Путь:** `/farmers/googleMaps`  
**Файл:** `lib/src/feature/google_map/view/pages/create_map_page.dart`  
**ViewModel:** `lib/src/feature/google_map/vm/create_map_page_vm.dart`

#### API:
- **GET** `/api/plantations/forme/map/` - Получает плантации пользователя для отображения на карте
- **GET** `/api/plantations/nearby/` - Получает соседние плантации
  - **Параметры:**
    - `latitude` (double)
    - `longitude` (double)
    - `radius` (double, default: 1000) - Радиус в метрах

#### Функции:
- `getCurrentLocation()` - Получает текущее местоположение пользователя
  - Запрашивает разрешение на геолокацию
  - Получает координаты
  - Устанавливает маркер на карте
  - Загружает плантации пользователя
- `onMapCreated(GoogleMapController controller)` - Инициализирует карту
- `onTap(LatLng position)` - Обрабатывает нажатие на карту
  - Добавляет точку в полигон
  - Рисует полилинию
  - Проверяет пересечения с другими плантациями
- `validateCoordinatesWithLimit(List<LatLng> coordinates, LatLng? currentLocation)` - Валидирует координаты
  - Проверяет минимальное расстояние от текущего местоположения
  - Использует `limitKm` из настроек пользователя
- `checkPolygonOverlap()` - Проверяет пересечение с другими плантациями
- `cordinatesConverter()` - Конвертирует координаты для отправки на сервер
- `calculatePolygonArea(List<LatLng> points)` - Рассчитывает площадь полигона
  - Использует формулу площади Гаусса
  - Возвращает площадь в квадратных метрах
- `calculateDistance(LatLng start, LatLng end)` - Рассчитывает расстояние между точками
  - Использует формулу гаверсинуса
- `loadNearbyPlantations()` - Загружает соседние плантации
- `loadUserPlantations()` - Загружает плантации пользователя
- `isPointInPolygon(LatLng point, List<LatLng> polygon)` - Проверяет, находится ли точка внутри полигона
- `startDrawingMode()` - Начинает режим точечного рисования
- `addDrawingPoint(LatLng point)` - Добавляет точку при рисовании
- `completeDrawing()` - Завершает рисование полигона
- `clearPolygon()` - Очищает полигон

#### Состояния:
- `polylineCoordinates` - Координаты полигона
- `currentLocation` - Текущее местоположение
- `isLocationPermissionGranted` - Разрешение на геолокацию
- `polylines` - Полилинии для отображения
- `polygons` - Полигоны для отображения
- `markers` - Маркеры на карте
- `nearbyPolygons` - Полигоны соседних плантаций
- `userPlantations` - Плантации пользователя
- `isLoadingNearby` - Загрузка соседних плантаций
- `limitKm` - Лимит расстояния в километрах
- `isDrawingMode` - Режим рисования
- `isPolygonComplete` - Полигон завершен

#### Валидация:
- Минимум 3 точки для создания полигона
- Проверка расстояния от текущего местоположения (limitKm)
- Проверка пересечения с другими плантациями
- Проверка минимальной площади

---

### 6. Страница просмотра карты плантации (Plantation Map View)

**Путь:** `/plantationMapView`  
**Файл:** `lib/src/feature/google_map/view/pages/plantation_map_view_page.dart`  
**ViewModel:** `lib/src/feature/google_map/vm/plantation_map_view_vm.dart`

#### API:
- **GET** `/api/plantations/{plantationId}/related-map/` - Получает связанные плантации для отображения на карте

#### Функции:
- `loadPlantationData(int plantationId)` - Загружает данные плантации
  - Загружает координаты плантации
  - Загружает связанные плантации
  - Отображает полигоны на карте
- `initializeFromDetailData(Map<String, dynamic> jsonData)` - Инициализирует карту из данных детальной страницы
- `onMapCreated(GoogleMapController controller)` - Инициализирует карту
- `calculateArea()` - Рассчитывает площадь плантации
- `calculatePerimeter()` - Рассчитывает периметр плантации

#### Отображаемая информация:
- Полигон плантации
- Связанные плантации
- Площадь плантации (в гектарах)
- Периметр плантации (в метрах)

---

### 7. Страница списка фермеров (Farmers Page)

**Путь:** `/farmers`  
**Файл:** `lib/src/feature/fermers/view/pages/fermers_page.dart`  
**ViewModel:** `lib/src/feature/fermers/vm/fermer_vm.dart`

#### API:
- **GET** `/api/farmers/`
  - **Параметры:**
    - `page` (int, optional) - Номер страницы
  - **Ответ:** Список фермеров с пагинацией

#### Функции:
- `getFermers({bool isLoadMore})` - Загружает список фермеров
  - Поддерживает пагинацию
  - Загружает следующую страницу при скролле

#### Состояния:
- `isLoading` - Загрузка данных
- `isFetchingMore` - Загрузка следующей страницы
- `currentPage` - Текущая страница
- `canLoad` - Можно ли загрузить следующую страницу
- `fermersList` - Список фермеров

---

### 8. Страница поиска фермеров (Farmer Search Page)

**Путь:** `/farmers/searchFarmer`  
**Файл:** `lib/src/feature/fermers/view/pages/farmer_search_page.dart`  
**ViewModel:** `lib/src/feature/fermers/vm/farmer_search_vm.dart`

#### API:
- **GET** `/api/farmers/`
  - **Параметры:**
    - `inn` (int) - ИНН фермера
  - **Ответ:** Список фермеров с указанным ИНН

#### Функции:
- `searchFarmers()` - Ищет фермеров по ИНН
  - Валидирует ввод ИНН
  - Отправляет запрос на сервер
  - Отображает результаты

#### Поля:
- `textEditingController` - Контроллер для ввода ИНН

---

### 9. Страница создания фермера (Farmer Create Page)

**Путь:** `/farmers/createFarmer`  
**Файл:** `lib/src/feature/fermers/view/pages/fermer_create_page.dart`  
**ViewModel:** `lib/src/feature/fermers/vm/fermer_create_vm.dart`

#### API:
- **POST** `/api/farmers/`
  - **Body:**
    ```json
    {
      "name": String,
      "founder_name": String,
      "director_name": String,
      "phone_number": String,
      "address": String,
      "inn": String,
      "established_year": int,
      "district": String
    }
    ```
  - **Ответ:**
    - `200/201` - Фермер создан
    - `400` - Ошибка валидации (например, ИНН уже существует)

#### Функции:
- `createFermer()` - Создает нового фермера
  - Валидирует данные
  - Отправляет запрос на сервер
  - Обрабатывает ответ
- `checkValidate()` - Валидирует форму
  - Проверяет длину полей
  - Проверяет формат телефона (9 цифр)
  - Проверяет формат года (4 цифры)
  - Проверяет, что год не больше текущего

#### Поля формы:
- `name` - Название организации
- `founderName` - Имя основателя
- `directorName` - Имя директора
- `phoneNumber` - Номер телефона (9 цифр)
- `address` - Адрес
- `inn` - ИНН
- `establishedYear` - Год основания

---

### 10. Страница плантаций фермера (Farmer Plantations Page)

**Путь:** `/farmers/farmerPlantations`  
**Файл:** `lib/src/feature/fermers/view/pages/farmer_plantations_page.dart`  
**ViewModel:** `lib/src/feature/fermers/vm/farmer_plantations_vm.dart`

#### API:
- **GET** `/api/mymap/plantations/?farmer_inn={farmerInn}`
  - **Параметры:**
    - `farmer_inn` (int) - ИНН фермера
  - **Ответ:** Список плантаций фермера

#### Функции:
- `loadFarmerPlantations(int farmerInn)` - Загружает плантации фермера
  - Отправляет запрос с ИНН фермера
  - Отображает список плантаций

---

### 11. Страница статистики фермеров (Farmers Statistics Page)

**Путь:** `/farmers/farmersStatistics`  
**Файл:** `lib/src/feature/fermers/view/pages/farmers_statistics_page.dart`  
**ViewModel:** `lib/src/feature/fermers/vm/farmers_statistics_vm.dart`

#### API:
- **GET** `/api/statistics/farmers`
  - **Параметры:**
    - `district_id` (int) - ID района
  - **Ответ:** Статистика по фермерам в районе

#### Функции:
- `loadStatistics(int districtId)` - Загружает статистику
  - Отправляет запрос с ID района
  - Отображает статистику

---

### 12. Страница описания плантации (Description Page)

**Путь:** `/descriptionPage`  
**Файл:** `lib/src/feature/home/view/pages/description_page.dart`  
**ViewModel:** `lib/src/feature/home/vm/description_vm.dart`

#### API:
- **GET** `/api/plantations/{id}/mobile` - Получает детальную информацию о плантации

#### Функции:
- `loadPlantationDetails(int id)` - Загружает детальную информацию
  - Отправляет запрос на сервер
  - Отображает все данные плантации

#### Отображаемая информация:
- Основные данные плантации
- Области фруктов
- Инвестиции
- Шпалеры
- Резервуары
- Субсидии
- Изображения
- Координаты и площадь

---

### 13. Страница просмотра плантации (Plantation View Page)

**Путь:** `/plantationView`  
**Файл:** `lib/src/feature/home/view/pages/plantation_view_page.dart`

#### Функции:
- Отображает краткую информацию о плантации
- Позволяет перейти к детальной странице
- Позволяет перейти к редактированию
- Позволяет перейти к карте

---

### 14. Страница уведомлений (Notifications Page)

**Путь:** `/natificationPage`  
**Файл:** `lib/src/feature/home/view/pages/natification_page.dart`  
**ViewModel:** `lib/src/feature/home/vm/notifications_vm.dart`

#### API:
- **GET** `/api/notifications/`
  - **Параметры:**
    - `limit` (int, default: 20) - Количество уведомлений
    - `offset` (int, default: 0) - Смещение
    - `unread_only` (bool, optional) - Только непрочитанные
    - `type` (String, optional) - Тип уведомления
  - **Ответ:**
    ```json
    {
      "notifications": [...],
      "unread_count": int,
      "has_more": bool
    }
    ```
- **GET** `/api/notifications/unread-count/` - Получает количество непрочитанных
- **PATCH** `/api/notifications/` - Отмечает уведомления как прочитанные
  - **Body:**
    ```json
    {
      "mark_all_as_read": bool,
      "notification_ids": [int]
    }
    ```
- **PATCH** `/api/notifications/{id}/` - Отмечает одно уведомление как прочитанное
- **DELETE** `/api/notifications/{id}/` - Удаляет уведомление

#### Функции:
- `refresh({bool unreadOnly})` - Обновляет список уведомлений
  - Сбрасывает список
  - Загружает новые уведомления
- `fetchMore()` - Загружает следующую страницу уведомлений
- `markAllAsRead()` - Отмечает все уведомления как прочитанные
- `markAsRead(int id)` - Отмечает одно уведомление как прочитанное
- `delete(int id)` - Удаляет уведомление

#### Состояния:
- `notifications` - Список уведомлений
- `isLoading` - Загрузка данных
- `isFetchingMore` - Загрузка следующей страницы
- `unreadCount` - Количество непрочитанных
- `hasMore` - Есть ли еще уведомления
- `limit` - Лимит на страницу
- `offset` - Текущее смещение

---

### 15. Страница одобренных плантаций (Approved Page)

**Путь:** `/approvedPage`  
**Файл:** `lib/src/feature/home/view/pages/approved_page.dart`

#### Функции:
- Отображает только одобренные плантации (isChecked == true)
- Использует `HomePageVm.approvedPlantations`

---

### 16. Страница ожидающих плантаций (Pending Page)

**Путь:** `/pendingPage`  
**Файл:** `lib/src/feature/home/view/pages/pending_page.dart`

#### Функции:
- Отображает плантации, ожидающие модерации
- Использует `HomePageVm.pendingPlantations`

---

### 17. Страница на перепроверку (Recheck Page)

**Путь:** `/recheckPage`  
**Файл:** `lib/src/feature/home/view/pages/recheck_page.dart`

#### Функции:
- Отображает плантации, отправленные на перепроверку
- Использует `HomePageVm.recheckPlantations`

---

### 18. Страница заблокированных пользователей (Blocked Page)

**Путь:** `/blocked`  
**Файл:** `lib/src/feature/page/blocked_page.dart`

#### Функции:
- Отображается при блокировке пользователя
- Показывает сообщение о блокировке

---

### 19. Страница настроек профиля (Profile Settings Page)

**Путь:** `/profile/settings`  
**Файл:** `lib/src/feature/profile/view/pages/profile_settings_page.dart`

#### Функции:
- Отображает информацию о пользователе
- Позволяет выйти из аккаунта

---

## 🔌 API Endpoints

### Базовый URL
```
https://luxa.uz
```

### Аутентификация

#### POST `/api/login/`
Вход в систему
- **Body:**
  ```json
  {
    "username": "string",
    "password": "string"
  }
  ```
- **Ответ 200/201:**
  ```json
  {
    "access": "string",
    "refresh": "string"
  }
  ```

#### GET `/api/user_info/`
Получение информации о пользователе
- **Headers:** `Authorization: Bearer {token}`
- **Ответ 200:**
  ```json
  {
    "id": int,
    "username": "string",
    "first_name": "string",
    "last_name": "string",
    "district_id": int,
    "district_name": "string",
    "user_role": int,
    "is_specialuser": bool,
    "limit_km": double?,
    "flutter_version": "string"
  }
  ```

### Плантации

#### GET `/api/plantations/forme/`
Список плантаций пользователя
- **Параметры:**
  - `page` (int, optional)
  - `search` (String, optional)
- **Ответ 200:**
  ```json
  {
    "count": int,
    "next": "string|null",
    "previous": "string|null",
    "results": [...]
  }
  ```

#### GET `/api/plantations/{id}/mobile`
Детальная информация о плантации
- **Ответ 200:**
  ```json
  {
    "id": int,
    "district": int,
    "land_type": int,
    "total_area": double,
    "coordinates": [...],
    "fruit_areas": [...],
    "investments": [...],
    "trellises": [...],
    "reservoirs": [...],
    "subsidies": [...],
    "images": [...],
    "user_locations": [...]
  }
  ```

#### POST `/api/plantations/create/`
Создание новой плантации
- **Content-Type:** `multipart/form-data`
- **Body:** См. раздел "Создание плантации" в Detail Page

#### PATCH `/api/plantations/{id}/mobile-update/`
Обновление плантации
- **Content-Type:** `application/json`
- **Body:** Только измененные поля

#### DELETE `/api/plantations/{id}/`
Удаление неподтвержденной плантации
- **Ответ 204:** Успешно удалено

#### PATCH `/api/plantations/{id}/delete/`
Отправка плантации на удаление в модерацию
- **Body:**
  ```json
  {
    "moderation_comment": [
      {
        "text": "string",
        "image": null
      }
    ]
  }
  ```

#### GET `/api/plantations/forme/map/`
Плантации пользователя для отображения на карте
- **Ответ 200:**
  ```json
  {
    "plantations": [
      {
        "id": int,
        "coordinates": [...],
        "is_checked": bool
      }
    ]
  }
  ```

#### GET `/api/plantations/nearby/`
Соседние плантации
- **Параметры:**
  - `latitude` (double)
  - `longitude` (double)
  - `radius` (double, default: 1000)
- **Ответ 200:**
  ```json
  {
    "plantations": [
      {
        "id": int,
        "coordinates": [...],
        "is_checked": bool
      }
    ]
  }
  ```

#### GET `/api/plantations/{plantationId}/related-map/`
Связанные плантации для карты
- **Ответ 200:**
  ```json
  {
    "current": {...},
    "related": [...]
  }
  ```

### Изображения плантаций

#### GET `/api/plantations/{id}/images/`
Получение изображений плантации
- **Ответ 200:**
  ```json
  {
    "images": [
      {
        "id": int,
        "image": "url",
        "created_at": "datetime"
      }
    ]
  }
  ```

#### POST `/api/plantations/{id}/images/`
Добавление изображения
- **Content-Type:** `multipart/form-data`
- **Body:**
  ```
  image: File
  ```

#### DELETE `/api/plantations/{plantationId}/images/{imageId}/`
Удаление изображения
- **Ответ 204:** Успешно удалено

### Фермеры

#### GET `/api/farmers/`
Список фермеров
- **Параметры:**
  - `page` (int, optional)
  - `inn` (int, optional) - Поиск по ИНН
- **Ответ 200:**
  ```json
  {
    "count": int,
    "next": "string|null",
    "previous": "string|null",
    "results": [...]
  }
  ```

#### POST `/api/farmers/`
Создание нового фермера
- **Body:**
  ```json
  {
    "name": "string",
    "founder_name": "string",
    "director_name": "string",
    "phone_number": "string",
    "address": "string",
    "inn": "string",
    "established_year": int,
    "district": "string"
  }
  ```

#### GET `/api/farmers/{id}/`
Детальная информация о фермере
- **Ответ 200:**
  ```json
  {
    "id": int,
    "name": "string",
    "inn": "string",
    ...
  }
  ```

#### GET `/api/mymap/plantations/?farmer_inn={farmerInn}`
Плантации фермера
- **Параметры:**
  - `farmer_inn` (int) - ИНН фермера
- **Ответ 200:**
  ```json
  {
    "plantations": [...]
  }
  ```

### Справочники

#### GET `/api/fruits`
Список фруктов
- **Ответ 200:**
  ```json
  [
    {
      "id": int,
      "name": "string"
    }
  ]
  ```

#### GET `/api/variety/?fruit={fruitId}`
Сорта фрукта
- **Параметры:**
  - `fruit` (int) - ID фрукта
- **Ответ 200:**
  ```json
  [
    {
      "id": int,
      "name": "string"
    }
  ]
  ```

#### GET `/api/rootstocks/?fruit={fruitId}`
Подвои фрукта
- **Параметры:**
  - `fruit` (int) - ID фрукта
- **Ответ 200:**
  ```json
  [
    {
      "id": int,
      "name": "string"
    }
  ]
  ```

#### GET `/api/districts/`
Список районов
- **Ответ 200:**
  ```json
  [
    {
      "id": int,
      "name": "string"
    }
  ]
  ```

#### GET `/api/regions/`
Список регионов
- **Ответ 200:**
  ```json
  [
    {
      "id": int,
      "name": "string"
    }
  ]
  ```

### Статистика

#### GET `/api/statistics/farmers`
Статистика по фермерам
- **Параметры:**
  - `district_id` (int) - ID района
- **Ответ 200:**
  ```json
  {
    "total_farmers": int,
    "total_plantations": int,
    ...
  }
  ```

### Уведомления

#### GET `/api/notifications/`
Список уведомлений
- **Параметры:**
  - `limit` (int, default: 20)
  - `offset` (int, default: 0)
  - `unread_only` (bool, optional)
  - `type` (String, optional)
- **Ответ 200:**
  ```json
  {
    "notifications": [
      {
        "id": int,
        "type": "string",
        "title": "string",
        "message": "string",
        "priority": "string",
        "is_read": bool,
        "created_at": "datetime",
        "read_at": "datetime|null",
        "data": {}
      }
    ],
    "unread_count": int,
    "has_more": bool
  }
  ```

#### GET `/api/notifications/unread-count/`
Количество непрочитанных уведомлений
- **Ответ 200:**
  ```json
  {
    "count": int
  }
  ```

#### PATCH `/api/notifications/`
Отметить уведомления как прочитанные
- **Body:**
  ```json
  {
    "mark_all_as_read": bool,
    "notification_ids": [int]
  }
  ```

#### PATCH `/api/notifications/{id}/`
Отметить одно уведомление как прочитанное
- **Body:** `{}`

#### DELETE `/api/notifications/{id}/`
Удалить уведомление
- **Ответ 204:** Успешно удалено

---

## 🛠️ Функции и методы

### Утилиты

#### `ApiService`
Класс для работы с API

**Методы:**
- `initDio()` - Инициализирует Dio клиент
- `getHeaders({bool isUpload})` - Получает заголовки запроса
- `get(String api, Map<String, dynamic> params)` - GET запрос
- `post(String api, Map<String, dynamic> data, [Map<String, dynamic> params])` - POST запрос
- `patch(String api, Map<String, dynamic> data)` - PATCH запрос
- `delete(String api)` - DELETE запрос
- `multipart(String api, Map<String, dynamic> body, List<String> filePaths)` - Multipart запрос
- `postFile(String api, String filePath)` - Загрузка файла

#### `AppStorage`
Класс для работы с локальным хранилищем

**Методы:**
- `$write({required StorageKey key, required dynamic value})` - Запись значения
- `$read({required StorageKey key})` - Чтение значения
- `$writeInt({required StorageKey key, required int value})` - Запись int
- `$readInt({required StorageKey key})` - Чтение int
- `$writeBool({required StorageKey key, required bool value})` - Запись bool
- `$readBool({required StorageKey key})` - Чтение bool
- `$writeDouble({required StorageKey key, required double value})` - Запись double
- `$readDouble({required StorageKey key})` - Чтение double
- `$delete({required StorageKey key})` - Удаление значения

#### `Utils`
Утилиты приложения

**Методы:**
- `fireTopSnackBar(String message, Color color, BuildContext context)` - Показывает snackbar

### Математические функции

#### `calculatePolygonArea(List<LatLng> points)`
Рассчитывает площадь полигона
- **Параметры:** Список координат
- **Возвращает:** Площадь в квадратных метрах
- **Алгоритм:** Формула площади Гаусса для сферических координат

#### `calculateDistance(LatLng start, LatLng end)`
Рассчитывает расстояние между двумя точками
- **Параметры:** Две координаты
- **Возвращает:** Расстояние в метрах
- **Алгоритм:** Формула гаверсинуса

#### `isPointInPolygon(LatLng point, List<LatLng> polygon)`
Проверяет, находится ли точка внутри полигона
- **Параметры:** Точка и полигон
- **Возвращает:** `true` если точка внутри
- **Алгоритм:** Ray casting algorithm

#### `findMinimumDistance(List<LatLng> coordinates, LatLng currentLocation)`
Находит минимальное расстояние от точки до полигона
- **Параметры:** Координаты полигона и текущее местоположение
- **Возвращает:** Минимальное расстояние в метрах

---

## 📦 Модели данных

### TokenModel
```dart
{
  "access": String,
  "refresh": String
}
```

### UserInfoModel
```dart
{
  "id": int,
  "username": String,
  "first_name": String?,
  "last_name": String?,
  "district_id": int,
  "district_name": String,
  "user_role": int,
  "is_specialuser": bool,
  "limit_km": double?,
  "flutter_version": String?
}
```

### PlantationModel
```dart
{
  "id": int,
  "district": int,
  "land_type": int,
  "total_area": double,
  "not_usable_area": double,
  "empty_area": double,
  "coordinates": [Coordinate],
  "fruit_areas": [FruitArea],
  "investments": [Investment],
  "trellises": [Trellis],
  "reservoirs": [Reservoir],
  "subsidies": [Subsidy],
  "images": [String],
  "user_locations": [UserLocation],
  "is_checked": bool?,
  "moderation_comments": [ModerationComment]?
}
```

### Coordinate
```dart
{
  "latitude": double,
  "longitude": double
}
```

### FruitArea
```dart
{
  "fruit": int,
  "variety": int?,
  "rootstock": int?,
  "planted_year": int,
  "area": double,
  "schema": String,
  "fenced": bool,
  "weight": double?,
  "iqtisodiysamarasiz": bool?,
  "economic_inefficient_area": double?
}
```

### Investment
```dart
{
  "invest_type": String, // "1" - местные, "2" - иностранные
  "investment_amount": double
}
```

### Trellis
```dart
{
  "trellis_type": int, // 1 - бетон, 2 - железо
  "trellis_count": int,
  "trellis_installed_area": double
}
```

### Reservoir
```dart
{
  "reservoir_type": int, // 1 - бетон, 2 - покрытый
  "reservoir_volume": double
}
```

### Subsidy
```dart
{
  "year": int,
  "contract_number": String,
  "direction": int,
  "amount": double,
  "efficiency": bool
}
```

### UserLocation
```dart
{
  "latitude": double,
  "longitude": double
}
```

### FarmerModel
```dart
{
  "id": int,
  "name": String,
  "founder_name": String,
  "director_name": String,
  "phone_number": String,
  "address": String,
  "inn": String,
  "established_year": int,
  "district": int
}
```

### NotificationItem
```dart
{
  "id": int,
  "type": String,
  "title": String,
  "message": String,
  "priority": String,
  "is_read": bool,
  "created_at": DateTime,
  "read_at": DateTime?,
  "data": Map<String, dynamic>?
}
```

---

## 🔐 Безопасность

### Токены
- Access токен хранится в `flutter_secure_storage`
- Refresh токен используется для обновления access токена
- Токены автоматически добавляются в заголовки запросов через `TokenInterceptor`

### Разрешения
- Геолокация запрашивается при первом использовании карты
- Разрешения на камеру и галерею запрашиваются при выборе изображения

---

## 📝 Примечания

1. Все API запросы требуют авторизации (кроме `/api/login/`)
2. Таймауты запросов: 2 минуты
3. Пагинация используется для больших списков (20 элементов на страницу)
4. Изображения загружаются через `multipart/form-data`
5. Координаты передаются в формате `[{"latitude": double, "longitude": double}]`
6. `user_location` передается как массив с одним элементом для совместимости с Django REST Framework

---

**Версия документации:** 1.0  
**Дата обновления:** 2025-11-18

