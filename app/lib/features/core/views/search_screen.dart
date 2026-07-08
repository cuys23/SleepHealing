import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medyo/config/app_colors.dart';
import 'package:medyo/config/app_text_decor.dart';
import 'package:medyo/features/core/logic/core_provider.dart';
import 'package:medyo/features/core/models/category_list_model/category.dart';
import 'package:medyo/features/core/models/dashboard_category_a_lbums_list/albam.dart'
    as hAlbam;
import 'package:medyo/utils/context_less_nav.dart';
import 'package:medyo/utils/dialouges.dart';
import 'package:medyo/utils/global_function.dart';
import 'package:medyo/utils/routes.dart';
import 'package:medyo/widgets/artwork_image.dart';
import 'package:medyo/widgets/misc_widgets.dart';

/// Local search over catalog data already fetched by Home (categories +
/// the "Most Recomanded" / time-of-day dashboard sections). No new API call
/// is made - matching and text-based only, on name and description.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

enum _SearchFilter { all, categories, sounds }

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';
  _SearchFilter _filter = _SearchFilter.all;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _matches(String? name, String? description) {
    if (_query.isEmpty) return true;
    final q = _query.toLowerCase();
    return (name ?? '').toLowerCase().contains(q) ||
        (description ?? '').toLowerCase().contains(q);
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriessProvider).maybeWhen(
          loaded: (data) => data.data?.category ?? <Category>[],
          orElse: () => <Category>[],
        );

    final albums = <hAlbam.Albam>[];
    ref.watch(dashboardcategoryalbumListProvider('Most Recomanded')).maybeWhen(
          loaded: (data) => albums.addAll(data.data?.albams ?? []),
          orElse: () {},
        );
    ref
        .watch(dashboardcategoryalbumListProvider(
            AppGLF.getTimeOfDay().toLowerCase()))
        .maybeWhen(
          loaded: (data) => albums.addAll(data.data?.albams ?? []),
          orElse: () {},
        );

    final seen = <int?>{};
    final uniqueAlbums = albums.where((a) => seen.add(a.id)).toList();

    final matchedCategories = _filter == _SearchFilter.sounds
        ? <Category>[]
        : categories.where((c) => _matches(c.name, c.description)).toList();
    final matchedAlbums = _filter == _SearchFilter.categories
        ? <hAlbam.Albam>[]
        : uniqueAlbums.where((a) => _matches(a.name, a.description)).toList();

    final hasResults = matchedCategories.isNotEmpty || matchedAlbums.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.darkTeal,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('search_screen.title'.tr(),
            style: AppTextDecor.heading3_17),
        leading: InkWell(
          onTap: () => context.nav.pop(),
          child: const Icon(Icons.arrow_back_rounded,
              color: AppColors.textPrimary),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _controller,
                autofocus: true,
                style: AppTextDecor.bodyTitle16,
                onChanged: (value) => setState(() => _query = value.trim()),
                decoration: InputDecoration(
                  hintText: 'search_screen.hint'.tr(),
                  hintStyle: AppTextDecor.caption13
                      .copyWith(color: AppColors.textTertiary),
                  prefixIcon:
                      const Icon(Icons.search, color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.inputBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide:
                        const BorderSide(color: AppColors.accentPrimary),
                  ),
                ),
              ),
              AppSpacerH(14.h),
              Row(
                children: [
                  _FilterChip(
                    label: 'search_screen.filter_all'.tr(),
                    selected: _filter == _SearchFilter.all,
                    onTap: () => setState(() => _filter = _SearchFilter.all),
                  ),
                  AppSpacerW(8.w),
                  _FilterChip(
                    label: 'search_screen.filter_categories'.tr(),
                    selected: _filter == _SearchFilter.categories,
                    onTap: () =>
                        setState(() => _filter = _SearchFilter.categories),
                  ),
                  AppSpacerW(8.w),
                  _FilterChip(
                    label: 'search_screen.filter_sounds'.tr(),
                    selected: _filter == _SearchFilter.sounds,
                    onTap: () =>
                        setState(() => _filter = _SearchFilter.sounds),
                  ),
                ],
              ),
              AppSpacerH(16.h),
              if (_query.isNotEmpty && !hasResults)
                Padding(
                  padding: EdgeInsets.only(top: 40.h),
                  child: Center(
                    child: Text('search_screen.no_results'.tr(),
                        style: AppTextDecor.caption13Muted),
                  ),
                ),
              Expanded(
                child: ListView(
                  children: [
                    if (matchedCategories.isNotEmpty) ...[
                      Text('menu_screen.view_all'.tr(),
                          style: AppTextDecor.heading3_17),
                      AppSpacerH(8.h),
                      Wrap(
                        spacing: 10.w,
                        runSpacing: 10.h,
                        children: matchedCategories
                            .map((c) => GestureDetector(
                                  onTap: () => context.nav.pushNamed(
                                      Routes.subCategoryScreen,
                                      arguments: c),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 14.w, vertical: 10.h),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12.r),
                                      color: AppColors.surface,
                                    ),
                                    child: Text(
                                      c.name?.toString().tr() ?? '',
                                      style: AppTextDecor.bodyTitle15,
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                      AppSpacerH(20.h),
                    ],
                    if (matchedAlbums.isNotEmpty) ...[
                      Text('menu_screen.recommand'.tr(),
                          style: AppTextDecor.heading3_17),
                      AppSpacerH(8.h),
                      ...matchedAlbums.map((a) => _SearchAlbumTile(album: a)),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          color: selected
              ? AppColors.accentPrimary.withOpacity(0.15)
              : Colors.white.withOpacity(0.04),
        ),
        child: Text(
          label,
          style: AppTextDecor.tagBadge11.copyWith(
            color: selected ? AppColors.textSecondary : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

class _SearchAlbumTile extends ConsumerWidget {
  const _SearchAlbumTile({required this.album});
  final hAlbam.Albam album;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPaid = album.isPaid ?? false;
    return GestureDetector(
      onTap: () {
        if (isPaid) {
          showPremiumDialouge(context);
        } else {
          ref.read(selectedDatumProvider.notifier).state = album;
          ref.read(selectedMusicProvider.notifier).state = "Home";
          context.nav.pushNamed(Routes.playerScreen);
        }
      },
      child: Padding(
        padding: EdgeInsets.only(bottom: 10.h),
        child: Row(
          children: [
            ArtworkImage(
              imageUrl: album.thumbnail,
              width: 56.w,
              height: 56.h,
              borderRadius: BorderRadius.circular(10.r),
            ),
            AppSpacerW(12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    album.name?.toString().tr() ?? '',
                    style: AppTextDecor.bodyTitle15,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    album.description ?? '',
                    style: AppTextDecor.caption13Muted,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
