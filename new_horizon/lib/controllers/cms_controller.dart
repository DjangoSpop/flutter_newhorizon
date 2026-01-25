import 'package:get/get.dart';
import '../models/cms_content.dart';
import '../service/cms_service.dart';

class CMSController extends GetxController {
  final CMSService _cmsService = Get.find<CMSService>();

  // Observable state
  var banners = <Banner>[].obs;
  var heroBanners = <Banner>[].obs;
  var promotionalBanners = <Banner>[].obs;
  var homePageContent = Rx<PageContent?>(null);
  var headerMenu = Rx<NavigationMenu?>(null);
  var footerMenu = Rx<NavigationMenu?>(null);
  var mobileMenu = Rx<NavigationMenu?>(null);

  var isLoading = false.obs;
  var isLoadingBanners = false.obs;
  var isLoadingMenus = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadBanners();
    loadHomePageContent();
    loadMenus();
  }

  /// Load all banners
  Future<void> loadBanners({BannerType? type}) async {
    try {
      isLoadingBanners.value = true;

      final fetchedBanners = await _cmsService.getVisibleBanners(type: type);
      banners.value = fetchedBanners;

      // Filter by type
      heroBanners.value =
          fetchedBanners.where((b) => b.type == BannerType.hero).toList();
      promotionalBanners.value = fetchedBanners
          .where((b) => b.type == BannerType.promotional)
          .toList();
    } catch (e) {
      print('Error loading banners: $e');
    } finally {
      isLoadingBanners.value = false;
    }
  }

  /// Load homepage content
  Future<void> loadHomePageContent() async {
    try {
      isLoading.value = true;

      final content = await _cmsService.getPageContent('home');
      homePageContent.value = content;
    } catch (e) {
      print('Error loading homepage content: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load page content by name
  Future<PageContent?> loadPageContent(String pageName) async {
    try {
      isLoading.value = true;

      final content = await _cmsService.getPageContent(pageName);
      return content;
    } catch (e) {
      print('Error loading page content: $e');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// Load navigation menus
  Future<void> loadMenus() async {
    try {
      isLoadingMenus.value = true;

      final results = await Future.wait([
        _cmsService.getMenu(MenuPosition.header),
        _cmsService.getMenu(MenuPosition.footer),
        _cmsService.getMenu(MenuPosition.mobile),
      ]);

      headerMenu.value = results[0];
      footerMenu.value = results[1];
      mobileMenu.value = results[2];
    } catch (e) {
      print('Error loading menus: $e');
    } finally {
      isLoadingMenus.value = false;
    }
  }

  /// Create banner (admin only)
  Future<bool> createBanner({
    required String title,
    String? subtitle,
    required String imageUrl,
    String? mobileImageUrl,
    String? tabletImageUrl,
    required BannerType type,
    String? actionUrl,
    String? actionType,
    Map<String, dynamic>? actionData,
    int sortOrder = 0,
    bool isActive = true,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      isLoading.value = true;

      final banner = await _cmsService.createBanner(
        title: title,
        subtitle: subtitle,
        imageUrl: imageUrl,
        mobileImageUrl: mobileImageUrl,
        tabletImageUrl: tabletImageUrl,
        type: type,
        actionUrl: actionUrl,
        actionType: actionType,
        actionData: actionData,
        sortOrder: sortOrder,
        isActive: isActive,
        startDate: startDate,
        endDate: endDate,
      );

      banners.add(banner);
      banners.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

      // Update type-specific lists
      if (banner.type == BannerType.hero) {
        heroBanners.add(banner);
      } else if (banner.type == BannerType.promotional) {
        promotionalBanners.add(banner);
      }

      Get.snackbar(
        'Success',
        'Banner created successfully',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Update banner (admin only)
  Future<bool> updateBanner({
    required String bannerId,
    String? title,
    String? subtitle,
    String? imageUrl,
    String? mobileImageUrl,
    String? tabletImageUrl,
    BannerType? type,
    String? actionUrl,
    bool? isActive,
    int? sortOrder,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      isLoading.value = true;

      final updatedBanner = await _cmsService.updateBanner(
        bannerId: bannerId,
        title: title,
        subtitle: subtitle,
        imageUrl: imageUrl,
        mobileImageUrl: mobileImageUrl,
        tabletImageUrl: tabletImageUrl,
        type: type,
        actionUrl: actionUrl,
        isActive: isActive,
        sortOrder: sortOrder,
        startDate: startDate,
        endDate: endDate,
      );

      // Update in list
      final index = banners.indexWhere((b) => b.id == bannerId);
      if (index != -1) {
        banners[index] = updatedBanner;
        banners.refresh();
      }

      // Update type-specific lists
      _updateTypeLists();

      Get.snackbar(
        'Success',
        'Banner updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Delete banner (admin only)
  Future<bool> deleteBanner(String bannerId) async {
    try {
      isLoading.value = true;

      final success = await _cmsService.deleteBanner(bannerId);

      if (success) {
        banners.removeWhere((b) => b.id == bannerId);
        _updateTypeLists();

        Get.snackbar(
          'Success',
          'Banner deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
        );

        return true;
      } else {
        throw Exception('Failed to delete banner');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Update page content (admin only)
  Future<bool> updatePageContent({
    required String pageName,
    String? pageTitle,
    String? pageDescription,
    List<ContentSection>? sections,
    bool? isActive,
  }) async {
    try {
      isLoading.value = true;

      final updatedContent = await _cmsService.updatePageContent(
        pageName: pageName,
        pageTitle: pageTitle,
        pageDescription: pageDescription,
        sections: sections,
        isActive: isActive,
      );

      if (pageName == 'home') {
        homePageContent.value = updatedContent;
      }

      Get.snackbar(
        'Success',
        'Page content updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Update navigation menu (admin only)
  Future<bool> updateMenu({
    required MenuPosition position,
    List<MenuItem>? items,
    bool? isActive,
  }) async {
    try {
      isLoading.value = true;

      final updatedMenu = await _cmsService.updateMenu(
        position: position,
        items: items,
        isActive: isActive,
      );

      // Update the appropriate menu
      switch (position) {
        case MenuPosition.header:
          headerMenu.value = updatedMenu;
          break;
        case MenuPosition.footer:
          footerMenu.value = updatedMenu;
          break;
        case MenuPosition.mobile:
          mobileMenu.value = updatedMenu;
          break;
        case MenuPosition.sidebar:
          // Handle sidebar menu if needed
          break;
      }

      Get.snackbar(
        'Success',
        'Menu updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh all CMS content
  Future<void> refreshAllContent() async {
    await Future.wait([
      loadBanners(),
      loadHomePageContent(),
      loadMenus(),
    ]);
  }

  /// Update type-specific banner lists
  void _updateTypeLists() {
    heroBanners.value =
        banners.where((b) => b.type == BannerType.hero).toList();
    promotionalBanners.value =
        banners.where((b) => b.type == BannerType.promotional).toList();
  }

  /// Get banners by type
  List<Banner> getBannersByType(BannerType type) {
    return banners.where((b) => b.type == type && b.isVisible).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  /// Get active sections for homepage
  List<ContentSection> get homePageSections {
    return homePageContent.value?.activeSections ?? [];
  }

  /// Get active header menu items
  List<MenuItem> get headerMenuItems {
    return headerMenu.value?.activeItems ?? [];
  }

  /// Get active footer menu items
  List<MenuItem> get footerMenuItems {
    return footerMenu.value?.activeItems ?? [];
  }

  /// Get active mobile menu items
  List<MenuItem> get mobileMenuItems {
    return mobileMenu.value?.activeItems ?? [];
  }

  /// Clear CMS cache
  Future<void> clearCache() async {
    try {
      await _cmsService.clearCache();
      banners.clear();
      heroBanners.clear();
      promotionalBanners.clear();
      homePageContent.value = null;
      headerMenu.value = null;
      footerMenu.value = null;
      mobileMenu.value = null;
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }
}
