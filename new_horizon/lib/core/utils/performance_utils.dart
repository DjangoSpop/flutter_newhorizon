import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

/// Performance utilities for optimization
class PerformanceUtils {
  /// Debounce function calls
  static Function debounce(
    Function function, {
    Duration delay = const Duration(milliseconds: 300),
  }) {
    DateTime? lastCall;
    return () {
      final now = DateTime.now();
      if (lastCall == null || now.difference(lastCall!) > delay) {
        lastCall = now;
        function();
      }
    };
  }

  /// Throttle function calls
  static Function throttle(
    Function function, {
    Duration interval = const Duration(milliseconds: 300),
  }) {
    bool isThrottled = false;
    return () {
      if (!isThrottled) {
        function();
        isThrottled = true;
        Future.delayed(interval, () {
          isThrottled = false;
        });
      }
    };
  }

  /// Log performance metrics in debug mode
  static void logPerformance(String operation, Function function) {
    if (kDebugMode) {
      final stopwatch = Stopwatch()..start();
      function();
      stopwatch.stop();
      print('$operation took ${stopwatch.elapsedMilliseconds}ms');
    } else {
      function();
    }
  }

  /// Measure widget build time
  static Future<void> measureBuildTime(
    String widgetName,
    Future<void> Function() buildFunction,
  ) async {
    if (kDebugMode) {
      final stopwatch = Stopwatch()..start();
      await buildFunction();
      stopwatch.stop();
      print('$widgetName build time: ${stopwatch.elapsedMilliseconds}ms');
    } else {
      await buildFunction();
    }
  }
}

/// Optimized image widget with caching and lazy loading
class OptimizedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool enableMemoryCache;
  final bool enableDiskCache;

  const OptimizedImage({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.enableMemoryCache = true,
    this.enableDiskCache = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget imageWidget = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit ?? BoxFit.cover,
      memCacheWidth: width != null ? (width! * 2).toInt() : null,
      memCacheHeight: height != null ? (height! * 2).toInt() : null,
      placeholder: (context, url) =>
          placeholder ??
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: width,
              height: height,
              color: Colors.white,
            ),
          ),
      errorWidget: (context, url, error) =>
          errorWidget ??
          Container(
            width: width,
            height: height,
            color: Colors.grey[200],
            child: const Icon(Icons.error, color: Colors.grey),
          ),
    );

    if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}

/// Lazy loading list view for better performance
class LazyLoadingListView extends StatefulWidget {
  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final Future<void> Function()? onLoadMore;
  final ScrollController? scrollController;
  final EdgeInsets? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final double loadMoreThreshold;

  const LazyLoadingListView({
    Key? key,
    required this.itemCount,
    required this.itemBuilder,
    this.onLoadMore,
    this.scrollController,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
    this.loadMoreThreshold = 200,
  }) : super(key: key);

  @override
  State<LazyLoadingListView> createState() => _LazyLoadingListViewState();
}

class _LazyLoadingListViewState extends State<LazyLoadingListView> {
  late ScrollController _scrollController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  void _onScroll() {
    if (_isLoading) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final threshold = widget.loadMoreThreshold;

    if (maxScroll - currentScroll <= threshold) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (widget.onLoadMore == null || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    await widget.onLoadMore!();

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: widget.itemCount + (_isLoading ? 1 : 0),
      padding: widget.padding,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics,
      itemBuilder: (context, index) {
        if (index == widget.itemCount) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }
        return widget.itemBuilder(context, index);
      },
    );
  }
}

/// Lazy loading grid view
class LazyLoadingGridView extends StatefulWidget {
  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final Future<void> Function()? onLoadMore;
  final ScrollController? scrollController;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;
  final EdgeInsets? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final double loadMoreThreshold;

  const LazyLoadingGridView({
    Key? key,
    required this.itemCount,
    required this.itemBuilder,
    this.onLoadMore,
    this.scrollController,
    required this.crossAxisCount,
    this.mainAxisSpacing = 8.0,
    this.crossAxisSpacing = 8.0,
    this.childAspectRatio = 1.0,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
    this.loadMoreThreshold = 200,
  }) : super(key: key);

  @override
  State<LazyLoadingGridView> createState() => _LazyLoadingGridViewState();
}

