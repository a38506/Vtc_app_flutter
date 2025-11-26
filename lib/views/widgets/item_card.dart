import 'package:flutter/material.dart';
import 'package:marketky/constants/app_color.dart';
import 'package:marketky/core/models/product_model.dart';
import 'package:marketky/views/screens/product_detail.dart';
import 'package:intl/intl.dart';
import 'package:marketky/core/services/category_service.dart';

class ItemCard extends StatefulWidget {
  final Product product;
  final Color titleColor;
  final Color priceColor;
  final VoidCallback? onTap;

  ItemCard({
    Key? key,
    required this.product,
    this.titleColor = Colors.black,
    this.priceColor = AppColor.accent,
    this.onTap,
  }) : super(key: key);

  @override
  _ItemCardState createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  Map<dynamic, String> _categoryMap = {};
  bool _loadingCategories = true;

  @override
  void initState() {
    super.initState();
    // có thể load danh mục ở đây nếu cần
  }

  @override
  Widget build(BuildContext context) {
    // Lấy ảnh ưu tiên: gallery/thumbnail/all
    String? imageUrl = (widget.product.images?.all.isNotEmpty ?? false)
        ? widget.product.images!.all.first
        : (widget.product.images?.thumbnail ?? null);

    ImageProvider imageProvider;
    if (imageUrl != null && imageUrl.startsWith('http')) {
      imageProvider = NetworkImage(imageUrl);
    } else {
      imageProvider = const AssetImage('assets/images/default.png');
    }

    final bool isFresh = widget.product.isFresh ?? false;

    final priceText = NumberFormat.currency(locale: 'vi_VN', symbol: '₫')
        .format(widget.product.price);

    return GestureDetector(
      onTap: widget.onTap ??
          () {
            Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) => ProductDetail(product: widget.product)),
            );
          },
      child: Container(
        width: MediaQuery.of(context).size.width / 2 - 16 - 8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColor.border),
          boxShadow: [
            BoxShadow(
              color: AppColor.primary.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area
            Container(
              height: MediaQuery.of(context).size.width / 2 - 16 - 8,
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(14)),
                image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
              ),
              child: Stack(
                children: [
                  // category chip (top-left)
                  Positioned(
                    left: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColor.primary.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        (isFresh ? "Tươi ngon" : "Tươi ngon"),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  // price badge (bottom-right)
                  
                ],
              ),
            ),

            // Info area
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: widget.titleColor == Colors.black
                          ? AppColor.secondary
                          : widget.titleColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    priceText,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: widget.priceColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.product.shortDescription ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: AppColor.secondary.withOpacity(0.7),
                        fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
