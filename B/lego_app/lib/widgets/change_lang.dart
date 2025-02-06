import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lego_app/controllers/language_controller.dart';

class LanguageSwitcher extends StatelessWidget {
  final LanguageController languageController = Get.put(LanguageController());

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.language),
      onSelected: (String newValue) {
        languageController.changeLanguage(newValue, newValue == 'en' ? 'US' : 'SA');
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'en',
          child: Text('English'),
        ),
        PopupMenuItem<String>(
          value: 'ar',
          child: Text('العربية'),
        ),
      ],
    );
  }
}