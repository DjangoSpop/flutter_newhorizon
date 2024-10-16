import 'package:get/get.dart';
import 'package:lego_app/models/product.dart';
import 'package:lego_app/service/product_service.dart';
import 'dart:io';

class ProductController extends GetxController {
  // Observable variables
  var productList = <Product>[].obs;
  var isLoading = true.obs;
  var errorMessage = ''.obs;

  late final ProductService _productService;

  @override
  void onInit() {
    super.onInit();
    _productService = Get.find<ProductService>();
    fetchProducts();
  }

  // Fetch products from the API
  Future<void> fetchProducts() async {
    try {
      isLoading(true);
      List<Product> products = await _productService.fetchProducts();
      productList.assignAll(products);
    } catch (error) {
      errorMessage.value = 'Error occurred: $error';
    } finally {
      isLoading(false);
    }
  }

  // Add a new product
  Future<void> addProduct(Product product, List<File> images) async {
    try {
      isLoading(true);
      Product newProduct = await _productService.addProduct(product, images);
      productList.add(newProduct);
    } catch (error) {
      errorMessage.value = 'Error occurred while adding product: $error';
    } finally {
      isLoading(false);
    }
  }

  // Additional methods for updating and deleting products can be added similarly
}
