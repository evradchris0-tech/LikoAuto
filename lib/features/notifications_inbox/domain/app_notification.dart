import 'package:flutter/material.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';

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
        return LucideIcons.messageSquare;
      case NotifType.priceDrop:
        return LucideIcons.trendingDown;
      case NotifType.appointment:
        return LucideIcons.calendarCheck;
      case NotifType.listingApproved:
        return LucideIcons.checkCircle;
      case NotifType.listingRejected:
        return LucideIcons.xCircle;
      case NotifType.review:
        return LucideIcons.star;
      case NotifType.system:
        return LucideIcons.shield;
      case NotifType.promo:
        return LucideIcons.tag;
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

  AppNotification copyWith({bool? isRead}) {
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
