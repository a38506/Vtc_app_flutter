import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:marketky/constants/app_color.dart';
import 'package:marketky/core/services/search_service.dart';
import 'package:marketky/views/screens/search_result_page.dart';
import 'package:marketky/views/widgets/search_history_tile.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<String> listSearchHistory = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await SearchService.getSearchHistory();
    setState(() => listSearchHistory = history);
  }

  void _onSearch(String keyword) async {
    if (keyword.isEmpty) return;
    await SearchService.addSearchHistory(keyword); // lưu vào SharedPreferences
    await _loadHistory(); // cập nhật UI
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SearchResultPage(searchKeyword: keyword),
      ),
    );
  }

  void _clearHistory() async {
    await SearchService.clearSearchHistory();
    setState(() => listSearchHistory.clear());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColor.primary,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: SvgPicture.asset('assets/icons/Arrow-left.svg', color: Colors.white),
        ),
        title: Container(
          height: 40,
          child: TextField(
            controller: _searchController,
            autofocus: true,
            style: TextStyle(fontSize: 14, color: Colors.white),
            onSubmitted: _onSearch,
            decoration: InputDecoration(
              hintStyle: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.3)),
              hintText: 'Tìm kiếm sản phẩm...',
              prefixIcon: Container(
                padding: EdgeInsets.all(10),
                child: SvgPicture.asset('assets/icons/Search.svg', color: Colors.white),
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent, width: 1),
                borderRadius: BorderRadius.circular(16),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
                borderRadius: BorderRadius.circular(16),
              ),
              fillColor: Colors.white.withOpacity(0.1),
              filled: true,
            ),
          ),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: ListView(
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Lịch sử tìm kiếm',
                    style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w400)),
                TextButton(
                  onPressed: _clearHistory,
                  child: Text('Xóa', style: TextStyle(fontSize: 12, color: AppColor.secondary.withOpacity(0.5))),
                ),
              ],
            ),
          ),
          if (listSearchHistory.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Chưa có lịch sử tìm kiếm', style: TextStyle(color: Colors.grey)),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: listSearchHistory.length,
              itemBuilder: (context, index) {
                final keyword = listSearchHistory[index];
                return SearchHistoryTile(
                  keyword: keyword,
                  onTap: () => _onSearch(keyword),
                );
              },
            ),
        ],
      ),
    );
  }
}
