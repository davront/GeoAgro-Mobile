# Автоматическая валидация фотографий

## ✅ Реализовано

Добавлена динамическая проверка минимального количества фотографий в зависимости от:
- Типа плантации
- Количества добавленных фруктов
- Типа земли (орошаемая/неорошаемая)

## 📐 Формула расчета

```
Минимальное количество фото = 
  1 (базовая для плантации)
  + количество_фруктов
  + (1 если ярокциз/lalmi, иначе 0)
```

## 🎯 Примеры

### Пример 1: Боғ с одним фруктом, сувли майдон
```
Тип: Боғ (bog)
Фрукты: 1 (например, олма)
Ер тури: Сувли майдон (орошаемая)

Минимум фото = 1 + 1 + 0 = 2 фото
```

### Пример 2: Узумзор с двумя фруктами, lalmi
```
Тип: Узумзор (uzumzor)
Фрукты: 2 (например, кишмиш + хўраки)
Ер тури: Лалми (неорошаемая/ярокциз)

Минимум фото = 1 + 2 + 1 = 4 фото
```

### Пример 3: Иссиқxона с тремя фруктами
```
Тип: Иссиқxона
Фрукты: 3
Ер тури: Сувли майдон

Минимум фото = 1 + 3 + 0 = 4 фото
```

## 💡 Логика по требованиям

### Базовое фото (всегда 1)
- Любая плантация требует минимум 1 фото общего вида

### Фото фруктов (+1 за каждый)
- При добавлении фрукта в `selectedDetails` → +1 фото
- Например:
  - Добавили олма → +1 фото
  - Добавили олча → еще +1 фото
  - Добавили ўрик → еще +1 фото

### Фото ярокциз майдона (+1 если lalmi)
- Если `yerType == 1` (Лалми/неорошаемая) → +1 фото
- Для других типов земли (Тоғолди, Адир, Сувли) → +0 фото

## 🎨 Визуальные индикаторы

### Недостаточно фото ⚠️

```
┌──────────────────────────────────────┐
│ ⚠️ Kamida 3 ta rasm yuklang (1/3)   │ ← Желтый баннер
└──────────────────────────────────────┘

┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐
│  ✓  │ │  +  │ │  +  │ │  +  │  ← Карточки фото
└─────┘ └─────┘ └─────┘ └─────┘
```

### Все фото загружены ✅

```
┌──────────────────────────────────────┐
│ ✅ Barcha rasmlar yuklandi (3/3)    │ ← Зеленый баннер
└──────────────────────────────────────┘

┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐
│  ✓  │ │  ✓  │ │  ✓  │ │  +  │  ← Карточки фото
└─────┘ └─────┘ └─────┘ └─────┘
```

## 🔍 Сообщение при валидации

При попытке сохранить без достаточного количества фото:

```
Kamida 4 ta rasm yuklash kerak. Hozir: 2 ta.

• Asosiy plantatsiya: 1 ta rasm
• Mevalar (2 ta): 2 ta rasm
• Lalmi (yaroqsiz) maydon: 1 ta rasm
```

## 📝 Технические детали

### Файл: `lib/src/feature/detail_page/vm/detail_vm.dart`

**Новые методы:**

#### `calculateMinimumPhotosRequired()`
Рассчитывает минимальное количество фото.

```dart
int calculateMinimumPhotosRequired() {
  int minPhotos = 1; // Base photo
  minPhotos += selectedDetails.length; // Fruits
  if (selectedYerType == 1) minPhotos += 1; // Lalmi
  return minPhotos;
}
```

#### `getPhotoRequirementDetails()`
Возвращает детальное описание требований.

```dart
String getPhotoRequirementDetails() {
  final details = <String>[];
  details.add("• Asosiy plantatsiya: 1 ta rasm");
  if (selectedDetails.isNotEmpty) {
    details.add("• Mevalar (${selectedDetails.length} ta): ${selectedDetails.length} ta rasm");
  }
  if (selectedYerType == 1) {
    details.add("• Lalmi (yaroqsiz) maydon: 1 ta rasm");
  }
  return details.join('\n');
}
```

### Обновленная валидация в `validateFields()`

**Было:**
```dart
if (uploadedImagesCount < 2) {
  return 'Rasm yuklash majburiy, kamida 2 ta rasm yuklang';
}
```

