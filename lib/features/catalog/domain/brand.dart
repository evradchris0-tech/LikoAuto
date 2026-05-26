import 'package:flutter/foundation.dart';

@immutable
class Brand {
  const Brand({
    required this.id,
    required this.name,
    this.logoUrl,
    this.isActive = true,
  });

  factory Brand.fromJson(Map<String, dynamic> json) => Brand(
        id: json['id'] as int,
        name: json['name'] as String,
        logoUrl: json['logo_url'] as String?,
        isActive: json['is_active'] as bool? ?? true,
      );

  final int id;
  final String name;
  final String? logoUrl;
  final bool isActive;

  @override
  bool operator ==(Object other) => other is Brand && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => name;
}
