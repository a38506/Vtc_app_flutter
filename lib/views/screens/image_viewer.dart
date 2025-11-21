import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ImageViewer extends StatefulWidget {
  final dynamic imageUrl; // có thể là String hoặc List<String>

  const ImageViewer({super.key, required this.imageUrl});

  @override
  _ImageViewerState createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  final PageController productImageSlider = PageController();

  @override
  Widget build(BuildContext context) {
    // Nếu chỉ là String thì tạo list 1 phần tử
    final List<String> imageList = widget.imageUrl is String
        ? [widget.imageUrl]
        : (widget.imageUrl as List<String>);

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: SvgPicture.asset(
            'assets/icons/Arrow-left.svg',
            color: Colors.white,
          ),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: Stack(
        children: [
          PageView(
            physics: const BouncingScrollPhysics(),
            controller: productImageSlider,
            children: List.generate(
              imageList.length,
              (index) => Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: _buildImage(imageList[index]),
              ),
            ),
          ),

          // Indicator ở dưới
          if (imageList.length > 1)
            Positioned(
              bottom: 16,
              child: Container(
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.center,
                child: SmoothPageIndicator(
                  controller: productImageSlider,
                  count: imageList.length,
                  effect: ExpandingDotsEffect(
                    dotColor: Colors.white.withOpacity(0.2),
                    activeDotColor: Colors.white,
                    dotHeight: 8,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Tự động phân biệt ảnh asset và ảnh từ mạng
  Widget _buildImage(String url) {
    if (url.startsWith('http')) {
      return Image.network(
        url,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image, color: Colors.white54, size: 80),
      );
    } else {
      return Image.asset(
        url,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image, color: Colors.white54, size: 80),
      );
    }
  }
}
