import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

final selectedCityProvider = StateProvider<String>((ref) => 'Douala');

final detectCityProvider = FutureProvider.autoDispose<String>((ref) async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw Exception('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw Exception('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    throw Exception('Location permissions are permanently denied.');
  }

  final position = await Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
  );

  const cities = {
    'Douala': {'lat': 4.0511, 'lng': 9.7679},
    'Yaoundé': {'lat': 3.8480, 'lng': 11.5021},
    'Bafoussam': {'lat': 5.4801, 'lng': 10.4217},
  };

  var closestCity = 'Douala';
  var minDistance = double.infinity;

  double haversine(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371; // Rayon de la terre en km
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return r * c;
  }

  for (final entry in cities.entries) {
    final dist = haversine(
      position.latitude,
      position.longitude,
      entry.value['lat']!,
      entry.value['lng']!,
    );
    if (dist < minDistance) {
      minDistance = dist;
      closestCity = entry.key;
    }
  }

  ref.read(selectedCityProvider.notifier).state = closestCity;
  return closestCity;
});

double _deg2rad(double deg) => deg * (pi / 180.0);
