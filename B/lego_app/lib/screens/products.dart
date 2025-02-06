import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:lego_app/models/product.dart';
import 'package:lego_app/screens/edit_product.dart';
import 'package:lego_app/screens/product_overview.dart';
import 'package:lego_app/service/product_service.dart';
import 'package:lego_app/models/category.dart';

class ProductListScreen extends StatefulWidget {
  final ProductService productService;

  const ProductListScreen({Key? key, required this.productService})
      : super(key: key);

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = _fetchProducts();
  }
void _GroupBuyScreen(){
  Get.toNamed('/groups');
}
  void _ViewCart(){
    Get.toNamed('/cart');
  }
  Future<List<Product>> _fetchProducts() async {
    try {
      return await widget.productService.getProducts();
    } catch (e) {
      print('Error fetching products: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching products: $e')),
      );
      return [];
    }
  }

  void _refreshProducts() {
    setState(() {
      _productsFuture = _fetchProducts();
    });
  }

  Future<void> _addProduct(Product product) async {
    try {
      await widget.productService
          .addProduct(product, []); // Assuming no images for now
      _refreshProducts();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product added successfully')),
      );
    } catch (e) {
      print('Error adding product: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding product: $e')),
      );
    }
  }

  Future<void> _editProduct(Product updatedProduct) async {
    try {
      List<File> newImages = []; // Define newImages as an empty list for now
      await widget.productService.updateProduct(updatedProduct, newImages);
      _refreshProducts();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product updated successfully')),
      );
    } catch (e) {
      print('Error updating product: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating product: $e')),
      );
    }
  }

  Future<void> _deleteProduct(String productId) async {
    try {
      await widget.productService.deleteProduct(productId);
      _refreshProducts();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product deleted successfully')),
      );
    } catch (e) {
      print('Error deleting product: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting product: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToEditProductScreen(null),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshProducts,
          ),
          IconButton(
            icon: const Icon(Icons.group),
            onPressed: _GroupBuyScreen,
          ),
          IconButton(
            icon: const Icon(Icons.checkroom_outlined),
            onPressed: _ViewCart,
          ),
        ],
      ),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No products available.'));
          }

          final products = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: products.length,
            separatorBuilder: (context, index) =>
                const Divider(color: Colors.grey),
            itemBuilder: (context, index) {
              final product = products[index];
              return _buildProductListItem(product, screenWidth);
            },
          );
        },
      ),
    );
  }

  Widget _buildProductListItem(Product product, double screenWidth) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: product.imagePaths.isNotEmpty
            ? NetworkImage(product.imagePaths.first)
            : const AssetImage('assets/default_image.png') as ImageProvider,
        radius: screenWidth > 600 ? 40.0 : 30.0,
      ),
      title: Text(
        product.name,
        style: TextStyle(
          fontSize: screenWidth > 600 ? 24 : 18,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${product.category ?? 'No Category'} - \$${product.price.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: screenWidth > 600 ? 18 : 14,
            ),
          ),
          Text(
            'Brand: ${product.brand} | ${product.inStock ? "In Stock" : "Out of Stock"}',
            style: TextStyle(
              color: product.inStock ? Colors.green : Colors.red,
              fontSize: screenWidth > 600 ? 16 : 12,
            ),
          ),
        ],
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'edit') {
            _navigateToEditProductScreen(product);
          } else if (value == 'delete') {
            _deleteProduct(product.id);
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(value: 'edit', child: Text('Edit')),
          const PopupMenuItem(value: 'delete', child: Text('Delete')),
        ],
      ),
      onTap: () => _navigateToProductOverview(product),
    );
  }

  void _navigateToEditProductScreen(Product? product) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EditProductScreen(
          product: product,
          onSave: (updatedProduct) {
            if (product == null) {
              _addProduct(updatedProduct);
            } else {
              _editProduct(updatedProduct);
            }
          },
        ),
      ),
    );
    if (result == true) {
      _refreshProducts();
    }
  }

  void _navigateToProductOverview(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductOverview(
          productId: product.id,
          onSave: _editProduct,
        ),
      ),
    );
  }
}
