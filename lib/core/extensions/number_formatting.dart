import 'package:intl/intl.dart';
import 'package:liko_auto/core/constants/app_constants.dart';

extension PriceFormatting on num {
  /// Formate un montant en FCFA avec espaces (ex : 8 500 000 FCFA).
  String toFcfa() {
    final formatter = NumberFormat.decimalPattern('fr_FR');
    return '${formatter.format(this)} ${AppConstants.currency}';
  }

  /// Formate sans devise (ex : 8 500 000).
  String toGroupedString() => NumberFormat.decimalPattern('fr_FR').format(this);
}
