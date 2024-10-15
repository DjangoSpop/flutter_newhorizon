import 'package:flutter/material.dart';

class SizeSelector extends StatefulWidget {
  final List<String> sizes;
  final Function(String) onSelected;

  const SizeSelector({Key? key, required this.sizes, required this.onSelected})
      : super(key: key);

  @override
  _SizeSelectorState createState() => _SizeSelectorState();
}

class _SizeSelectorState extends State<SizeSelector> {
  String? selectedSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Size', style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: widget.sizes.map((size) {
            return ChoiceChip(
              label: Text(size),
              selected: selectedSize == size,
              onSelected: (selected) {
                setState(() {
                  selectedSize = selected ? size : null;
                });
                widget.onSelected(size);
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
