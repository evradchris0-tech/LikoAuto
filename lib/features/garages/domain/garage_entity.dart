class GarageEntity {
  const GarageEntity({
    required this.id,
    required this.name,
    required this.location,
    required this.rating,
    required this.reviewCount,
    required this.listingsCount,
    required this.isVerified,
    this.isCertified = false,
    this.phone,
    this.city,
    this.district,
    this.specialties = const [],
  });

  factory GarageEntity.fromJson(Map<String, dynamic> j) => GarageEntity(
    id: j['id'] as String,
    name: j['name'] as String,
    location: j['location'] as String,
    rating: (j['rating'] as num).toDouble(),
    reviewCount: j['reviewCount'] as int,
    listingsCount: j['listingsCount'] as int? ?? 0,
    isVerified: j['isVerified'] as bool? ?? false,
    isCertified: j['isCertified'] as bool? ?? false,
    phone: j['phone'] as String?,
    city: j['city'] as String?,
    district: j['district'] as String?,
    specialties:
        (j['specialties'] as List<dynamic>?)?.cast<String>() ?? const [],
  );

  final String id;
  final String name;
  final String location;
  final double rating;
  final int reviewCount;
  final int listingsCount;
  final bool isVerified;
  final bool isCertified;

  final String? phone;
  final String? city;
  final String? district;
  final List<String> specialties;
}
