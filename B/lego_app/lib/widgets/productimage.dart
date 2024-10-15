import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ProductImageCarousel extends StatelessWidget {
  final List<String> imageUrls;

  ProductImageCarousel({required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(height: 400.0),
      items: imageUrls.map((imageUrl) {
        return Builder(
          builder: (BuildContext context) {
            return Image.network(imageUrl);
          },
        );
      }).toList(),
    );
  }
}
