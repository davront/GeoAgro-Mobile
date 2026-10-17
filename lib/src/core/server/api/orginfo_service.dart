import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;
import 'package:l/l.dart';

class OrginfoResult {
  final String name;
  final String address;
  final String? founderName;
  final String? directorName;
  final String? phoneNumber;
  final int? establishedYear;

  OrginfoResult({
    required this.name,
    required this.address,
    this.founderName,
    this.directorName,
    this.phoneNumber,
    this.establishedYear,
  });
}

/// Скрейпит публичную страницу поиска orginfo.uz по ИНН организации.
/// У orginfo.uz нет официального API — используется парсинг HTML.
/// Данные неофициальные (сам сайт это указывает), проверять на бэкенде.
class OrginfoService {
  static Dio? _dio;

  static Dio get _client {
    _dio ??= Dio(
      BaseOptions(
        baseUrl: 'https://orginfo.uz',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );
    return _dio!;
  }

  static String _collapseWhitespace(String input) =>
      input.replaceAll(RegExp(r'\s+'), ' ').trim();

  /// Бросает [OrginfoParseException], если разметка orginfo.uz поменялась
  /// (страница отдалась, но ожидаемых карточек в ней нет) — сигнал сломанного парсера,
  /// в отличие от штатного "организация не найдена" (null).
  static Future<OrginfoResult?> lookupByInn(String inn) async {
    final Response response;
    try {
      response = await _client.get(
        '/ru/search/organizations/',
        queryParameters: {'q': inn},
      );
    } catch (e) {
      l.e('OrginfoService: network error for INN $inn: $e');
      rethrow;
    }

    if (response.statusCode != 200 || response.data is! String) {
      l.e('OrginfoService: unexpected response for INN $inn, '
          'status=${response.statusCode}');
      throw OrginfoParseException(
          'orginfo.uz javob bermadi (status: ${response.statusCode})');
    }

    final rawHtml = response.data as String;

    // Пустая выдача — организация правда не найдена, а не поломка парсера
    if (!rawHtml.contains('search-tab')) {
      l.e('OrginfoService: response for INN $inn does not look like '
          'a search page — markup may have changed');
      throw OrginfoParseException(
          "orginfo.uz sahifa tuzilishi o'zgargan bo'lishi mumkin");
    }

    final document = parse(rawHtml);

    // Страница также содержит login/register-модалки, которые тоже
    // используют .card-body > h*.card-title (h4/h5, "Войти" и т.п.) —
    // результат поиска отличается тегом h6 без text-center, так что
    // ищем именно его, а не первый попавшийся .card-title.
    final Element? titleEl =
        document.querySelector('.card-body > h6.card-title');
    if (titleEl == null) return null;

    final cardBody = titleEl.parent;
    final addressEl = cardBody?.querySelector('.text-body-tertiary');
    if (addressEl == null) {
      l.w('OrginfoService: title matched but address did not for INN $inn — '
          'markup may have partially changed');
    }

    final name = _collapseWhitespace(titleEl.text);
    final address = _collapseWhitespace(addressEl?.text ?? '');

    // Карточка результата обёрнута в <a href="/ru/organization/{id}/">
    // с доп. данными (директор, учредитель, телефон, год основания).
    // Best-effort: любая ошибка на этом шаге не должна ломать базовый
    // результат (name+address), поэтому ничего отсюда не пробрасывается.
    final detailHref = _findDetailHref(titleEl);
    if (detailHref == null) {
      return OrginfoResult(name: name, address: address);
    }

    try {
      final detailResponse = await _client.get(detailHref);
      if (detailResponse.statusCode != 200 || detailResponse.data is! String) {
        return OrginfoResult(name: name, address: address);
      }
      final detailDoc = parse(detailResponse.data as String);
      final jsonLd = _parseJsonLd(detailDoc);

      return OrginfoResult(
        name: name,
        address: address,
        phoneNumber: _asNonEmptyString(jsonLd?['telephone']),
        directorName: _directorFromJsonLd(jsonLd),
        establishedYear: _yearFromFoundingDate(jsonLd?['foundingDate']),
        founderName: _founderFromDetailPage(detailDoc),
      );
    } catch (e) {
      l.w('OrginfoService: detail page fetch/parse failed for INN $inn: $e');
      return OrginfoResult(name: name, address: address);
    }
  }

  /// Ближайшая обёртка `<a href="/ru/organization/...">` вокруг карточки
  /// результата, ведущая на страницу с деталями организации.
  static String? _findDetailHref(Element el) {
    Element? node = el;
    while (node != null) {
      if (node.localName == 'a') {
        final href = node.attributes['href'];
        if (href != null && href.contains('/organization/')) return href;
      }
      node = node.parent;
    }
    return null;
  }

  static String? _asNonEmptyString(dynamic value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  /// JSON-LD (schema.org/Organization) блок детальной страницы. Возвращает
  /// null при отсутствии/поломке разметки — не критично, доп.поля просто
  /// останутся незаполненными.
  static Map<String, dynamic>? _parseJsonLd(Document doc) {
    try {
      final scriptText =
          doc.querySelector('script[type="application/ld+json"]')?.text;
      if (scriptText == null || scriptText.trim().isEmpty) return null;
      final decoded = jsonDecode(scriptText);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (e) {
      l.w('OrginfoService: JSON-LD parse failed: $e');
      return null;
    }
  }

  /// `employee.name`, когда `employee.jobTitle` — "Руководитель" (директор).
  static String? _directorFromJsonLd(Map<String, dynamic>? jsonLd) {
    final employee = jsonLd?['employee'];
    if (employee is! Map) return null;
    if (employee['jobTitle'] != 'Руководитель') return null;
    return _asNonEmptyString(employee['name']);
  }

  static int? _yearFromFoundingDate(dynamic foundingDate) {
    if (foundingDate is! String || foundingDate.isEmpty) return null;
    final parsed = DateTime.tryParse(foundingDate);
    if (parsed != null) return parsed.year;
    final yearPart = foundingDate.split('-').first;
    return int.tryParse(yearPart);
  }

  /// Первый учредитель из секции "Учредители" (может быть несколько —
  /// берём первого по списку, не пытаемся угадать "главного").
  static String? _founderFromDetailPage(Document doc) {
    final section = doc.querySelectorAll('section').where((el) {
      return el.attributes['aria-label'] == 'Учредители';
    }).firstOrNull;
    if (section == null) return null;

    final founderLink = section
        .querySelectorAll('a')
        .where(
            (a) => (a.attributes['href'] ?? '').contains('/search/founders/'))
        .firstOrNull;
    return _asNonEmptyString(founderLink?.text);
  }
}

/// Парсер сломан (вёрстка orginfo.uz изменилась) — отличается от "ничего не найдено".
class OrginfoParseException implements Exception {
  final String message;
  OrginfoParseException(this.message);

  @override
  String toString() => message;
}
