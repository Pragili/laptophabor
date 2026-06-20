class Address {
  final int id;
  final String line1;
  final String city;
  final String? state;
  final String? postalCode;
  final String country;
  final bool isDefault;
  Address({
    required this.id,
    required this.line1,
    required this.city,
    this.state,
    this.postalCode,
    required this.country,
    this.isDefault = false,
  });
  String get oneLine =>
      [line1, city, if (state != null) state, country].whereType<String>().join(', ');

  factory Address.fromJson(Map<String, dynamic> j) => Address(
        id: j['id'],
        line1: j['line1'],
        city: j['city'],
        state: j['state'],
        postalCode: j['postalCode'],
        country: j['country'],
        isDefault: j['isDefault'] == true,
      );
}
