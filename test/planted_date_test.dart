import 'package:flutter_test/flutter_test.dart';

import 'package:agro_employee_public/src/core/server/api/api_constants.dart';
import 'package:agro_employee_public/src/core/utils/date_utils.dart';
import 'package:agro_employee_public/src/data/model/plantation/edit_plantation.dart'
    as edit;
import 'package:agro_employee_public/src/data/model/plantation/new_plantation_model.dart'
    as create;

void main() {
  test('подпись даты: 1 января — только год, без даты — planted_year', () {
    expect(plantedDateLabel('2021-03-15', 2021), '15.03.2021');
    expect(plantedDateLabel('2016-01-01', 2016), '2016');
    expect(plantedDateLabel(null, 2019), '2019');
    expect(plantedDateLabel(null, null), '');
  });

  test('дата для формы: planted_date, иначе 1 января planted_year', () {
    expect(plantedDateFromApi('2021-03-15', 2021), DateTime(2021, 3, 15));
    expect(plantedDateFromApi(null, 2019), DateTime(2019));
    expect(plantedDateFromApi(null, 0), isNull);
    expect(plantedDateForApi(DateTime(2021, 3, 5)), '2021-03-05');
  });

  test('создание: planted_date уходит в form-data, у iqtisodiy — нет', () {
    final json = create.Garden(fruitAreas: [
      create.FruitArea(
          fruit: 1, variety: 2, plantedYear: '2021', plantedDate: '2021-03-15'),
      create.FruitArea(fruit: 1, variety: 2, iqtisodiysamarasiz: true),
    ]).toJson();
    expect(json['fruit_areas[0][planted_date]'], '2021-03-15');
    expect(json.containsKey('fruit_areas[1][planted_date]'), isFalse);
  });

  test('правка: нетронутая зона отправляет свою planted_date обратно', () {
    final zone = edit.FruitArea.fromJson(
        {'fruit': 1, 'planted_year': 2021, 'planted_date': '2021-03-15'});
    expect(zone.toJson()['planted_date'], '2021-03-15');
    expect(zone.copyWith(area: 2).toJson()['planted_date'], '2021-03-15');
  });

  test('статистика: planted_month уходит, только если выбран', () {
    expect(ApiParams.farmersStatisticsParams(plantedMonth: 3)['planted_month'],
        3);
    expect(ApiParams.farmersStatisticsParams().containsKey('planted_month'),
        isFalse);
  });
}