**Стало:**
```dart
final minPhotosRequired = calculateMinimumPhotosRequired();
final uploadedImagesCount = _imageFiles.values.where((file) => file != null).length;

if (uploadedImagesCount < minPhotosRequired) {
  return 'Kamida $minPhotosRequired ta rasm yuklash kerak. Hozir: $uploadedImagesCount ta.\n${getPhotoRequirementDetails()}';
}
```

## 📊 Таблица требований

| Тип плантации | Фрукты | Ер тури | Минимум фото |
|---------------|--------|---------|--------------|
| Боғ | 0 | Сувли | 1 |
| Боғ | 1 | Сувли | 2 |
| Боғ | 1 | Лалми | 3 |
| Боғ | 2 | Сувли | 3 |
| Боғ | 2 | Лалми | 4 |
| Узумзор | 1 | Сувли | 2 |
| Узумзор | 1 | Лалми | 3 |
| Узумзор | 3 | Лалми | 5 |
| Иссиқxона | 2 | Сувли | 3 |

## 🎯 Преимущества

✅ **Гибкость** - требования меняются в зависимости от введенных данных  
✅ **Прозрачность** - пользователь видит почему нужно столько фото  
✅ **UX** - визуальный индикатор показывает прогресс  
✅ **Предотвращение ошибок** - невозможно сохранить без нужного количества фото

## 🔄 Динамическое обновление

Индикатор обновляется автоматически при:
- Добавлении/удалении фрукта → пересчет минимума
- Изменении типа земли → пересчет минимума
- Загрузке фото → обновление счетчика

## 🧪 Тестовые сценарии

### Сценарий 1: Базовая валидация
1. Открыть создание плантации
2. Выбрать тип "Боғ"
3. Добавить 1 фрукт
4. Выбрать "Сувли майдон"
5. Загрузить 1 фото
6. **Результат:** ⚠️ Нужно еще 1 фото (требуется 2)

### Сценарий 2: С ярокциз майдоном
1. Выбрать "Лалми" (ярокциз)
2. Добавить 2 фрукта
3. **Результат:** Требуется минимум 4 фото (1 + 2 + 1)

### Сценарий 3: Успешная валидация
1. Выбрать тип, добавить фрукты
2. Загрузить нужное количество фото
3. **Результат:** ✅ Зеленый индикатор, можно сохранять

## 🎨 Кастомизация

### Изменить базовое количество фото

В `calculateMinimumPhotosRequired()`:
```dart
int minPhotos = 2; // Например, всегда минимум 2
```

### Разные требования для разных типов

```dart
int calculateMinimumPhotosRequired() {
  int minPhotos;
  
  // Разные базовые требования для разных типов
  if (selectedPlantationType == 1) {
    minPhotos = 1; // Боғ - 1 фото
  } else if (selectedPlantationType == 2) {
    minPhotos = 2; // Узумзор - 2 фото
  } else if (selectedPlantationType == 3) {
    minPhotos = 3; // Иссиқxона - 3 фото
  } else {
    minPhotos = 1; // По умолчанию
  }
  
  minPhotos += selectedDetails.length;
  if (selectedYerType == 1) minPhotos += 1;
  
  return minPhotos;
}
```

### Добавить требование для бога по подтипу

```dart
// Если боғ + intensiv → +1 фото
if (selectedPlantationType == 1 && selectedBogType == 1) {
  minPhotos += 1;
}
```

## 🚀 Будущие улучшения

### 1. Подсказки что фотографировать
```dart
String getPhotoSuggestion(int photoIndex) {
  if (photoIndex == 0) return "Umumiy ko'rinish";
  if (photoIndex <= selectedDetails.length) {
    return "Meva: ${selectedDetails[photoIndex-1].fruitName}";
  }
  if (selectedYerType == 1 && photoIndex == calculateMinimumPhotosRequired() - 1) {
    return "Lalmi maydon";
  }
  return "Qo'shimcha";
}
```

### 2. Умная сортировка карточек фото
- Первая карточка - общий вид
- Следующие N карточек - по количеству фруктов
- Последняя - для ярокциз (если применимо)

### 3. Валидация качества фото
- Проверка минимального размера файла
- Проверка разрешения изображения
- Проверка что фото не размыто

## 📚 Связанные файлы

- `lib/src/feature/detail_page/vm/detail_vm.dart` - Логика валидации
- `lib/src/feature/detail_page/view/pages/detail_page.dart` - UI индикатор
- `lib/src/feature/detail_page/view/widgets/images_upload_widget.dart` - Виджет загрузки фото

## ✨ Итог

Теперь система автоматически определяет сколько фото нужно и показывает это пользователю в реальном времени! 🎉
