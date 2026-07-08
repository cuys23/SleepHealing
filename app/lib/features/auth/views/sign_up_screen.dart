import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:medyo/config/app_colors.dart';
import 'package:medyo/config/app_text_decor.dart';
import 'package:medyo/config/hive_contants.dart';
import 'package:medyo/config/input_field_decorations.dart';
import 'package:medyo/features/auth/logic/auth_provider.dart';
import 'package:medyo/features/auth/views/auth_screen_wrapper.dart';
import 'package:medyo/utils/context_less_nav.dart';
import 'package:medyo/utils/routes.dart';
import 'package:medyo/widgets/brand_logo.dart';
import 'package:medyo/widgets/buttons/full_width_button.dart';
import 'package:medyo/widgets/misc_widgets.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final GlobalKey<FormBuilderState> _formkey = GlobalKey<FormBuilderState>();
  bool obsecureText = true;
  bool savePass = false;
  @override
  Widget build(BuildContext context) {
    return AuthScreenWrapper(
        child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: FormBuilder(
        key: _formkey,
        child: ListView(
          children: [
            AppSpacerH(20.h),
            GestureDetector(
              onTap: () {
                context.nav.pushNamedAndRemoveUntil(
                    Routes.loginScreen, (route) => false);
              },
              child: Container(
                width: 36.w,
                height: 36.h,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_back_ios_new,
                    color: AppColors.textPrimary, size: 16.sp),
              ),
            ),
            AppSpacerH(20.h),
            const Center(
              child: BrandLogo(size: 64),
            ),
            AppSpacerH(28.h),
            Text(
              "signup_screen.sign_up".tr(),
              textAlign: TextAlign.center,
              style: AppTextDecor.largeTitle28,
            ),
            AppSpacerH(10.h),
            Text(
              "signup_screen.sign_up_text".tr(),
              textAlign: TextAlign.center,
              style: AppTextDecor.caption13,
            ),
            AppSpacerH(32.h),
            _AuthCard(
              child: Column(
                children: [
                  FormBuilderTextField(
                    name: "name",
                    decoration: AppInputDecor.dgBordered.copyWith(
                      labelText: "signup_screen.full_name".tr(),
                      hintText: "signup_screen.hint_name".tr(),
                    ),
                    style: AppTextDecor.bodyTitle16,
                    validator: FormBuilderValidators.required(),
                  ),
                  AppSpacerH(16.h),
                  FormBuilderTextField(
                    name: "email",
                    decoration: AppInputDecor.dgBordered.copyWith(
                      labelText: "signup_screen.email".tr(),
                      hintText: "signup_screen.hint_email".tr(),
                    ),
                    style: AppTextDecor.bodyTitle16,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.email(),
                    ]),
                  ),
                  AppSpacerH(16.h),
                  FormBuilderTextField(
                    name: "password",
                    decoration: AppInputDecor.dgBordered.copyWith(
                      labelText: "signup_screen.password".tr(),
                      hintText: "signup_screen.hint_pass".tr(),
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            obsecureText = !obsecureText;
                          });
                        },
                        child: Icon(
                          obsecureText
                              ? Icons.visibility_off_outlined
                              : Icons.visibility,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                    style: AppTextDecor.bodyTitle16,
                    obscureText: obsecureText,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.minLength(4),
                    ]),
                  ),
                  AppSpacerH(24.h),
                  ref.watch(registerProvider).map(initial: (_) {
                    return AppTextButton(
                      title: "signup_screen.sign_up".tr(),
                      onTap: () {
                        if (_formkey.currentState!.saveAndValidate()) {
                          final formValue = _formkey.currentState!.value;

                          ref.watch(registerProvider.notifier).register(
                              name: formValue["name"],
                              email: formValue["email"],
                              password: formValue["password"]);
                        }
                      },
                    );
                  }, error: (_) {
                    Future.delayed(50.milisec).then((e) {
                      ref.invalidate(registerProvider);
                    });
                    Future.delayed(50.milisec).then((e) {
                      EasyLoading.showError(_.error.toString());
                    });
                    return ErrorTextWidget(error: _.error);
                  }, loading: (_) {
                    return const LoadingWidget();
                  }, loaded: (_) {
                    Future.delayed(50.milisec).then((e) {
                      final Box authBox = Hive.box(
                        AppHSC.authBox,
                      ); //Stores Auth Data
                      final Box userBox = Hive.box(
                        AppHSC.userBox,
                      );
                      authBox.putAll(_.data.data!.access!.toMap());
                      userBox.putAll(_.data.data!.user!.toMap());
                      ref.invalidate(registerProvider);
                      context.nav.pushNamedAndRemoveUntil(
                          Routes.homeScreen, (route) => false);
                    });
                    return const AppTextButton(
                      title: "Success",
                    );
                  }),
                ],
              ),
            ),
            AppSpacerH(80.h),
            Center(
              child: GestureDetector(
                onTap: () {
                  context.nav.pushNamedAndRemoveUntil(
                      Routes.loginScreen, (route) => false);
                },
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "signup_screen.already_have_acc".tr(),
                        style: AppTextDecor.caption13,
                      ),
                      WidgetSpan(
                          child: SizedBox(
                        width: 4.w,
                      )),
                      TextSpan(
                        text: "login_screen.sign_in".tr(),
                        style: AppTextDecor.caption13.copyWith(
                          color: AppColors.accentPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}

/// Rounded glassy container for the auth form fields, matching the design's
/// card style (translucent surface fill, soft border, generous radius).
class _AuthCard extends StatelessWidget {
  const _AuthCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.55),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.divider),
      ),
      child: child,
    );
  }
}
