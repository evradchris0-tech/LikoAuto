import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:liko_auto/core/theme/app_colors.dart';

/// Données passées à `PhotoGalleryScreen` via `state.extra`.
class PhotoGalleryArgs {
  const PhotoGalleryArgs({
    required this.assets,
    required this.initialIndex,
    this.heroTagPrefix,
    this.title,
  });

  final List<String> assets;
  final int initialIndex;
  final String? heroTagPrefix;
  final String? title;
}

/// Visualiseur fullscreen swipeable de photos avec pinch-to-zoom.
class PhotoGalleryScreen extends ConsumerStatefulWidget {
  const PhotoGalleryScreen({required this.args, super.key});

  final PhotoGalleryArgs args;

  @override
  ConsumerState<PhotoGalleryScreen> createState() => _PhotoGalleryScreenState();
}

class _PhotoGalleryScreenState extends ConsumerState<PhotoGalleryScreen> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.args.initialIndex.clamp(
      0,
      widget.args.assets.length - 1,
    );
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.args.assets.length;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.black.withValues(alpha: 0.3),
          elevation: 0,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => context.pop(),
          ),
          title: Text(
            widget.args.title != null
                ? '${widget.args.title}  ·  ${_currentIndex + 1}/$total'
                : '${_currentIndex + 1} / $total',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: total,
              onPageChanged: (i) => setState(() => _currentIndex = i),
              itemBuilder: (_, i) {
                final asset = widget.args.assets[i];
                final tag = widget.args.heroTagPrefix != null
                    ? '${widget.args.heroTagPrefix}_$i'
                    : null;
                return _ZoomablePhoto(asset: asset, heroTag: tag);
              },
            ),
            // Thumbnails strip
            if (total > 1)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SafeArea(
                  top: false,
                  child: Container(
                    height: 80,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: total,
                      separatorBuilder: (_, __) => const SizedBox(width: 6),
                      itemBuilder: (_, i) {
                        final isActive = i == _currentIndex;
                        return GestureDetector(
                          onTap: () => _pageController.animateToPage(
                            i,
                            duration: const Duration(milliseconds: 280),
                            curve: Curves.easeOutCubic,
                          ),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            width: isActive ? 66 : 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isActive
                                    ? AppColors.primary
                                    : Colors.white24,
                                width: isActive ? 2 : 1,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.asset(
                                widget.args.assets[i],
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const ColoredBox(
                                  color: AppColors.darkSurface,
                                  child: Icon(
                                    Icons.broken_image_outlined,
                                    color: Colors.white24,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ZoomablePhoto extends StatefulWidget {
  const _ZoomablePhoto({required this.asset, this.heroTag});

  final String asset;
  final String? heroTag;

  @override
  State<_ZoomablePhoto> createState() => _ZoomablePhotoState();
}

class _ZoomablePhotoState extends State<_ZoomablePhoto>
    with SingleTickerProviderStateMixin {
  final _transformCtrl = TransformationController();
  TapDownDetails? _doubleTapDetails;
  late final AnimationController _resetCtrl;

  @override
  void initState() {
    super.initState();
    _resetCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    )..addListener(() {
        _transformCtrl.value = Matrix4Tween(
          begin: _transformCtrl.value,
          end: Matrix4.identity(),
        ).lerp(_resetCtrl.value);
      });
  }

  @override
  void dispose() {
    _transformCtrl.dispose();
    _resetCtrl.dispose();
    super.dispose();
  }

  void _handleDoubleTap() {
    if (_transformCtrl.value != Matrix4.identity()) {
      _resetCtrl.forward(from: 0);
      return;
    }
    final pos = _doubleTapDetails?.localPosition ?? Offset.zero;
    final zoom = Matrix4.identity()
      ..translateByDouble(-pos.dx * 1.5, -pos.dy * 1.5, 0, 1)
      ..scaleByDouble(2.5, 2.5, 1, 1);
    _transformCtrl.value = zoom;
  }

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      widget.asset,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => const ColoredBox(
        color: Colors.black,
        child: Center(
          child: Icon(
            Icons.broken_image_outlined,
            color: Colors.white38,
            size: 64,
          ),
        ),
      ),
    );
    return GestureDetector(
      onDoubleTapDown: (d) => _doubleTapDetails = d,
      onDoubleTap: _handleDoubleTap,
      child: InteractiveViewer(
        transformationController: _transformCtrl,
        minScale: 1,
        maxScale: 4,
        child: Center(
          child: widget.heroTag != null
              ? Hero(tag: widget.heroTag!, child: image)
              : image,
        ),
      ),
    );
  }
}
