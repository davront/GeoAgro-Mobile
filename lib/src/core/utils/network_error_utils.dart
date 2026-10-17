import 'dart:io';

/// Классифицирует пойманное исключение как сетевую ошибку — то есть
/// такую, после которой имеет смысл положить операцию в офлайн-очередь
/// вместо показа обычного сообщения об ошибке.
///
/// Строковое сравнение `e.toString()` — хрупкий паттерн (зависит от
/// формата сообщения исключения), но он уже использовался в проекте
/// (edit_vm.dart) до появления офлайн-очереди; здесь просто вынесен в
/// одно место вместо трёх разных копий. `DioException.type` был бы
/// надёжнее, но требует доступа к самому DioException в момент catch,
/// который не всегда типизирован явно на этом уровне.
bool isNetworkError(Object e) {
  if (e is SocketException) return true;
  final message = e.toString().toLowerCase();
  return message.contains('socketexception') ||
      message.contains('handshakeexception') ||
      message.contains('connection refused') ||
      message.contains('network is unreachable') ||
      message.contains('timeoutexception') ||
      message.contains('connection') ||
      message.contains('network');
}
