# 🚀 Инструкция по запуску приложения с live логами

## Способ 1: Запуск вручную (Рекомендуется)

### Terminal 1: Запуск приложения
```bash
cd /Users/rokki/Desktop/Agrosanoat/geoagro-flutter
flutter run -d emulator-5554
```

### Terminal 2: Live логи Flutter
```bash
cd /Users/rokki/Desktop/Agrosanoat/geoagro-flutter
./watch_logs.sh
```

### Terminal 3: HTTP логи (Dio)
```bash
cd /Users/rokki/Desktop/Agrosanoat/geoagro-flutter
./watch_dio_logs.sh
```

## Способ 2: Использование скрипта
```bash
cd /Users/rokki/Desktop/Agrosanoat/geoagro-flutter
./run_with_logs.sh
```

## Способ 3: Один терминал с разделением
```bash
cd /Users/rokki/Desktop/Agrosanoat/geoagro-flutter

# Очистить логи
adb logcat -c

# Запустить приложение (в фоне)
flutter run -d emulator-5554 &

# Смотреть логи (в том же терминале)
adb logcat | grep -E "(flutter|ERROR|REQUEST|RESPONSE)"
```

## Полезные команды

### Hot Reload
Нажмите `r` в терминале где запущено `flutter run`

### Hot Restart  
Нажмите `R` в терминале где запущено `flutter run`

### Остановка
Нажмите `q` или `Ctrl+C`

### Просмотр только ошибок
```bash
adb logcat *:E
```

### Просмотр всех логов Flutter
```bash
adb logcat | grep flutter
```

### Очистка логов
```bash
adb logcat -c
```

## Если черный экран:

1. **Проверьте компиляцию:**
   ```bash
   flutter analyze
   ```

2. **Проверьте логи на ошибки:**
   ```bash
   adb logcat | grep -i error
   ```

3. **Перезапустите эмулятор:**
   ```bash
   adb emu kill
   # Затем запустите эмулятор снова из Android Studio
   ```

4. **Очистите build:**
   ```bash
   flutter clean
   flutter pub get
   flutter run -d emulator-5554
   ```

