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
  int quantity = 1;
  int currentImageIndex = 0;

  List<Review> reviews = [];
  bool isLoadingReviews = true;

  @override
  void initState() {
    super.initState();
    if (widget.product.variants != null &&
        widget.product.variants!.isNotEmpty) {
      selectedVariant = widget.product.variants!.first;
    }
    _loadReviews();
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
    return reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;
  }

  double get totalPrice =>
      (selectedVariant?.price ?? widget.product.price) * quantity;

  Future<void> _addToCart() async {
    if (selectedVariant?.id == null) {
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
        quantity: quantity,
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

  Color _lighterPrimary(double amount) {
    return Color.alphaBlend(Colors.white.withOpacity(amount), AppColor.primary);
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    bool inStock = selectedVariant?.id != null;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: _lighterPrimary(0.1),
        elevation: 1,
        centerTitle: false,
        title: const Text(
          "Chi tiết sản phẩm",
          style: TextStyle(
            color: AppColor.primarySoft,
            fontSize: 19,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColor.primarySoft),
      ),
      bottomNavigationBar: _buildBottomBar(),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          // Ảnh sản phẩm
          Stack(
            children: [
              GestureDetector(
                onTap: () {
                  if (product.images?.gallery != null) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            ImageViewer(imageUrl: product.images!.gallery),
                      ),
                    );
                  }
                },
                child: SizedBox(
                  height: 310,
                  child: PageView.builder(
                    controller: productImageSlider,
                    itemCount: product.images?.gallery.length ?? 0,
                    onPageChanged: (index) {
                      setState(() {
                        currentImageIndex = index;
                      });
                    },
                    itemBuilder: (context, index) => Image.network(
                      product.images!.gallery[index],
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tên + còn/hết hàng
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColor.secondary,
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      child: Text(
                        inStock ? 'Còn hàng' : 'Hết hàng',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: inStock ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Giá tiền
                Text(
                  NumberFormat.currency(locale: 'vi_VN', symbol: '₫')
                      .format(selectedVariant?.price ?? product.price),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColor.primary,
                  ),
                ),
                const SizedBox(height: 12),
                // Mô tả
                Text(
                  product.description ?? product.shortDescription ?? '',
                  style: TextStyle(
                    color: AppColor.secondary.withOpacity(0.7),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                // Tùy chọn variant
                if (product.variants != null && product.variants!.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tùy chọn',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      SelectableVariant(
                        variants: product.variants!,
                        onVariantSelected: (variant) {
                          setState(() => selectedVariant = variant);
                        },
                      ),
                    ],
                  ),
                const SizedBox(height: 24),
                // PHẦN REVIEW
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        RatingBarIndicator(
                          rating: averageRating,
                          itemBuilder: (context, index) =>
                              const Icon(Icons.star, color: Colors.amber),
                          itemCount: 5,
                          itemSize: 18.0,
                          direction: Axis.horizontal,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          averageRating > 0 ? averageRating.toStringAsFixed(1) : 'Chưa có đánh giá',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 8),
                        Text('(${reviews.length})'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => _showReviewBottomSheet(product.id),
                          child: const Text('Viết đánh giá'),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () {
                            // Open a full list of reviews in a bottom sheet
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                              ),
                              builder: (context) {
                                return Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Đánh giá', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 12),
                                      if (isLoadingReviews)
                                        const Center(child: CircularProgressIndicator())
                                      else if (reviews.isEmpty)
                                        const Text('Chưa có đánh giá nào.')
                                      else
                                        ...reviews.map((r) => ListTile(
                                          title: Text(r.title ?? ''),
                                          subtitle: Text(r.content ?? ''),
                                          trailing: Text(r.rating.toString()),
                                        )),
                                      const SizedBox(height: 12),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          child: const Text('Xem đánh giá'),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showReviewBottomSheet(int productId) {
  int _rating = 5;
  String _title = '';
  String _content = '';

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 16,
          left: 16,
          right: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Đánh giá sản phẩm",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            // Chọn số sao
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                  onPressed: () {
                    _rating = index + 1;
                    (context as Element).markNeedsBuild(); // cập nhật UI
                  },
                );
              }),
            ),
            // Tiêu đề
            TextField(
              decoration: const InputDecoration(
                labelText: "Tiêu đề",
              ),
              onChanged: (value) => _title = value,
            ),
            const SizedBox(height: 8),
            // Nội dung
            TextField(
              decoration: const InputDecoration(
                labelText: "Nội dung",
              ),
              maxLines: 4,
              onChanged: (value) => _content = value,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (_title.isEmpty || _content.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Vui lòng nhập tiêu đề và nội dung")),
                    );
                    return;
                  }
                  try {
                    await ReviewService.submitReview(
                      productId: productId,
                      rating: _rating,
                      title: _title,
                      content: _content,
                    );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            "Gửi đánh giá thành công. Đánh giá của bạn đang chờ duyệt."),
                      ),
                    );
                  } catch (e) {
                    print("Submit review error: $e");
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Gửi đánh giá thất bại!")),
                    );
                  }
                },
                child: const Text("Gửi đánh giá"),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      );
    },
  );
}


  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Số lượng
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Số lượng',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, size: 24),
                    onPressed:
                        quantity > 1 ? () => setState(() => quantity--) : null,
                  ),
                  Text(
                    quantity.toString(),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, size: 24),
                    onPressed: () => setState(() => quantity++),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Nút thêm vào giỏ hàng
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: selectedVariant?.id != null && !isAddingToCart
                  ? _addToCart
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: isAddingToCart
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white)),
                    )
                  : const Text(
                      'Thêm vào giỏ hàng',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
