import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medyo/config/app_colors.dart';
import 'package:medyo/features/payment/logic/mic_controller.dart';
import 'package:medyo/features/payment/logic/paymentUrlController.dart';
import 'package:medyo/utils/context_less_nav.dart';
import 'package:medyo/utils/routes.dart';

import '../logic/payment_controller.dart';
import 'inweb_viewpayment.dart';

class OnlinePaymentMethodList extends ConsumerStatefulWidget {
  final int planId;
  const OnlinePaymentMethodList({
    super.key,
    required this.planId,
  });

  @override
  ConsumerState<OnlinePaymentMethodList> createState() =>
      _OnlinePaymentMethodListState();
}

class _OnlinePaymentMethodListState
    extends ConsumerState<OnlinePaymentMethodList> {
  int? selectedIndex;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(paymentControllerProvider.notifier).getPaymentMethods();
    });
  }

  @override
  Widget build(BuildContext context) {
    final paymentState = ref.watch(paymentControllerProvider);
    final selectedIndex = ref.watch(selectedPaymentIndexProvider);
    //final paymentUrlController = ref.watch(paymentUrlControllerProvider);
    final state = ref.watch(paymentUrlControllerProvider);

    return paymentState.when(
      data: (paymentModel) {
        final gateways = paymentModel.data?.paymentGateway ?? [];

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: gateways.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                final gateway = gateways[index];
                final isSelected = selectedIndex == index;

                return GestureDetector(
                  onTap: () {
                    // ref.read(selectedPlanIdProvider.notifier).state = plan.id;
                    ref.read(selectedPaymentIndexProvider.notifier).state =
                        index;
                    ref.read(onlinePaymentProvider.notifier).state =
                        gateway.name ?? '';

                    debugPrint("Selected: ${gateway.name}");
                  },
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.grey.shade300,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                      color: isSelected ? Colors.blue.shade50 : Colors.white,
                    ),
                    child: Row(
                      children: [
                        Image.network(
                          gateway.thumbnail ?? '',
                          width: 48.w,
                          height: 48.h,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.broken_image),
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          gateway.name ?? 'No Name',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected ? Colors.blue : Colors.black,
                          ),
                        ),
                        const Spacer(),
                        if (isSelected)
                          Icon(Icons.check_circle,
                              color: Colors.blue, size: 24.w),
                      ],
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              style: ButtonStyle(
                elevation: WidgetStateProperty.all(0),
                backgroundColor:
                    WidgetStateProperty.all(AppColors.primaryColor),
                minimumSize: WidgetStateProperty.all(
                  Size(double.infinity, 50.h),
                ),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50.r),
                  ),
                ),
              ),
              onPressed: () async {
                // final authBox = Hive.box('authBox');
                // final String? token = authBox.get(AppHSC.authToken) as String?;

                // if (token == null || token.isEmpty) {
                //   // ইউজার লগইন করেনি
                //   ScaffoldMessenger.of(context).showSnackBar(
                //     const SnackBar(content: Text("Please login to continue")),
                //   );
                //   return;
                // }
                await ref
                    .read(paymentUrlControllerProvider.notifier)
                    .fetchPaymentUrl(name: 'stripe', id: widget.planId);

                ref.read(paymentUrlControllerProvider).when(
                      data: (paymentModel) {
                        final url = paymentModel.data?.redirectUrl;

                        context.nav.pushNamedAndRemoveUntil(
                          Routes.webviewPayment,
                          (route) => false,
                          arguments: WebPaymentScreenArg(paymentUrl: url ?? ''),
                        );
                      },
                      loading: () => const CircularProgressIndicator(),
                      error: (e, st) {
                        //showToast("Error: $e");
                      },
                    );
              },
              child: const Text(
                "Pay Now",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            )
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, st) => Center(child: Text("Error: $err")),
    );
  }
}
