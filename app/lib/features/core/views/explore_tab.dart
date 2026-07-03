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
import 'package:medyo/widgets/collection/collection_carousel.dart';
import 'package:medyo/widgets/collection/collection_data.dart';
import 'package:medyo/widgets/misc_widgets.dart';

class ExploreTab extends ConsumerStatefulWidget {
  const ExploreTab({super.key});

  @override
  ConsumerState<ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends ConsumerState<ExploreTab> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgPrimary,
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('explore_screen.title'.tr(),
                  style: AppTextDecor.largeTitle28),
              AppSpacerH(16.h),
              _SearchBar(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value.trim()),
                onClear: () => setState(() {
                  _searchController.clear();
                  _query = '';
                }),
              ),
              AppSpacerH(24.h),
              if (_query.isEmpty) ...[
                Text('explore_screen.featured'.tr(),
                    style: AppTextDecor.sectionHeader20),
                AppSpacerH(12.h),
                CollectionCarousel(collections: kFeaturedCollections),
                AppSpacerH(24.h),
                Text('explore_screen.collections'.tr(),
                    style: AppTextDecor.sectionHeader20),
                AppSpacerH(12.h),
                const _CollectionsGrid(),
                AppSpacerH(24.h),
              ] else ...[
                _SearchResults(query: _query),
                AppSpacerH(24.h),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar(
      {required this.controller,
      required this.onChanged,
      required this.onClear});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppColors.inputBg,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: AppColors.textTertiary, size: 20.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style:
                  AppTextDecor.caption13.copyWith(color: AppColors.textPrimary),
              cursorColor: AppColors.accentPrimary,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'explore_screen.search_hint'.tr(),
                hintStyle: AppTextDecor.caption13
                    .copyWith(color: AppColors.textTertiary),
              ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              if (value.text.isEmpty) return const SizedBox();
              return GestureDetector(
                onTap: onClear,
                child: Icon(Icons.close,
                    color: AppColors.textTertiary, size: 18.sp),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SearchResults extends ConsumerWidget {
  const _SearchResults({required this.query});
  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(categoriessProvider).map(
          initial: (_) => const LoadingWidget(),
          loading: (_) => const LoadingWidget(),
          loaded: (state) {
            final categories = state.data.data?.category ?? [];
            final q = query.toLowerCase();
            final results = categories
                .where((c) => (c.name ?? '').toLowerCase().contains(q))
                .toList();
            if (results.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 40.h),
                child: Center(
                  child: Text(
                    'explore_screen.no_results'.tr(),
                    style: AppTextDecor.caption13,
                  ),
                ),
              );
            }
            return Column(
              children: [
                for (final category in results) ...[
                  _SearchResultRow(
                    category: category,
                    onTap: () {
                      context.nav.pushNamed(
                        Routes.subCategoryScreen,
                        arguments: category,
                      );
                    },
                  ),
                  AppSpacerH(10.h),
                ],
              ],
            );
          },
          error: (_) => const SizedBox(),
        );
  }
}

class _SearchResultRow extends StatelessWidget {
  const _SearchResultRow({required this.category, required this.onTap});
  final Category category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final name = category.name?.toString() ?? '';
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
              width: 44.w,
              height: 44.h,
              decoration: BoxDecoration(
                color: tint.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              child: category.icon != null
                  ? Padding(
                      padding: EdgeInsets.all(10.w),
                      child: Image.network(category.icon.toString()),
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

class _CollectionsGrid extends ConsumerWidget {
  const _CollectionsGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(categoriessProvider).map(
          initial: (_) => const LoadingWidget(),
          loading: (_) => const LoadingWidget(),
          loaded: (state) {
            final categories = state.data.data?.category ?? [];
            if (categories.isEmpty) return const SizedBox();
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 10.w,
              mainAxisSpacing: 10.h,
              childAspectRatio: 1.5,
              children: categories
                  .map((category) => _CollectionCard(
                        category: category,
                        onTap: () {
                          context.nav.pushNamed(
                            Routes.subCategoryScreen,
                            arguments: category,
                          );
                        },
                      ))
                  .toList(),
            );
          },
          error: (_) => const SizedBox(),
        );
  }
}

class _CollectionCard extends StatelessWidget {
  const _CollectionCard({required this.category, required this.onTap});

  final Category category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final name = category.name?.toString() ?? '';
    final color = AppColors.categoryColor(name);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 44.w,
              height: 44.h,
              decoration: BoxDecoration(
                color: color.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              child: category.icon != null
                  ? Padding(
                      padding: EdgeInsets.all(10.w),
                      child: Image.network(category.icon.toString()),
                    )
                  : Icon(Icons.spa_outlined, color: color),
            ),
            SizedBox(height: 10.h),
            Text(
              name.isEmpty ? 'Chill' : name.tr(),
              style: AppTextDecor.bodyTitle15,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
