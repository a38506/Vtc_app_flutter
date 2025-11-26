import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:marketky/constants/app_color.dart';
import 'package:marketky/core/models/product_model.dart';
import 'package:marketky/core/models/review_model.dart';
import 'package:marketky/core/services/cart_service.dart';
import 'package:marketky/core/services/review_service.dart';
import 'package:marketky/views/screens/image_viewer.dart';
import 'package:marketky/views/widgets/selectable_variant.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../core/services/wishlist_service.dart';
import '../../core/models/wishlist_model.dart';

class ProductDetail extends StatefulWidget {
  final Product product;
  const ProductDetail({required this.product, super.key});

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  final PageController productImageSlider = PageController();
  ProductVariant? selectedVariant;
  bool isAddingToCart = false;
  int quantity = 1;
  int currentImageIndex = 0;

  List<Review> reviews = [];
  bool isLoadingReviews = true;

  bool isWishlisted = false;
  bool isLoadingWishlist = false;

  @override
  void initState() {
    super.initState();
    if (widget.product.variants != null &&
        widget.product.variants!.isNotEmpty) {
      selectedVariant = widget.product.variants!.first;
    }
    _loadReviews();
    _loadWishlistStatus();
  }

  @override
  void dispose() {
    productImageSlider.dispose();
    super.dispose();
  }

  Future<void> _loadWishlistStatus() async {
    setState(() => isLoadingWishlist = true);
    try {
      final ids = await WishlistService.getWishlistProductIds();
      if (mounted) {
        setState(() {
          isWishlisted = ids.contains(widget.product.id);
        });
      }
    } catch (e) {
      print("❌ Error loading wishlist status: $e");
    } finally {
      if (mounted) setState(() => isLoadingWishlist = false);
    }
  }

  Future<void> _loadReviews() async {
    setState(() => isLoadingReviews = true);
    try {
      reviews = await ReviewService.getApprovedReviews(widget.product.id);
    } catch (e) {
      reviews = [];
    } finally {
      if (mounted) setState(() => isLoadingReviews = false);
    }
  }

  double get averageRating {
    if (reviews.isEmpty) return 0.0;
    return reviews.map((r) => r.rating).reduce((a, b) => a + b) /
        reviews.length;
  }

  double get totalPrice =>
      (selectedVariant?.price ?? widget.product.price) * quantity;

  Future<void> _addToCart() async {
    if (selectedVariant?.id == null) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn một phiên bản sản phẩm!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isAddingToCart = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final customerId = prefs.getInt('customerId');

      if (customerId == null) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          const SnackBar(
            content: Text('Không tìm thấy thông tin khách hàng.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final success = await CartService.addItemToCart(
        customerId: customerId,
        variantId: selectedVariant!.id,
        quantity: quantity,
      );

      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(
          content: Text(success
              ? '✅ Đã thêm vào giỏ hàng!'
              : '❌ Không thể thêm vào giỏ hàng.'),
          backgroundColor:
              success ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(
          content: Text('⚠️ Lỗi khi thêm vào giỏ hàng: $e'),
          backgroundColor: Colors.orange,
        ),
      );
    } finally {
      if (mounted) setState(() => isAddingToCart = false);
    }
  }

