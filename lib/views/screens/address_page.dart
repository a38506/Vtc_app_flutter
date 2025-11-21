import 'dart:convert';
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
    final data = await _locationService.getProvinces();
    setState(() {
      provinces = data;
    });
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Không thể tải danh sách địa chỉ.')));
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
      shape: RoundedRectangleBorder(
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
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  isEditing ? 'Chỉnh sửa địa chỉ' : 'Thêm địa chỉ mới',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColor.primary),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Tên người nhận',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Vui lòng nhập tên' : null,
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Số điện thoại',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Vui lòng nhập SĐT';
                    if (!RegExp(r'^\d{10,11}$').hasMatch(v))
                      return 'SĐT không hợp lệ';
                    return null;
                  },
                ),
                SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: provinceCode,
                  decoration: InputDecoration(
                    labelText: 'Tỉnh/Thành phố',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
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
                SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: districtCode,
                  decoration: InputDecoration(
                    labelText: 'Quận/Huyện',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
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
                SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: wardCode,
                  decoration: InputDecoration(
                    labelText: 'Phường/Xã',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  items: wards
                      .map((w) =>
                          DropdownMenuItem(value: w.code, child: Text(w.name)))
                      .toList(),
                  onChanged: (v) => setModalState(() => wardCode = v),
                  validator: (v) =>
                      v == null ? 'Vui lòng chọn Phường/Xã' : null,
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: 'Địa chỉ chi tiết',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Vui lòng nhập địa chỉ' : null,
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Checkbox(
                        value: _isDefault,
                        onChanged: (v) =>
                            setModalState(() => _isDefault = v ?? false)),
                    Text('Đặt làm địa chỉ mặc định')
                  ],
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _saveAddress,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(isEditing ? 'Cập nhật' : 'Lưu địa chỉ',
                      style: TextStyle(fontSize: 16)),
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Không tìm thấy thông tin KH.')));
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
        title: Text('Địa chỉ của tôi', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColor.primary,
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : addresses.isEmpty
              ? Center(
                  child: Text('Bạn chưa có địa chỉ nào.',
                      style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: EdgeInsets.all(12),
                  itemCount: addresses.length,
                  itemBuilder: (context, index) {
                    final a = addresses[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 3,
                      child: Padding(
                        padding:
                            const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.location_on, color: AppColor.primary, size: 28),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(a.name,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15)),
                                      if (a.isDefault)
                                        Container(
                                          margin: EdgeInsets.only(left: 6),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                              color: Colors.green.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(6)),
                                          child: Text('Mặc định',
                                              style: TextStyle(
                                                  color: Colors.green[800],
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600)),
                                        ),
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  Text('${a.phone}',
                                      style: TextStyle(color: Colors.grey[700])),
                                  SizedBox(height: 4),
                                  Text(
                                    '${a.address}, ${a.wardName ?? ''}, ${a.districtName ?? ''}, ${a.provinceName ?? ''}',
                                    style: TextStyle(color: Colors.grey[800]),
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      TextButton.icon(
                                        onPressed: () =>
                                            _showAddressForm(address: a),
                                        icon: Icon(Icons.edit, size: 18),
                                        label: Text('Sửa'),
                                      ),
                                      TextButton.icon(
                                        onPressed: () => _deleteAddress(a.id),
                                        icon: Icon(Icons.delete, size: 18),
                                        label: Text('Xóa'),
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
        child: Icon(Icons.add),
      ),
    );
  }
}
