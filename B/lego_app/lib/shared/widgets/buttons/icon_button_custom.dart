import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';

/// Custom icon button with consistent styling
class IconButtonCustom extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? iconColor;
  final Color? backgroundColor;
  final double? size;
  final double? iconSize;
  final String? tooltip;
  final bool hasBorder;

  const IconButtonCustom({
    Key? key,
    required this.icon,
    this.onPressed,
    this.iconColor,
    this.backgroundColor,
    this.size,
    this.iconSize,
    this.tooltip,
    this.hasBorder = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final buttonSize = size ?? AppDimensions.iconLg;
    final actualIconSize = iconSize ?? AppDimensions.iconMd;

    final button = Container(
      width: buttonSize,
      height: buttonSize,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.transparent,
        shape: BoxShape.circle,
        border: hasBorder
            ? Border.all(
                color: AppColors.border,
                width: AppDimensions.borderThin,
              )
            : null,
      ),
      child: IconButton(
        icon: Icon(icon),
        iconSize: actualIconSize,
        color: iconColor ?? AppColors.textPrimary,
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}

/// Wishlist toggle button
class WishlistButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback? onPressed;
  final double? size;

  const WishlistButton({
    Key? key,
    required this.isFavorite,
    this.onPressed,
    this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButtonCustom(
      icon: isFavorite ? Icons.favorite : Icons.favorite_border,
      iconColor: isFavorite
          ? AppColors.wishlistActive
          : AppColors.wishlistInactive,
      onPressed: onPressed,
      size: size,
      tooltip: isFavorite ? 'Remove from wishlist' : 'Add to wishlist',
    );
  }
}

/// Cart button with badge
class CartButton extends StatelessWidget {
  final int itemCount;
  final VoidCallback? onPressed;

  const CartButton({
    Key? key,
    required this.itemCount,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButtonCustom(
          icon: Icons.shopping_cart_outlined,
          onPressed: onPressed,
          tooltip: 'Shopping cart',
        ),
        if (itemCount > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: EdgeInsets.all(AppDimensions.xxs),
              decoration: BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              constraints: BoxConstraints(
                minWidth: AppDimensions.badgeSizeSm,
                minHeight: AppDimensions.badgeSizeSm,
              ),
              child: Center(
                child: Text(
                  itemCount > 99 ? '99+' : itemCount.toString(),
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
