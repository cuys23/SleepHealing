import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/logic/app_config_provider.dart';

final paymentUrlServiceProvider = Provider((ref) => PaymentServices(ref));

abstract class PaymentRepository {
  Future<Response> getPaymentMethodUrl({required String name, required int id});
}

class PaymentServices implements PaymentRepository {
  final Ref ref;
  PaymentServices(this.ref);

  @override
  Future<Response> getPaymentMethodUrl(
      {required String name, required int id}) {
    final response = ref.read(dioProvider).post(
      '/buy/subscription',
      options: Options(headers: {'Accept': 'application/json'}),
      data: {'payment_method': name, 'plan_id': id},
    );

    return response;
  }
}
