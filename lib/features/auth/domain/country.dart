import 'package:flutter/foundation.dart';

/// Représente un pays de la plateforme (table `countries` NestJS).
@immutable
class Country {
  const Country({required this.code, required this.name});

  factory Country.fromJson(Map<String, dynamic> json) =>
      Country(code: json['code'] as String, name: json['name'] as String);

  final String code; // ISO 3166-1 alpha-2 : 'CM', 'GA', 'CI'...
  final String name; // 'Cameroun', 'Gabon', 'Côte d\'Ivoire'...

  Map<String, dynamic> toJson() => {'code': code, 'name': name};

  @override
  bool operator ==(Object other) => other is Country && other.code == code;

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => name;
}

/// Pays disponibles en dur (fallback si l'API ne répond pas encore).
const List<Country> kDefaultCountries = [
  Country(code: 'CM', name: 'Cameroun'),
  Country(code: 'GA', name: 'Gabon'),
  Country(code: 'CI', name: "Côte d'Ivoire"),
  Country(code: 'SN', name: 'Sénégal'),
  Country(code: 'TG', name: 'Togo'),
];
