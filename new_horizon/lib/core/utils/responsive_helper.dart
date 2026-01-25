import 'package:flutter/material.dart';

/// Responsive breakpoints
class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
  static const double largeDesktop = 1600;
}

/// Device type enum
enum DeviceType {
  mobile,
  tablet,
  desktop,
  largeDesktop,
}

/// Responsive helper class for adaptive layouts
class ResponsiveHelper {
  /// Get device type based on screen width
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < Breakpoints.mobile) {
      return DeviceType.mobile;
    } else if (width < Breakpoints.tablet) {
      return DeviceType.tablet;
    } else if (width < Breakpoints.desktop) {
      return DeviceType.desktop;
    } else {
      return DeviceType.largeDesktop;
    }
  }

  /// Check if device is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < Breakpoints.mobile;
  }

  /// Check if device is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= Breakpoints.mobile && width < Breakpoints.tablet;
  }

  /// Check if device is desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= Breakpoints.tablet;
  }

  /// Check if device is large desktop
  static bool isLargeDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= Breakpoints.largeDesktop;
  }

  /// Get responsive value based on device type
  static T getValue<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
    T? largeDesktop,
  }) {
    final deviceType = getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
      case DeviceType.largeDesktop:
        return largeDesktop ?? desktop ?? tablet ?? mobile;
    }
  }

  /// Get number of grid columns based on screen width
  static int getGridColumns(BuildContext context, {int? min, int? max}) {
    final width = MediaQuery.of(context).size.width;
    int columns;

    if (width < Breakpoints.mobile) {
      columns = 2;
    } else if (width < Breakpoints.tablet) {
      columns = 3;
    } else if (width < Breakpoints.desktop) {
      columns = 4;
    } else if (width < Breakpoints.largeDesktop) {
      columns = 5;
    } else {
      columns = 6;
    }

    if (min != null && columns < min) columns = min;
    if (max != null && columns > max) columns = max;

    return columns;
  }

  /// Get responsive padding
  static EdgeInsets getResponsivePadding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: getValue(
        context,
        mobile: 16.0,
        tablet: 24.0,
        desktop: 32.0,
        largeDesktop: 48.0,
      ),
      vertical: getValue(
        context,
        mobile: 16.0,
        tablet: 20.0,
        desktop: 24.0,
      ),
    );
  }

  /// Get responsive horizontal padding
  static EdgeInsets getHorizontalPadding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: getValue(
        context,
        mobile: 16.0,
        tablet: 24.0,
        desktop: 32.0,
        largeDesktop: 48.0,
      ),
    );
  }

  /// Get responsive font size
  static double getFontSize(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    return getValue(
      context,
      mobile: mobile,
      tablet: tablet ?? mobile * 1.1,
      desktop: desktop ?? tablet ?? mobile * 1.2,
    );
  }

  /// Get maximum content width for centered layouts
  static double getMaxContentWidth(BuildContext context) {
    return getValue(
      context,
      mobile: double.infinity,
      tablet: 768,
      desktop: 1024,
      largeDesktop: 1280,
    );
  }

  /// Get responsive spacing
  static double getSpacing(BuildContext context) {
    return getValue(
      context,
      mobile: 8.0,
      tablet: 12.0,
      desktop: 16.0,
    );
  }

  /// Get responsive card width
  static double getCardWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final columns = getGridColumns(context);
    final spacing = getSpacing(context);
    final horizontalPadding = getHorizontalPadding(context).horizontal;

    return (screenWidth - horizontalPadding - (spacing * (columns - 1))) /
        columns;
  }

  /// Check if should show drawer (mobile) or permanent navigation (desktop)
  static bool shouldShowDrawer(BuildContext context) {
    return !isDesktop(context);
  }

  /// Get app bar height
  static double getAppBarHeight(BuildContext context) {
    return getValue(
      context,
      mobile: 56.0,
      tablet: 64.0,
      desktop: 72.0,
    );
  }

  /// Get responsive icon size
  static double getIconSize(BuildContext context, {double base = 24.0}) {
    return getValue(
      context,
      mobile: base,
      tablet: base * 1.1,
      desktop: base * 1.2,
    );
  }

  /// Get responsive border radius
  static double getBorderRadius(BuildContext context, {double base = 12.0}) {
    return getValue(
      context,
      mobile: base,
      tablet: base * 1.1,
      desktop: base * 1.2,
    );
  }
}

/// Responsive builder widget
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, DeviceType deviceType) builder;

  const ResponsiveBuilder({
    Key? key,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final deviceType = ResponsiveHelper.getDeviceType(context);
    return builder(context, deviceType);
  }
}

