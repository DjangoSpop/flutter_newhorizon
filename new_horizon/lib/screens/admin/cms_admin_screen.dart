import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/cms_controller.dart';
import '../../models/cms_content.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/utils/responsive_helper.dart';
import 'package:intl/intl.dart';

class CMSAdminScreen extends StatelessWidget {
  const CMSAdminScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cmsController = Get.find<CMSController>();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Content Management', style: AppTypography.headlineSmall),
          elevation: 0,
          bottom: TabBar(
            tabs: const [
              Tab(icon: Icon(Icons.image), text: 'Banners'),
              Tab(icon: Icon(Icons.web), text: 'Pages'),
              Tab(icon: Icon(Icons.menu), text: 'Menus'),
            ],
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => cmsController.refreshAllContent(),
              tooltip: 'Refresh',
            ),
          ],
        ),
        body: TabBarView(
          children: [
            _BannersTab(controller: cmsController),
            _PagesTab(controller: cmsController),
            _MenusTab(controller: cmsController),
          ],
        ),
      ),
    );
  }
}

// ==================== BANNERS TAB ====================
class _BannersTab extends StatelessWidget {
  final CMSController controller;

  const _BannersTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildBannerFilters(),
        Expanded(
          child: Obx(() {
            if (controller.isLoadingBanners.value && controller.banners.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.banners.isEmpty) {
              return _buildEmptyState(
                icon: Icons.image,
                title: 'No Banners',
                message: 'Create your first banner to display on the homepage',
                actionLabel: 'Create Banner',
                onAction: () => _showBannerDialog(context),
              );
            }

            return ResponsiveBuilder(
              builder: (ctx, deviceType) {
                if (deviceType == DeviceType.mobile) {
                  return _buildBannerList();
                } else {
                  return _buildBannerGrid();
                }
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildBannerFilters() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search banners...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.md),
          ChoiceChip(
            label: const Text('All'),
            selected: true,
            onSelected: (_) {},
          ),
          const SizedBox(width: AppDimensions.sm),
          ChoiceChip(
            label: const Text('Active'),
            selected: false,
            onSelected: (_) {},
          ),
          const SizedBox(width: AppDimensions.sm),
          ChoiceChip(
            label: const Text('Scheduled'),
            selected: false,
            onSelected: (_) {},
          ),
        ],
      ),
    );
  }

  Widget _buildBannerList() {
    return Obx(() {
      return ListView.builder(
        padding: const EdgeInsets.all(AppDimensions.md),
        itemCount: controller.banners.length,
        itemBuilder: (context, index) {
          final banner = controller.banners[index];
          return _buildBannerCard(context, banner);
        },
      );
    });
  }