  Future<void> _toggleWishlist() async {
    final productId = widget.product.id;
    if (isLoadingWishlist) return;

    setState(() {
      isLoadingWishlist = true;
      isWishlisted = !isWishlisted;
    });

    try {
      bool success;
      if (isWishlisted) {
        success = await WishlistService.addToWishlist(productId);
      } else {
        success = await WishlistService.removeFromWishlist(productId);
      }
    } catch (e) {
      print('❌ Lỗi wishlist: $e');
    } finally {
      if (mounted) setState(() => isLoadingWishlist = false);
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(
          content: Text(isWishlisted
              ? "❤️ Đã thêm vào yêu thích"
              : "Đã xoá khỏi yêu thích"),
          backgroundColor: AppColor.primary,
        ),
      );
    }
  }

  Color _lighterPrimary(double amount) {
    return Color.alphaBlend(Colors.white.withOpacity(amount), AppColor.primary);
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final bool inStock = selectedVariant?.id != null;
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.95),
        elevation: 1,
        centerTitle: true,
        title: const Text(
          "Chi tiết sản phẩm",
          style: TextStyle(
            color: AppColor.primary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColor.primary),
        actions: [
          IconButton(
            icon: isLoadingWishlist
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColor.primary),
                    ),
                  )
                : Icon(
                    isWishlisted ? Icons.favorite : Icons.favorite_border,
                    color: isWishlisted ? Colors.red : AppColor.primary,
                    size: 26,
                  ),
            onPressed: isLoadingWishlist ? null : _toggleWishlist,
          ),
          IconButton(
            icon: const Icon(Icons.report, color: AppColor.primary, size: 26),
            onPressed:() => {},
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          // Image slider
          Stack(
            children: [
              GestureDetector(
                onTap: () {
                  final gallery = product.images?.gallery;
                  if (gallery != null && gallery.isNotEmpty) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ImageViewer(imageUrl: gallery),
                      ),
                    );
                  }
                },
                child: Container(
                  height: 320,
                  decoration: BoxDecoration(
                    color: AppColor.primarySoft,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(20),
                    ),
                  ),
                  child: (product.images?.gallery != null &&
                          product.images!.gallery.isNotEmpty)
                      ? PageView.builder(
                          controller: productImageSlider,
                          itemCount: product.images!.gallery.length,
                          onPageChanged: (index) {
                            setState(() => currentImageIndex = index);
                          },
                          itemBuilder: (context, index) => Image.network(
                            product.images!.gallery[index],
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(AppColor.primary),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(Icons.broken_image, size: 80, color: Colors.grey),
                              );
                            },
                          ),
                        )
                      : Container(
                          color: AppColor.primarySoft,
                          child: const Center(
                            child: Icon(Icons.image_not_supported,
                                size: 80, color: Colors.grey),
                          ),
                        ),
                ),
              ),
              // Indicators
              if (product.images?.gallery != null &&
                  product.images!.gallery.length > 1)
                Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(product.images!.gallery.length, (i) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        width: currentImageIndex == i ? 12 : 8,
                        height: currentImageIndex == i ? 12 : 8,
                        decoration: BoxDecoration(
                          color: currentImageIndex == i
                              ? AppColor.primary
                              : Colors.white70,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                            )
                          ],
                        ),
                      );
                    }),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 18),

          // Product info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + Stock
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColor.secondary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: inStock
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: inStock ? Colors.green : Colors.red,
                        ),
                      ),
                      child: Text(
                        inStock ? '✓ Còn hàng' : '✗ Hết hàng',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: inStock ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // SKU
                Text(
                  'SKU: ${selectedVariant?.sku ?? product.sku ?? "N/A"}',
                  style: TextStyle(
                    color: AppColor.secondary.withOpacity(0.7),
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 8),

                // Price
                Text(
                  NumberFormat.currency(locale: 'vi_VN', symbol: '₫')
                      .format(selectedVariant?.price ?? product.price),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColor.accent,
                  ),
                ),

                const SizedBox(height: 12),

                // Description
                Container(
                  child: Text(
                    product.description ?? product.shortDescription ?? 'Không có mô tả',
                    style: TextStyle(
                      color: AppColor.secondary.withOpacity(0.85),
                      height: 1,
                      fontSize: 14,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Variants
                if (product.variants != null && product.variants!.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Chọn phiên bản',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColor.secondary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SelectableVariant(
                        variants: product.variants!,
                        onVariantSelected: (variant) {
                          setState(() => selectedVariant = variant);
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),

                // Ratings
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColor.border),
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.primary.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          RatingBarIndicator(
                            rating: averageRating,
                            itemBuilder: (context, index) =>
                                const Icon(Icons.star, color: Colors.amber),
                            itemCount: 5,
                            itemSize: 20,
                            direction: Axis.horizontal,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            averageRating > 0
                                ? '${averageRating.toStringAsFixed(1)} ⭐'
                                : 'Chưa có đánh giá',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: AppColor.secondary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(${reviews.length} đánh giá)',
                            style: TextStyle(
                              color: AppColor.secondary.withOpacity(0.7),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      if (reviews.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        const Divider(color: AppColor.border),
                        const SizedBox(height: 14),
                        ...reviews.take(2).map((review) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        review.title ?? 'Không có tiêu đề',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                          color: AppColor.secondary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    RatingBarIndicator(
                                      rating: review.rating.toDouble(),
                                      itemBuilder: (context, index) => const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 14,
                                      ),
                                      itemCount: 5,
                                      itemSize: 14,
                                      direction: Axis.horizontal,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  review.content ?? 'Không có nội dung',
                                  style: TextStyle(
                                    color: AppColor.secondary.withOpacity(0.8),
                                    fontSize: 13,
                                    height: 1.5,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  review.customerName ?? 'Khách hàng',
                                  style: TextStyle(
                                    color: AppColor.secondary.withOpacity(0.6),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        if (reviews.length > 2)
                          SizedBox(
                            width: double.infinity,
                            child: TextButton(
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20),
                                    ),
                                  ),
                                  builder: (ctx) => DraggableScrollableSheet(
                                    expand: false,
                                    initialChildSize: 0.7,
                                    maxChildSize: 0.9,
                                    builder: (context, scrollController) => Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(20),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Header
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 12,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  'Tất cả đánh giá (${reviews.length})',
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w800,
                                                    color: AppColor.secondary,
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.close),
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Divider(color: AppColor.border),
                                          // Reviews list
                                          Expanded(
                                            child: ListView.separated(
                                              controller: scrollController,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 12,
                                                  ),
                                              itemCount: reviews.length,
                                              separatorBuilder: (_, __) =>
                                                  const Divider(
                                                color: AppColor.border,
                                              ),
                                              itemBuilder: (context, index) {
                                                final review = reviews[index];
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                    vertical: 12,
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  review.title ??
                                                                      'Không có tiêu đề',
                                                                  style:
                                                                      const TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                    fontSize: 14,
                                                                    color:
                                                                        AppColor
                                                                            .secondary,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  height: 6,
                                                                ),
                                                                RatingBarIndicator(
                                                                  rating: review
                                                                      .rating
                                                                      .toDouble(),
                                                                  itemBuilder:
                                                                      (context,
                                                                          index) =>
                                                                          const Icon(
                                                                    Icons.star,
                                                                    color: Colors
                                                                        .amber,
                                                                    size: 16,
                                                                  ),
                                                                  itemCount: 5,
                                                                  itemSize: 16,
                                                                  direction: Axis
                                                                      .horizontal,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 10),
                                                      Text(
                                                        review.content ??
                                                            'Không có nội dung',
                                                        style: TextStyle(
                                                          color: AppColor
                                                              .secondary
                                                              .withOpacity(0.8),
                                                          fontSize: 13,
                                                          height: 1.6,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 10),
                                                      Text(
                                                        review.customerName ??
                                                            'Khách hàng',
                                                        style: TextStyle(
                                                          color: AppColor
                                                              .secondary
                                                              .withOpacity(0.6),
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: AppColor.primary,
                              ),
                              child: Text(
                                'Xem thêm ${reviews.length - 2} đánh giá',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColor.primary.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Số lượng',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColor.secondary,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColor.primarySoft,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColor.border),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 20, color: AppColor.primary),
                      onPressed: quantity > 1
                          ? () => setState(() => quantity--)
                          : null,
                      iconSize: 20,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        quantity.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColor.secondary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 20, color: AppColor.primary),
                      onPressed: () => setState(() => quantity++),
                      iconSize: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: selectedVariant?.id != null && !isAddingToCart
                  ? _addToCart
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary,
                disabledBackgroundColor: AppColor.primary.withOpacity(0.5),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: isAddingToCart
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Thêm vào giỏ - ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(totalPrice)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
