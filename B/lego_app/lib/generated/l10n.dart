// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Add Product`
  String get addProduct {
    return Intl.message(
      'Add Product',
      name: 'addProduct',
      desc: '',
      args: [],
    );
  }

  /// `Edit Product`
  String get editProduct {
    return Intl.message(
      'Edit Product',
      name: 'editProduct',
      desc: '',
      args: [],
    );
  }

  /// `Product Name`
  String get productName {
    return Intl.message(
      'Product Name',
      name: 'productName',
      desc: '',
      args: [],
    );
  }

  /// `Description`
  String get description {
    return Intl.message(
      'Description',
      name: 'description',
      desc: '',
      args: [],
    );
  }

  /// `Price`
  String get price {
    return Intl.message(
      'Price',
      name: 'price',
      desc: '',
      args: [],
    );
  }

  /// `Discounted Price`
  String get discountedPrice {
    return Intl.message(
      'Discounted Price',
      name: 'discountedPrice',
      desc: '',
      args: [],
    );
  }

  /// `Quantity`
  String get quantity {
    return Intl.message(
      'Quantity',
      name: 'quantity',
      desc: '',
      args: [],
    );
  }

  /// `Category`
  String get category {
    return Intl.message(
      'Category',
      name: 'category',
      desc: '',
      args: [],
    );
  }

  /// `Subcategory`
  String get subcategory {
    return Intl.message(
      'Subcategory',
      name: 'subcategory',
      desc: '',
      args: [],
    );
  }

  /// `Brand`
  String get brand {
    return Intl.message(
      'Brand',
      name: 'brand',
      desc: '',
      args: [],
    );
  }

  /// `Barcode`
  String get barcode {
    return Intl.message(
      'Barcode',
      name: 'barcode',
      desc: '',
      args: [],
    );
  }

  /// `Sizes`
  String get sizes {
    return Intl.message(
      'Sizes',
      name: 'sizes',
      desc: '',
      args: [],
    );
  }

  /// `Colors`
  String get colors {
    return Intl.message(
      'Colors',
      name: 'colors',
      desc: '',
      args: [],
    );
  }

  /// `In Stock`
  String get inStock {
    return Intl.message(
      'In Stock',
      name: 'inStock',
      desc: '',
      args: [],
    );
  }

  /// `Out of Stock`
  String get outOfStock {
    return Intl.message(
      'Out of Stock',
      name: 'outOfStock',
      desc: '',
      args: [],
    );
  }

  /// `Add Image`
  String get addImage {
    return Intl.message(
      'Add Image',
      name: 'addImage',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get save {
    return Intl.message(
      'Save',
      name: 'save',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message(
      'Delete',
      name: 'delete',
      desc: '',
      args: [],
    );
  }

  /// `Product Details`
  String get productDetails {
    return Intl.message(
      'Product Details',
      name: 'productDetails',
      desc: '',
      args: [],
    );
  }

  /// `Product List`
  String get productList {
    return Intl.message(
      'Product List',
      name: 'productList',
      desc: '',
      args: [],
    );
  }

  /// `No products available.`
  String get noProductsAvailable {
    return Intl.message(
      'No products available.',
      name: 'noProductsAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Product added successfully`
  String get productAddedSuccessfully {
    return Intl.message(
      'Product added successfully',
      name: 'productAddedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Product updated successfully`
  String get productUpdatedSuccessfully {
    return Intl.message(
      'Product updated successfully',
      name: 'productUpdatedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Product deleted successfully`
  String get productDeletedSuccessfully {
    return Intl.message(
      'Product deleted successfully',
      name: 'productDeletedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Error fetching products: {error}`
  String errorFetchingProducts(Object error) {
    return Intl.message(
      'Error fetching products: $error',
      name: 'errorFetchingProducts',
      desc: '',
      args: [error],
    );
  }

  /// `Error adding product: {error}`
  String errorAddingProduct(Object error) {
    return Intl.message(
      'Error adding product: $error',
      name: 'errorAddingProduct',
      desc: '',
      args: [error],
    );
  }

  /// `Error updating product: {error}`
  String errorUpdatingProduct(Object error) {
    return Intl.message(
      'Error updating product: $error',
      name: 'errorUpdatingProduct',
      desc: '',
      args: [error],
    );
  }

  /// `Error deleting product: {error}`
  String errorDeletingProduct(Object error) {
    return Intl.message(
      'Error deleting product: $error',
      name: 'errorDeletingProduct',
      desc: '',
      args: [error],
    );
  }

  /// `Please enter a product name`
  String get enterProductName {
    return Intl.message(
      'Please enter a product name',
      name: 'enterProductName',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid price`
  String get enterValidPrice {
    return Intl.message(
      'Please enter a valid price',
      name: 'enterValidPrice',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid quantity`
  String get enterValidQuantity {
    return Intl.message(
      'Please enter a valid quantity',
      name: 'enterValidQuantity',
      desc: '',
      args: [],
    );
  }

  /// `Please select a category`
  String get selectCategory {
    return Intl.message(
      'Please select a category',
      name: 'selectCategory',
      desc: '',
      args: [],
    );
  }

  /// `Add Size`
  String get addSize {
    return Intl.message(
      'Add Size',
      name: 'addSize',
      desc: '',
      args: [],
    );
  }

  /// `Remove Size`
  String get removeSize {
    return Intl.message(
      'Remove Size',
      name: 'removeSize',
      desc: '',
      args: [],
    );
  }

  /// `Add Color`
  String get addColor {
    return Intl.message(
      'Add Color',
      name: 'addColor',
      desc: '',
      args: [],
    );
  }

  /// `Remove Color`
  String get removeColor {
    return Intl.message(
      'Remove Color',
      name: 'removeColor',
      desc: '',
      args: [],
    );
  }

  /// `Scan Barcode`
  String get scanBarcode {
    return Intl.message(
      'Scan Barcode',
      name: 'scanBarcode',
      desc: '',
      args: [],
    );
  }

  /// `Upload Image`
  String get uploadImage {
    return Intl.message(
      'Upload Image',
      name: 'uploadImage',
      desc: '',
      args: [],
    );
  }

  /// `Take Photo`
  String get takePhoto {
    return Intl.message(
      'Take Photo',
      name: 'takePhoto',
      desc: '',
      args: [],
    );
  }

  /// `Choose from Gallery`
  String get chooseFromGallery {
    return Intl.message(
      'Choose from Gallery',
      name: 'chooseFromGallery',
      desc: '',
      args: [],
    );
  }

  /// `Minimum Quantity`
  String get minimumQuantity {
    return Intl.message(
      'Minimum Quantity',
      name: 'minimumQuantity',
      desc: '',
      args: [],
    );
  }

  /// `Buy Now Price`
  String get buyNowPrice {
    return Intl.message(
      'Buy Now Price',
      name: 'buyNowPrice',
      desc: '',
      args: [],
    );
  }

  /// `Total Quantity`
  String get totalQuantity {
    return Intl.message(
      'Total Quantity',
      name: 'totalQuantity',
      desc: '',
      args: [],
    );
  }

  /// `Sizes and Quantities`
  String get sizesAndQuantities {
    return Intl.message(
      'Sizes and Quantities',
      name: 'sizesAndQuantities',
      desc: '',
      args: [],
    );
  }

  /// `Refresh`
  String get refresh {
    return Intl.message(
      'Refresh',
      name: 'refresh',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get edit {
    return Intl.message(
      'Edit',
      name: 'edit',
      desc: '',
      args: [],
    );
  }

  /// `View`
  String get view {
    return Intl.message(
      'View',
      name: 'view',
      desc: '',
      args: [],
    );
  }

  /// `loginFailed`
  String get loginFailed {
    return Intl.message(
      'loginFailed',
      name: 'loginFailed',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
