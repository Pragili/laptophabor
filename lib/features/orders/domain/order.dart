class OrderLine {
  final String title;
  final String? thumbnailUrl;
  final int quantity;
  final double unitPrice;
  OrderLine({required this.title, this.thumbnailUrl, required this.quantity, required this.unitPrice});
  factory OrderLine.fromJson(Map<String, dynamic> j) => OrderLine(
        title: j['product']?['title'] ?? 'Item',
        thumbnailUrl: j['product']?['thumbnailUrl'],
        quantity: j['quantity'],
        unitPrice: double.parse(j['unitPrice'].toString()),
      );
}

class OrderModel {
  final int id;
  final String status;
  final double total;
  final String? trackingCode;
  final DateTime? createdAt;
  final List<OrderLine> items;
  OrderModel({
    required this.id,
    required this.status,
    required this.total,
    this.trackingCode,
    this.createdAt,
    this.items = const [],
  });
  factory OrderModel.fromJson(Map<String, dynamic> j) => OrderModel(
        id: j['id'],
        status: j['status'] ?? 'pending',
        total: double.parse(j['total'].toString()),
        trackingCode: j['trackingCode'],
        createdAt: j['createdAt'] == null ? null : DateTime.tryParse(j['createdAt']),
        items: (j['items'] as List?)?.map((e) => OrderLine.fromJson(e)).toList() ?? [],
      );
}