  Widget _buildBannerGrid() {
    return Obx(() {
      return GridView.builder(
        padding: const EdgeInsets.all(AppDimensions.lg),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 400,
          childAspectRatio: 1.5,
          crossAxisSpacing: AppDimensions.lg,
          mainAxisSpacing: AppDimensions.lg,
        ),
        itemCount: controller.banners.length,
        itemBuilder: (context, index) {
          final banner = controller.banners[index];
          return _buildBannerCard(context, banner);
        },
      );
    });
  }

  Widget _buildBannerCard(BuildContext context, Banner banner) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Image Preview
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  banner.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.backgroundLight,
                    child: const Icon(Icons.image, size: 48, color: AppColors.textSecondary),
                  ),
                ),
                if (!banner.isActive)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: Chip(
                        label: Text('Inactive', style: TextStyle(color: Colors.white)),
                        backgroundColor: AppColors.error,
                      ),
                    ),
                  ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.sm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getBannerTypeColor(banner.type),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                    ),
                    child: Text(
                      _getBannerTypeLabel(banner.type),
                      style: AppTypography.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppDimensions.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  banner.title,
                  style: AppTypography.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (banner.subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    banner.subtitle!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: AppDimensions.md),
                Row(
                  children: [
                    Icon(
                      banner.isActive ? Icons.check_circle : Icons.cancel,
                      size: 16,
                      color: banner.isActive ? AppColors.success : AppColors.error,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      banner.isActive ? 'Active' : 'Inactive',
                      style: AppTypography.labelSmall,
                    ),
                    const Spacer(),
                    Text(
                      'Order: ${banner.sortOrder}',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                if (banner.isScheduled) ...[
                  const SizedBox(height: AppDimensions.sm),
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 14, color: AppColors.info),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _getScheduleText(banner),
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.info,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: AppDimensions.md),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _showBannerDialog(context, banner: banner),
                        child: const Text('Edit'),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.sm),
                    IconButton(
                      icon: const Icon(Icons.delete, color: AppColors.error),
                      onPressed: () => _confirmDeleteBanner(context, banner),
                      tooltip: 'Delete',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getBannerTypeColor(BannerType type) {
    switch (type) {
      case BannerType.hero:
        return AppColors.primary;
      case BannerType.promotional:
        return AppColors.warning;
      case BannerType.category:
        return AppColors.info;
      case BannerType.product:
        return AppColors.success;
      case BannerType.seasonal:
        return const Color(0xFF9C27B0);
      case BannerType.announcement:
        return const Color(0xFFFF5722);
    }
  }

  String _getBannerTypeLabel(BannerType type) {
    switch (type) {
      case BannerType.hero:
        return 'Hero';
      case BannerType.promotional:
        return 'Promo';
      case BannerType.category:
        return 'Category';
      case BannerType.product:
        return 'Product';
      case BannerType.seasonal:
        return 'Seasonal';
      case BannerType.announcement:
        return 'News';
    }
  }

  String _getScheduleText(Banner banner) {
    if (banner.startDate != null && banner.endDate != null) {
      final start = DateFormat('MMM dd').format(banner.startDate!);
      final end = DateFormat('MMM dd').format(banner.endDate!);
      return '$start - $end';
    } else if (banner.startDate != null) {
      return 'From ${DateFormat('MMM dd').format(banner.startDate!)}';
    } else if (banner.endDate != null) {
      return 'Until ${DateFormat('MMM dd').format(banner.endDate!)}';
    }
    return '';
  }

  void _showBannerDialog(BuildContext context, {Banner? banner}) {
    final isEdit = banner != null;
    final titleController = TextEditingController(text: banner?.title);
    final subtitleController = TextEditingController(text: banner?.subtitle);
    final imageUrlController = TextEditingController(text: banner?.imageUrl);
    var selectedType = banner?.type ?? BannerType.hero;
    var isActive = banner?.isActive ?? true;
    var sortOrder = banner?.sortOrder ?? 0;

    Get.dialog(
      AlertDialog(
        title: Text(isEdit ? 'Edit Banner' : 'Create Banner'),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppDimensions.md),
                TextField(
                  controller: subtitleController,
                  decoration: const InputDecoration(
                    labelText: 'Subtitle',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppDimensions.md),
                TextField(
                  controller: imageUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Image URL *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppDimensions.md),
                DropdownButtonFormField<BannerType>(
                  value: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Banner Type',
                    border: OutlineInputBorder(),
                  ),
                  items: BannerType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(_getBannerTypeLabel(type)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) selectedType = value;
                  },
                ),
                const SizedBox(height: AppDimensions.md),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Sort Order',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(text: sortOrder.toString()),
                  onChanged: (value) {
                    sortOrder = int.tryParse(value) ?? 0;
                  },
                ),
                const SizedBox(height: AppDimensions.md),
                SwitchListTile(
                  title: const Text('Active'),
                  value: isActive,
                  onChanged: (value) {
                    isActive = value;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isEmpty || imageUrlController.text.isEmpty) {
                Get.snackbar('Error', 'Please fill in required fields');
                return;
              }

              if (isEdit) {
                controller.updateBanner(
                  bannerId: banner.id,
                  title: titleController.text,
                  subtitle: subtitleController.text.isEmpty ? null : subtitleController.text,
                  imageUrl: imageUrlController.text,
                  type: selectedType,
                  isActive: isActive,
                  sortOrder: sortOrder,
                );
              } else {
                controller.createBanner(
                  title: titleController.text,
                  subtitle: subtitleController.text.isEmpty ? null : subtitleController.text,
                  imageUrl: imageUrlController.text,
                  type: selectedType,
                  isActive: isActive,
                  sortOrder: sortOrder,
                );
              }
              Get.back();
            },
            child: Text(isEdit ? 'Update' : 'Create'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteBanner(BuildContext context, Banner banner) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Banner'),
        content: Text('Are you sure you want to delete "${banner.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.deleteBanner(banner.id);
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: AppColors.textSecondary.withOpacity(0.5)),
            const SizedBox(height: AppDimensions.lg),
            Text(title, style: AppTypography.titleLarge),
            const SizedBox(height: AppDimensions.sm),
            Text(
              message,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.xl),
            ElevatedButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add),
              label: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== PAGES TAB ====================
class _PagesTab extends StatelessWidget {
  final CMSController controller;

  const _PagesTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final homeContent = controller.homePageContent.value;

      if (controller.isLoading.value && homeContent == null) {
        return const Center(child: CircularProgressIndicator());
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Homepage Content', style: AppTypography.headlineSmall),
                ElevatedButton.icon(
                  onPressed: () => _showAddSectionDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Section'),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.xl),
            if (homeContent != null) ...[
              ...controller.homePageSections.asMap().entries.map((entry) {
                return _buildSectionCard(context, entry.value, entry.key);
              }).toList(),
            ] else
              _buildEmptyContentState(context),
          ],
        ),
      );
    });
  }

  Widget _buildSectionCard(BuildContext context, ContentSection section, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.md),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppDimensions.sm),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                  ),
                  child: Icon(_getSectionIcon(section.type), color: AppColors.primary),
                ),
                const SizedBox(width: AppDimensions.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(section.name, style: AppTypography.titleMedium),
                      if (section.title != null)
                        Text(
                          section.title!,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                Chip(
                  label: Text(_getSectionTypeLabel(section.type)),
                  backgroundColor: AppColors.info.withOpacity(0.1),
                  labelStyle: const TextStyle(color: AppColors.info),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.md),
            Row(
              children: [
                Text('Order: ${section.sortOrder}', style: AppTypography.bodySmall),
                const SizedBox(width: AppDimensions.lg),
                Icon(
                  section.isActive ? Icons.visibility : Icons.visibility_off,
                  size: 16,
                  color: section.isActive ? AppColors.success : AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  section.isActive ? 'Visible' : 'Hidden',
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.md),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Edit'),
                ),
                const SizedBox(width: AppDimensions.sm),
                OutlinedButton.icon(
                  onPressed: index > 0 ? () {} : null,
                  icon: const Icon(Icons.arrow_upward, size: 18),
                  label: const Text('Move Up'),
                ),
                const SizedBox(width: AppDimensions.sm),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.arrow_downward, size: 18),
                  label: const Text('Move Down'),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete, color: AppColors.error),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getSectionIcon(ContentSectionType type) {
    switch (type) {
      case ContentSectionType.bannerCarousel:
        return Icons.view_carousel;
      case ContentSectionType.productGrid:
        return Icons.grid_view;
      case ContentSectionType.productCarousel:
        return Icons.view_carousel;
      case ContentSectionType.categoryGrid:
        return Icons.category;
      case ContentSectionType.featuredProducts:
        return Icons.star;
      case ContentSectionType.newArrivals:
        return Icons.new_releases;
      case ContentSectionType.bestSellers:
        return Icons.trending_up;
      case ContentSectionType.flashSale:
        return Icons.flash_on;
      case ContentSectionType.testimonials:
        return Icons.format_quote;
      case ContentSectionType.customHtml:
        return Icons.code;
      case ContentSectionType.videoSection:
        return Icons.video_library;
      case ContentSectionType.imageGallery:
        return Icons.photo_library;
    }
  }

  String _getSectionTypeLabel(ContentSectionType type) {
    return type.toString().split('.').last.replaceAllMapped(
          RegExp(r'([A-Z])'),
          (match) => ' ${match.group(0)}',
        ).trim();
  }

  Widget _buildEmptyContentState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.web, size: 64, color: AppColors.textSecondary),
          const SizedBox(height: AppDimensions.lg),
          Text('No content sections', style: AppTypography.titleMedium),
          const SizedBox(height: AppDimensions.sm),
          Text(
            'Add sections to build your homepage',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  void _showAddSectionDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Add Content Section'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: ContentSectionType.values.map((type) {
              return ListTile(
                leading: Icon(_getSectionIcon(type)),
                title: Text(_getSectionTypeLabel(type)),
                onTap: () {
                  Get.back();
                  // Add section logic here
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// ==================== MENUS TAB ====================
class _MenusTab extends StatelessWidget {
  final CMSController controller;

  const _MenusTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppDimensions.lg),
      children: [
        _buildMenuSection(
          context,
          'Header Menu',
          Icons.menu,
          controller.headerMenu.value,
          MenuPosition.header,
        ),
        const SizedBox(height: AppDimensions.xl),
        _buildMenuSection(
          context,
          'Footer Menu',
          Icons.grid_view,
          controller.footerMenu.value,
          MenuPosition.footer,
        ),
        const SizedBox(height: AppDimensions.xl),
        _buildMenuSection(
          context,
          'Mobile Menu',
          Icons.phone_android,
          controller.mobileMenu.value,
          MenuPosition.mobile,
        ),
      ],
    );
  }

  Widget _buildMenuSection(
    BuildContext context,
    String title,
    IconData icon,
    NavigationMenu? menu,
    MenuPosition position,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: AppDimensions.md),
                Text(title, style: AppTypography.titleLarge),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => _showAddMenuItemDialog(context, position),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Item'),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.lg),
            if (menu != null && menu.activeItems.isNotEmpty)
              ...menu.activeItems.map((item) => _buildMenuItem(context, item, position)).toList()
            else
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.xl),
                  child: Text(
                    'No menu items',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, MenuItem item, MenuPosition position) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.sm),
      child: ListTile(
        leading: item.icon != null
            ? Icon(Icons.link)
            : const Icon(Icons.label),
        title: Text(item.label),
        subtitle: item.url != null ? Text(item.url!) : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item.hasChildren)
              Chip(
                label: Text('${item.activeChildren.length} sub-items'),
                backgroundColor: AppColors.info.withOpacity(0.1),
              ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: AppColors.error),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  void _showAddMenuItemDialog(BuildContext context, MenuPosition position) {
    final labelController = TextEditingController();
    final urlController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Add Menu Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: labelController,
              decoration: const InputDecoration(
                labelText: 'Label *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppDimensions.md),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: 'URL',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (labelController.text.isEmpty) return;
              // Add menu item logic here
              Get.back();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
