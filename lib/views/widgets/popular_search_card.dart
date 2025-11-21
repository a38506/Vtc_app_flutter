// import 'package:flutter/material.dart';
// import 'package:marketky/constants/app_color.dart';
// import 'package:marketky/core/models/search.dart';

// class PopularSearchCard extends StatelessWidget {
//   final PopularSearch data;
//   final VoidCallback? onTap;

//   PopularSearchCard({required this.data, this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: MediaQuery.of(context).size.width / 2 - 16, // để có khoảng cách
//         margin: EdgeInsets.only(bottom: 12, right: 8),
//         padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.15),
//               blurRadius: 4,
//               offset: Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             // Nếu có ảnh icon/ảnh đại diện cho popular search
//             Container(
//               width: 40,
//               height: 40,
//               margin: EdgeInsets.only(right: 12),
//               decoration: BoxDecoration(
//                 color: AppColor.primarySoft,
//                 borderRadius: BorderRadius.circular(8),
//                 image: data.imageUrl != null
//                     ? DecorationImage(
//                         image: NetworkImage(data.imageUrl!),
//                         fit: BoxFit.cover,
//                       )
//                     : null,
//               ),
//               child: data.imageUrl == null
//                   ? Icon(Icons.trending_up, color: AppColor.primary)
//                   : null,
//             ),
//             Expanded(
//               child: Text(
//                 data.title,
//                 style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w500,
//                   color: AppColor.secondary,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
