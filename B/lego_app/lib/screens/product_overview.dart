import 'package:flutter/material.dart';
import 'package:lego_app/models/product.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lego_app/widgets/productimage.dart';
import 'package:lego_app/widgets/sizeselctor.dart';
import 'package:lego_app/widgets/colorselctor.dart';
import 'dart:io';
import 'package:lego_app/service/product_service.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/v4.dart';

class ProductOverview extends StatefulWidget {
  final String productId;
  final Function(Product) onSave;

  const ProductOverview({
    Key? key,
    required this.productId,
    required this.onSave,
  }) : super(key: key);

  @override
  State<ProductOverview> createState() => _ProductOverviewState();
}

class _ProductOverviewState extends State<ProductOverview> {
  late Future<Product> _productFuture;
  final ProductService _productService = ProductService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _descountController = TextEditingController();
  String? selectedSize;
  String? selectedColor;
  List<File> _productImages = [];
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _productFuture = _productService.getProduct(widget.productId);
  }

  Future<Product> _fetchProduct(UuidV4 id) async {
    if (id == 'new') {
      _isEditing = true;
      return Product(
        id: Uuid().v4(),
        name: '',
        description: '',
        price: 0,
        discountedPrice: 0,
        barcode: '',
        category: '',
        subcategory: '',
        sizes: [],
        colors: [],
        brand: '',
        quantity: 0,
        inStock: true,
        imagePaths: [],
      );
    } else {
      final product = await _productService.getProduct(widget.productId);
      _populateFields(product);
      return product;
    }
  }

  void _populateFields(Product product) {
    _nameController.text = product.name;
    _descriptionController.text = product.description;
    _priceController.text = product.price.toString();
    _descountController.text = product.discountedPrice.toString();
    _quantityController.text = product.quantity.toString();
    selectedSize = product.sizes.isNotEmpty ? product.sizes.first : null;
    selectedColor = product.colors.isNotEmpty ? product.colors.first : null;
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _productImages.add(File(image.path));
      });
    }
  }

  void _saveProduct() {
    if (_isEditing) {
      final updatedProduct = Product(
        id: Uuid().v4(),
        name: _nameController.text,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        discountedPrice: double.parse(_descountController
            .text), // You might want to add a discounted price field
        barcode: '', // You might want to add a barcode field
        category: '', // Add category field
        subcategory: '', // Add subcategory field
        sizes: selectedSize != null ? [selectedSize!] : [],
        colors: selectedColor != null ? [selectedColor!] : [],
        brand: '', // Add brand field
        quantity: int.parse(_quantityController.text),
        inStock: int.parse(_quantityController.text) > 0,
        imagePaths: _productImages.map((file) => file.path).toList(),
      );
      widget.onSave(updatedProduct);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Product' : 'Product Details'),
        backgroundColor: Colors.black,
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveProduct,
            ),
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
        ],
      ),
      body: FutureBuilder<Product>(
        future: _productFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Product not found'));
          }

          Product product = snapshot.data!;

          return LayoutBuilder(
            builder: (context, constraints) {
              bool isTablet = constraints.maxWidth > 600;
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 32 : 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_isEditing)
                      ElevatedButton(
                        onPressed: _pickImage,
                        child: const Text('Add Image'),
                      ),
                    ProductImageCarousel(
                      imageUrls: _productImages.isEmpty
                          ? product.imagePaths
                          : _productImages.map((file) => file.path).toList(),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(_nameController, 'Product Name'),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: _buildTextField(_priceController, 'Price',
                              isEditing: _isEditing),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                              _quantityController, 'Quantity',
                              isEditing: _isEditing),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(_descriptionController, 'Description',
                        maxLines: 3),
                    const SizedBox(height: 16),
                    SizeSelector(
                      sizes: product.sizes,
                      onSelected: (size) {
                        setState(() {
                          selectedSize = size;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    ColorSelector(
                      colors: product.colors,
                      selectedColor: selectedColor,
                      onSelected: (color) {
                        setState(() {
                          selectedColor = color;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    if (!_isEditing)
                      ElevatedButton(
                        child: const Text('Add to Cart'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        onPressed: product.inStock
                            ? () {
                                // TODO: Implement add to cart functionality
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Added to cart')),
                                );
                              }
                            : null,
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isEditing = true, int maxLines = 1}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      enabled: isEditing,
      maxLines: maxLines,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }
}


// class ProductOverview extends StatefulWidget {
//   final String productId;
//   final Function(Product) onSave;

//   const ProductOverview({
//     super.key,
//     required this.productId,
//     required this.onSave,
//   });

//   @override
//   State<ProductOverview> createState() => _ProductOverviewState();
// }

// class _ProductOverviewState extends State<ProductOverview> {
//   late Future<Product> _productFuture;
//   String? selectedSize;
//   String? selectedColor;
//   List<File> _productImages = [];

//   @override
//   void initState() {
//     super.initState();
//     _productFuture = _fetchProduct(widget.productId);
//   }

//   Future<Product> _fetchProduct(String id) async {
//     if (id == 'new') {
//       _isEditing = true;
//       return Product.create(
//         id: 'new',
//         name: '',
//         description: '',
//         price: 0,
//         barcode: '',
//         category: '',
//         subcategory: '',
//         sizes: [],
//         colors: [],
//         brand: '',
//         quantity: 0,
//         inStock: true,
//         imagePaths: [],
//       );
//     } else {
//       final product = await _productService.getProduct(id);
//       _populateFields(product);
//       return product;
//     }
//   }

//   Future<void> _pickImage() async {
//     final ImagePicker _picker = ImagePicker();
//     final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
//     if (image != null) {
//       setState(() {
//         _productImages.add(File(image.path));
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Product Details'),
//         backgroundColor: Colors.black,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.share),
//             onPressed: () {
//               // TODO: Implement share functionality
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.favorite_border),
//             onPressed: () {
//               // TODO: Implement favorite functionality
//             },
//           ),
//         ],
//       ),
//       body: FutureBuilder<Product>(
//         future: _productFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else if (!snapshot.hasData) {
//             return const Center(child: Text('Product not found'));
//           }

//           Product product = snapshot.data!;

//           return LayoutBuilder(
//             builder: (context, constraints) {
//               bool isTablet = constraints.maxWidth > 600;
//               return SingleChildScrollView(
//                 padding: EdgeInsets.symmetric(
//                     horizontal: isTablet ? 32 : 16, vertical: 16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     ProductImageCarousel(imageUrls: product.imagePaths),
//                     const SizedBox(height: 16),
//                     Text(
//                       product.name,
//                       style: Theme.of(context).textTheme.headlineSmall,
//                     ),
//                     const SizedBox(height: 8),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           '\$${product.price.toStringAsFixed(2)}',
//                           style:
//                               Theme.of(context).textTheme.bodyLarge?.copyWith(
//                                     color: Colors.green,
//                                   ),
//                         ),
//                         Row(
//                           children: [
//                             const Icon(Icons.star, color: Colors.amber),
//                             Text(
//                                 '${product.rating} (${product.reviewCount} reviews)'),
//                           ],
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 16),
//                     Text(
//                       'Description',
//                       style: Theme.of(context).textTheme.bodyLarge,
//                     ),
//                     const SizedBox(height: 8),
//                     Text(product.description),
//                     const SizedBox(height: 16),
//                     SizeSelector(
//                       sizes: product.sizes,
//                       onSelected: (size) {
//                         setState(() {
//                           selectedSize = size;
//                         });
//                       },
//                     ),
//                     const SizedBox(height: 16),
//                     ColorSelector(
//                       colors: product.colors,
//                       selectedColor: selectedColor,
//                       onSelected: (color) {
//                         setState(() {
//                           selectedColor = color;
//                         });
//                       },
//                     ),
//                     const SizedBox(height: 24),
//                     ElevatedButton(
//                       child: const Text('Add to Cart'),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.black,
//                         minimumSize: const Size(double.infinity, 50),
//                       ),
//                       onPressed: product.inStock
//                           ? () {
//                               // TODO: Implement add to cart functionality
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(content: Text('Added to cart')),
//                               );
//                             }
//                           : null,
//                     ),
//                   ],
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
