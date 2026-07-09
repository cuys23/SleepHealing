import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medyo/config/app_colors.dart';
import 'package:medyo/config/app_text_decor.dart';
import 'package:medyo/features/core/logic/core_provider.dart';
import 'package:medyo/features/core/models/album_list_model/albam.dart';
import 'package:medyo/features/core/models/category_list_model/category.dart';
import 'package:medyo/features/wellness/mock/meditation_mock_data.dart';
import 'package:medyo/utils/context_less_nav.dart';
import 'package:medyo/utils/routes.dart';
import 'package:medyo/widgets/artwork_image.dart';
import 'package:medyo/widgets/chips/app_chip.dart';
import 'package:medyo/widgets/misc_widgets.dart';
import 'package:medyo/widgets/progress/circular_progress_ring.dart';

/// Guided Meditation hybrid (design 15/16): if the catalog has a real
/// "meditation"-like category, show a real browse list (hero + albums,
/// structurally mirroring Collection Detail) backed by
/// categoriessProvider/albumsProvider. Otherwise fall back to today's
/// standalone timer, unchanged in substance - only the session
/// title/benefits copy is placeholder content (see meditation_mock_data.dart
/// TODO), since there is no dedicated meditation-session content type in
/// the catalog yet.
class MeditationScreen extends ConsumerWidget {
  const MeditationScreen({super.key});

  Category? _findMeditationCategory(WidgetRef ref) {
    return ref.watch(categoriessProvider).maybeWhen(
          loaded: (data) {
            final categories = data.data?.category ?? <Category>[];
            for (final c in categories) {
              if ((c.name ?? '').toLowerCase().contains('meditat')) return c;
            }
            return null;
          },
          orElse: () => null,
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meditationCategory = _findMeditationCategory(ref);

    return Scaffold(
      backgroundColor: AppColors.bgAlt,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              AppSpacerH(8.h),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => context.nav.pop(),
                    child: Icon(Icons.arrow_back_ios_new,
                        size: 16.sp, color: AppColors.textPrimary),
                  ),
                  AppSpacerW(10.w),
                  Text('meditation_screen.title'.tr(),
                      style: AppTextDecor.bodyTitle16),
                ],
              ),
              Expanded(
                child: meditationCategory != null
                    ? _GuidedMeditationBrowse(category: meditationCategory)
                    : const _MeditationTimerView(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Real-data branch: hero (category thumbnail/name/description, all
/// existing fields) + a vertical list of the category's albums
/// (albumsProvider - the same provider Collection Detail uses). Tapping an
/// album opens the new MeditationDetailScreen rather than jumping straight
/// to Player, since design 16 is a distinct About/Start Meditation screen.
class _GuidedMeditationBrowse extends ConsumerWidget {
  const _GuidedMeditationBrowse({required this.category});
  final Category category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(albumsProvider(category.id.toString())).map(
          initial: (_) => const Center(child: LoadingWidget()),
          loading: (_) => const Center(child: LoadingWidget()),
          error: (_) => Center(child: ErrorTextWidget(error: _.error)),
          loaded: (state) {
            final albums = state.data.data?.albams ?? <Albam>[];
            return ListView(
              padding: EdgeInsets.only(top: 16.h, bottom: 24.h),
              children: [
                Text('meditation_screen.take_a_moment'.tr(),
                    style: AppTextDecor.caption13Muted),
                AppSpacerH(16.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20.r),
                  child: SizedBox(
                    width: double.infinity,
                    height: 140.h,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ArtworkImage(
                          imageUrl: category.thumbnail,
                          width: double.infinity,
                          height: 140.h,
                          borderRadius: BorderRadius.zero,
                          category: category.name,
                        ),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.bgPrimary.withOpacity(0.8),
                                AppColors.bgPrimary.withOpacity(0.1),
                              ],
                              begin: Alignment.bottomLeft,
                              end: Alignment.topRight,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 14.w,
                          right: 14.w,
                          bottom: 12.h,
                          child: Text(
                            (category.name ?? '').tr(),
                            style: AppTextDecor.heading3_17,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                AppSpacerH(20.h),
                Text('meditation_screen.popular'.tr(),
                    style: AppTextDecor.heading3_17),
                AppSpacerH(10.h),
                for (final album in albums) ...[
                  _MeditationAlbumRow(album: album),
                  AppSpacerH(10.h),
                ],
              ],
            );
          },
        );
  }
}

class _MeditationAlbumRow extends StatelessWidget {
  const _MeditationAlbumRow({required this.album});
  final Albam album;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.nav
          .pushNamed(Routes.meditationDetailScreen, arguments: album),
      child: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          children: [
            ArtworkImage(
              imageUrl: album.thumbnail,
              width: 48.w,
              height: 48.w,
              borderRadius: BorderRadius.circular(10.r),
              category: album.name,
            ),
            AppSpacerW(12.w),
            Expanded(
              child: Text(
                (album.name ?? '').tr(),
                style: AppTextDecor.bodyTitle15,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              album.isPaid == true
                  ? Icons.lock_outline
                  : Icons.play_circle_outline,
              color: AppColors.textMuted,
              size: 22.h,
            ),
          ],
        ),
      ),
    );
  }
}

/// Today's standalone timer, unchanged in substance from before this phase -
/// only extracted into its own widget so MeditationScreen can branch onto it.
class _MeditationTimerView extends StatefulWidget {
  const _MeditationTimerView();

