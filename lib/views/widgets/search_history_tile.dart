import 'package:flutter/material.dart';
import 'package:marketky/constants/app_color.dart';

class SearchHistoryTile extends StatelessWidget {
  final String keyword;
  final VoidCallback? onTap;

  const SearchHistoryTile({required this.keyword, this.onTap, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(
              color: AppColor.primarySoft,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.history, color: AppColor.primary, size: 20),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                keyword,
                style: TextStyle(fontSize: 14, color: AppColor.secondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
