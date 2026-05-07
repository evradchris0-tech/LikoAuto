import 'package:flutter_riverpod/flutter_riverpod.dart';

final sellStepProvider = StateProvider<int>((ref) => 1);
final sellTotalStepsProvider = Provider<int>((ref) => 5);
