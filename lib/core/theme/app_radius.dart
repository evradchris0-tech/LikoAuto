import 'package:flutter/widgets.dart';

abstract final class AppRadius {
  static const double sm = 8;
  static const double button = 12;
  static const double card = 16;
  static const double bottomSheet = 24;
  static const double pill = 999;

  static const BorderRadius rButton = BorderRadius.all(Radius.circular(button));
  static const BorderRadius rCard = BorderRadius.all(Radius.circular(card));
  static const BorderRadius rBottomSheet = BorderRadius.vertical(
    top: Radius.circular(bottomSheet),
  );
}
