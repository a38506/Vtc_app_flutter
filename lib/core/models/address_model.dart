class Address {
  final int id;
  final int customerId;
  final String name;
  final String phone;
  final String address;
  final String? provinceCode;
  final String? provinceName;
  final String? districtCode;
  final String? districtName;
  final String? wardCode;
  final String? wardName;
  final bool isDefault;

  Address({
    required this.id,
    required this.customerId,
    required this.name,
    required this.phone,
    required this.address,
    this.provinceCode,
    this.provinceName,
    this.districtCode,
    this.districtName,
    this.wardCode,
    this.wardName,
    required this.isDefault,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
  return Address(
    id: int.parse(json['id']),
    customerId: int.parse(json['customer_id']),
    name: json['name']?.toString() ?? '',
    phone: json['phone']?.toString() ?? '',
    address: json['address']?.toString() ?? '',
    provinceCode: json['province_code']?.toString(),
    provinceName: json['province_name']?.toString(),
    districtCode: json['district_code']?.toString(),
    districtName: json['district_name']?.toString(),
    wardCode: json['ward_code']?.toString(),
    wardName: json['ward_name']?.toString(),
    isDefault: json['is_default'] ?? false,
  );
}


  Map<String, dynamic> toJson() {
    return {
      'id': id.toString(),
      'customer_id': customerId.toString(),
      'name': name,
      'phone': phone,
      'address': address,
      'province_code': provinceCode,
      'province_name': provinceName,
      'district_code': districtCode,
      'district_name': districtName,
      'ward_code': wardCode,
      'ward_name': wardName,
      'is_default': isDefault,
    };
  }
}
