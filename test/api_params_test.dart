import 'package:flutter_test/flutter_test.dart';

import 'package:agro_employee_public/src/core/server/api/api_constants.dart';

// page и offset должны указывать на одни и те же записи — иначе старый
// бэк (page) и новый (offset, GA-4) отдадут разные страницы.
void main() {
  test('pageParams: offset = (page - 1) * limit', () {
    expect(ApiParams.pageParams(page: 1),
        {"page": 1, "page_size": 20, "offset": 0, "limit": 20});
    expect(ApiParams.pageParams(page: 3),
        {"page": 3, "page_size": 20, "offset": 40, "limit": 20});
  });

  test('tasksListParams: страница задач в обоих форматах', () {
    final p = ApiParams.tasksListParams(page: 2);
    expect(p["page"], 2);
    expect(p["offset"], 20);
    expect(p["limit"], p["page_size"]);
  });

  test('tasksListParams без page (stats) — без пагинации', () {
    final p = ApiParams.tasksListParams(statuses: ["new"]);
    expect(p.containsKey("offset"), isFalse);
    expect(p.containsKey("page"), isFalse);
  });
}
