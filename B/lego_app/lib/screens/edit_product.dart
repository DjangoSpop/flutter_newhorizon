import 'package:flutter/material.dart';
import 'package:lego_app/models/product.dart';
import 'package:lego_app/service/product_service.dart';
import 'package:lego_app/widgets/colorselctor.dart';
import 'package:lego_app/widgets/image_picer_widget.dart';
import 'package:lego_app/widgets/sizeselctor.dart';
import 'package:uuid/uuid.dart';

class EditProductScreen extends StatefulWidget {
  final Product? product;
  final Function(Product) onSave;

  const EditProductScreen({
    super.key,
    this.product,
    required this.onSave,
  });

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProductService _productService = ProductService();
  final Uuid _uuid = const Uuid();

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _barcodeController;
  late final TextEditingController _quantityController;
  late final TextEditingController _categoryController;
  late final TextEditingController _subcategoryController;
  late final TextEditingController _brandController;
  late final TextEditingController _discController;
  List<String> _sizes = [];
  List<String> _colors = [];
  List<String> _imagePaths = [];
  bool _inStock = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadProductData();
  }

  void _initializeControllers() {
    final product = widget.product;
    _nameController = TextEditingController(text: product?.name ?? '');
    _descriptionController =
        TextEditingController(text: product?.description ?? '');
    _priceController =
        TextEditingController(text: product?.price.toString() ?? '');
    _barcodeController = TextEditingController(text: product?.barcode ?? '');
    _quantityController =
        TextEditingController(text: product?.quantity.toString() ?? '');
    _categoryController = TextEditingController(text: product?.category ?? '');
    _subcategoryController =
        TextEditingController(text: product?.subcategory ?? '');
    _brandController = TextEditingController(text: product?.brand ?? '');
  }

  void _loadProductData() {
    if (widget.product != null) {
      setState(() {
        _sizes = List.from(widget.product!.sizes);
        _colors = List.from(widget.product!.colors);
        _imagePaths = List.from(widget.product!.imagePaths);
        _inStock = widget.product!.inStock;
      });
    }
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      if (_isSaving) return;

      setState(() {
        _isSaving = true;
      });

      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );

        final id = widget.product?.id ?? _uuid.v4().toString();
        final updatedProduct = Product(
          id: id,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          price: double.parse(_priceController.text),
          discountedPrice: double.parse(_discController.text),
          barcode: _barcodeController.text.trim(),
          category: _categoryController.text.trim(),
          subcategory: _subcategoryController.text.trim(),
          sizes: _sizes,
          colors: _colors,
          brand: _brandController.text.trim(),
          quantity: int.parse(_quantityController.text),
          inStock: _inStock,
          imagePaths: _imagePaths,
        );

        await widget.onSave(updatedProduct);

        Navigator.of(context).pop(); // Dismiss loading indicator

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.product == null
                ? 'Product added successfully!'
                : 'Product updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
      } catch (error) {
        Navigator.of(context).pop(); // Dismiss loading indicator

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save product: $error'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveChanges,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ImagePickerWidget(
                initialImages: _imagePaths,
                onImagesChanged: (paths) {
                  setState(() {
                    _imagePaths = paths;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                  controller: _nameController, label: 'Product Name'),
              _buildTextField(
                  controller: _descriptionController,
                  label: 'Description',
                  maxLines: 3),
              _buildTextField(
                  controller: _priceController,
                  label: 'Price',
                  keyboardType: TextInputType.number),
              _buildTextField(
                  controller: _barcodeController,
                  label: 'Barcode/Product Code'),
              _buildTextField(
                  controller: _quantityController,
                  label: 'Quantity',
                  keyboardType: TextInputType.number,
                  isQuantity: true),
              _buildTextField(
                  controller: _categoryController, label: 'Category'),
              _buildTextField(
                  controller: _subcategoryController, label: 'Subcategory'),
              _buildTextField(controller: _brandController, label: 'Brand'),
              const SizedBox(height: 16),
              Text('Sizes', style: Theme.of(context).textTheme.titleMedium),
              SizeSelector(
                sizes: _sizes,
                onSelected: (size) {
                  setState(() {
                    if (_sizes.contains(size)) {
                      _sizes.remove(size);
                    } else {
                      _sizes.add(size);
                    }
                  });
                },
              ),
              const SizedBox(height: 16),
              Text('Colors', style: Theme.of(context).textTheme.titleMedium),
              ColorSelector(
                colors: _colors,
                onSelected: (color) {
                  setState(() {
                    if (_colors.contains(color)) {
                      _colors.remove(color);
                    } else {
                      _colors.add(color);
                    }
                  });
                },
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('In Stock'),
                value: _inStock,
                onChanged: (value) {
                  setState(() {
                    _inStock = value ?? false;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool isQuantity = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter $label';
          }
          if (label == 'Price') {
            if (double.tryParse(value) == null) {
              return 'Please enter a valid number for Price';
            }
          }
          if (isQuantity) {
            if (int.tryParse(value) == null) {
              return 'Please enter a valid integer for Quantity';
            }
          }
          return null;
        },
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _barcodeController.dispose();
    _quantityController.dispose();
    _categoryController.dispose();
    _subcategoryController.dispose();
    _brandController.dispose();
    super.dispose();
  }
}
