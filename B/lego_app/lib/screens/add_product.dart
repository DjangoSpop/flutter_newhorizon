import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lego_app/controllers/auth_controller.dart';
import 'package:lego_app/controllers/product_controller.dart';
import 'package:lego_app/models/product.dart';

import '../service/api_service.dart';

class AddProductScreen extends StatefulWidget {
  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final ProductController productController = Get.find<ProductController>();
  final ApiService apiService =
      ApiService(baseUrl: 'http://localhost:8000/api/products');
  final AuthController authController = Get.find<AuthController>();
  final isLoading = false.obs;
  RxString selectedCategory = ''.obs;
  RxString selectedSize = ''.obs;
  RxList<File> images = <File>[].obs;
  late TabController _tabController;
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _totalQuantityController =
      TextEditingController();
  final Map<String, TextEditingController> _sizeQuantityControllers = {};
  final TextEditingController _nameProductController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _minQuantityController = TextEditingController();
  final TextEditingController _discountedPriceController =
      TextEditingController();
  final TextEditingController _buyNowPriceController = TextEditingController();

  String? _selectedCategory;
  final List<TextEditingController> _sizesController = [
    TextEditingController()
  ];
  final List<File> _images = [];
  final List<String> _categories = [
    'Men'.tr,
    'Women'.tr,
    'Kids'.tr,
    'Accessories'.tr,
    'Shoes'.tr
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Removed _initializeCustomAuth(); since authentication should be handled globally
  }

  @override
  void dispose() {
    _tabController.dispose();
    _barcodeController.dispose();
    _totalQuantityController.dispose();
    _nameProductController.dispose();
    _descriptionController.dispose();
    _minQuantityController.dispose();
    _discountedPriceController.dispose();
    _buyNowPriceController.dispose();
    _sizesController.forEach((controller) => controller.dispose());
    _sizeQuantityControllers.values
        .forEach((controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _scanBarcode() async {
    try {
      final barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
      if (barcodeScanRes != '-1') {
        _barcodeController.text = barcodeScanRes;
      }
    } catch (e) {
      print('Error scanning barcode: $e'.tr);
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: Icon(Icons.photo_library),
            title: Text('Gallery'.tr),
            onTap: () => Navigator.of(context).pop(ImageSource.gallery),
          ),
          ListTile(
            leading: Icon(Icons.camera_alt),
            title: Text('Camera'.tr),
            onTap: () => Navigator.of(context).pop(ImageSource.camera),
          ),
        ],
      ),
    );

    if (source != null) {
      final XFile? imageFile = await picker.pickImage(source: source);
      if (imageFile != null) {
        setState(() {
          _images.add(File(imageFile.path));
        });
      }
    }
  }

  void _addSize() {
    setState(() {
      _sizesController.add(TextEditingController());
    });
  }

  void _removeSize(int index) {
    setState(() {
      _sizesController[index].dispose();
      _sizesController.removeAt(index);
    });
  }

