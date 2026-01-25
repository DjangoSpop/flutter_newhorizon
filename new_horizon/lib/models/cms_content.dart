/// CMS Banner model
class Banner {
  final String id;
  final String title;
  final String? subtitle;
  final String imageUrl;
  final String? mobileImageUrl;
  final String? tabletImageUrl;
  final BannerType type;
  final String? actionUrl;
  final String? actionType;
  final Map<String, dynamic>? actionData;
  final int sortOrder;
  final bool isActive;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? targetAudience;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Banner({
    required this.id,
    required this.title,
    this.subtitle,
    required this.imageUrl,
    this.mobileImageUrl,
    this.tabletImageUrl,
    required this.type,
    this.actionUrl,
    this.actionType,
    this.actionData,
    this.sortOrder = 0,
    this.isActive = true,
    this.startDate,
    this.endDate,
    this.targetAudience,
    required this.createdAt,
    this.updatedAt,
  });

  factory Banner.fromJson(Map<String, dynamic> json) {
    return Banner(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'],
      imageUrl: json['image_url'] ?? '',
      mobileImageUrl: json['mobile_image_url'],
      tabletImageUrl: json['tablet_image_url'],
      type: BannerType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => BannerType.hero,
      ),
      actionUrl: json['action_url'],
      actionType: json['action_type'],
      actionData: json['action_data'],
      sortOrder: json['sort_order'] ?? 0,
      isActive: json['is_active'] ?? true,
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'])
          : null,
      endDate:
          json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      targetAudience: json['target_audience'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt:
          json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
      'target_audience': targetAudience,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  bool get isScheduled => startDate != null || endDate != null;

  bool get isVisible {
    if (!isActive) return false;

    final now = DateTime.now();
    if (startDate != null && now.isBefore(startDate!)) return false;
    if (endDate != null && now.isAfter(endDate!)) return false;

    return true;
  }

  String getResponsiveImageUrl(String deviceType) {
    switch (deviceType) {
      case 'mobile':
        return mobileImageUrl ?? imageUrl;
      case 'tablet':
        return tabletImageUrl ?? mobileImageUrl ?? imageUrl;
      default:
        return imageUrl;
    }
  }
}

enum BannerType {
  hero,
  promotional,
  category,
  product,
  seasonal,
  announcement,
}

/// Content section model
class ContentSection {
  final String id;
  final String name;
  final ContentSectionType type;
  final String? title;
  final String? subtitle;
  final Map<String, dynamic> configuration;
  final int sortOrder;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ContentSection({
    required this.id,
    required this.name,
    required this.type,
    this.title,
    this.subtitle,
    required this.configuration,
    this.sortOrder = 0,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory ContentSection.fromJson(Map<String, dynamic> json) {
    return ContentSection(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: ContentSectionType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => ContentSectionType.productGrid,
      ),
      title: json['title'],
      subtitle: json['subtitle'],
      configuration: json['configuration'] ?? {},
      sortOrder: json['sort_order'] ?? 0,
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt:
          json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toString().split('.').last,
      'title': title,
      'subtitle': subtitle,
      'configuration': configuration,
      'sort_order': sortOrder,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

enum ContentSectionType {
  bannerCarousel,
  productGrid,
  productCarousel,
  categoryGrid,
  featuredProducts,
  newArrivals,
  bestSellers,
  flashSale,
  testimonials,
  customHtml,
  videoSection,
  imageGallery,
}

/// Page content model
class PageContent {
  final String id;
  final String pageName;
  final String? pageTitle;
  final String? pageDescription;
  final List<ContentSection> sections;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? publishedAt;

  PageContent({
    required this.id,
    required this.pageName,
    this.pageTitle,
    this.pageDescription,
    required this.sections,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
    this.publishedAt,
  });

  factory PageContent.fromJson(Map<String, dynamic> json) {
    return PageContent(
      id: json['id'] ?? '',
      pageName: json['page_name'] ?? '',
      pageTitle: json['page_title'],
      pageDescription: json['page_description'],
      sections: (json['sections'] as List?)
              ?.map((s) => ContentSection.fromJson(s))
              .toList() ??
          [],
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt:
          json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      publishedAt: json['published_at'] != null
          ? DateTime.parse(json['published_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'page_name': pageName,
      'page_title': pageTitle,
      'page_description': pageDescription,
      'sections': sections.map((s) => s.toJson()).toList(),
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'published_at': publishedAt?.toIso8601String(),
    };
  }

  bool get isPublished => publishedAt != null && isActive;

  List<ContentSection> get activeSections {
    return sections.where((s) => s.isActive).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }
}

/// Navigation menu model
class NavigationMenu {
  final String id;
  final String name;
  final MenuPosition position;
  final List<MenuItem> items;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  NavigationMenu({
    required this.id,
    required this.name,
    required this.position,
    required this.items,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory NavigationMenu.fromJson(Map<String, dynamic> json) {
    return NavigationMenu(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      position: MenuPosition.values.firstWhere(
        (e) => e.toString().split('.').last == json['position'],
        orElse: () => MenuPosition.header,
      ),
      items: (json['items'] as List?)
              ?.map((i) => MenuItem.fromJson(i))
              .toList() ??
          [],
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt:
          json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'position': position.toString().split('.').last,
      'items': items.map((i) => i.toJson()).toList(),
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  List<MenuItem> get activeItems {
    return items.where((i) => i.isActive).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }
}

enum MenuPosition {
  header,
  footer,
  sidebar,
  mobile,
}

class MenuItem {
  final String id;
  final String label;
  final String? icon;
  final String? url;
  final String? actionType;
  final Map<String, dynamic>? actionData;
  final List<MenuItem> children;
  final int sortOrder;
  final bool isActive;

  MenuItem({
    required this.id,
    required this.label,
    this.icon,
    this.url,
    this.actionType,
    this.actionData,
    this.children = const [],
    this.sortOrder = 0,
    this.isActive = true,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] ?? '',
      label: json['label'] ?? '',
      icon: json['icon'],
      url: json['url'],
      actionType: json['action_type'],
      actionData: json['action_data'],
      children: (json['children'] as List?)
              ?.map((c) => MenuItem.fromJson(c))
              .toList() ??
          [],
      sortOrder: json['sort_order'] ?? 0,
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'icon': icon,
      'url': url,
      'action_type': actionType,
      'action_data': actionData,
      'children': children.map((c) => c.toJson()).toList(),
      'sort_order': sortOrder,
      'is_active': isActive,
    };
  }

  bool get hasChildren => children.isNotEmpty;

  List<MenuItem> get activeChildren {
    return children.where((c) => c.isActive).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }
}

/// SEO meta data model
class SEOMetaData {
  final String pageId;
  final String? metaTitle;
  final String? metaDescription;
  final List<String>? metaKeywords;
  final String? ogTitle;
  final String? ogDescription;
  final String? ogImage;
  final String? twitterCard;
  final String? canonicalUrl;
  final Map<String, dynamic>? structuredData;

  SEOMetaData({
    required this.pageId,
    this.metaTitle,
    this.metaDescription,
    this.metaKeywords,
    this.ogTitle,
    this.ogDescription,
    this.ogImage,
    this.twitterCard,
    this.canonicalUrl,
    this.structuredData,
  });

  factory SEOMetaData.fromJson(Map<String, dynamic> json) {
    return SEOMetaData(
      pageId: json['page_id'] ?? '',
      metaTitle: json['meta_title'],
      metaDescription: json['meta_description'],
      metaKeywords: json['meta_keywords'] != null
          ? List<String>.from(json['meta_keywords'])
          : null,
      ogTitle: json['og_title'],
      ogDescription: json['og_description'],
      ogImage: json['og_image'],
      twitterCard: json['twitter_card'],
      canonicalUrl: json['canonical_url'],
      structuredData: json['structured_data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page_id': pageId,
      'meta_title': metaTitle,
      'meta_description': metaDescription,
      'meta_keywords': metaKeywords,
      'og_title': ogTitle,
      'og_description': ogDescription,
      'og_image': ogImage,
      'twitter_card': twitterCard,
      'canonical_url': canonicalUrl,
      'structured_data': structuredData,
    };
  }
}
