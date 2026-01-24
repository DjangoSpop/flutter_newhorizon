/// Spacing, sizing, and dimension constants for consistent UI
class AppDimensions {
  AppDimensions._(); // Private constructor

  // ============================================
  // Spacing System (8px base unit)
  // ============================================

  /// Extra extra small spacing (2px)
  static const double xxs = 2.0;

  /// Extra small spacing (4px)
  static const double xs = 4.0;

  /// Small spacing (8px)
  static const double sm = 8.0;

  /// Medium spacing (12px)
  static const double md = 12.0;

  /// Large spacing (16px)
  static const double lg = 16.0;

  /// Extra large spacing (24px)
  static const double xl = 24.0;

  /// Extra extra large spacing (32px)
  static const double xxl = 32.0;

  /// Extra extra extra large spacing (48px)
  static const double xxxl = 48.0;

  /// Massive spacing (64px)
  static const double massive = 64.0;

  // ============================================
  // Padding Presets
  // ============================================

  /// Page horizontal padding
  static const double pagePaddingHorizontal = 16.0;

  /// Page vertical padding
  static const double pagePaddingVertical = 16.0;

  /// Card padding
  static const double cardPadding = 16.0;

  /// Section spacing
  static const double sectionSpacing = 24.0;

  /// Item spacing in lists
  static const double listItemSpacing = 12.0;

  // ============================================
  // Border Radius
  // ============================================

  /// No radius
  static const double radiusNone = 0.0;

  /// Extra small radius
  static const double radiusXs = 4.0;

  /// Small radius
  static const double radiusSm = 8.0;

  /// Medium radius
  static const double radiusMd = 12.0;

  /// Large radius
  static const double radiusLg = 16.0;

  /// Extra large radius
  static const double radiusXl = 20.0;

  /// Round (circle or pill)
  static const double radiusRound = 999.0;

  /// Card border radius
  static const double cardRadius = 12.0;

  /// Button border radius
  static const double buttonRadius = 8.0;

  /// Dialog border radius
  static const double dialogRadius = 16.0;

  /// Bottom sheet border radius
  static const double bottomSheetRadius = 24.0;

  // ============================================
  // Icon Sizes
  // ============================================

  /// Extra small icon (12px)
  static const double iconXs = 12.0;

  /// Small icon (16px)
  static const double iconSm = 16.0;

  /// Medium icon (24px)
  static const double iconMd = 24.0;

  /// Large icon (32px)
  static const double iconLg = 32.0;

  /// Extra large icon (48px)
  static const double iconXl = 48.0;

  /// Extra extra large icon (64px)
  static const double iconXxl = 64.0;

  // ============================================
  // Button Sizes
  // ============================================

  /// Small button height
  static const double buttonHeightSm = 36.0;

  /// Medium button height
  static const double buttonHeightMd = 48.0;

  /// Large button height
  static const double buttonHeightLg = 56.0;

  /// Button horizontal padding
  static const double buttonPaddingHorizontal = 24.0;

  /// Button minimum width
  static const double buttonMinWidth = 120.0;

  // ============================================
  // Input Field Sizes
  // ============================================

  /// Input field height
  static const double inputHeight = 56.0;

  /// Input field padding
  static const double inputPadding = 16.0;

  /// Input field border width
  static const double inputBorderWidth = 1.0;

  // ============================================
  // Product Card Dimensions
  // ============================================

  /// Product card image aspect ratio (width / height)
  static const double productImageAspectRatio = 0.75; // Portrait (3:4)

  /// Product card height (small grid)
  static const double productCardHeightSm = 280.0;

  /// Product card height (medium list)
  static const double productCardHeightMd = 320.0;

  /// Product card height (large featured)
  static const double productCardHeightLg = 400.0;

  /// Product card width (small grid)
  static const double productCardWidthSm = 160.0;

  /// Product card width (medium grid)
  static const double productCardWidthMd = 180.0;

  /// Product grid spacing
  static const double productGridSpacing = 12.0;

  /// Product grid cross-axis count (columns)
  static const int productGridColumns = 2;

  // ============================================
  // Image Sizes
  // ============================================

  /// Thumbnail size
  static const double thumbnailSize = 60.0;

  /// Small image size
  static const double imageSizeSm = 100.0;

  /// Medium image size
  static const double imageSizeMd = 200.0;

  /// Large image size
  static const double imageSizeLg = 300.0;

  /// Avatar size small
  static const double avatarSizeSm = 32.0;

