import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/logic/app_config_provider.dart';

final paymentServiceProvider = Provider((ref) => PaymentService(ref));

abstract class PaymentRepository {
  Future<Response> getPaymentList();
  //Future<Response> getPaymentMethodUrl({required String name, required int id});
}

class PaymentService implements PaymentRepository {
  final Ref ref;
  PaymentService(this.ref);
  @override
  Future<Response> getPaymentList() async {
    final response = await ref.read(dioProvider).get(
          '/v2/config',
        );
    return response;
  }

  // @override
  // Future<Response> getPaymentMethodUrl(
  //     {required String name, required int id}) {
  //   final response = ref.read(dioProvider).post(
  //     '/buy/subscription',
  //     data: {'payment_method': name, 'plan_id': id},
  //   );

  //   return response;
  // }
}
