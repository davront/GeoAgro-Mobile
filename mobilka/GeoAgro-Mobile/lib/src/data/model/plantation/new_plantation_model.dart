class Coordinate {
  final double? latitude;
  final double? longitude;

  Coordinate({
    this.latitude,
    this.longitude,
  });

  factory Coordinate.fromJson(Map<String, dynamic> json) => Coordinate(
        latitude: json["latitude"]?.toDouble(),
        longitude: json["longitude"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
      };
}

class Investment {
  final String? investType;
  final double? investmentAmount;

  Investment({
    this.investType,
    this.investmentAmount,
  });

  Map<String, dynamic> toJson() => {
        'invest_type': investType,
        'investment_amount': investmentAmount,
      };
}

class Trellis {
  final int? trellisType;
  final int? trellisCount;
  final double? trellisInstalledArea;

  Trellis({
    this.trellisType,
    this.trellisCount,
    this.trellisInstalledArea,
  });

  Map<String, dynamic> toJson() => {
        'trellis_type': trellisType,
        'trellis_count': trellisCount,
        'trellis_installed_area': trellisInstalledArea,
      };
}

class Subsidy {
  final String? year;
  final String? contractNumber;
  final int? direction;
  final double? amount;
  final bool? efficiency;

  Subsidy({
    this.year,
    this.contractNumber,
    this.direction,
    this.amount,
    this.efficiency,
  });

  Map<String, dynamic> toJson() => {
        'year': year,
        'contract_number': contractNumber,
        'direction': direction,
        'amount': amount,
        'efficiency': efficiency,
      };
}

class Reservoir {
  final String? reservoirType;
  final int? reservoirVolume;

  Reservoir({
    this.reservoirType,
    this.reservoirVolume,
  });

  Map<String, dynamic> toJson() => {
        'reservoir_type': reservoirType,
        'reservoir_volume': reservoirVolume,
      };
}

class FruitArea {
  final int? fruit; // ID фрукта
  final int? variety; // ID сорта
  final int? rootstock; // ID подвоя
  final String? fruitName; // Название фрукта
  final String? varietyName; // Название сорта
  final String? rootstockName; // Название подвоя
  final String? plantedYear;
  final double? area;
  final String? schema;
  final double? weight;
  final bool? fenced;
  final bool? iqtisodiysamarasiz;
  final double? economicInefficientArea;

  FruitArea({
    this.fruit,
    this.variety,
    this.rootstock,
    this.fruitName,
    this.varietyName,
    this.rootstockName,
    this.plantedYear,
    this.area,
    this.schema,
    this.weight,
    this.fenced,
    this.iqtisodiysamarasiz,
    this.economicInefficientArea,
  });

  Map<String, dynamic> toJson() => {
        'fruit': fruit,
        'variety': variety,
        'rootstock': rootstock,
        'planted_year': plantedYear,
        'area': area,
        'schema': schema,
        'weight': weight,
        'fenced': fenced,
        'iqtisodiy_samarasiz': iqtisodiysamarasiz,
        'economic_inefficient_area': economicInefficientArea ?? 0.0,
      };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FruitArea &&
        other.fruit == fruit &&
        other.variety == variety &&
        other.rootstock == rootstock &&
        other.plantedYear == plantedYear &&
        other.area == area &&
        other.schema == schema &&
        other.weight == weight &&
        other.fenced == fenced &&
        other.iqtisodiysamarasiz == iqtisodiysamarasiz &&
        other.economicInefficientArea == economicInefficientArea;
  }

  @override
  int get hashCode {
    return fruit.hashCode ^
        variety.hashCode ^
        rootstock.hashCode ^
        plantedYear.hashCode ^
        area.hashCode ^
        schema.hashCode ^
        weight.hashCode ^
        fenced.hashCode ^
        iqtisodiysamarasiz.hashCode ^
        economicInefficientArea.hashCode;
  }
}

class Types {
  final int? plantationType;
  final int? typeChoice;
  final int? subtype;

  Types({
    this.plantationType,
    this.typeChoice,
    this.subtype,
  });

  Map<String, dynamic> toJson() => {
        'plantation_type': plantationType,
        'type_choice': typeChoice,
        'subtype': subtype,
      };
}

class Garden {
  final String? gardenEstablishedYear;
  final String? district;
  final String? farmer;
  final String? emptyArea;
  final String? irrigationArea;
  final String? fertilityScore;
  final String? landType;
  final String? notUsableArea;
  final String? irrigationSystemsCount;
  final bool? isFertile;
  final Types? types;
  final List<Coordinate>? coordinates;
  final List<Investment>? investments;
  final List<Trellis>? trellises;
  final List<Subsidy>? subsidies;
  final List<Reservoir>? reservoirs;
  final List<FruitArea>? fruitAreas;
  final String? dealNumber;
  final String? dealDate;
  final String? resolutionNumber;
  final String? resolutionDate;

