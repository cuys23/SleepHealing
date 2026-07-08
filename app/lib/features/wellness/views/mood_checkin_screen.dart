import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medyo/config/app_colors.dart';
import 'package:medyo/config/app_text_decor.dart';
import 'package:medyo/features/wellness/mock/mood_checkin_mock_data.dart';
import 'package:medyo/utils/context_less_nav.dart';
import 'package:medyo/widgets/buttons/full_width_button.dart';
import 'package:medyo/widgets/misc_widgets.dart';
import 'package:medyo/widgets/regular_app_bar.dart';
import 'package:medyo/widgets/screen_wrapper.dart';

/// No mood-logging backend exists yet — saving only shows a local
/// confirmation and pops. See mood_checkin_mock_data.dart TODO.
class MoodCheckinScreen extends StatefulWidget {
  const MoodCheckinScreen({super.key});

  @override
  State<MoodCheckinScreen> createState() => _MoodCheckinScreenState();
}

class _MoodCheckinScreenState extends State<MoodCheckinScreen> {
  int? _selectedMood = 1;
  final _noteController = TextEditingController();
  final Set<String> _selectedTags = {};

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
      child: Column(
        children: [
          RegularAppBar(title: 'mood_checkin_screen.title'.tr()),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              children: [
                Text('mood_checkin_screen.headline'.tr(),
                    textAlign: TextAlign.center,
                    style: AppTextDecor.heading3_17),
                AppSpacerH(6.h),
                Text('mood_checkin_screen.subtitle'.tr(),
                    textAlign: TextAlign.center,
                    style: AppTextDecor.caption13Muted),
                AppSpacerH(24.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(moodOptionsMock.length, (index) {
                    final mood = moodOptionsMock[index];
                    final selected = _selectedMood == index;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedMood = index),
                      child: Column(
                        children: [
                          Container(
                            width: 44.w,
                            height: 44.w,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14.r),
                              color: AppColors.accentPrimary
                                  .withOpacity(selected ? 0.18 : 0.08),
                              border: Border.all(
                                color: selected
                                    ? AppColors.accentPrimary
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Text(mood.emoji,
                                style: TextStyle(fontSize: 20.sp)),
                          ),
                          AppSpacerH(4.h),
                          Text(mood.labelKey.tr(),
                              style: AppTextDecor.tagBadge11.copyWith(
                                color: selected
                                    ? AppColors.textSecondary
                                    : AppColors.textMuted,
                              )),
                        ],
                      ),
                    );
                  }),
                ),
                AppSpacerH(28.h),
                Text('mood_checkin_screen.note_label'.tr(),
                    style: AppTextDecor.bodyTitle15),
                AppSpacerH(10.h),
                TextField(
                  controller: _noteController,
                  maxLines: 3,
                  style: AppTextDecor.bodyTitle15,
                  decoration: InputDecoration(
                    hintText: 'mood_checkin_screen.note_hint'.tr(),
                    hintStyle: AppTextDecor.caption13Muted,
                    filled: true,
                    fillColor: AppColors.inputBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(13.r),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                AppSpacerH(20.h),
                Text('mood_checkin_screen.concerns_label'.tr(),
                    style: AppTextDecor.bodyTitle15),
                AppSpacerH(10.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: sleepConcernTagsMock.map((tagKey) {
                    final selected = _selectedTags.contains(tagKey);
                    return GestureDetector(
                      onTap: () => setState(() {
                        selected
                            ? _selectedTags.remove(tagKey)
                            : _selectedTags.add(tagKey);
                      }),
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.r),
                          color: selected
                              ? AppColors.accentPrimary.withOpacity(0.12)
                              : Colors.white.withOpacity(0.04),
                          border: selected
                              ? Border.all(
                                  color: AppColors.accentPrimary.withOpacity(0.2))
                              : null,
                        ),
                        child: Text(tagKey.tr(),
                            style: AppTextDecor.tagBadge11.copyWith(
                              color: selected
                                  ? AppColors.textSecondary
                                  : AppColors.textMuted,
                            )),
                      ),
                    );
                  }).toList(),
                ),
                AppSpacerH(28.h),
                AppTextButton(
                  title: 'mood_checkin_screen.save'.tr(),
                  onTap: () {
                    EasyLoading.showSuccess(
                        'mood_checkin_screen.saved_toast'.tr());
                    context.nav.pop();
                  },
                ),
                AppSpacerH(24.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
