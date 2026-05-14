import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:liko_auto/core/theme/app_colors.dart';

/// Types de notifications reçues par l'utilisateur.
enum NotifType {
  newMessage,
  priceDrop,
  appointment,
  listingApproved,
  listingRejected,
  review,
  system,
  promo,
}

extension NotifTypeStyle on NotifType {
  IconData get icon {
    switch (this) {
      case NotifType.newMessage:
        return Icons.forum_rounded;
      case NotifType.priceDrop:
        return Icons.trending_down_rounded;
      case NotifType.appointment:
        return Icons.event_available_rounded;
      case NotifType.listingApproved:
        return Icons.check_circle_rounded;
      case NotifType.listingRejected:
        return Icons.cancel_rounded;
      case NotifType.review:
        return Icons.star_rounded;
      case NotifType.system:
        return Icons.shield_rounded;
      case NotifType.promo:
        return Icons.local_offer_rounded;
    }
  }

  Color get accent {
    switch (this) {
      case NotifType.newMessage:
        return AppColors.primary;
      case NotifType.priceDrop:
        return AppColors.success;
      case NotifType.appointment:
        return AppColors.trust;
      case NotifType.listingApproved:
        return AppColors.success;
      case NotifType.listingRejected:
        return AppColors.error;
      case NotifType.review:
        return AppColors.primary;
      case NotifType.system:
        return AppColors.trust;
      case NotifType.promo:
        return AppColors.warning;
    }
  }
}

@immutable
class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
    this.payload = const {},
  });

  final String id;
  final NotifType type;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic> payload;

  AppNotification copyWith({
    bool? isRead,
  }) {
    return AppNotification(
      id: id,
      type: type,
      title: title,
      body: body,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
      payload: payload,
    );
  }
}
