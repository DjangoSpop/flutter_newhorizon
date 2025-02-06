// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(error) => "Error adding product: ${error}";

  static String m1(error) => "Error deleting product: ${error}";

  static String m2(error) => "Error fetching products: ${error}";

  static String m3(error) => "Error updating product: ${error}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "addColor": MessageLookupByLibrary.simpleMessage("Add Color"),
        "addImage": MessageLookupByLibrary.simpleMessage("Add Image"),
        "addProduct": MessageLookupByLibrary.simpleMessage("Add Product"),
        "addSize": MessageLookupByLibrary.simpleMessage("Add Size"),
        "barcode": MessageLookupByLibrary.simpleMessage("Barcode"),
        "brand": MessageLookupByLibrary.simpleMessage("Brand"),
        "buyNowPrice": MessageLookupByLibrary.simpleMessage("Buy Now Price"),
        "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "category": MessageLookupByLibrary.simpleMessage("Category"),
        "chooseFromGallery":
            MessageLookupByLibrary.simpleMessage("Choose from Gallery"),
        "colors": MessageLookupByLibrary.simpleMessage("Colors"),
        "delete": MessageLookupByLibrary.simpleMessage("Delete"),
        "description": MessageLookupByLibrary.simpleMessage("Description"),
        "discountedPrice":
            MessageLookupByLibrary.simpleMessage("Discounted Price"),
        "edit": MessageLookupByLibrary.simpleMessage("Edit"),
        "editProduct": MessageLookupByLibrary.simpleMessage("Edit Product"),
        "enterProductName":
            MessageLookupByLibrary.simpleMessage("Please enter a product name"),
        "enterValidPrice":
            MessageLookupByLibrary.simpleMessage("Please enter a valid price"),
        "enterValidQuantity": MessageLookupByLibrary.simpleMessage(
            "Please enter a valid quantity"),
        "errorAddingProduct": m0,
        "errorDeletingProduct": m1,
        "errorFetchingProducts": m2,
        "errorUpdatingProduct": m3,
        "inStock": MessageLookupByLibrary.simpleMessage("In Stock"),
        "loginFailed": MessageLookupByLibrary.simpleMessage("loginFailed"),
        "minimumQuantity":
            MessageLookupByLibrary.simpleMessage("Minimum Quantity"),
        "noProductsAvailable":
            MessageLookupByLibrary.simpleMessage("No products available."),
        "outOfStock": MessageLookupByLibrary.simpleMessage("Out of Stock"),
        "price": MessageLookupByLibrary.simpleMessage("Price"),
        "productAddedSuccessfully":
            MessageLookupByLibrary.simpleMessage("Product added successfully"),
        "productDeletedSuccessfully": MessageLookupByLibrary.simpleMessage(
            "Product deleted successfully"),
        "productDetails":
            MessageLookupByLibrary.simpleMessage("Product Details"),
        "productList": MessageLookupByLibrary.simpleMessage("Product List"),
        "productName": MessageLookupByLibrary.simpleMessage("Product Name"),
        "productUpdatedSuccessfully": MessageLookupByLibrary.simpleMessage(
            "Product updated successfully"),
        "quantity": MessageLookupByLibrary.simpleMessage("Quantity"),
        "refresh": MessageLookupByLibrary.simpleMessage("Refresh"),
        "removeColor": MessageLookupByLibrary.simpleMessage("Remove Color"),
        "removeSize": MessageLookupByLibrary.simpleMessage("Remove Size"),
        "save": MessageLookupByLibrary.simpleMessage("Save"),
        "scanBarcode": MessageLookupByLibrary.simpleMessage("Scan Barcode"),
        "selectCategory":
            MessageLookupByLibrary.simpleMessage("Please select a category"),
        "sizes": MessageLookupByLibrary.simpleMessage("Sizes"),
        "sizesAndQuantities":
            MessageLookupByLibrary.simpleMessage("Sizes and Quantities"),
        "subcategory": MessageLookupByLibrary.simpleMessage("Subcategory"),
        "takePhoto": MessageLookupByLibrary.simpleMessage("Take Photo"),
        "totalQuantity": MessageLookupByLibrary.simpleMessage("Total Quantity"),
        "uploadImage": MessageLookupByLibrary.simpleMessage("Upload Image"),
        "view": MessageLookupByLibrary.simpleMessage("View")
      };
}