class _LazyLoadingGridViewState extends State<LazyLoadingGridView> {
  late ScrollController _scrollController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  void _onScroll() {
    if (_isLoading) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final threshold = widget.loadMoreThreshold;

    if (maxScroll - currentScroll <= threshold) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (widget.onLoadMore == null || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    await widget.onLoadMore!();

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: _scrollController,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.crossAxisCount,
        mainAxisSpacing: widget.mainAxisSpacing,
        crossAxisSpacing: widget.crossAxisSpacing,
        childAspectRatio: widget.childAspectRatio,
      ),
      itemCount: widget.itemCount + (_isLoading ? 1 : 0),
      padding: widget.padding,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics,
      itemBuilder: (context, index) {
        if (index == widget.itemCount) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return widget.itemBuilder(context, index);
      },
    );
  }
}

/// Shimmer loading skeleton
class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerLoading({
    Key? key,
    required this.width,
    required this.height,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }
}

/// Product card shimmer
class ProductCardShimmer extends StatelessWidget {
  const ProductCardShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerLoading(
            width: double.infinity,
            height: 200,
            borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ShimmerLoading(width: 150, height: 16),
                SizedBox(height: 8),
                ShimmerLoading(width: 100, height: 14),
                SizedBox(height: 8),
                ShimmerLoading(width: 80, height: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Memoized widget for expensive builds
class MemoizedWidget extends StatefulWidget {
  final Widget Function() builder;
  final List<Object?> dependencies;

  const MemoizedWidget({
    Key? key,
    required this.builder,
    required this.dependencies,
  }) : super(key: key);

  @override
  State<MemoizedWidget> createState() => _MemoizedWidgetState();
}

class _MemoizedWidgetState extends State<MemoizedWidget> {
  late Widget _cachedWidget;
  late List<Object?> _cachedDependencies;

  @override
  void initState() {
    super.initState();
    _cachedWidget = widget.builder();
    _cachedDependencies = List.from(widget.dependencies);
  }

  @override
  void didUpdateWidget(MemoizedWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    bool dependenciesChanged = false;
    if (_cachedDependencies.length != widget.dependencies.length) {
      dependenciesChanged = true;
    } else {
      for (int i = 0; i < _cachedDependencies.length; i++) {
        if (_cachedDependencies[i] != widget.dependencies[i]) {
          dependenciesChanged = true;
          break;
        }
      }
    }

    if (dependenciesChanged) {
      _cachedWidget = widget.builder();
      _cachedDependencies = List.from(widget.dependencies);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _cachedWidget;
  }
}

/// Visibility detector for lazy loading widgets
class VisibilityDetector extends StatefulWidget {
  final Widget child;
  final Function(bool isVisible)? onVisibilityChanged;
  final double visibilityThreshold;

  const VisibilityDetector({
    Key? key,
    required this.child,
    this.onVisibilityChanged,
    this.visibilityThreshold = 0.1,
  }) : super(key: key);

  @override
  State<VisibilityDetector> createState() => _VisibilityDetectorState();
}

class _VisibilityDetectorState extends State<VisibilityDetector> {
  bool _isVisible = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _checkVisibility();
        });
        return widget.child;
      },
    );
  }

  void _checkVisibility() {
    // Implementation for visibility detection
    // This would require render box calculations
    final RenderObject? renderObject = context.findRenderObject();
    if (renderObject is RenderBox && renderObject.hasSize) {
      final bool nowVisible = renderObject.size.height > 0;
      if (nowVisible != _isVisible) {
        _isVisible = nowVisible;
        widget.onVisibilityChanged?.call(_isVisible);
      }
    }
  }
}

/// Preload cache manager
class PreloadCacheManager {
  static final Map<String, dynamic> _cache = {};

  /// Preload data into cache
  static void preload(String key, dynamic data) {
    _cache[key] = data;
  }

  /// Get cached data
  static T? get<T>(String key) {
    return _cache[key] as T?;
  }

  /// Check if data exists in cache
  static bool has(String key) {
    return _cache.containsKey(key);
  }

  /// Clear specific cache entry
  static void clear(String key) {
    _cache.remove(key);
  }

  /// Clear all cache
  static void clearAll() {
    _cache.clear();
  }

  /// Get cache size
  static int get size => _cache.length;
}

/// Image preloader
class ImagePreloader {
  /// Preload list of images
  static Future<void> preloadImages(
    BuildContext context,
    List<String> imageUrls,
  ) async {
    final futures = imageUrls.map((url) {
      return precacheImage(CachedNetworkImageProvider(url), context);
    }).toList();

    await Future.wait(futures);
  }

  /// Preload single image
  static Future<void> preloadImage(BuildContext context, String imageUrl) async {
    await precacheImage(CachedNetworkImageProvider(imageUrl), context);
  }
}
