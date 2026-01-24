import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';

/// Enhanced image gallery with zoom capability
class ProductImageGallery extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;
  final bool showThumbnails;
  final bool enable360View;
  final List<String>? view360Images;

  const ProductImageGallery({
    Key? key,
    required this.imageUrls,
    this.initialIndex = 0,
    this.showThumbnails = true,
    this.enable360View = false,
    this.view360Images,
  }) : super(key: key);

  @override
  State<ProductImageGallery> createState() => _ProductImageGalleryState();
}

class _ProductImageGalleryState extends State<ProductImageGallery> {
  late PageController _pageController;
  late int _currentIndex;
  bool _is360Mode = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggle360View() {
    if (widget.enable360View && widget.view360Images != null) {
      setState(() {
        _is360Mode = !_is360Mode;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final images = _is360Mode ? widget.view360Images! : widget.imageUrls;

    return Column(
      children: [
        // Main image gallery with zoom
        Expanded(
          child: Stack(
            children: [
              PhotoViewGallery.builder(
                scrollPhysics: const BouncingScrollPhysics(),
                builder: (BuildContext context, int index) {
                  return PhotoViewGalleryPageOptions(
                    imageProvider: CachedNetworkImageProvider(images[index]),
                    initialScale: PhotoViewComputedScale.contained,
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.covered * 2,
                    heroAttributes: PhotoViewHeroAttributes(
                      tag: 'product_image_$index',
                    ),
                  );
                },
                itemCount: images.length,
                loadingBuilder: (context, event) => Center(
                  child: CircularProgressIndicator(
                    value: event == null
                        ? 0
                        : event.cumulativeBytesLoaded /
                            (event.expectedTotalBytes ?? 1),
                  ),
                ),
                backgroundDecoration: BoxDecoration(
                  color: AppColors.background,
                ),
                pageController: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),

              // 360 view toggle button
              if (widget.enable360View && widget.view360Images != null)
                Positioned(
                  top: AppDimensions.lg,
                  right: AppDimensions.lg,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusRound,
                      ),
                    ),
                    child: IconButton(
                      icon: Icon(
                        _is360Mode ? Icons.image : Icons.threesixty,
                        color: AppColors.white,
                      ),
                      onPressed: _toggle360View,
                      tooltip: _is360Mode ? 'Normal View' : '360° View',
                    ),
                  ),
                ),

              // Image counter
              Positioned(
                bottom: AppDimensions.lg,
                right: AppDimensions.lg,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.md,
                    vertical: AppDimensions.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusRound,
                    ),
                  ),
                  child: Text(
                    '${_currentIndex + 1}/${images.length}',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Thumbnail strip
        if (widget.showThumbnails && images.length > 1)
          Container(
            height: 80,
            margin: EdgeInsets.all(AppDimensions.md),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              itemBuilder: (context, index) {
                final isActive = index == _currentIndex;
                return GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(
                      index,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    width: 60,
                    margin: EdgeInsets.only(right: AppDimensions.sm),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isActive
                            ? AppColors.primary
                            : AppColors.border,
                        width: isActive ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusSm,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusSm,
                      ),
                      child: CachedNetworkImage(
                        imageUrl: images[index],
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppColors.grey200,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

/// Product video player widget
class ProductVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String? thumbnailUrl;

  const ProductVideoPlayer({
    Key? key,
    required this.videoUrl,
    this.thumbnailUrl,
  }) : super(key: key);

  @override
  State<ProductVideoPlayer> createState() => _ProductVideoPlayerState();
}

class _ProductVideoPlayerState extends State<ProductVideoPlayer> {
  bool _isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Thumbnail
          if (widget.thumbnailUrl != null && !_isPlaying)
            CachedNetworkImage(
              imageUrl: widget.thumbnailUrl!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),

          // Play button
          if (!_isPlaying)
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  Icons.play_arrow,
                  size: 32,
                  color: AppColors.black,
                ),
                onPressed: () {
                  setState(() {
                    _isPlaying = true;
                  });
                  // TODO: Initialize and play video player
                },
              ),
            ),

          // Video player placeholder
          if (_isPlaying)
            Center(
              child: Text(
                'Video Player\n(Integration with video_player package)',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.white),
              ),
            ),
        ],
      ),
    );
  }
}

/// Interactive size guide widget
class SizeGuideWidget extends StatelessWidget {
  final String productCategory;

  const SizeGuideWidget({
    Key? key,
    required this.productCategory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Size Guide',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          SizedBox(height: AppDimensions.lg),

          // Size chart table
          _buildSizeChart(),

          SizedBox(height: AppDimensions.lg),

          // Measurement guide
          Text(
            'How to Measure',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: AppDimensions.md),

          _buildMeasurementGuide(),

          SizedBox(height: AppDimensions.lg),

          // Find your size button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Implement size finder
              },
              child: Text('Find Your Size'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSizeChart() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        border: TableBorder.all(color: AppColors.border),
        columns: [
          DataColumn(label: Text('Size')),
          DataColumn(label: Text('Chest (cm)')),
          DataColumn(label: Text('Waist (cm)')),
          DataColumn(label: Text('Hip (cm)')),
        ],
        rows: [
          _buildSizeRow('XS', '86-89', '71-74', '91-94'),
          _buildSizeRow('S', '90-93', '75-78', '95-98'),
          _buildSizeRow('M', '94-97', '79-82', '99-102'),
          _buildSizeRow('L', '98-101', '83-86', '103-106'),
          _buildSizeRow('XL', '102-105', '87-90', '107-110'),
          _buildSizeRow('XXL', '106-109', '91-94', '111-114'),
        ],
      ),
    );
  }

  DataRow _buildSizeRow(String size, String chest, String waist, String hip) {
    return DataRow(
      cells: [
        DataCell(Text(size, style: TextStyle(fontWeight: FontWeight.bold))),
        DataCell(Text(chest)),
        DataCell(Text(waist)),
        DataCell(Text(hip)),
      ],
    );
  }

  Widget _buildMeasurementGuide() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMeasurementStep(
          '1. Chest',
          'Measure around the fullest part of your chest',
        ),
        SizedBox(height: AppDimensions.sm),
        _buildMeasurementStep(
          '2. Waist',
          'Measure around your natural waistline',
        ),
        SizedBox(height: AppDimensions.sm),
        _buildMeasurementStep(
          '3. Hip',
          'Measure around the fullest part of your hips',
        ),
      ],
    );
  }

  Widget _buildMeasurementStep(String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.straighten,
          size: 20,
          color: AppColors.primary,
        ),
        SizedBox(width: AppDimensions.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Complete the look recommendations widget
class CompleteTheLook extends StatelessWidget {
  final String productId;
  final List<Map<String, dynamic>> recommendations;

  const CompleteTheLook({
    Key? key,
    required this.productId,
    required this.recommendations,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (recommendations.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(AppDimensions.lg),
          child: Text(
            'Complete the Look',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        Container(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: AppDimensions.lg),
            itemCount: recommendations.length,
            itemBuilder: (context, index) {
              final item = recommendations[index];
              return _buildRecommendationCard(context, item);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationCard(
    BuildContext context,
    Map<String, dynamic> item,
  ) {
    return Container(
      width: 160,
      margin: EdgeInsets.only(right: AppDimensions.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            child: CachedNetworkImage(
              imageUrl: item['image'] ?? '',
              height: 200,
              width: 160,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: AppColors.grey200,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          ),

          SizedBox(height: AppDimensions.sm),

          // Product name
          Text(
            item['name'] ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(height: AppDimensions.xxs),

          // Price
          Text(
            '\$${item['price'] ?? 0}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
