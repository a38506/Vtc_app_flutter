import 'package:flutter/material.dart';
import 'package:marketky/constants/app_color.dart';
import 'package:marketky/core/models/product_model.dart';
import 'package:marketky/core/services/wishlist_service.dart';
import 'package:marketky/core/services/product_service.dart';
import 'package:marketky/views/screens/product_detail.dart';
import 'package:marketky/views/widgets/item_card.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  _WishlistPageState createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  List<Product> allProducts = [];
  List<Product> wishlistProducts = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchAllAndWishlist();
  }

  Future<void> fetchAllAndWishlist() async {
    setState(() => loading = true);
    try {
      // Lấy tất cả sản phẩm
      final result = await ProductService.getAllProducts();
      allProducts = List<Product>.from(result);

      // Lấy wishlist
      final items = await WishlistService.getWishlist();

      // Map WishlistItem thành Product đầy đủ
      wishlistProducts = items.map((item) {
        final prod = allProducts.firstWhere(
          (p) => p.id == item.productId,
          orElse: () => Product(
            id: item.productId,
            name: item.name,
            price: item.price,
            slug: item.slug,
            stockQuantity: 0,
            variants: [],
          ),
        );
        return prod;
      }).toList();
    } catch (e) {
      print("❌ Error loading wishlist or products: $e");
    }
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    // Luôn hiển thị AppBar; body thay đổi theo trạng thái
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text("Danh sách yêu thích"),
        centerTitle: true,
      ),
      body: Builder(builder: (context) {
        if (loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (wishlistProducts.isEmpty) {
          return const Center(child: Text("Bạn chưa thích sản phẩm nào"));
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: GridView.builder(
            physics: const BouncingScrollPhysics(),
            shrinkWrap: true,
            itemCount: wishlistProducts.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.58,
            ),
            itemBuilder: (_, index) {
              final product = wishlistProducts[index];
              return ItemCard(
                product: product,
                titleColor: AppColor.secondary,
                priceColor: AppColor.accent,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetail(product: product),
                    ),
                  );
                },
              );
            },
          ),
        );
      }),
    );
  }
}
