import 'package:flutter/material.dart';

class ColorSelector extends StatelessWidget {
  final List<String> colors;
  final String? selectedColor;
  final Function(String) onSelected;

  const ColorSelector({
    Key? key,
    required this.colors,
    required this.onSelected,
    this.selectedColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Color',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: colors.map((color) {
            final isSelected = selectedColor == color;

            return GestureDetector(
              onTap: () {
                onSelected(color);
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                padding: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.black : Colors.grey,
                    width: isSelected ? 3.0 : 1.0,
                  ),
                ),
                child: CircleAvatar(
                  backgroundColor: _getColorFromString(color),
                  radius: 20,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Helper function to convert color string to a Color object
  Color _getColorFromString(String color) {
    switch (color.toLowerCase()) {
      case 'indigo':
        return Colors.indigo;
      case 'black':
        return Colors.black;
      case 'light blue':
        return Colors.lightBlue;
      default:
        return Colors.grey;
    }
  }
}
