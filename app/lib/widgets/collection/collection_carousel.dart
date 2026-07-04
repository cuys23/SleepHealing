import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medyo/widgets/collection/collection_card.dart';
import 'package:medyo/widgets/collection/collection_indicator.dart';
import 'package:medyo/widgets/collection/collection_model.dart';

const Duration _kTransitionDuration = Duration(milliseconds: 350);

/// Swipeable "Collection of the Day" carousel.
///
/// A transparent [PageView] drives swipe/drag gestures and owns the paging
/// state; the visible card is rendered separately through an
/// [AnimatedSwitcher] so the title/subtitle/description cross-fade smoothly
/// regardless of whether the page changed via swipe or a dot tap.
class CollectionCarousel extends StatefulWidget {
  const CollectionCarousel({
    super.key,
    required this.collections,
    this.onCollectionTap,
    this.height = 190,
  });

  final List<CollectionModel> collections;
  final ValueChanged<CollectionModel>? onCollectionTap;
  final double height;

  @override
  State<CollectionCarousel> createState() => _CollectionCarouselState();
}

class _CollectionCarouselState extends State<CollectionCarousel> {
  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: _kTransitionDuration,
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.collections.isEmpty) return const SizedBox();
    final current = widget.collections[_currentIndex];

    return Column(
      children: [
        SizedBox(
          height: widget.height.h,
          child: Stack(
            children: [
              AnimatedSwitcher(
                duration: _kTransitionDuration,
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) =>
                    FadeTransition(opacity: animation, child: child),
                child: CollectionCard(
                  key: ValueKey(current.id),
                  collection: current,
                ),
              ),
              Positioned.fill(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: widget.collections.length,
                  onPageChanged: (index) =>
                      setState(() => _currentIndex = index),
                  itemBuilder: (context, index) => GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: widget.onCollectionTap == null
                        ? null
                        : () =>
                            widget.onCollectionTap!(widget.collections[index]),
                    child: const ColoredBox(color: Colors.transparent),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        CollectionIndicator(
          count: widget.collections.length,
          currentIndex: _currentIndex,
          onDotTap: _goToPage,
        ),
      ],
    );
  }
}
