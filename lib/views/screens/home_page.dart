import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:marketky/constants/app_color.dart';
import 'package:marketky/core/models/Category.dart';
import 'package:marketky/core/models/product_model.dart';
import 'package:marketky/core/services/CategoryService.dart';
import 'package:marketky/core/services/product_service.dart';
import 'package:marketky/core/services/cart_service.dart';
import 'package:marketky/views/screens/cart_page.dart';
import 'package:marketky/views/screens/empty_cart_page.dart';
import 'package:marketky/views/screens/message_page.dart';
import 'package:marketky/views/screens/search_page.dart';
import 'package:marketky/views/widgets/custom_icon_button_widget.dart';
import 'package:marketky/views/widgets/dummy_search_widget_1.dart';
import 'package:marketky/views/widgets/item_card.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Category> categoryData = CategoryService.categoryData;
  List<Product> productData = [];
  List<dynamic> banners = [];

  // Banner carousel
  PageController _pageController = PageController(viewportFraction: 1.0);
  int _currentBannerPage = 0;
  Timer? _bannerTimer;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _fetchMockBanners();
  }

  Future<void> _loadProducts() async {
    final result = await ProductService.getAllProducts();
    if (!mounted) return;
    setState(() {
      productData = List<Product>.from(result);
    });
  }

  Future<void> _fetchMockBanners() async {
    await Future.delayed(Duration(milliseconds: 500));
    final mockData = [
      {
        "image":
            "https://lambanner.com/wp-content/uploads/2022/10/MNT-DESIGN-BANNER-DEP-DOWNLOAD-MIEN-PHI-update-1130x570.jpg",
        "title": "Xoài cát Hòa Lộc siêu ngọt!"
      },
      {
        "image":
            "https://tse3.mm.bing.net/th/id/OIP.BoM_awdtiDuFVEYxsVa4gQHaEK?rs=1&pid=ImgDetMain&o=7&rm=3",
        "title": "Sầu riêng Ri6 - Ưu đãi khủng!"
      },
      {
        "image":
            "https://lambanner.com/wp-content/uploads/2022/10/MNT-DESIGN-BANNER-DEP-DOWNLOAD-MIEN-PHI-update-1130x570.jpg",
        "title": "Trái cây tươi ngon mỗi ngày"
      },
    ];

    if (!mounted) return;

    setState(() {
      banners = mockData;
    });

    _startAutoSlideBanner();
  }

  void _startAutoSlideBanner() {
    _bannerTimer?.cancel();
    _bannerTimer = Timer.periodic(Duration(seconds: 3), (_) {
      if (!mounted || banners.isEmpty) return;

      _currentBannerPage++;
      if (_currentBannerPage >= banners.length) _currentBannerPage = 0;

      _pageController.animateToPage(
        _currentBannerPage,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _pageController.dispose();
    super.dispose();
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
                        'Tìm loại trái cây\nphù hợp cho bạn.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          height: 1.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: [
                          CustomIconButtonWidget(
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
                                      builder: (context) => EmptyCartPage()),
                                );
                              }
                            },
                            value: 0,
                            icon: SvgPicture.asset(
                              'assets/icons/Bag.svg',
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 16),
                          CustomIconButtonWidget(
                            onTap: () {
                              Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => MessagePage()));
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

          // ---------------- BANNER CAROUSEL ----------------
          if (banners.isNotEmpty)
            Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 5),
                  height: 180,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: banners.length,
                    onPageChanged: (index) {
                      setState(() => _currentBannerPage = index);
                    },
                    itemBuilder: (context, index) {
                      final banner = banners[index];
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(
                          banner['image'],
                          width: double.infinity,
                          height: 180,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            color: Colors.grey.shade300,
                            alignment: Alignment.center,
                            child: Icon(Icons.image_not_supported,
                                color: Colors.grey),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 8),
                // Dot indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    banners.length,
                    (index) => Container(
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      width: _currentBannerPage == index ? 10 : 6,
                      height: _currentBannerPage == index ? 10 : 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentBannerPage == index
                            ? AppColor.primary
                            : Colors.grey.shade400,
                      ),
                    ),
                  ),
                ),
              ],
            ),

          // ---------------- GỢI Ý HÔM NAY ----------------
          Padding(
            padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
            child: Text(
              'Gợi ý hôm nay...',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),

          // ---------------- GRID SẢN PHẨM ----------------
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: productData.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.58,
              ),
              itemBuilder: (_, index) {
                final product = productData[index];
                return ItemCard(
                  product: product,
                  titleColor: Colors.black,
                  priceColor: AppColor.primary,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
