import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lego_app/widgets/product_detail_drawer.dart';
import 'cart_screen.dart';
import 'package:lego_app/controllers/product_controller.dart';
import 'package:lego_app/controllers/cart_controller.dart';
import 'package:lego_app/controllers/group_buy_controller.dart'; // Ensure this import is correct and the file exists
import 'package:lego_app/models/product.dart';

import 'package:lego_app/controllers/cart_controller.dart';
import 'package:lego_app/controllers/product_controller.dart';

class BuyerMainScreen extends StatefulWidget {
  const BuyerMainScreen({super.key});

  @override
  State<BuyerMainScreen> createState() => _BuyerMainScreenState();
}

class _BuyerMainScreenState extends State<BuyerMainScreen> {
  // Injecting the controllers with GetX
  final ProductController productController = Get.put(ProductController());
  final CartController cartController = Get.put(CartController());
  final GroupBuyController groupBuyController = Get.put(
      GroupBuyController()); // Ensure GroupBuyController class is defined in the imported file

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Streetwear Store'),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Get.to(() => CartScreen());
            },
          ),
        ],
      ),
      body: Obx(() {
        if (productController.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        } else {
          return GridView.builder(
            padding: EdgeInsets.all(10),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.7,
            ),
            itemCount: productController.productList.length,
            itemBuilder: (context, index) {
              final product = productController.productList[index];
              return ProductTile(product: product);
            },
          );
        }
      }),
    );
  }
}

class ProductTile extends StatelessWidget {
  final Product product;

  ProductTile({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Open product detail drawer when the product is tapped
        showModalBottomSheet(
          context: context,
          builder: (context) => ProductDetailDrawer(product: product),
        );
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: [
            Expanded(
              child:
                  (product.imagePaths != null && product.imagePaths.isNotEmpty)
                      ? Image.network(product.imagePaths[1], fit: BoxFit.cover)
                      : Placeholder(), // Placeholder for missing image
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 5),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      // Add to cart logic using GetX
                      Get.find<CartController>().addToCart(product);
                    },
                    child: Text('Add to Cart'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent, // Button color
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Join Group Buy logic
                      Get.find<GroupBuyController>()
                          .joinGroupBuy(product.id, product.name);
                    },
                    child: Text('Join Group Buy'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.orangeAccent, // Button color for group buy
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
