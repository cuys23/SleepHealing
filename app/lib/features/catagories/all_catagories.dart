import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medyo/config/app_colors.dart';
import 'package:medyo/config/app_text_decor.dart';
import 'package:medyo/features/core/logic/core_provider.dart';
import 'package:medyo/features/core/models/category_list_model/category.dart';
import 'package:medyo/utils/context_less_nav.dart';
import 'package:medyo/utils/routes.dart';
import 'package:medyo/widgets/misc_widgets.dart';
import 'package:medyo/widgets/regular_app_bar.dart';
import 'package:medyo/widgets/screen_wrapper.dart';

class AllCatagoriesScreen extends ConsumerStatefulWidget {
  const AllCatagoriesScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AllCatagoriesScreenState();
}

class _AllCatagoriesScreenState extends ConsumerState<AllCatagoriesScreen> {
  List<String> images = [
    "assets/images/home_sgstn_tile_3.png",
    "assets/images/home_sgstn_tile_2.png",
    "assets/images/home_sgstn_tile_1.png",
    "assets/images/home_sgstn_tile_3.png",
    "assets/images/home_sgstn_tile_2.png",
    "assets/images/home_sgstn_tile_1.png",
    "assets/images/home_sgstn_tile_3.png",
    "assets/images/home_sgstn_tile_2.png",
    "assets/images/home_sgstn_tile_1.png",
  ];
  List<String> types = [
    "Empower",
    "Chill-Out",
    "Sleep",
    "Empower",
    "Chill-Out",
    "Sleep",
    "Empower",
    "Chill-Out",
    "Sleep",
  ];
  List<int> tiles = [1, 2, 3, 4, 5, 6, 7, 8];
  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
        child: Stack(children: [
      SizedBox(
          height: 844.h,
          width: 390.w,
          child: Column(children: [
            const RegularAppBar(title: 'All Meditations'),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: ref.watch(categoriessProvider).map(
                    initial: (_) => const LoadingWidget(),
                    loading: (_) => const LoadingWidget(),
                    loaded: (_) {
                      if (_.data.data?.category?.isNotEmpty == true) {
                        final categories = _.data.data!.category!;
                        return ListView.separated(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          itemCount: categories.length,
                          separatorBuilder: (context, index) =>
                              AppSpacerH(12.h),
                          itemBuilder: (context, index) {
                            return CategoryListRow(
                              data: categories[index],
                              onTap: () {
                                context.nav.pushNamed(
                                    Routes.subCategoryScreen,
                                    arguments: categories[index]);
                              },
                            );
                          },
                        );
                      } else {
                        return const Center(
                          child: Text('No Data'),
                        );
                      }
                    },
                    error: (_) => ErrorTextWidget(error: _.error)),
              ),
            )
          ]))
    ]));
  }
}

class CategoryListRow extends StatelessWidget {
  const CategoryListRow({super.key, required this.data, this.onTap});
  final Category data;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final name = data.name?.toString() ?? '';
    final tint = AppColors.categoryColor(name);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          children: [
            Container(
              width: 52.w,
              height: 52.h,
              decoration: BoxDecoration(
                color: tint.withOpacity(0.18),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: data.icon != null
                  ? Padding(
                      padding: EdgeInsets.all(12.w),
                      child: Image.network(
                        data.icon.toString(),
                        fit: BoxFit.contain,
                      ),
                    )
                  : Icon(Icons.spa_outlined, color: tint),
            ),
            AppSpacerW(12.w),
            Expanded(
              child: Text(
                name.isEmpty ? 'Chill' : name.tr(),
                style: AppTextDecor.bodyTitle15,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.chevron_right,
                color: AppColors.textTertiary, size: 20.sp),
          ],
        ),
      ),
    );
  }
}
