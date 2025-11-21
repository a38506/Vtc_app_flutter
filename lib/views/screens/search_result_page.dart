import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:marketky/constants/app_color.dart';
import 'package:marketky/core/models/product_model.dart';
import 'package:marketky/core/services/search_service.dart';
import 'package:marketky/views/widgets/item_card.dart';

class SearchResultPage extends StatefulWidget {
  final String searchKeyword;
  const SearchResultPage({required this.searchKeyword});

  @override
  State<SearchResultPage> createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage>
    with TickerProviderStateMixin {
  late TabController tabController;
  TextEditingController searchInputController = TextEditingController();

  List<Product> relatedProducts = [];
  List<Product> newestProducts = [];
  List<Product> popularProducts = [];
  List<Product> bestSellerProducts = [];

  bool isLoading = true;

  double? priceMin;
  double? priceMax;

  @override
  void initState() {
    super.initState();
    searchInputController.text = widget.searchKeyword;
    tabController = TabController(length: 4, vsync: this);
    _fetchAllTabs(widget.searchKeyword);
  }

  Future<void> _fetchAllTabs(String keyword) async {
    setState(() => isLoading = true);

    try {
      // Related
      relatedProducts = await SearchService.searchProducts(
        search: keyword,
        limit: 20,
        priceMin: priceMin,
        priceMax: priceMax,
      );

      // Newest
      newestProducts = await SearchService.searchProducts(
        search: keyword,
        sortBy: 'created_at',
        sortOrder: 'desc',
        limit: 20,
        priceMin: priceMin,
        priceMax: priceMax,
      );

      // Popular
      popularProducts = await SearchService.searchProducts(
        search: keyword,
        isFeatured: true,
        limit: 20,
        priceMin: priceMin,
        priceMax: priceMax,
      );

      // Best Seller
      bestSellerProducts = await SearchService.searchProducts(
        search: keyword,
        sortBy: 'soldCount',
        sortOrder: 'desc',
        limit: 20,
        priceMin: priceMin,
        priceMax: priceMax,
      );
    } catch (e) {
      print('Lỗi tìm kiếm: $e');
    }

    if (!mounted) return;
    setState(() => isLoading = false);
  }

  Widget _buildTabContent(List<Product> products) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    if (products.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(child: Text('Không có sản phẩm nào')),
      );
    }
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        children:
            products.map((product) => ItemCard(product: product)).toList(),
      ),
    );
  }

  void _onSearch(String keyword) {
    if (keyword.isEmpty) return;
    _fetchAllTabs(keyword);
  }

  void _openPriceFilter() {
    double tempMin = priceMin ?? 0;
    double tempMax = priceMax ?? 1000000;

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      margin: EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                  Text('Chọn khoảng giá',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 16),
                  RangeSlider(
                    min: 0,
                    max: 1000000,
                    divisions: 100,
                    labels: RangeLabels(
                      '${tempMin.toInt()}₫',
                      '${tempMax.toInt()}₫',
                    ),
                    values: RangeValues(tempMin, tempMax),
                    onChanged: (RangeValues values) {
                      setModalState(() {
                        tempMin = values.start;
                        tempMax = values.end;
                      });
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Từ: ${tempMin.toInt()}₫'),
                        Text('Đến: ${tempMax.toInt()}₫'),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        priceMin = tempMin;
                        priceMax = tempMax;
                      });
                      Navigator.pop(context);
                      _fetchAllTabs(searchInputController.text);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primary,
                      minimumSize: Size(double.infinity, 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text('Áp dụng', style: TextStyle(fontSize: 16)),
                  ),
                  SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        backgroundColor: AppColor.primary,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: SvgPicture.asset(
            'assets/icons/Arrow-left.svg',
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _openPriceFilter,
            icon: SvgPicture.asset(
              'assets/icons/Filter.svg',
              color: Colors.white,
            ),
          ),
        ],
        title: Container(
          height: 40,
          child: TextField(
            autofocus: false,
            controller: searchInputController,
            style: TextStyle(fontSize: 14, color: Colors.white),
            onSubmitted: _onSearch,
            decoration: InputDecoration(
              hintStyle:
                  TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.3)),
              hintText: 'Tìm kiếm sản phẩm...',
              prefixIcon: Container(
                padding: EdgeInsets.all(10),
                child: SvgPicture.asset('assets/icons/Search.svg',
                    color: Colors.white),
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent, width: 1),
                borderRadius: BorderRadius.circular(16),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
                borderRadius: BorderRadius.circular(16),
              ),
              fillColor: Colors.white.withOpacity(0.1),
              filled: true,
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 50,
            color: AppColor.secondary,
            child: TabBar(
              controller: tabController,
              indicatorColor: AppColor.accent,
              indicatorWeight: 5,
              unselectedLabelColor: Colors.white.withOpacity(0.5),
              labelStyle: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Roboto',
                  fontSize: 12),
              unselectedLabelStyle: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Roboto',
                  fontSize: 12),
              tabs: [
                Tab(text: 'Liên quan'),
                Tab(text: 'Mới nhất'),
                Tab(text: 'Phổ biến'),
                Tab(text: 'Bán chạy'),
              ],
            ),
          ),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          _buildTabContent(relatedProducts),
          _buildTabContent(newestProducts),
          _buildTabContent(popularProducts),
          _buildTabContent(bestSellerProducts),
        ],
      ),
    );
  }
}
