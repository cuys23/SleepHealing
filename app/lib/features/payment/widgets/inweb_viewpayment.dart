// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medyo/utils/routes.dart';

import 'custom_dialog.dart';

class WebPayementScreen extends ConsumerStatefulWidget {
  final WebPaymentScreenArg webPaymentScreenAr;
  const WebPayementScreen({
    super.key,
    required this.webPaymentScreenAr,
    // required String redirectUrl,
  });

  @override
  ConsumerState<WebPayementScreen> createState() => _WebPayementScreenState();
}

class _WebPayementScreenState extends ConsumerState<WebPayementScreen> {
  late InAppWebViewController _webViewController;
  bool _isLoading = true;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: PopScope(
        onPopInvokedWithResult: (didPop, result) async {
          log("----------------$didPop, $result");
          Navigator.of(context).pushNamedAndRemoveUntil(
            Routes.homeScreen,
            (route) => false,
          );
        },
        canPop: false,
        child: Scaffold(
          // appBar: AppBar(
          //   leading: IconButton(
          //     onPressed: () {
          //       Navigator.of(context).pop();
          //     },
          //     icon: const Icon(Icons.arrow_back),
          //   ),
          // ),
          body: Stack(
            children: [
              InAppWebView(
                initialUrlRequest: URLRequest(
                    url: WebUri(widget.webPaymentScreenAr.paymentUrl)),
                onWebViewCreated: (controller) {
                  _webViewController = controller;
                },
                onLoadStart: (controller, url) async {
                  print('Load start $url');

                  String onLoadUrl = url.toString();
                  if (onLoadUrl.trim().contains('payment/success/response')) {
                    _buildRouting();

                    _buildPaymentDoneDialog(context);
                  } else if (onLoadUrl.toString().contains('payment/fail')) {
                    _buildRouting();
                    _buildPaymentFailedDialog(context);
                  } else if (onLoadUrl.toString().contains('payment/cancel')) {
                    _buildRouting();
                    _buildPaymentFailedDialog(context);
                  } else {}
                  setState(() {
                    _isLoading = true;
                  });
                },
                onLoadStop: (controller, url) {
                  setState(() {
                    _isLoading = false;
                  });
                },
              ),
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  _buildRouting() {
    Navigator.of(context).pushNamed(Routes.homeScreen);
  }

  _buildPaymentDoneDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => CustomDialog(
        title: 'Payment Success',
        des:
            'Your payment has been processed successfully. Thank you for your purchase.',
        assetName: 'assets/svgs/done_icon.svg',
        buttonText: 'close',
        callback: () {
          Navigator.of(context).pop();
          //ContextLess.context.nav.pop();
        },
      ),
    );
  }

  _buildPaymentFailedDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => CustomDialog(
        title: 'Payment Failed',
        des:
            '😞 Oops!Something went wrong with your payment. Please check your details and try again.',
        assetName: 'assets/svgs/cancel_icon.svg',
        buttonText: 'close',
        callback: () {
          Navigator.of(context).pop();
          //ContextLess.context.nav.pop();
        },
      ),
    );
  }
}

class WebPaymentScreenArg {
  final int? orderId;
  final String paymentUrl;
  WebPaymentScreenArg({
    this.orderId,
    required this.paymentUrl,
  });
}
