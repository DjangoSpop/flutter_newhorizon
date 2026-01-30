import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/localization/language_controller.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/theme/app_dimensions.dart';

/// Language Switcher Widget - Shows current language and allows changing
class LanguageSwitcher extends StatelessWidget {
  final bool showLabel;
  final bool isCompact;

  const LanguageSwitcher({
    Key? key,
    this.showLabel = true,
    this.isCompact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageController = Get.find<LanguageController>();

    return Obx(() {
      final currentLanguage = languageController.currentLanguage;

      if (isCompact) {
        return InkWell(
          onTap: () => _showLanguageDialog(context),
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.sm,
              vertical: AppDimensions.xs,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  currentLanguage.flag,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 4),
                Text(
                  currentLanguage.code.toUpperCase(),
                  style: AppTypography.labelSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_drop_down, size: 16),
              ],
            ),
          ),
        );
      }

      return InkWell(
        onTap: () => _showLanguageDialog(context),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.md),
          decoration: BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    currentLanguage.flag,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              if (showLabel) ...[
                const SizedBox(width: AppDimensions.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'language'.tr,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        currentLanguage.nativeName,
                        style: AppTypography.titleSmall.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      );
    });
  }

  void _showLanguageDialog(BuildContext context) {
    final languageController = Get.find<LanguageController>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('select_language'.tr),
        contentPadding: const EdgeInsets.symmetric(vertical: AppDimensions.lg),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languageController.availableLanguages.map((language) {
            return Obx(() {
              final isSelected = languageController.locale.languageCode == language.code;

              return ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.1)
                        : AppColors.backgroundLight,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      language.flag,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                title: Text(
                  language.nativeName,
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: Text(language.name),
                trailing: isSelected
                    ? const Icon(Icons.check_circle, color: AppColors.primary)
                    : null,
                selected: isSelected,
                onTap: () {
                  languageController.changeLanguage(language.code);
                  Navigator.of(context).pop();
                },
              );
            });
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('cancel'.tr),
          ),
        ],
      ),
    );
  }
}

/// Simple language toggle button (switches between English and Arabic)
class LanguageToggleButton extends StatelessWidget {
  final IconData? icon;
  final String? tooltip;

  const LanguageToggleButton({
    Key? key,
    this.icon,
    this.tooltip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageController = Get.find<LanguageController>();

    return Obx(() {
      final currentLanguage = languageController.currentLanguage;

      return IconButton(
        icon: Icon(icon ?? Icons.language),
        tooltip: tooltip ?? 'language'.tr,
        onPressed: () => languageController.toggleLanguage(),
      );
    });
  }
}

/// Language selector for AppBar
class AppBarLanguageSelector extends StatelessWidget {
  const AppBarLanguageSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageController = Get.find<LanguageController>();

    return Obx(() {
      final currentLanguage = languageController.currentLanguage;

      return PopupMenuButton<String>(
        icon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              currentLanguage.flag,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, size: 20),
          ],
        ),
        tooltip: 'select_language'.tr,
        onSelected: (languageCode) {
          languageController.changeLanguage(languageCode);
        },
        itemBuilder: (context) {
          return languageController.availableLanguages.map((language) {
            final isSelected = currentLanguage.code == language.code;

            return PopupMenuItem<String>(
              value: language.code,
              child: Row(
                children: [
                  Text(
                    language.flag,
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: AppDimensions.md),
                  Text(
                    language.nativeName,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const Spacer(),
                  if (isSelected)
                    const Icon(Icons.check, color: AppColors.primary, size: 20),
                ],
              ),
            );
          }).toList();
        },
      );
    });
  }
}