  @override
  State<_MeditationTimerView> createState() => _MeditationTimerViewState();
}

class _MeditationTimerViewState extends State<_MeditationTimerView> {
  int _selectedMinutes = 15;
  late Duration _remaining = Duration(minutes: _selectedMinutes);
  Timer? _timer;
  bool _running = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _selectDuration(int minutes) {
    _timer?.cancel();
    setState(() {
      _selectedMinutes = minutes;
      _remaining = Duration(minutes: minutes);
      _running = false;
    });
  }

  void _toggle() {
    if (_running) {
      _timer?.cancel();
      setState(() => _running = false);
      return;
    }
    setState(() => _running = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remaining.inSeconds <= 1) {
        timer.cancel();
        setState(() {
          _remaining = Duration.zero;
          _running = false;
        });
        return;
      }
      setState(() => _remaining -= const Duration(seconds: 1));
    });
  }

  @override
  Widget build(BuildContext context) {
    final total = Duration(minutes: _selectedMinutes).inSeconds;
    final progress = total == 0 ? 0.0 : 1 - (_remaining.inSeconds / total);
    final minutes = _remaining.inMinutes.toString().padLeft(2, '0');
    final seconds = (_remaining.inSeconds % 60).toString().padLeft(2, '0');

    return Column(
      children: [
        const Spacer(),
        CircularProgressRing(
          progress: progress,
          size: 200.w,
          strokeWidth: 6,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$minutes:$seconds',
                  style: AppTextDecor.heading1_30.copyWith(fontSize: 32.sp)),
              Text('meditation_screen.remaining'.tr(),
                  style: AppTextDecor.caption13Muted),
            ],
          ),
        ),
        AppSpacerH(24.h),
        Text(meditationSessionTitleKey.tr(), style: AppTextDecor.heading3_17),
        AppSpacerH(4.h),
        Text(meditationSessionSubtitleKey.tr(),
            style: AppTextDecor.caption13Muted),
        AppSpacerH(20.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: meditationDurationsMinutes
              .map((m) => Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: AppChip(
                      label: '$m ${'player_screen.minutes'.tr()}',
                      selected: _selectedMinutes == m,
                      onTap: () => _selectDuration(m),
                    ),
                  ))
              .toList(),
        ),
        AppSpacerH(28.h),
        GestureDetector(
          onTap: _toggle,
          child: Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppColors.accentPrimary, AppColors.accentSecondary],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentPrimary.withOpacity(0.4),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              _running ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 26.sp,
            ),
          ),
        ),
        AppSpacerH(24.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Column(
            children: [
              Text('meditation_screen.session_benefits'.tr(),
                  style: AppTextDecor.caption13Muted),
              AppSpacerH(4.h),
              Text(meditationBenefitsKey.tr(),
                  textAlign: TextAlign.center,
                  style: AppTextDecor.tagBadge11
                      .copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
        AppSpacerH(16.h),
      ],
    );
  }
}
