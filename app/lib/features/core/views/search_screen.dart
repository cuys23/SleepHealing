import 'package:cached_network_image/cached_network_image.dart';
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
import 'package:medyo/widgets/misc_widgets.dart';

/// Local search over catalog data already fetched by Home (categories +
/// the "Most Recomanded" / time-of-day dashboard sections). No new API call
/// is made - matching and text-based only, on name and description.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';

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

    final matchedCategories =
        categories.where((c) => _matches(c.name, c.description)).toList();
    final matchedAlbums = uniqueAlbums
        .where((a) => _matches(a.name, a.description))
        .toList();

    final hasResults = matchedCategories.isNotEmpty || matchedAlbums.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.darkTeal,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('search_screen.title'.tr(),
            style: AppTextDecor.regular18White),
        leading: InkWell(
          onTap: () => context.nav.pop(),
          child: const Icon(Icons.arrow_back_rounded, color: AppColors.white),
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
                style: AppTextDecor.regular16White,
                onChanged: (value) => setState(() => _query = value.trim()),
                decoration: InputDecoration(
                  hintText: 'search_screen.hint'.tr(),
                  hintStyle: AppTextDecor.regular14lightGeay,
                  prefixIcon:
                      const Icon(Icons.search, color: AppColors.lightGeay),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: const BorderSide(color: AppColors.gray),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: const BorderSide(color: AppColors.lightGeay),
                  ),
                ),
              ),
              AppSpacerH(16.h),
              if (_query.isNotEmpty && !hasResults)
                Padding(
                  padding: EdgeInsets.only(top: 40.h),
                  child: Center(
                    child: Text('search_screen.no_results'.tr(),
                        style: AppTextDecor.regular14White),
                  ),
                ),
              Expanded(
                child: ListView(
                  children: [
                    if (matchedCategories.isNotEmpty) ...[
                      Text('menu_screen.view_all'.tr(),
                          style: AppTextDecor.bold14White),
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
                                      borderRadius: BorderRadius.circular(20.r),
                                      border: Border.all(color: AppColors.gray),
                                    ),
                                    child: Text(
                                      c.name?.toString().tr() ?? '',
                                      style: AppTextDecor.regular14White,
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                      AppSpacerH(20.h),
                    ],
                    if (matchedAlbums.isNotEmpty) ...[
                      Text('menu_screen.recommand'.tr(),
                          style: AppTextDecor.bold14White),
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
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: CachedNetworkImage(
                imageUrl: album.thumbnail ?? '',
                width: 56.w,
                height: 56.h,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Container(
                  width: 56.w,
                  height: 56.h,
                  color: AppColors.gray.withOpacity(0.2),
                ),
              ),
            ),
            AppSpacerW(12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    album.name?.toString().tr() ?? '',
                    style: AppTextDecor.regular14White,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    album.description ?? '',
                    style: AppTextDecor.regular12Gray,
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
