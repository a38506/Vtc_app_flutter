import 'package:flutter/material.dart';
import 'package:marketky/constants/app_color.dart';
import 'package:marketky/core/models/product_model.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ReviewTile extends StatelessWidget {
  final ProductReview review;
  const ReviewTile({Key? key, required this.review}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      width: MediaQuery.of(context).size.width,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🧍 User Photo (dùng ảnh đầu tiên nếu có)
          Container(
            width: 36,
            height: 36,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(100),
              image: review.images != null && review.images!.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(review.images!.first),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: review.images == null || review.images!.isEmpty
                ? Icon(Icons.person, color: Colors.white)
                : null,
          ),

          // 💬 Username - Rating - Comments
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rating + Optional title
                Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        flex: 8,
                        child: Text(
                          review.title ?? 'Đánh giá',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColor.primary,
                            fontFamily: 'Roboto',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Flexible(
                        flex: 4,
                        child: RatingBarIndicator(
                          rating: review.rating,
                          itemBuilder: (context, index) => const Icon(
                            Icons.star,
                            color: Colors.orange,
                          ),
                          itemCount: 5,
                          itemSize: 16,
                          unratedColor: AppColor.primarySoft,
                        ),
                      ),
                    ],
                  ),
                ),

                // Content / comment
                if (review.content != null)
                  Text(
                    review.content!,
                    style: TextStyle(
                      color: AppColor.secondary.withOpacity(0.7),
                      height: 1.5,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
