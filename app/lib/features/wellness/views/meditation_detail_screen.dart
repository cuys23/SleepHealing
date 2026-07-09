import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medyo/config/app_colors.dart';
import 'package:medyo/config/app_text_decor.dart';
import 'package:medyo/features/core/logic/core_provider.dart';
import 'package:medyo/features/core/models/album_list_model/albam.dart';
import 'package:medyo/utils/context_less_nav.dart';
import 'package:medyo/utils/dialouges.dart';
import 'package:medyo/utils/routes.dart';
import 'package:medyo/widgets/artwork_image.dart';
import 'package:medyo/widgets/buttons/full_width_button.dart';
import 'package:medyo/widgets/misc_widgets.dart';

/// Design 16 - only reachable from the real-data branch of MeditationScreen
/// (Phase 7C). Shows only fields the existing Albam model actually has
/// (name/description/thumbnail/isPaid) - no fabricated duration or Benefits
/// bullet list, since neither exists as real data on an album today.
class MeditationDetailScreen extends ConsumerWidget {
  const MeditationDetailScreen({super.key, required this.album});

  final Albam album;

  void _start(BuildContext context, WidgetRef ref) {
    if (album.isPaid == true) {
      showPremiumDialouge(context);
      return;
    }
    ref.read(selectedAlbumProvider.notifier).state = album;
    ref.read(selectedMusicProvider.notifier).state = "Sub";
    context.nav.pushNamed(Routes.playerScreen);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.bgAlt,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSpacerH(8.h),
              GestureDetector(
                onTap: () => context.nav.pop(),
                child: Icon(Icons.arrow_back_ios_new,
                    size: 16.sp, color: AppColors.textPrimary),
              ),
              AppSpacerH(16.h),
              Expanded(
                child: ListView(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20.r),
                      child: ArtworkImage(
                        imageUrl: album.thumbnail,
                        width: double.infinity,
                        height: 200.h,
                        borderRadius: BorderRadius.zero,
                        category: album.name,
                      ),
                    ),
                    AppSpacerH(16.h),
                    Text(
                      (album.name ?? '').tr(),
                      style: AppTextDecor.heading2_22,
                    ),
                    if ((album.description ?? '').isNotEmpty) ...[
                      AppSpacerH(16.h),
                      Text('meditation_detail_screen.about'.tr(),
                          style: AppTextDecor.heading3_17),
                      AppSpacerH(6.h),
                      Text(
                        album.description!,
                        style: AppTextDecor.caption13Muted,
                      ),
                    ],
                    AppSpacerH(24.h),
                  ],
                ),
              ),
              AppTextButton(
                title: album.isPaid == true
                    ? 'meditation_detail_screen.unlock'.tr()
                    : 'meditation_detail_screen.start'.tr(),
                onTap: () => _start(context, ref),
              ),
              AppSpacerH(16.h),
            ],
          ),
        ),
      ),
    );
  }
}
