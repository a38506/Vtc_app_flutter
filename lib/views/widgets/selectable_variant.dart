import 'package:flutter/material.dart';
import 'package:marketky/constants/app_color.dart';
import 'package:marketky/core/models/product_model.dart';

class SelectableVariant extends StatefulWidget {
  final List<ProductVariant> variants;
  final Function(ProductVariant) onVariantSelected;
  final EdgeInsetsGeometry? margin;
  final double? runSpacing;

  SelectableVariant({
    required this.variants,
    required this.onVariantSelected,
    this.margin,
    this.runSpacing,
  });

  @override
  _SelectableVariantState createState() => _SelectableVariantState();
}

class _SelectableVariantState extends State<SelectableVariant> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: widget.runSpacing ?? 8,
      children: List.generate(widget.variants.length, (index) {
        final variant = widget.variants[index];
        final isSelected = index == _selectedIndex;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedIndex = index;
            });
            widget.onVariantSelected(variant);
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColor.primary : AppColor.primarySoft,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              variant.name,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColor.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }),
    );
  }
}