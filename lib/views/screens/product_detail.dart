import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:marketky/constants/app_color.dart';
import 'package:marketky/core/models/product_model.dart';
import 'package:marketky/core/services/cart_service.dart';
import 'package:marketky/views/screens/image_viewer.dart';
import 'package:marketky/views/widgets/custom_app_bar.dart';
import 'package:marketky/views/widgets/selectable_variant.dart';
import 'package:intl/intl.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/review_tile.dart';
import 'reviews_page.dart';

class ProductDetail extends StatefulWidget {
  final Product product;
  const ProductDetail({required this.product, super.key});

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  PageController productImageSlider = PageController();
  ProductVariant? selectedVariant;
  bool isAddingToCart = false;
  bool isReviewExpanded = false; // trạng thái mở/đóng review

  @override
  void initState() {
    super.initState();
    // Chọn variant đầu tiên nếu có
    if (widget.product.variants != null &&
        widget.product.variants!.isNotEmpty) {
      selectedVariant = widget.product.variants!.first;
    }
  }

  Future<void> _addToCart() async {
    if (selectedVariant == null) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn một phiên bản sản phẩm!')),
      );
      return;
    }

    setState(() => isAddingToCart = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final customerId = prefs.getInt('customerId');

      if (customerId == null) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          const SnackBar(content: Text('Không tìm thấy thông tin khách hàng.')),
        );
        return;
      }

      final success = await CartService.addItemToCart(
        customerId: customerId,
        variantId: selectedVariant!.id,
        quantity: 1,
      );

      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(
          content: Text(
            success
                ? '✅ Đã thêm vào giỏ hàng!'
                : '❌ Không thể thêm vào giỏ hàng.',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text('⚠️ Lỗi khi thêm vào giỏ hàng: $e')),
      );
    } finally {
      if (mounted) setState(() => isAddingToCart = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Product product = widget.product;

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      bottomNavigationBar: _buildBottomBar(),
      body: ListView(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        children: [
          _buildImageSection(product),
          _buildProductInfo(product),
          if (product.variants != null && product.variants!.isNotEmpty)
            _buildVariantPicker(product),
          _buildReviewSection(product),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColor.border, width: 1)),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 50,
            margin: const EdgeInsets.only(right: 14),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.secondary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              onPressed: () {},
              child: SvgPicture.asset('assets/icons/Chat.svg',
                  color: Colors.white),
            ),
          ),
          Expanded(
            child: SizedBox(
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: isAddingToCart ? null : _addToCart,
                child: isAddingToCart
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                    : const Text(
                        'Thêm vào giỏ hàng',
                        style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontSize: 16),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(Product product) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        GestureDetector(
          onTap: () {
            if (product.images?.thumbnail != null) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      ImageViewer(imageUrl: product.images!.thumbnail!),
                ),
              );
            }
          },
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 310,
            color: Colors.white,
            padding: const EdgeInsets.only(top: 63),
            child: PageView.builder(
              controller: productImageSlider,
              physics: const BouncingScrollPhysics(),
              itemCount: product.images?.gallery.length ?? 0,
              itemBuilder: (context, index) => Image.network(
                product.images!.gallery[index],
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        CustomAppBar(
          title: product.name,
          leftIcon: SvgPicture.asset('assets/icons/Arrow-left.svg'),
          rightIcon: SvgPicture.asset('assets/icons/Bookmark.svg',
              color: Colors.black.withOpacity(0.5)),
          leftOnTap: () => Navigator.of(context).pop(),
          rightOnTap: () {},
        ),
        Positioned(
          bottom: 16,
          child: SmoothPageIndicator(
            controller: productImageSlider,
            count: product.images?.gallery.length ?? 0,
            effect: ExpandingDotsEffect(
              dotColor: AppColor.primary.withOpacity(0.2),
              activeDotColor: AppColor.primary,
              dotHeight: 8,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductInfo(Product product) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.name,
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                fontFamily: 'Roboto',
                color: AppColor.secondary),
          ),
          const SizedBox(height: 8),
          Text(
            NumberFormat.currency(locale: 'vi_VN', symbol: '₫')
                .format(selectedVariant?.price ?? product.price),
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontFamily: 'Roboto',
                color: AppColor.primary),
          ),
          const SizedBox(height: 16),
          Text(
            product.description ?? product.shortDescription ?? '',
            style: TextStyle(
                color: AppColor.secondary.withOpacity(0.7), height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildVariantPicker(Product product) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tùy chọn',
            style: TextStyle(
                color: AppColor.secondary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: 'Roboto'),
          ),
          SelectableVariant(
            variants: product.variants!,
            margin: const EdgeInsets.only(top: 15),
            onVariantSelected: (variant) {
              setState(() => selectedVariant = variant);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReviewSection(Product product) {
    final hasReviews = product.reviews != null && product.reviews!.isNotEmpty;
    final reviewsToShow = hasReviews
        ? (product.reviews!.length > 2 ? 2 : product.reviews!.length)
        : 0;

    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề nhấn vào mở review
          InkWell(
            onTap: () {
              setState(() {
                isReviewExpanded = !isReviewExpanded;
              });
            },
            child: Text(
              'Đánh giá sản phẩm',
              style: TextStyle(
                color: AppColor.secondary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: 'Roboto',
              ),
            ),
          ),
          const SizedBox(height: 8),
          AnimatedCrossFade(
            firstChild: Container(),
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasReviews)
                  Column(
                    children: List.generate(
                      reviewsToShow,
                      (index) => Column(
                        children: [
                          ReviewTile(review: product.reviews![index]),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      'Chưa có đánh giá nào.',
                      style:
                          TextStyle(color: AppColor.secondary.withOpacity(0.7)),
                    ),
                  ),
                if (hasReviews)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                ReviewsPage(reviews: product.reviews!),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: AppColor.primary,
                        elevation: 0,
                        backgroundColor: AppColor.primarySoft,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        'Xem tất cả đánh giá',
                        style: TextStyle(
                            color: AppColor.secondary,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
              ],
            ),
            crossFadeState: isReviewExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}
