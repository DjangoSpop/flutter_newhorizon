import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cms_content.dart';

class CMSService extends GetxService {
  final String baseUrl = 'http://your-backend-url.com/api';

  /// Get banners
  Future<List<Banner>> getBanners({
    BannerType? type,
    bool? activeOnly,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (type != null) queryParams['type'] = type.toString().split('.').last;
      if (activeOnly == true) queryParams['active_only'] = 'true';

      final uri = Uri.parse('$baseUrl/cms/banners/')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> bannersJson = data['results'] ?? data;

        final banners =
            bannersJson.map((json) => Banner.fromJson(json)).toList();

        // Cache banners
        await _cacheBanners(banners);

        return banners;
      } else {
        return _getCachedBanners();
      }
    } catch (e) {
      print('Error fetching banners: $e');
      return _getCachedBanners();
    }
  }

  /// Get visible banners (respecting schedule and active status)
  Future<List<Banner>> getVisibleBanners({BannerType? type}) async {
    try {
      final banners = await getBanners(type: type, activeOnly: true);
      return banners.where((b) => b.isVisible).toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    } catch (e) {
      print('Error getting visible banners: $e');
      return [];
    }
  }

  /// Create banner (admin only)
  Future<Banner> createBanner({
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
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (authToken == null) {
        throw Exception('Authentication required');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/cms/banners/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'title': title,
          'subtitle': subtitle,
          'image_url': imageUrl,
          'mobile_image_url': mobileImageUrl,
          'tablet_image_url': tabletImageUrl,
          'type': type.toString().split('.').last,
          'action_url': actionUrl,
          'action_type': actionType,
          'action_data': actionData,
          'sort_order': sortOrder,
          'is_active': isActive,
          'start_date': startDate?.toIso8601String(),
          'end_date': endDate?.toIso8601String(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Banner.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to create banner');
      }
    } catch (e) {
      print('Error creating banner: $e');
      rethrow;
    }
  }

  /// Update banner (admin only)
  Future<Banner> updateBanner({
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
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (authToken == null) {
        throw Exception('Authentication required');
      }

      final updates = <String, dynamic>{};
      if (title != null) updates['title'] = title;
      if (subtitle != null) updates['subtitle'] = subtitle;
      if (imageUrl != null) updates['image_url'] = imageUrl;
      if (mobileImageUrl != null) updates['mobile_image_url'] = mobileImageUrl;
      if (tabletImageUrl != null) updates['tablet_image_url'] = tabletImageUrl;
      if (type != null) updates['type'] = type.toString().split('.').last;
      if (actionUrl != null) updates['action_url'] = actionUrl;
      if (isActive != null) updates['is_active'] = isActive;
      if (sortOrder != null) updates['sort_order'] = sortOrder;
      if (startDate != null) updates['start_date'] = startDate.toIso8601String();
      if (endDate != null) updates['end_date'] = endDate.toIso8601String();

      final response = await http.patch(
        Uri.parse('$baseUrl/cms/banners/$bannerId/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(updates),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Banner.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to update banner');
      }
    } catch (e) {
      print('Error updating banner: $e');
      rethrow;
    }
  }

  /// Delete banner (admin only)
  Future<bool> deleteBanner(String bannerId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (authToken == null) {
        throw Exception('Authentication required');
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/cms/banners/$bannerId/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Error deleting banner: $e');
      return false;
    }
  }

  /// Get page content
  Future<PageContent?> getPageContent(String pageName) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/cms/pages/$pageName/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final pageContent = PageContent.fromJson(data);

        // Cache page content
        await _cachePageContent(pageName, pageContent);

        return pageContent;
      } else {
        return _getCachedPageContent(pageName);
      }
    } catch (e) {
      print('Error fetching page content: $e');
      return _getCachedPageContent(pageName);
    }
  }

  /// Update page content (admin only)
  Future<PageContent> updatePageContent({
    required String pageName,
    String? pageTitle,
    String? pageDescription,
    List<ContentSection>? sections,
    bool? isActive,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (authToken == null) {
        throw Exception('Authentication required');
      }

      final updates = <String, dynamic>{};
      if (pageTitle != null) updates['page_title'] = pageTitle;
      if (pageDescription != null) updates['page_description'] = pageDescription;
      if (sections != null) {
        updates['sections'] = sections.map((s) => s.toJson()).toList();
      }
      if (isActive != null) updates['is_active'] = isActive;

      final response = await http.put(
        Uri.parse('$baseUrl/cms/pages/$pageName/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(updates),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return PageContent.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to update page content');
      }
    } catch (e) {
      print('Error updating page content: $e');
      rethrow;
    }
  }

  /// Get navigation menu
  Future<NavigationMenu?> getMenu(MenuPosition position) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/cms/menus/${position.toString().split('.').last}/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final menu = NavigationMenu.fromJson(data);

        // Cache menu
        await _cacheMenu(position, menu);

        return menu;
      } else {
        return _getCachedMenu(position);
      }
    } catch (e) {
      print('Error fetching menu: $e');
      return _getCachedMenu(position);
    }
  }

  /// Update navigation menu (admin only)
  Future<NavigationMenu> updateMenu({
    required MenuPosition position,
    List<MenuItem>? items,
    bool? isActive,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (authToken == null) {
        throw Exception('Authentication required');
      }

      final updates = <String, dynamic>{};
      if (items != null) {
        updates['items'] = items.map((i) => i.toJson()).toList();
      }
      if (isActive != null) updates['is_active'] = isActive;

      final response = await http.put(
        Uri.parse('$baseUrl/cms/menus/${position.toString().split('.').last}/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(updates),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return NavigationMenu.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to update menu');
      }
    } catch (e) {
      print('Error updating menu: $e');
      rethrow;
    }
  }

  /// Cache banners locally
  Future<void> _cacheBanners(List<Banner> banners) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bannersJson = banners.map((b) => b.toJson()).toList();
      await prefs.setString('cached_banners', jsonEncode(bannersJson));
    } catch (e) {
      print('Error caching banners: $e');
    }
  }

  /// Get cached banners
  Future<List<Banner>> _getCachedBanners() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('cached_banners');

      if (cachedData != null) {
        final List<dynamic> bannersJson = jsonDecode(cachedData);
        return bannersJson.map((json) => Banner.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      print('Error getting cached banners: $e');
      return [];
    }
  }

  /// Cache page content locally
  Future<void> _cachePageContent(String pageName, PageContent content) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'cached_page_$pageName',
        jsonEncode(content.toJson()),
      );
    } catch (e) {
      print('Error caching page content: $e');
    }
  }

  /// Get cached page content
  Future<PageContent?> _getCachedPageContent(String pageName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('cached_page_$pageName');

      if (cachedData != null) {
        return PageContent.fromJson(jsonDecode(cachedData));
      }

      return null;
    } catch (e) {
      print('Error getting cached page content: $e');
      return null;
    }
  }

  /// Cache menu locally
  Future<void> _cacheMenu(MenuPosition position, NavigationMenu menu) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'cached_menu_${position.toString().split('.').last}',
        jsonEncode(menu.toJson()),
      );
    } catch (e) {
      print('Error caching menu: $e');
    }
  }

  /// Get cached menu
  Future<NavigationMenu?> _getCachedMenu(MenuPosition position) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(
        'cached_menu_${position.toString().split('.').last}',
      );

      if (cachedData != null) {
        return NavigationMenu.fromJson(jsonDecode(cachedData));
      }

      return null;
    } catch (e) {
      print('Error getting cached menu: $e');
      return null;
    }
  }

  /// Clear CMS cache
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();

      for (var key in keys) {
        if (key.startsWith('cached_banners') ||
            key.startsWith('cached_page_') ||
            key.startsWith('cached_menu_')) {
          await prefs.remove(key);
        }
      }
    } catch (e) {
      print('Error clearing CMS cache: $e');
    }
  }
}
