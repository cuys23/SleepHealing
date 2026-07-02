import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medyo/features/core/models/payment/paymnet_url_model.dart';
import 'package:medyo/features/payment/logic/getUrlservice.dart';

// Payment Controller with AsyncValue state
final paymentUrlControllerProvider =
    StateNotifierProvider<PaymentController, AsyncValue<PaymentUrlModel>>(
  (ref) => PaymentController(ref),
);

class PaymentController extends StateNotifier<AsyncValue<PaymentUrlModel>> {
  final Ref ref;

  PaymentController(this.ref) : super(AsyncValue.data(PaymentUrlModel()));

  Future<void> fetchPaymentUrl({required String name, required int id}) async {
    state = const AsyncValue.loading();

    try {
      final response = await ref
          .read(paymentUrlServiceProvider)
          .getPaymentMethodUrl(name: name, id: id);
      print('API Response: ${response.data}');

      final data = PaymentUrlModel.fromJson(response.data);
      print('Redirect URL: ${data.data?.redirectUrl}');

      state = AsyncValue.data(data);
    } catch (e, st) {
      print('Payment URL fetch error: $e');
      state = AsyncValue.error(e, st);
      print("hfjgfj$st");
    }
  }
}
