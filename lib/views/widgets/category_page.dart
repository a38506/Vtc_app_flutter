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
        physics: BouncingScrollPhysics(),
        children: [
          // ---------------- HEADER ----------------
          Container(
            height: 190,
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 26),
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Khám phá\ncác loại trái cây.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          height: 1.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: [
                          // ---------------- Icon Cart with ValueListenableBuilder ----------------
                          ValueListenableBuilder<int>(
                            valueListenable: CartHelper.cartItemCount,
                            builder: (context, count, _) {
                              return CustomIconButtonWidget(
                                onTap: () async {
                                  final cart = await CartService.getCart();
                                  if (cart != null && cart.items.isNotEmpty) {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            CartPage(initialCartItems: cart.items),
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
                          SizedBox(width: 16),
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
                DummySearchWidget1(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => SearchPage()),
                    );
                  },
                ),
              ],
            ),
          ),

          // ---------------- SẢN PHẨM NỔI BẬT ----------------
          Padding(
            padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
            child: Text(
              'Sản phẩm nổi bật',
              style: TextStyle(
                color: AppColor.secondary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildProductGrid(newProducts),

          // ---------------- BÁN CHẠY NHẤT ----------------
          Padding(
            padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
            child: Text(
              'Bán chạy nhất',
              style: TextStyle(
                color: AppColor.secondary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildProductGrid(bestSellers),
        ],
      ),
    );
  }

  Widget _buildProductGrid(List<Product> products) {
    if (products.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(child: Text('Không có sản phẩm nào')),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GridView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: products.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
