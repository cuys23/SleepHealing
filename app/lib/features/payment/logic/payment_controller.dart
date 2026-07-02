import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medyo/features/core/models/payment/payment_model.dart';

import 'payment_services.dart';

final paymentControllerProvider =
    StateNotifierProvider<PaymentController, AsyncValue<PaymentModel>>(
  (ref) => PaymentController(ref),
);

class PaymentController extends StateNotifier<AsyncValue<PaymentModel>> {
  final Ref ref;

  PaymentController(this.ref) : super(const AsyncLoading()) {
    getPaymentMethods();
  }

  Future<void> getPaymentMethods() async {
    try {
      final response = await ref.read(paymentServiceProvider).getPaymentList();

      if (response.statusCode == 200) {
        final paymentData = PaymentModel.fromJson(response.data);
        print(paymentData);
        state = AsyncData(paymentData);
      } else {
        state =
            AsyncError("Failed to fetch payment methods", StackTrace.current);
      }
    } catch (e, st) {
      state = AsyncError(e.toString(), st);
    }
  }
}
