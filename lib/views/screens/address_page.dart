import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:marketky/constants/app_color.dart';
import 'package:marketky/core/models/address_model.dart';
import 'package:marketky/core/services/address_service.dart';
import 'package:marketky/core/services/location_service.dart';

class AddressPage extends StatefulWidget {
  final bool selectMode;
  const AddressPage({Key? key, this.selectMode = false}) : super(key: key);

  @override
  _AddressPageState createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  List<Address> addresses = [];
  List<Province> provinces = [];
  List<District> districts = [];
  List<Ward> wards = [];

  String? provinceCode;
  String? districtCode;
  String? wardCode;
  String? provinceName;
  String? districtName;
  String? wardName;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isDefault = false;
  bool isLoading = true;
  bool isEditing = false;
  Address? editingAddress;
  final LocationService _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    _loadProvinces();
    _fetchAddresses();
  }

  Future<void> _loadProvinces() async {
    final data = await _location_service_getSafe();
    setState(() {
      provinces = data;
    });
  }

  // small wrapper to avoid analyzer warnings in patch view
  Future<List<Province>> _location_service_getSafe() async {
    return await _locationService.getProvinces();
  }

  Future<void> _loadDistricts(String provinceCode) async {
    final data = await _locationService.getDistricts(provinceCode);
    setState(() {
      districts = data;
    });
  }

  Future<void> _loadWards(String districtCode) async {
    final data = await _locationService.getWards(districtCode);
    setState(() {
      wards = data;
    });
  }

  Future<void> _fetchAddresses() async {
    setState(() => isLoading = true);
    try {
      final data = await AddressService.getAddresses();
      setState(() {
        addresses = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể tải danh sách địa chỉ.')));
    }
  }

  Future<void> _deleteAddress(int addressId) async {
    final success = await AddressService.deleteAddress(addressId);
    if (success) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Địa chỉ đã được xóa.')));
      _fetchAddresses();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Không thể xóa địa chỉ.')));
    }
  }

  void _showAddressForm({Address? address}) async {
    isEditing = address != null;
    editingAddress = address;

    if (isEditing) {
      _nameController.text = address!.name;
      _phoneController.text = address.phone;
      _addressController.text = address.address;
      provinceCode = address.provinceCode;
      districtCode = address.districtCode;
      wardCode = address.wardCode;
      provinceName = address.provinceName;
      districtName = address.districtName;
      wardName = address.wardName;
      _isDefault = address.isDefault;
      if (provinceCode != null) await _loadDistricts(provinceCode!);
      if (districtCode != null) await _loadWards(districtCode!);
    } else {
      _nameController.clear();
      _phoneController.clear();
      _addressController.clear();
      provinceCode = null;
      districtCode = null;
      wardCode = null;
      provinceName = null;
      districtName = null;
      wardName = null;
      _isDefault = false;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Form(
            key: _formKey,
            child: ListView(
              shrinkWrap: true,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                        color: AppColor.border,
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  isEditing ? 'Chỉnh sửa địa chỉ' : 'Thêm địa chỉ mới',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColor.primary),
                ),
                const SizedBox(height: 12),
                Text(
                  'Điền thông tin chính xác để giao hàng nhanh chóng.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColor.secondary.withOpacity(0.7)),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Tên người nhận',
                    prefixIcon: Icon(Icons.person, color: AppColor.primary),
                    filled: true,
                    fillColor: AppColor.primarySoft,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: AppColor.border),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: AppColor.primary, width: 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Vui lòng nhập tên' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: 'Số điện thoại',
                    prefixIcon: Icon(Icons.phone, color: AppColor.primary),
                    filled: true,
                    fillColor: AppColor.primarySoft,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: AppColor.border),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: AppColor.primary, width: 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Vui lòng nhập SĐT';
                    if (!RegExp(r'^\d{10,11}$').hasMatch(v)) {
                      return 'SĐT không hợp lệ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: provinceCode,
                  decoration: InputDecoration(
                    labelText: 'Tỉnh/Thành phố',
                    filled: true,
                    fillColor: AppColor.primarySoft,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColor.border)),
                  ),
                  items: provinces
                      .map((p) =>
                          DropdownMenuItem(value: p.code, child: Text(p.name)))
                      .toList(),
                  onChanged: (v) async {
                    setModalState(() {
                      provinceCode = v;
                      districtCode = null;
                      wardCode = null;
                    });
                    if (v != null) await _loadDistricts(v);
                  },
                  validator: (v) =>
                      v == null ? 'Vui lòng chọn Tỉnh/Thành phố' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: districtCode,
                  decoration: InputDecoration(
                    labelText: 'Quận/Huyện',
                    filled: true,
                    fillColor: AppColor.primarySoft,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColor.border)),
                  ),
                  items: districts
                      .map((d) =>
                          DropdownMenuItem(value: d.code, child: Text(d.name)))
                      .toList(),
                  onChanged: (v) async {
                    setModalState(() {
                      districtCode = v;
                      wardCode = null;
                    });
                    if (v != null) await _loadWards(v);
                  },
                  validator: (v) =>
                      v == null ? 'Vui lòng chọn Quận/Huyện' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: wardCode,
                  decoration: InputDecoration(
                    labelText: 'Phường/Xã',
                    filled: true,
                    fillColor: AppColor.primarySoft,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColor.border)),
                  ),
                  items: wards
                      .map((w) =>
                          DropdownMenuItem(value: w.code, child: Text(w.name)))
                      .toList(),
                  onChanged: (v) => setModalState(() => wardCode = v),
                  validator: (v) =>
                      v == null ? 'Vui lòng chọn Phường/Xã' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    hintText: 'Địa chỉ chi tiết',
                    prefixIcon: Icon(Icons.home, color: AppColor.primary),
                    filled: true,
                    fillColor: AppColor.primarySoft,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: AppColor.border),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: AppColor.primary, width: 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Vui lòng nhập địa chỉ' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Checkbox(
                        value: _isDefault,
                        activeColor: AppColor.primary,
                        onChanged: (v) =>
                            setModalState(() => _isDefault = v ?? false)),
                    Text('Đặt làm địa chỉ mặc định',
                        style:
                            TextStyle(color: AppColor.secondary.withOpacity(0.8)))
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _saveAddress,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(isEditing ? 'Cập nhật' : 'Lưu địa chỉ',
                      style: const TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;
    final prefs = await SharedPreferences.getInstance();
    final customerId = prefs.getInt('customerId');
    if (customerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không tìm thấy thông tin KH.')));
      return;
    }

    final payload = isEditing
        ? {
            'name': _nameController.text,
            'phone': _phoneController.text,
            'address': _addressController.text,
            'province_code': provinceCode,
            'district_code': districtCode,
            'ward_code': wardCode,
            'is_default': _isDefault,
          }
        : {
            'name': _nameController.text,
            'phone': _phoneController.text,
            'address': _addressController.text,
            'province_code': provinceCode,
            'province_name': provinceName,
            'district_code': districtCode,
            'district_name': districtName,
            'ward_code': wardCode,
            'ward_name': wardName,
            'is_default': _isDefault,
          };

    final success = isEditing
        ? await AddressService.updateAddress(editingAddress!.id, payload)
        : await AddressService.addAddress(payload);

    if (success) {
      Navigator.pop(context);
      _fetchAddresses();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(isEditing
              ? 'Cập nhật địa chỉ thành công!'
              : 'Thêm địa chỉ thành công!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.98),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Địa chỉ của tôi",
          style: TextStyle(
            color: AppColor.primary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColor.primary),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(color: AppColor.primary),
            )
          : addresses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_off,
                          size: 64, color: AppColor.primarySoft),
                      const SizedBox(height: 12),
                      Text(
                        'Bạn chưa có địa chỉ nào.',
                        style: TextStyle(
                            color: AppColor.secondary.withOpacity(0.8)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Thêm địa chỉ để giao hàng nhanh chóng.',
                        style: TextStyle(
                            color: AppColor.secondary.withOpacity(0.6),
                            fontSize: 13),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: addresses.length,
                  itemBuilder: (context, index) {
                    final a = addresses[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 2,
                      shadowColor: AppColor.primary.withOpacity(0.08),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColor.primarySoft,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(Icons.location_on,
                                  color: AppColor.primary, size: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(a.name,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15)),
                                      ),
                                      if (a.isDefault)
                                        Container(
                                          margin: const EdgeInsets.only(left: 6),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                              color: AppColor.primary.withOpacity(0.12),
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          child: Text('Mặc định',
                                              style: TextStyle(
                                                  color: AppColor.primary,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600)),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text('${a.phone}',
                                      style: TextStyle(color: AppColor.secondary.withOpacity(0.8))),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${a.address}, ${a.wardName ?? ''}, ${a.districtName ?? ''}, ${a.provinceName ?? ''}',
                                    style: TextStyle(color: AppColor.secondary.withOpacity(0.85)),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      TextButton.icon(
                                        onPressed: () =>
                                            _showAddressForm(address: a),
                                        icon: Icon(Icons.edit, size: 18, color: AppColor.primary),
                                        label: Text('Sửa', style: TextStyle(color: AppColor.primary)),
                                      ),
                                      const SizedBox(width: 8),
                                      TextButton.icon(
                                        onPressed: () => _deleteAddress(a.id),
                                        icon: Icon(Icons.delete, size: 18, color: Colors.redAccent),
                                        label: Text('Xóa', style: TextStyle(color: Colors.redAccent)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColor.primary,
        onPressed: () => _showAddressForm(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}
