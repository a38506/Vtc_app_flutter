import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:marketky/constants/app_color.dart';
import 'package:marketky/views/widgets/category_page.dart';
import 'package:marketky/views/screens/home_page.dart';
import 'package:marketky/views/screens/notification_page.dart';
import 'package:marketky/views/screens/profile_page.dart';

class PageSwitcher extends StatefulWidget {
  @override
  PageSwitcherState createState() => PageSwitcherState();
}

class PageSwitcherState extends State<PageSwitcher> {
  int _selectedIndex = 0;

  void switchToTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: [
        HomePage(),
        CategoryPage(),
        NotificationPage(),
        ProfilePage(),
      ][_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
            border:
                Border(top: BorderSide(color: AppColor.primarySoft, width: 2))),
        child: BottomNavigationBar(
          onTap: switchToTab,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: [
            (_selectedIndex == 0)
                ? BottomNavigationBarItem(
                    icon: SvgPicture.asset('assets/icons/Home-active.svg'),
                    label: '')
                : BottomNavigationBarItem(
                    icon: SvgPicture.asset('assets/icons/Home.svg'), label: ''),
            (_selectedIndex == 1)
                ? BottomNavigationBarItem(
                    icon: SvgPicture.asset('assets/icons/Category-active.svg'),
                    label: '')
                : BottomNavigationBarItem(
                    icon: SvgPicture.asset('assets/icons/Category.svg'),
                    label: ''),
            (_selectedIndex == 2)
                ? BottomNavigationBarItem(
                    icon: SvgPicture.asset(
                        'assets/icons/Notification-active.svg'),
                    label: '')
                : BottomNavigationBarItem(
                    icon: SvgPicture.asset('assets/icons/Notification.svg'),
                    label: ''),
            (_selectedIndex == 3)
                ? BottomNavigationBarItem(
                    icon: SvgPicture.asset('assets/icons/Profile-active.svg'),
                    label: '')
                : BottomNavigationBarItem(
                    icon: SvgPicture.asset('assets/icons/Profile.svg'),
                    label: ''),
          ],
        ),
      ),
    );
  }
}