  Future<void> _scanText() async {
    final picker = ImagePicker();
    final XFile? imageFile = await picker.pickImage(source: ImageSource.camera);

    if (imageFile != null) {
      final inputImage = InputImage.fromFilePath(imageFile.path);
      final textRecognizer =
          TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);

      if (recognizedText.text.isNotEmpty) {
        _descriptionController.text = recognizedText.text;
        textRecognizer.close();
      }
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() && images.isNotEmpty) {
      final product = Product(
        id: '', // ID will be assigned by the server
        name: _nameProductController.text,
        description: _descriptionController.text,
        price: double.tryParse(_buyNowPriceController.text) ?? 0.0,
        barcode: _barcodeController.text,
        category: _selectedCategory!,
        subcategory: '',
        sizes: _sizesController.map((controller) => controller.text).toList(),
        colors: [],
        brand: '',
        quantity: int.tryParse(_totalQuantityController.text) ?? 0,
        inStock: true,
        imagePaths: [],
        rating: 0.0,
        reviewCount: 0,
        discountedPrice:
            double.tryParse(_discountedPriceController.text) ?? 0.0,
      );

      productController.addProduct(product, images);
      Get.to('buyer'); // Navigate back after adding the product
    }
  }

  void _resetForm() {
    _formKey.currentState!.reset();
    setState(() {
      _images.clear();
      _sizesController.forEach((controller) => controller.dispose());
      _sizesController.clear();
      _sizesController.add(TextEditingController());
      _sizeQuantityControllers.values
          .forEach((controller) => controller.dispose());
      _sizeQuantityControllers.clear();
      _tabController.animateTo(0);
    });
    _selectedCategory = null;
    _nameProductController.clear();
    _descriptionController.clear();
    _minQuantityController.clear();
    _discountedPriceController.clear();
    _buyNowPriceController.clear();
    _barcodeController.clear();
    _totalQuantityController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Product'.tr),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.image), text: 'Images'.tr),
            Tab(icon: Icon(Icons.description), text: 'Details'.tr),
            Tab(icon: Icon(Icons.price_change), text: 'Pricing'.tr),
          ],
        ),
      ),
      body: Obx(() {
        return isLoading.value
            ? Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildImageTab(),
                    _buildDetailsTab(),
                    _buildPricingTab(),
                  ],
                ),
              );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: isLoading.value ? null : _submitForm,
        child: Icon(Icons.save),
      ),
    );
  }

  Widget _buildPricingTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          TextFormField(
            controller: _minQuantityController,
            decoration: InputDecoration(
              labelText: 'Minimum Quantity'.tr,
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: (value) =>
                value!.isEmpty ? 'Please enter a minimum quantity'.tr : null,
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _discountedPriceController,
            decoration: InputDecoration(
              labelText: 'Discounted Price'.tr,
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: (value) =>
                value!.isEmpty ? 'Please enter a discounted price'.tr : null,
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _buyNowPriceController,
            decoration: InputDecoration(
              labelText: 'Buy Now Price'.tr,
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: (value) =>
                value!.isEmpty ? 'Please enter a buy now price'.tr : null,
          ),
        ],
      ),
    );
  }

  Widget _buildImageTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text('Add images'.tr, style: Theme.of(context).textTheme.titleLarge),
          SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _pickImage,
            icon: Icon(Icons.add_a_photo),
            label: Text('Add Images'.tr),
          ),
          SizedBox(height: 16),
          _images.isEmpty
              ? Text('No images selected.'.tr)
              : Container(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _images.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Stack(
                          children: [
                            Image.file(_images[index],
                                width: 100, height: 100, fit: BoxFit.cover),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: IconButton(
                                icon: Icon(Icons.close, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _images.removeAt(index);
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          TextFormField(
            controller: _nameProductController,
            decoration: InputDecoration(
              labelText: 'Product Name'.tr,
              border: OutlineInputBorder(),
            ),
            validator: (value) =>
                value!.isEmpty ? 'Please enter a product name'.tr : null,
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: 'Description'.tr,
              border: OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(Icons.scanner),
                onPressed: null,
                // onPressed: _scanText,
              ),
            ),
            maxLines: 3,
            validator: (value) =>
                value!.isEmpty ? 'Please enter a description'.tr : null,
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _barcodeController,
            decoration: InputDecoration(
              labelText: 'Barcode',
              border: OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(Icons.camera_alt),
                onPressed: _scanBarcode,
              ),
            ),
            validator: (value) =>
                value!.isEmpty ? 'Please enter or scan a barcode'.tr : null,
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _totalQuantityController,
            decoration: InputDecoration(
              labelText: 'Total Quantity'.tr,
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: (value) =>
                value!.isEmpty ? 'Please enter the total quantity'.tr : null,
          ),
          SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: InputDecoration(
              labelText: 'Category'.tr,
              border: OutlineInputBorder(),
              filled: true, // Optional: Adds a background color
              fillColor: Colors
                  .black, // Optional: Light grey background for the input field
              labelStyle: TextStyle(color: Colors.black), // Label text color
            ),
            dropdownColor: Colors.black87,

            // Background color of the dropdown menu
            style: const TextStyle(
                color: Colors.white), // Text color of the selected item
            items: _categories.map((category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(
                  category,
                  style: TextStyle(
                      color: Colors.white), // Text color of dropdown items
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value;
              });
            },
            validator: (value) =>
                value == null ? 'Please select a category'.tr : null,
          ),
          SizedBox(height: 16),
          Text(
            'Sizes and Quantities'.tr,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _sizesController.length,
            itemBuilder: (context, index) {
              String sizeKey = 'size_$index';
              _sizeQuantityControllers[sizeKey] ??= TextEditingController();

              return Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _sizesController[index],
                      decoration: InputDecoration(
                        labelText: 'Size'.tr,
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Enter size'.tr : null,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _sizeQuantityControllers[sizeKey],
                      decoration: InputDecoration(
                        labelText: 'Quantity'.tr,
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value!.isEmpty ? 'Enter quantity'.tr : null,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.remove_circle),
                    onPressed: () => _removeSize(index),
                  ),
                ],
              );
            },
          ),
          TextButton.icon(
            onPressed: _addSize,
            icon: Icon(Icons.add),
            label: Text('Add Size'.tr),
          ),
        ],
      ),
    );
  }
}