/// Responsive layout widget with different layouts for different screen sizes
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? largeDesktop;

  const ResponsiveLayout({
    Key? key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType) {
        switch (deviceType) {
          case DeviceType.mobile:
            return mobile;
          case DeviceType.tablet:
            return tablet ?? mobile;
          case DeviceType.desktop:
            return desktop ?? tablet ?? mobile;
          case DeviceType.largeDesktop:
            return largeDesktop ?? desktop ?? tablet ?? mobile;
        }
      },
    );
  }
}

/// Centered content container with max width
class CenteredContentContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? backgroundColor;

  const CenteredContentContainer({
    Key? key,
    required this.child,
    this.padding,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: ResponsiveHelper.getMaxContentWidth(context),
          ),
          padding: padding ?? ResponsiveHelper.getResponsivePadding(context),
          child: child,
        ),
      ),
    );
  }
}

/// Responsive grid view
class ResponsiveGridView extends StatelessWidget {
  final List<Widget> children;
  final int? minColumns;
  final int? maxColumns;
  final double? mainAxisSpacing;
  final double? crossAxisSpacing;
  final double? childAspectRatio;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final EdgeInsets? padding;

  const ResponsiveGridView({
    Key? key,
    required this.children,
    this.minColumns,
    this.maxColumns,
    this.mainAxisSpacing,
    this.crossAxisSpacing,
    this.childAspectRatio,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final columns = ResponsiveHelper.getGridColumns(
      context,
      min: minColumns,
      max: maxColumns,
    );
    final spacing = ResponsiveHelper.getSpacing(context);

    return GridView.count(
      crossAxisCount: columns,
      mainAxisSpacing: mainAxisSpacing ?? spacing,
      crossAxisSpacing: crossAxisSpacing ?? spacing,
      childAspectRatio: childAspectRatio ?? 0.75,
      physics: physics,
      shrinkWrap: shrinkWrap,
      padding: padding ?? ResponsiveHelper.getResponsivePadding(context),
      children: children,
    );
  }
}

/// Responsive card
class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? color;
  final double? elevation;
  final VoidCallback? onTap;

  const ResponsiveCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.elevation,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final borderRadius = ResponsiveHelper.getBorderRadius(context);

    return Card(
      elevation: elevation ?? 2,
      color: color,
      margin: margin,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Padding(
          padding: padding ??
              EdgeInsets.all(ResponsiveHelper.getValue(
                context,
                mobile: 12.0,
                tablet: 16.0,
                desktop: 20.0,
              )),
          child: child,
        ),
      ),
    );
  }
}

/// Responsive text
class ResponsiveText extends StatelessWidget {
  final String text;
  final double mobileFontSize;
  final double? tabletFontSize;
  final double? desktopFontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextStyle? style;

  const ResponsiveText(
    this.text, {
    Key? key,
    required this.mobileFontSize,
    this.tabletFontSize,
    this.desktopFontSize,
    this.fontWeight,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fontSize = ResponsiveHelper.getFontSize(
      context,
      mobile: mobileFontSize,
      tablet: tabletFontSize,
      desktop: desktopFontSize,
    );

    return Text(
      text,
      style: (style ?? const TextStyle()).copyWith(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// Responsive spacing widget
class ResponsiveSpacing extends StatelessWidget {
  final double mobile;
  final double? tablet;
  final double? desktop;
  final bool isHorizontal;

  const ResponsiveSpacing({
    Key? key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.isHorizontal = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final spacing = ResponsiveHelper.getValue(
      context,
      mobile: mobile,
      tablet: tablet ?? mobile,
      desktop: desktop ?? tablet ?? mobile,
    );

    return SizedBox(
      width: isHorizontal ? spacing : null,
      height: !isHorizontal ? spacing : null,
    );
  }
}

/// Responsive row/column widget
class ResponsiveRowColumn extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final bool forceColumn;
  final double? spacing;

  const ResponsiveRowColumn({
    Key? key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.forceColumn = false,
    this.spacing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final shouldUseColumn = forceColumn || ResponsiveHelper.isMobile(context);
    final spacingValue = spacing ?? ResponsiveHelper.getSpacing(context);

    final childrenWithSpacing = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      childrenWithSpacing.add(children[i]);
      if (i < children.length - 1) {
        childrenWithSpacing.add(SizedBox(
          width: shouldUseColumn ? 0 : spacingValue,
          height: shouldUseColumn ? spacingValue : 0,
        ));
      }
    }

    if (shouldUseColumn) {
      return Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: childrenWithSpacing,
      );
    } else {
      return Row(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: childrenWithSpacing,
      );
    }
  }
}
