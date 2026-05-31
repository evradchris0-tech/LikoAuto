import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/features/bookings/domain/booking.dart';
import 'package:liko_auto/features/garage_detail/domain/garage_detail.dart';
import 'package:liko_auto/features/garages/domain/garage_entity.dart';
import 'package:liko_auto/features/home/widgets/listing_card.dart';
import 'package:liko_auto/features/notifications_inbox/domain/app_notification.dart';
import 'package:liko_auto/features/search/widgets/garage_result_card.dart';

class MockDataService {
  const MockDataService._({
    required this.garages,
    required this.garageDetails,
    required this.notificationSeeds,
    required this.bookingSeeds,
    required this.chats,
    required this.listings,
  });

  final List<GarageEntity> garages;
  final Map<String, GarageDetail> garageDetails;
  final List<AppNotification> notificationSeeds;
  final List<Booking> bookingSeeds;
  final List<Map<String, dynamic>> chats;
  final List<ListingCardData> listings;

  static Future<MockDataService> load() async {
    final raw = await rootBundle.loadString('assets/data/mock_data.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;

    final rawGarages = (json['garages'] as List).cast<Map<String, dynamic>>();

    final garageList = rawGarages.map(GarageEntity.fromJson).toList();

    final detailMap = <String, GarageDetail>{
      for (final g in rawGarages) g['id'] as String: _parseGarageDetail(g),
    };

    final now = DateTime.now();
    final notifSeeds = (json['notification_seeds'] as List)
        .cast<Map<String, dynamic>>()
        .map<AppNotification>((n) => _parseNotification(n, now))
        .toList();

    final bookingSeeds = (json['booking_seeds'] as List)
        .cast<Map<String, dynamic>>()
        .map<Booking>((b) => _parseBooking(b, now))
        .toList();

    final chats = (json['chats'] as List).cast<Map<String, dynamic>>();

    final listings = (json['listings'] as List)
        .cast<Map<String, dynamic>>()
        .map<ListingCardData>(_parseListing)
        .toList();

    return MockDataService._(
      garages: garageList,
      garageDetails: detailMap,
      notificationSeeds: notifSeeds,
      bookingSeeds: bookingSeeds,
      chats: chats,
      listings: listings,
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static GarageDetail _parseGarageDetail(Map<String, dynamic> g) {
    final card = GarageCardData(
      name: g['name'] as String,
      specialties: (g['specialties'] as List).cast<String>(),
      rating: (g['rating'] as num).toDouble(),

      location: g['location'] as String,
      imageAsset: 'assets/images/car_rav4.png',
      isCertified: g['isCertified'] as bool? ?? false,
    );

    final services = (g['services'] as List)
        .cast<Map<String, dynamic>>()
        .map(
          (s) => GarageService(
            label: s['label'] as String,
            priceFromFcfa: s['priceFromFcfa'] as int,
            durationMin: s['durationMin'] as int,
          ),
        )
        .toList();

    final reviews = (g['reviews'] as List)
        .cast<Map<String, dynamic>>()
        .map(
          (r) => GarageReview(
            author: r['author'] as String,
            rating: (r['rating'] as num).toDouble(),
            body: r['body'] as String,
            daysAgo: r['daysAgo'] as int,
            verified: r['verified'] as bool? ?? false,
          ),
        )
        .toList();

    final hours = (g['hours'] as List)
        .cast<Map<String, dynamic>>()
        .map(
          (h) =>
              GarageHours(day: h['day'] as String, range: h['range'] as String),
        )
        .toList();

    return GarageDetail(
      card: card,
      about: g['about'] as String,
      services: services,
      reviews: reviews,
      hours: hours,
      phone: g['phone'] as String,
      address: g['address'] as String,
    );
  }

  static ListingCardData _parseListing(Map<String, dynamic> l) =>
      ListingCardData(
        id: int.tryParse(l['id']?.toString() ?? '0') ?? 0,
        title: l['title'] as String,
        priceFcfa: l['priceFcfa'] as int,
        location: l['location'] as String,
        mileageKm: l['mileageKm'] as int,
        imageAsset: '',
        photoCount: l['photoCount'] as int? ?? 0,
        year: l['year'] as String? ?? '2020',
        isVinVerified: l['isVinVerified'] as bool? ?? false,
        isPro: l['isPro'] as bool? ?? false,
        priceDrop: l['priceDrop'] as int?,
      );

  static AppNotification _parseNotification(
    Map<String, dynamic> n,
    DateTime now,
  ) {
    final offsetMinutes = n['offsetMinutes'] as int? ?? 0;
    return AppNotification(
      id: n['id'] as String,
      type: NotifType.values[n['type'] as int],
      title: n['title'] as String,
      body: n['body'] as String,
      createdAt: now.add(Duration(minutes: offsetMinutes)),
      isRead: n['isRead'] as bool? ?? false,
      payload: (n['payload'] as Map<String, dynamic>?) ?? const {},
    );
  }

  static Booking _parseBooking(Map<String, dynamic> b, DateTime now) {
    final offsetDays = b['scheduledOffsetDays'] as int;
    final hour = b['scheduledHour'] as int;
    final minute = b['scheduledMinute'] as int;
    final scheduledAt = DateTime(
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    ).add(Duration(days: offsetDays));

    final statusStr = b['status'] as String;
    final status = switch (statusStr) {
      'confirmed' => BookingStatus.confirmed,
      'completed' => BookingStatus.completed,
      'cancelled' => BookingStatus.cancelled,
      _ => BookingStatus.pending,
    };

    return Booking(
      id: b['id'] as String,
      garageName: b['garageName'] as String,
      garageLocation: b['garageLocation'] as String,
      garageImageAsset: b['garageImageAsset'] as String,
      service: GarageService(
        label: b['serviceLabel'] as String,
        priceFromFcfa: b['servicePriceFromFcfa'] as int,
        durationMin: b['serviceDurationMin'] as int,
      ),
      scheduledAt: scheduledAt,
      status: status,
      note: b['note'] as String?,
      createdAt: now.subtract(const Duration(hours: 2)),
    );
  }
}

final mockDataServiceProvider = FutureProvider<MockDataService>((ref) {
  return MockDataService.load();
});
