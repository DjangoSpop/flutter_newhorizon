import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lego_app/controllers/cart_controller.dart';
import 'package:lego_app/controllers/group_buy_controller.dart';
import 'package:lego_app/models/group_buy_item.dart';
import 'package:lego_app/models/product.dart';

class ProductDetailDrawer extends StatelessWidget {
  final Product product;

  ProductDetailDrawer({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                product.imagePaths[0],
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 16),
          // Product Name
          Text(
            product.name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          SizedBox(height: 8),
          // Product Description
          Text(
            product.description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 16),
          // Product Price
          Text(
            '\$${product.price.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 22,
              color: Colors.green[700],
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Add to cart logic
                    Get.find<CartController>().addToCart(product);
                    Get.snackbar(
                        'Added to Cart', '${product.name} added to your cart');
                  },
                  child: Text('Add to Cart'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Join group buy logic
                    final groupBuyItem = GroupBuyItem(
                      id: 'someId', // Replace with actual id
                      name: product.name,
                      description: product.description,
                      originalPrice: product.price,
                      groupBuyPrice: product.price * 0.9, // Example discount
                      minQuantity: 5, // Example minimum quantity
                      maxQuantity:
                          100, // Example maximum quantity// Example current quantity
                      status: 'active', // Example status
                      startDate: DateTime.now(),
                      endDate: DateTime.now().add(Duration(days: 7)),
                      productId: product.id, // Assuming product has an id field
                      sellerId: 'someSellerId',
                      sizeDistribution: SizeDistribution(
                        currentQuantities: {'S': 0, 'M': 0, 'L': 0, 'XL': 0},
                        targetQuantities: {'S': 10, 'M': 20, 'L': 30, 'XL': 40},
                      ),
                      participants: [],
                      availableSizes: [], //TODO getting the availavle sizez from the api  //TODO adding the users ids  // Example seller id
                      // Replace with actual seller id, sizeDistribution: SizeDistribution.fromJson(json), // Example participant ids
                    );

                    Get.find<GroupBuyController>().joinGroupBuy(
                      groupBuyItem.id,
                      product.id,
                      product.name,
                    );
                    Get.snackbar('Joined Group Buy',
                        'You have joined the group buy for ${product.name}');
                  },
                  child: Text('Join Group Buy'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
