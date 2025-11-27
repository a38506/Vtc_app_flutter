import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:marketky/constants/app_color.dart';
import 'package:marketky/core/models/product_model.dart';
import 'package:marketky/core/helpers/cart_helper.dart';
import 'package:marketky/views/screens/cart_page.dart';
import 'package:marketky/views/screens/empty_cart_page.dart';
import 'package:marketky/views/screens/message_page.dart';
import 'package:marketky/views/screens/search_page.dart';
import 'package:marketky/views/widgets/custom_icon_button_widget.dart';
import 'package:marketky/views/widgets/dummy_search_widget_1.dart';
import 'package:marketky/views/widgets/item_card.dart';
import 'package:marketky/core/services/search_service.dart';
import 'package:marketky/core/services/cart_service.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({Key? key}) : super(key: key);

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  List<Product> newProducts = [];
  List<Product> bestSellers = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
    CartHelper.init(); // Khởi tạo CartHelper
  }

  Future<void> _loadProducts() async {
    final featuredProducts = await SearchService.searchProducts(
      isFeatured: true,
      page: 2,
    );

    final priceMinProducts = await SearchService.searchProducts(
      priceMin: 1000,
      sortOrder: "asc",
    );

    if (!mounted) return;
    setState(() {
      newProducts = featuredProducts.take(4).toList();
      bestSellers = priceMinProducts.take(4).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          // ============ HEADER SECTION (giống HomePage) ============
          Container(
            height: 200,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColor.primary,
                  AppColor.primary.withOpacity(0.85),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColor.primary.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                )
              ],
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 26),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          'Khám phá\ncác loại trái cây.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            height: 1.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          // ============ Icon Cart with ValueListenableBuilder ============
                          ValueListenableBuilder<int>(
                            valueListenable: CartHelper.cartItemCount,
                            builder: (context, count, _) {
                              return CustomIconButtonWidget(
                                onTap: () async {
                                  final cart = await CartService.getCart();
                                  if (cart != null && cart.items.isNotEmpty) {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => CartPage(
                                            initialCartItems: cart.items),
                                      ),
                                    );
                                  } else {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => EmptyCartPage(),
                                      ),
                                    );
                                  }
                                },
                                value: count,
                                icon: SvgPicture.asset(
                                  'assets/icons/Bag.svg',
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 10),
                          CustomIconButtonWidget(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => MessagePage(),
                                ),
                              );
                            },
                            value: 2,
                            icon: SvgPicture.asset(
                              'assets/icons/Chat.svg',
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: DummySearchWidget1(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => SearchPage()),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // ============ SẢN PHẨM NỔI BẬT ============
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 20, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sản phẩm nổi bật',
                      style: TextStyle(
                        color: AppColor.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Những sản phẩm được yêu thích',
                      style: TextStyle(
                        color: AppColor.secondary.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Xem tất cả',
                      style: TextStyle(
                        color: AppColor.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          _buildProductGrid(newProducts),

          // ============ BÁN CHẠY NHẤT ============
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 20, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bán chạy nhất',
                      style: TextStyle(
                        color: AppColor.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Những sản phẩm bán chạy nhất',
                      style: TextStyle(
                        color: AppColor.secondary.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Xem tất cả',
                      style: TextStyle(
                        color: AppColor.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),

          _buildProductGrid(bestSellers),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildProductGrid(List<Product> products) {
    if (products.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.shopping_bag_outlined,
                  size: 48, color: AppColor.primarySoft),
              const SizedBox(height: 12),
              Text(
                'Không có sản phẩm nào',
                style: TextStyle(
                  color: AppColor.secondary.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: products.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.58,
        ),
        itemBuilder: (_, index) {
          final product = products[index];
          return ItemCard(
            product: product,
            titleColor: Colors.black,
            priceColor: AppColor.accent,
          );
        },
      ),
    );
  }
}
