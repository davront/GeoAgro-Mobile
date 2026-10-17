# flutter run с отфильтрованным выводом — глушит системный Android-шум
# (HWUI image-decode логи, Firebase CctTransportBackend телеметрию),
# который не относится к коду приложения и топит реальные ошибки/принты.
# Использование: .\run-clean.ps1 [доп. аргументы flutter run, напр. -d emulator-5554]

$noise = 'HWUI|TRuntime\.CctTransportBackend|Image decoding logging dropped'

flutter run @args 2>&1 | Where-Object { $_ -notmatch $noise }