  Garden({
    this.gardenEstablishedYear,
    this.district,
    this.farmer,
    this.emptyArea,
    this.irrigationArea,
    this.fertilityScore,
    this.landType,
    this.notUsableArea,
    this.irrigationSystemsCount,
    this.isFertile,
    this.types,
    this.coordinates,
    this.investments,
    this.trellises,
    this.subsidies,
    this.reservoirs,
    this.fruitAreas,
    this.dealNumber,
    this.dealDate,
    this.resolutionNumber,
    this.resolutionDate,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'garden_established_year': gardenEstablishedYear,
      'district': district,
      'farmer': farmer,
      'empty_area': emptyArea,
      'irrigation_area': irrigationArea,
      'fertility_score': fertilityScore,
      'land_type': landType,
      'not_usable_area': notUsableArea,
      'irrigation_systems_count': irrigationSystemsCount,
      'is_fertile': isFertile,
      if (dealNumber != null && dealNumber!.isNotEmpty)
        'deal_number': dealNumber,
      if (dealDate != null && dealDate!.isNotEmpty) 'deal_date': dealDate,
      if (resolutionNumber != null && resolutionNumber!.isNotEmpty)
        'resolution_number': resolutionNumber,
      if (resolutionDate != null && resolutionDate!.isNotEmpty)
        'resolution_date': resolutionDate,
    };
    if (types != null) {
      json['types[plantation_type]'] = types!.plantationType;
      json['types[type_choice]'] = types!.typeChoice;
      json['types[subtype]'] = types!.subtype;
    }

    if (coordinates != null) {
      for (int i = 0; i < coordinates!.length; i++) {
        json['coordinates[$i][latitude]'] = coordinates![i].latitude.toString();
        json['coordinates[$i][longitude]'] =
            coordinates![i].longitude.toString();
      }
    }

    if (investments != null) {
      for (int i = 0; i < investments!.length; i++) {
        json['investments[$i][invest_type]'] = investments![i].investType;
        json['investments[$i][investment_amount]'] =
            investments![i].investmentAmount.toString();
      }
    }

    if (trellises != null) {
      for (int i = 0; i < trellises!.length; i++) {
        json['trellises[$i][trellis_type]'] = trellises![i].trellisType;
        json['trellises[$i][trellis_count]'] = trellises![i].trellisCount;
        json['trellises[$i][trellis_installed_area]'] =
            trellises![i].trellisInstalledArea.toString();
      }
    }

    if (subsidies != null) {
      for (int i = 0; i < subsidies!.length; i++) {
        json['subsidies[$i][year]'] = subsidies![i].year;
        json['subsidies[$i][contract_number]'] = subsidies![i].contractNumber;
        json['subsidies[$i][direction]'] = subsidies![i].direction;
        json['subsidies[$i][amount]'] = subsidies![i].amount.toString();
        json['subsidies[$i][efficiency]'] = subsidies![i].efficiency.toString();
      }
    }

    if (reservoirs != null) {
      for (int i = 0; i < reservoirs!.length; i++) {
        json['reservoirs[$i][reservoir_type]'] = reservoirs![i].reservoirType;
        json['reservoirs[$i][reservoir_volume]'] =
            reservoirs![i].reservoirVolume.toString();
      }
    }

    if (fruitAreas != null) {
      for (int i = 0; i < fruitAreas!.length; i++) {
        final fa = fruitAreas![i];

        // Базовые поля для обоих режимов
        json['fruit_areas[$i][fruit]'] = fa.fruit;
        json['fruit_areas[$i][variety]'] = fa.variety;
        json['fruit_areas[$i][iqtisodiy_samarasiz]'] =
            fa.iqtisodiysamarasiz ?? false;

        // rootstock опционален для обоих режимов
        if (fa.rootstock != null) {
          json['fruit_areas[$i][rootstock]'] = fa.rootstock;
        }

        if (fa.iqtisodiysamarasiz == true) {
          // Экономически неэффективная площадь
          json['fruit_areas[$i][economic_inefficient_area]'] =
              fa.economicInefficientArea ?? 0.0;
          // planted_year, area, schema, weight, fenced автоматически устанавливаются бэкендом
        } else {
          // Обычная посадка
          json['fruit_areas[$i][planted_year]'] = fa.plantedYear;
          json['fruit_areas[$i][area]'] = fa.area?.toString() ?? '0';

          // Опциональные поля
          if (fa.schema != null) json['fruit_areas[$i][schema]'] = fa.schema;
          if (fa.weight != null)
            json['fruit_areas[$i][weight]'] = fa.weight.toString();
          if (fa.fenced != null) json['fruit_areas[$i][fenced]'] = fa.fenced;
        }
      }
    }

    return json;
  }
}
