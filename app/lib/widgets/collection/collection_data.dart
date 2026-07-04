import 'package:medyo/config/app_colors.dart';
import 'package:medyo/widgets/collection/collection_model.dart';

/// Static showcase data for the "Collection of the Day" carousel.
/// Add a new entry here to add a new card — no widget changes required.
final List<CollectionModel> kFeaturedCollections = [
  CollectionModel(
    id: 'deep-sleep',
    title: 'Deep Sleep',
    subtitle: 'SLEEP SOUNDS',
    description:
        'Drift into peaceful slumber with curated sounds and gentle narration.',
    backgroundGradient: [
      AppColors.categorySleep.withOpacity(0.45),
      AppColors.bgAlt,
    ],
  ),
  CollectionModel(
    id: 'night-rain',
    title: 'Night Rain',
    subtitle: 'RAINFALL',
    description:
        'Relax beneath the soothing sound of gentle rainfall throughout the night.',
    backgroundGradient: [
      AppColors.categoryAnxiety.withOpacity(0.45),
      AppColors.bgAlt,
    ],
  ),
  CollectionModel(
    id: 'morning-focus',
    title: 'Morning Focus',
    subtitle: 'FOCUS RITUAL',
    description: 'Start your day with calm concentration and positive energy.',
    backgroundGradient: [
      AppColors.categoryFocus.withOpacity(0.45),
      AppColors.bgAlt,
    ],
  ),
  CollectionModel(
    id: 'forest-escape',
    title: 'Forest Escape',
    subtitle: 'NATURE AMBIENCE',
    description: 'Reconnect with nature through peaceful forest ambience.',
    backgroundGradient: [
      AppColors.categoryRelax.withOpacity(0.45),
      AppColors.bgAlt,
    ],
  ),
  CollectionModel(
    id: 'ocean-waves',
    title: 'Ocean Waves',
    subtitle: 'OCEAN SOUNDS',
    description: 'Fall asleep beside calming waves and soft sea breeze.',
    backgroundGradient: [
      AppColors.categoryBreathe.withOpacity(0.45),
      AppColors.bgAlt,
    ],
  ),
];
