import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medyo/features/core/logic/core_provider.dart';
import 'package:medyo/features/core/views/menu_page.dart' show AllCatagoriesCard;
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
  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
        child: Stack(children: [
      SizedBox(
          height: 844.h,
          width: 390.w,
          child: Column(children: [
            RegularAppBar(title: 'all_categories_screen.title'.tr()),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: ref.watch(categoriessProvider).map(
                    initial: (_) => const LoadingWidget(),
                    loading: (_) => const LoadingWidget(),
                    loaded: (_) {
                      if (_.data.data?.category?.isNotEmpty == true) {
                        final categories = _.data.data!.category!;
                        return GridView.builder(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10.w,
                            mainAxisSpacing: 10.h,
                            childAspectRatio: 104 / 96,
                          ),
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            return AllCatagoriesCard(
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
