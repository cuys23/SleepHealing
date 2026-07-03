import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medyo/config/app_colors.dart';
import 'package:medyo/config/app_text_decor.dart';
import 'package:medyo/widgets/collection/collection_model.dart';

/// Renders a single [CollectionModel] — gradient background, tag, title and
/// description. Stateless and driven entirely by the model passed in.
class CollectionCard extends StatelessWidget {
  const CollectionCard({super.key, required this.collection, this.onTap});

  final CollectionModel collection;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: collection.backgroundGradient,
          ),
          image: collection.image != null
              ? DecorationImage(
                  image: NetworkImage(collection.image!),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    AppColors.bgPrimary.withOpacity(0.35),
                    BlendMode.darken,
                  ),
                )
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              collection.subtitle.toUpperCase(),
              style: AppTextDecor.tagBadge11.copyWith(
                color: AppColors.accentPrimary,
                letterSpacing: 1,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              collection.title,
              style: AppTextDecor.largeTitle28,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8.h),
            Expanded(
              child: Text(
                collection.description,
                style: AppTextDecor.caption13,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
