import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:marketky/constants/app_color.dart';
import 'package:marketky/core/models/product_model.dart';
import 'package:marketky/core/services/product_service.dart';
import 'package:marketky/core/services/cart_service.dart';
import 'package:marketky/core/helpers/cart_helper.dart';
import 'package:marketky/views/screens/cart_page.dart';
import 'package:marketky/views/screens/empty_cart_page.dart';
import 'package:marketky/views/screens/message_page.dart';
import 'package:marketky/views/screens/search_page.dart';
import 'package:marketky/views/widgets/custom_icon_button_widget.dart';
import 'package:marketky/views/widgets/dummy_search_widget_1.dart';
import 'package:marketky/views/widgets/item_card.dart';
import 'package:marketky/views/screens/page_switcher.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Product> productData = [];
  List<dynamic> banners = [];

  PageController _pageController = PageController(viewportFraction: 1.0);
  int _currentBannerPage = 0;
  Timer? _bannerTimer;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _fetchMockBanners();
    CartHelper.init();
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
      {"image": "assets/images/d.png", "title": "Trái cây tươi ngon mỗi ngày"},
      {"image": "assets/images/1.jpg", "title": "Trái cây tươi ngon mỗi ngày"},
      {"image": "assets/images/2.jpg", "title": "Trái cây tươi ngon mỗi ngày"},
      {"image": "assets/images/3.png", "title": "Trái cây tươi ngon mỗi ngày"},
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
      backgroundColor: Colors.white,
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: [
          // ============ HEADER SECTION ============
          Container(
            height: 200,
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColor.primary,
                  AppColor.primary.withOpacity(0.85),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColor.primary.withOpacity(0.15),
                  blurRadius: 12,
                  offset: Offset(0, 6),
                )
              ],
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
                      Expanded(
                        child: Text(
                          'Tìm loại trái cây\nphù hợp cho bạn.',
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
                          // ============ Cart Icon ============
                          ValueListenableBuilder<int>(
                            valueListenable: CartHelper.cartItemCount,
                            builder: (context, count, _) {
                              return CustomIconButtonWidget(
                                value: count,
                                icon: SvgPicture.asset(
                                  'assets/icons/Bag.svg',
                                  color: Colors.white,
                                ),
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
                                          builder: (context) =>
                                              EmptyCartPage()),
                                    );
                                  }
                                },
                              );
                            },
                          ),
                          SizedBox(width: 16),
                          CustomIconButtonWidget(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) => MessagePage()));
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

          // ============ BANNER CAROUSEL ============
          if (banners.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                children: [
                  Container(
                    height: 160,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        )
                      ],
                    ),
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: banners.length,
                      onPageChanged: (index) {
                        setState(() => _currentBannerPage = index);
                      },
                      itemBuilder: (context, index) {
                        final banner = banners[index];
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            banner['image'],
                            width: double.infinity,
                            height: 160,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              color: AppColor.primarySoft,
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.image_not_supported,
                                color: AppColor.primary,
                                size: 48,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // ============ Banner Indicators ============
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      banners.length,
                      (index) => Container(
                        width: _currentBannerPage == index ? 28 : 8,
                        height: 8,
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: _currentBannerPage == index
                              ? AppColor.primary
                              : AppColor.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // ============ PROMOTION BANNER ============
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColor.accent.withOpacity(0.15),
                    AppColor.accent.withOpacity(0.08),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColor.accent.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.local_offer, color: AppColor.accent, size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ưu đãi hôm nay',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColor.accent,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Giảm 20% cho sản phẩm mới',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColor.secondary.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios,
                      color: AppColor.accent, size: 16),
                ],
              ),
            ),
          ),

          // ============ SUGGESTIONS SECTION ============
          Padding(
            padding: EdgeInsets.only(left: 16, top: 20, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gợi ý hôm nay',
                      style: TextStyle(
                        color: AppColor.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Sản phẩm được yêu thích nhất',
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
                    onPressed: () {
                      final pageSwitcherState =
                          context.findAncestorStateOfType<PageSwitcherState>();
                      if (pageSwitcherState != null) {
                        pageSwitcherState.switchToTab(1);
                      }
                    },
                    child: Text(
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

          // ============ PRODUCTS GRID ============
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: productData.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        children: [
                          Icon(Icons.shopping_bag_outlined,
                              size: 48, color: AppColor.primarySoft),
                          SizedBox(height: 12),
                          Text(
                            'Không có sản phẩm',
                            style: TextStyle(
                                color: AppColor.secondary.withOpacity(0.8)),
                          ),
                        ],
                      ),
                    ),
                  )
                : GridView.builder(
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
                        priceColor: AppColor.accent,
                      );
                    },
                  ),
          ),

          SizedBox(height: 20),
        ],
      ),
    );
  }
}
