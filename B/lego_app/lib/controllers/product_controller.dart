import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lego_app/models/product.dart'; // Import your Product model

class ProductController extends GetxController {
  // Observable variables
  var productList = <Product>[].obs; // Observable list of products
  var isLoading = true.obs;          // Observable boolean for loading state
  var errorMessage = ''.obs;         // Observable string for error messages

  @override
  void onInit() {
    super.onInit();
    fetchProducts();  // Fetch products when the controller is initialized
  }

  // Function to fetch products from the API
  Future<void> fetchProducts() async {
    try {
      isLoading(true);  // Set loading state to true
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('accessToken');

      final response = await http.get(
        Uri.parse('https://your-api-url/api/products/'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body) as List;
        productList.value = data.map((json) => Product.fromJson(json)).toList();  // Update productList with data
      } else {
        errorMessage('Failed to load products: ${response.statusCode}');  // Handle server errors
      }
    } catch (error) {
      errorMessage('Error occurred: $error');  // Handle network or parsing errors
    } finally {
      isLoading(false);  // Always set loading state to false
    }
  }
}