  /// Avatar size medium
  static const double avatarSizeMd = 48.0;

  /// Avatar size large
  static const double avatarSizeLg = 64.0;

  /// Avatar size extra large
  static const double avatarSizeXl = 96.0;

  // ============================================
  // Border Widths
  // ============================================

  /// Thin border
  static const double borderThin = 1.0;

  /// Medium border
  static const double borderMedium = 2.0;

  /// Thick border
  static const double borderThick = 3.0;

  /// Divider thickness
  static const double dividerThickness = 1.0;

  // ============================================
  // Elevation / Shadow
  // ============================================

  /// No elevation
  static const double elevationNone = 0.0;

  /// Low elevation
  static const double elevationLow = 2.0;

  /// Medium elevation
  static const double elevationMedium = 4.0;

  /// High elevation
  static const double elevationHigh = 8.0;

  /// Extra high elevation
  static const double elevationXHigh = 16.0;

  // ============================================
  // App Bar
  // ============================================

  /// App bar height
  static const double appBarHeight = 56.0;

  /// App bar elevation
  static const double appBarElevation = 0.0;

  /// Search bar height
  static const double searchBarHeight = 48.0;

  // ============================================
  // Bottom Navigation
  // ============================================

  /// Bottom nav bar height
  static const double bottomNavHeight = 60.0;

  /// Bottom nav icon size
  static const double bottomNavIconSize = 24.0;

  // ============================================
  // Cart & Checkout
  // ============================================

  /// Cart item height
  static const double cartItemHeight = 120.0;

  /// Cart item image size
  static const double cartItemImageSize = 80.0;

  /// Quantity selector size
  static const double quantitySelectorSize = 32.0;

  // ============================================
  // Badges
  // ============================================

  /// Badge size small
  static const double badgeSizeSm = 16.0;

  /// Badge size medium
  static const double badgeSizeMd = 20.0;

  /// Badge size large
  static const double badgeSizeLg = 24.0;

  /// Badge padding
  static const double badgePadding = 4.0;

  // ============================================
  // Dialogs & Bottom Sheets
  // ============================================

  /// Dialog max width
  static const double dialogMaxWidth = 400.0;

  /// Dialog padding
  static const double dialogPadding = 24.0;

  /// Bottom sheet max height ratio
  static const double bottomSheetMaxHeightRatio = 0.9;

  /// Bottom sheet min height
  static const double bottomSheetMinHeight = 200.0;

  // ============================================
  // Loading & Shimmer
  // ============================================

  /// Loading indicator size
  static const double loadingIndicatorSize = 40.0;

  /// Shimmer item height
  static const double shimmerItemHeight = 200.0;

  // ============================================
  // Responsive Breakpoints
  // ============================================

  /// Mobile breakpoint
  static const double breakpointMobile = 600.0;

  /// Tablet breakpoint
  static const double breakpointTablet = 900.0;

  /// Desktop breakpoint
  static const double breakpointDesktop = 1200.0;

  /// Max content width for web
  static const double maxContentWidth = 1440.0;

  // ============================================
  // Animation Durations (milliseconds)
  // ============================================

  /// Fast animation (150ms)
  static const int animationFast = 150;

  /// Normal animation (300ms)
  static const int animationNormal = 300;

  /// Slow animation (500ms)
  static const int animationSlow = 500;

  // ============================================
  // Utility Methods
  // ============================================

  /// Get responsive padding based on screen width
  static double getResponsivePadding(double screenWidth) {
    if (screenWidth < breakpointMobile) {
      return pagePaddingHorizontal;
    } else if (screenWidth < breakpointTablet) {
      return xl;
    } else {
      return xxl;
    }
  }

  /// Get product grid columns based on screen width
  static int getProductGridColumns(double screenWidth) {
    if (screenWidth < breakpointMobile) {
      return 2;
    } else if (screenWidth < breakpointTablet) {
      return 3;
    } else if (screenWidth < breakpointDesktop) {
      return 4;
    } else {
      return 5;
    }
  }

  /// Check if screen is mobile
  static bool isMobile(double screenWidth) {
    return screenWidth < breakpointMobile;
  }

  /// Check if screen is tablet
  static bool isTablet(double screenWidth) {
    return screenWidth >= breakpointMobile && screenWidth < breakpointDesktop;
  }

  /// Check if screen is desktop
  static bool isDesktop(double screenWidth) {
    return screenWidth >= breakpointDesktop;
  }
}
