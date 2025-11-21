import 'package:flutter/material.dart';
import 'package:marketky/core/models/cart_model.dart';
import 'package:marketky/core/services/cart_service.dart';
import 'package:marketky/core/services/product_service.dart';
import '../screens/image_viewer.dart';

class CartTile extends StatelessWidget {
  final CartItemWithProductDetails data;
  final Function(int newQuantity) onQuantityChanged;
  final VoidCallback onRemove;

  const CartTile({
    Key? key,
    required this.data,
    required this.onQuantityChanged,
    required this.onRemove,
  }) : super(key: key);

  Future<String> fetchProductThumbnail() async {
    try {
      final products = await ProductService.getAllProducts();
      final product = products.firstWhere(
          (p) => p.id == data.product.id,
          orElse: () => data.product);
      return product.images?.thumbnail ?? '';
    } catch (e) {
      return data.product.images?.thumbnail ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: FutureBuilder<String>(
        future: fetchProductThumbnail(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          }
          final imageUrl = snapshot.data ?? '';
          if (imageUrl.isEmpty) return const Icon(Icons.image, size: 50);
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ImageViewer(imageUrl: imageUrl)),
            ),
            child: Image.network(imageUrl, width: 50, height: 50, fit: BoxFit.cover),
          );
        },
      ),
      title: Text(data.variant.name ?? ''),
      subtitle: Text('${data.quantity} × ${data.variant.price} ₫'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: () => onQuantityChanged(data.quantity - 1),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => onQuantityChanged(data.quantity + 1),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}
