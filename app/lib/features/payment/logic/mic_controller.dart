import 'package:flutter_riverpod/flutter_riverpod.dart';

final onlinePaymentProvider = StateProvider<String>((ref) {
  return '';
});

final selectedPaymentIndexProvider = StateProvider<int?>((ref) => null);

final selectedPlanIdProvider = StateProvider<int?>((ref) => null);
