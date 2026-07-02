import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:medyo/config/app_colors.dart';
import 'package:medyo/config/app_text_decor.dart';
import 'package:medyo/features/core/logic/core_provider.dart';
import 'package:medyo/utils/context_less_nav.dart';
import 'package:medyo/utils/routes.dart';
import 'package:medyo/widgets/buttons/full_width_button.dart';
import 'package:medyo/widgets/misc_widgets.dart';
import 'package:medyo/widgets/regular_app_bar.dart';
import 'package:medyo/widgets/screen_wrapper.dart';

import '../../../config/hive_contants.dart';
import '../../payment/widgets/onlinepaymen_list.dart';

class PremiumSubScreen extends ConsumerStatefulWidget {
  const PremiumSubScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PremiumSubScreenState();
}

class _PremiumSubScreenState extends ConsumerState<PremiumSubScreen> {
  bool allowClick = true;

  @override
  Widget build(BuildContext context) {
    final authbox = Hive.box(AppHSC.authBox);
    return ScreenWrapper(
        child: SingleChildScrollView(
      child: Column(
        children: [
          const RegularAppBar(
            title: "Become Premium Member",
          ),
          // AppSpacerH(20.h),
          ref.watch(allPremiumsProvider).map(
              initial: (_) => const LoadingWidget(),
              loading: (_) => const LoadingWidget(),
              loaded: (_) {
                if (_.data.data?.plans?.isNotEmpty == true) {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _.data.data!.plans!.length,
                    // scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      final data = _.data.data!.plans![index];
                      return Container(
                        height: 430.h,
                        width: 220.w,
                        padding: EdgeInsets.all(16.r),
                        margin: EdgeInsets.all(16.r),
                        decoration: BoxDecoration(
                          color: AppColors.slidePanel,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              data.name ?? '',
                              style: AppTextDecor.bold20White,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            AppSpacerH(24.h),
                            ...data.features!.map((e) => Column(
                                  children: [
                                    PremiumCardTile(
                                      title: e,
                                    ),
                                    AppSpacerH(16.h),
                                  ],
                                )),
                            const Expanded(child: SizedBox()),
                            const HorizontalDivider(),
                            AppSpacerH(10.h),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '\$${data.amount.toString()}',
                                  style: AppTextDecor.bold24White,
                                ),
                                AppSpacerW(4.w),
                                Text(
                                  'for ${data.duration}',
                                  style: AppTextDecor.regular12White,
                                ),
                              ],
                            ),
                            AppSpacerH(10.h),
                            AppTextButton(
                              onTap: () {
                                // user login check this use function
                                final isLoggedIn =
                                    authbox.get(AppHSC.authToken) != null;

                                if (!isLoggedIn) {
                                  // Navigate to login screen
                                  context.nav.pushNamed(Routes
                                      .loginScreen); // or use pushReplacement if needed
                                  return;
                                }

                                showModalBottomSheet(
                                  context: context,
                                  backgroundColor: AppColors.slidePanel,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(16.r)),
                                  ),
                                  builder: (context) {
                                    return Padding(
                                      padding: EdgeInsets.all(16.r),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text("Select Payment Method",
                                              style: AppTextDecor.bold16White),
                                          SizedBox(height: 16.h),
                                          _PaymentMethodContainer(
                                            ontap: () {
                                              Navigator.of(context)
                                                  .pop(); // Optional: if previous bottom sheet is open
                                              Future.delayed(
                                                  const Duration(
                                                      milliseconds: 200), () {
                                                showModalBottomSheet(
                                                  context: context,
                                                  isScrollControlled: true,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.vertical(
                                                            top:
                                                                Radius.circular(
                                                                    16.r)),
                                                  ),
                                                  builder: (_) => Padding(
                                                    padding:
                                                        EdgeInsets.all(16.r),
                                                    child:
                                                        OnlinePaymentMethodList(
                                                      planId: data.id!,
                                                    ),
                                                  ),
                                                );
                                              });
                                              print(
                                                  "Selected Online - planId: ${data.id}");

                                              print("Selected Online");
                                            },
                                            icon:
                                                "assets/images/online_payment_icon.png",
                                            isselected: false,
                                            type: 'Online',
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                              title: 'Get Premium',
                              height: 39.h,
                            )
                          ],
                        ),
                      );
                    },
                  );
                } else {
                  return const MessageTextWidget(msg: "No Plans Found");
                }
              },
              error: (_) => ErrorTextWidget(error: _.error)),
          AppSpacerH(32.h),
        ],
      ),
    ));
  }
}

class PremiumReviewTile extends StatelessWidget {
  const PremiumReviewTile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: AppColors.darkTeal,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(24.r),
                  child: CachedNetworkImage(
                    imageUrl: '',
                    height: 48.h,
                    width: 48.h,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) =>
                        Image.asset('assets/images/cdlabel.png'),
                  ),
                ),
                AppSpacerW(16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mamun Mia',
                        style: AppTextDecor.bold16White,
                      ),
                      Text(
                        '12 Nov, 2022',
                        style: AppTextDecor.bold14White
                            .copyWith(color: AppColors.white.withOpacity(0.5)),
                      )
                    ],
                  ),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      color: Colors.yellow,
                      size: 14,
                    ),
                    const AppSpacerW(5),
                    Text(
                      '5/5',
                      style: AppTextDecor.bold16White,
                    )
                  ],
                )
              ],
            ),
            const AppSpacerH(13.5),
            Text(
              'I had very good experience with them, responsible, friendly and helpful. I recommend',
              style: AppTextDecor.regular14White,
            )
          ],
        ),
      ),
    );
  }
}

class PremiumCardTile extends StatelessWidget {
  const PremiumCardTile({super.key, this.isGiven = true, required this.title});
  final bool isGiven;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset(
          isGiven
              ? 'assets/svgs/app_premium_tick.svg'
              : 'assets/svgs/app_premium_tick.svg',
          height: 16.h,
          width: 16.h,
        ),
        AppSpacerW(12.w),
        Expanded(child: Text(title, style: AppTextDecor.regular14White))
      ],
    );
  }
}

// paymnet method con tainer
class _PaymentMethodContainer extends StatelessWidget {
  const _PaymentMethodContainer({
    required this.icon,
    required this.type,
    required this.isselected,
    this.ontap,
  });
  final String icon;
  final String type;
  final bool isselected;
  final Function()? ontap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontap,
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          // color: context.isDarkMode ? AppColor.cardBlackBg : Colors.white,
          border: Border.all(color: AppColors.buttonBorder, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 12.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset(
                    icon,
                    width: 48.w,
                    height: 48.h,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(
                    height: 8.h,
                  ),
                  Text(
                    type,
                    style: AppTextDecor.bold14White,
                  ),
                ],
              ),
              Container(
                width: 20.w,
                height: 20.h,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isselected ? AppColors.primaryColor : Colors.grey,
                    width: 3,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 8.w,
                    height: 8.h,
                    decoration: BoxDecoration(
                      color: isselected ? AppColors.primaryColor : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
