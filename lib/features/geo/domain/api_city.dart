import 'package:flutter/foundation.dart';

@immutable
class ApiCity {
  const ApiCity({
    required this.id,
    required this.regionId,
    required this.countryId,
    required this.name,
    this.isActive = true,
  });

  factory ApiCity.fromJson(Map<String, dynamic> json) => ApiCity(
    id: json['id'] as int,
    regionId: json['region_id'] as int? ?? 0,
    countryId: json['country_id'] as int? ?? 0,
    name: json['name'] as String,
    isActive: json['is_active'] as bool? ?? true,
  );

  final int id;
  final int regionId;
  final int countryId;
  final String name;
  final bool isActive;

  @override
  bool operator ==(Object other) => other is ApiCity && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => name;
}

@immutable
class ApiCountry {
  const ApiCountry({
    required this.id,
    required this.code,
    required this.name,
    this.currency,
    this.phonePrefix,
    this.isActive = true,
  });

  factory ApiCountry.fromJson(Map<String, dynamic> json) => ApiCountry(
    id: json['id'] as int,
    code: json['code'] as String,
    name: json['name'] as String,
    currency: json['currency'] as String?,
    phonePrefix: json['phone_prefix'] as String?,
    isActive: json['is_active'] as bool? ?? true,
  );

  final int id;
  final String code;
  final String name;
  final String? currency;
  final String? phonePrefix;
  final bool isActive;

  @override
  String toString() => name;
}
