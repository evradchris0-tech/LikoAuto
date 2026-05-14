import 'dart:convert';

import 'package:drift/drift.dart';

/// Convertisseur générique : `Map<String, dynamic>` ↔ JSON text.
class JsonMapConverter extends TypeConverter<Map<String, dynamic>, String>
    with JsonTypeConverter2<Map<String, dynamic>, String, Object> {
  const JsonMapConverter();

  @override
  Map<String, dynamic> fromSql(String fromDb) =>
      json.decode(fromDb) as Map<String, dynamic>;

  @override
  String toSql(Map<String, dynamic> value) => json.encode(value);

  @override
  Map<String, dynamic> fromJson(Object json) =>
      Map<String, dynamic>.from(json as Map);

  @override
  Object toJson(Map<String, dynamic> value) => value;
}

/// Convertisseur générique : `List<String>` ↔ JSON text.
class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();

  @override
  List<String> fromSql(String fromDb) =>
      (json.decode(fromDb) as List).cast<String>();

  @override
  String toSql(List<String> value) => json.encode(value);
}
