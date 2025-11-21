import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:marketky/constants/app_color.dart';
import 'package:marketky/views/screens/login_page.dart';
import 'package:marketky/views/widgets/main_app_bar_widget.dart';
import 'package:marketky/views/widgets/menu_tile_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/auth_service.dart';
import 'address_page.dart';
import 'my_order_page.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// 🔹 Load thông tin user từ SharedPreferences
  Future<void> _loadUserData() async {
    final userData = await AuthService.getUserData();
    setState(() {
      _user = userData;
      _loading = false;
    });
    print("👤 User data loaded: $_user");
  }

  /// 🔹 Xử lý đăng xuất
  Future<void> _handleLogout() async {
    await AuthService.logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final String? name = _user?['name'];
    final String? email = _user?['email'];
    final String? avatar = _user?['avartar']; // API trả về 'avartar'

    return Scaffold(
      appBar: MainAppBar(cartValue: 2, chatValue: 2),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                // 🔹 Phần 1 - Ảnh đại diện + thông tin người dùng
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/background.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Avatar
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Colors.grey[300],
                          image: DecorationImage(
                            image: (avatar != null && avatar.isNotEmpty)
                                ? NetworkImage(avatar)
                                : const AssetImage('assets/images/pp.jpg')
                                    as ImageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Tên
                      Text(
                        name ?? 'Đang tải...',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      // Email
                      Text(
                        email ?? '',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Nút chỉnh sửa thông tin
                    ],
                  ),
                ),

                // 🔹 Phần 2 - Menu tài khoản
                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.only(top: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(left: 16),
                        child: Text(
                          'TÀI KHOẢN',
                          style: TextStyle(
                            color: AppColor.secondary.withOpacity(0.5),
                            letterSpacing: 6 / 100,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      // Mục mới: Thay đổi thông tin cá nhân
                      MenuTileWidget(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => EditProfilePage(user: _user),
                            ),
                          );
                        },
                        margin: const EdgeInsets.only(top: 10),
                        icon: SvgPicture.asset(
                          'assets/icons/User.svg', // icon đại diện người dùng
                          color: AppColor.secondary.withOpacity(0.5),
                        ),
                        title: 'Thông tin cá nhân',
                        subtitle: 'Chỉnh sửa họ tên, số điện thoại, avatar',
                      ),
                      MenuTileWidget(
                        onTap: () {},
                        icon: SvgPicture.asset(
                          'assets/icons/Heart.svg',
                          color: AppColor.secondary.withOpacity(0.5),
                        ),
                        title: 'Danh sách yêu thích',
                        subtitle: 'Xem sản phẩm bạn yêu thích',
                      ),
                      MenuTileWidget(
                        onTap: () {},
                        icon: SvgPicture.asset(
                          'assets/icons/Show.svg',
                          color: AppColor.secondary.withOpacity(0.5),
                        ),
                        title: 'Lần truy cập cuối',
                        subtitle: 'Xem lịch sử truy cập',
                      ),
                      MenuTileWidget(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const MyOrdersPage()),
                          );
                        },
                        icon: SvgPicture.asset(
                          'assets/icons/Bag.svg',
                          color: AppColor.secondary.withOpacity(0.5),
                        ),
                        title: 'Đơn hàng',
                        subtitle: 'Xem các đơn hàng của bạn',
                      ),
                      MenuTileWidget(
                        onTap: () {},
                        icon: SvgPicture.asset(
                          'assets/icons/Wallet.svg',
                          color: AppColor.secondary.withOpacity(0.5),
                        ),
                        title: 'Ví tiền',
                        subtitle: 'Xem số dư và giao dịch',
                      ),
                      MenuTileWidget(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => AddressPage()),
                          );
                        },
                        icon: SvgPicture.asset(
                          'assets/icons/Location.svg',
                          color: AppColor.secondary.withOpacity(0.5),
                        ),
                        title: 'Địa chỉ',
                        subtitle: 'Quản lý địa chỉ giao hàng',
                      ),
                    ],
                  ),
                ),

                // 🔹 Phần 3 - Cài đặt
                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.only(top: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(left: 16),
                        child: Text(
                          'CÀI ĐẶT',
                          style: TextStyle(
                            color: AppColor.secondary.withOpacity(0.5),
                            letterSpacing: 6 / 100,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      MenuTileWidget(
                        onTap: () {},
                        margin: const EdgeInsets.only(top: 10),
                        icon: SvgPicture.asset(
                          'assets/icons/Filter.svg',
                          color: AppColor.secondary.withOpacity(0.5),
                        ),
                        title: 'Ngôn ngữ',
                        subtitle: 'Chọn ngôn ngữ sử dụng ứng dụng',
                      ),
                      MenuTileWidget(
                        onTap: _handleLogout,
                        icon: SvgPicture.asset(
                          'assets/icons/Log Out.svg',
                          color: Colors.red,
                        ),
                        iconBackground: Colors.red[100]!,
                        title: 'Đăng xuất',
                        titleColor: Colors.red,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
