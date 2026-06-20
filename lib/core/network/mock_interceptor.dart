import 'dart:math';
import 'package:dio/dio.dart';
import 'mock_data.dart';

/// Dev-bypass backend. Short-circuits every API call with in-memory data so the
/// app runs with no server, database or network. Cart / wishlist / orders are
/// stateful for the session. Enabled via kUseMockBackend (see dev_config.dart).
class MockInterceptor extends Interceptor {
  final List<Map<String, dynamic>> _cart = [];
  final Set<int> _wishlist = {};
  final List<Map<String, dynamic>> _orders = [];
  final List<Map<String, dynamic>> _addresses = [
    {'id': 1, 'line1': '12 Marina Road', 'city': 'Lagos', 'state': 'Lagos',
     'postalCode': '101001', 'country': 'Nigeria', 'isDefault': true},
  ];
  final List<Map<String, dynamic>> _notifications = [
    {'id': 1, 'title': 'Welcome to LaptopHarbor', 'body': 'You are in demo mode — explore freely.', 'isRead': false},
  ];
  int _cartSeq = 1;
  int _orderSeq = 1;
  int _addrSeq = 2;

  String _daysAgo(int d) =>
      DateTime.now().subtract(Duration(days: d)).toIso8601String();

  num _toNum(dynamic v, num d) => v == null ? d : num.parse(v.toString());

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    await Future<void>.delayed(const Duration(milliseconds: 220)); // simulate latency
    final method = options.method.toUpperCase();
    final path = options.path;
    final q = options.queryParameters;
    final body = options.data is Map ? Map<String, dynamic>.from(options.data) : <String, dynamic>{};
    final authed = (options.headers['Authorization'] ?? '').toString().isNotEmpty;

    Response ok(dynamic data, [int code = 200]) =>
        Response(requestOptions: options, statusCode: code, data: data);
    void resolve(dynamic data, [int code = 200]) => handler.resolve(ok(data, code));
    void fail(int code, String msg) => handler.reject(DioException(
        requestOptions: options,
        response: Response(requestOptions: options, statusCode: code, data: {'message': msg}),
        type: DioExceptionType.badResponse));

    int idFromPath() => int.tryParse(path.split('/').last.split('?').first) ?? 0;

    try {
      // ---------- AUTH ----------
      if (path == '/auth/login' && method == 'POST') {
        final email = (body['email'] ?? '').toString().toLowerCase();
        final isAdmin = email.contains('admin');
        final user = isAdmin
            ? {...mockAdmin, 'email': body['email'] ?? mockAdmin['email']}
            : {...mockUser, 'email': body['email'] ?? mockUser['email']};
        return resolve({'token': isAdmin ? 'mock-admin-token' : 'mock-token', 'user': user});
      }
      if (path == '/auth/register' && method == 'POST') {
        return resolve({'token': 'mock-token', 'user': {...mockUser, 'fullName': body['fullName'] ?? 'New User', 'email': body['email'] ?? mockUser['email']}}, 201);
      }
      if (path == '/auth/me' && method == 'GET') {
        if (!authed) return fail(401, 'Authentication required');
        final isAdmin = (options.headers['Authorization'] ?? '').toString().contains('admin');
        return resolve({'user': isAdmin ? mockAdmin : mockUser});
      }
      if (path == '/auth/forgot-password' && method == 'POST') {
        return resolve({'message': 'Reset token generated', 'resetToken': 'demo-reset'});
      }

      // ---------- CATALOG ----------
      if (path == '/products' && method == 'GET') {
        return resolve(_filterProducts(q));
      }
      if (path == '/products/featured' && method == 'GET') {
        return resolve({'data': mockProducts.where((p) => p['isFeatured'] == true).toList()});
      }
      if (RegExp(r'^/products/\d+$').hasMatch(path) && method == 'GET') {
        final p = Map<String, dynamic>.from(mockProductById(idFromPath()));
        p['reviews'] = mockReviews(p['id'] as int);
        return resolve({'data': p});
      }
      if (path == '/categories' && method == 'GET') return resolve({'data': mockCategories});
      if (path == '/brands' && method == 'GET') return resolve({'data': mockBrands});

      // ---------- CART ----------
      if (path == '/cart' && method == 'GET') return resolve({'data': _cart});
      if (path == '/cart' && method == 'POST') {
        final pid = body['productId'] as int;
        final qty = (body['quantity'] ?? 1) as int;
        final product = mockProductById(pid);
        final existing = _cart.where((c) => c['product']['id'] == pid).toList();
        if (existing.isNotEmpty) {
          existing.first['quantity'] = min<int>((existing.first['quantity'] as int) + qty, product['stockQty'] as int);
        } else {
          _cart.add({'id': _cartSeq++, 'quantity': min<int>(qty, product['stockQty'] as int), 'product': product});
        }
        return resolve({'data': _cart.last}, 201);
      }
      if (RegExp(r'^/cart/\d+$').hasMatch(path) && method == 'PUT') {
        final item = _cart.firstWhere((c) => c['id'] == idFromPath(), orElse: () => {});
        if (item.isEmpty) return fail(404, 'Cart item not found');
        final qty = body['quantity'] as int;
        if (qty <= 0) { _cart.removeWhere((c) => c['id'] == item['id']); return resolve({'message': 'Item removed'}); }
        item['quantity'] = min<int>(qty, item['product']['stockQty'] as int);
        return resolve({'data': item});
      }
      if (RegExp(r'^/cart/\d+$').hasMatch(path) && method == 'DELETE') {
        _cart.removeWhere((c) => c['id'] == idFromPath());
        return resolve({'message': 'Item removed'});
      }
      if (path == '/cart' && method == 'DELETE') { _cart.clear(); return resolve({'message': 'Cart cleared'}); }

      // ---------- WISHLIST ----------
      if (path == '/wishlist' && method == 'GET') {
        return resolve({'data': _wishlist.map((id) => {'product': mockProductById(id)}).toList()});
      }
      if (path == '/wishlist/toggle' && method == 'POST') {
        final pid = body['productId'] as int;
        final inList = _wishlist.contains(pid);
        inList ? _wishlist.remove(pid) : _wishlist.add(pid);
        return resolve({'inWishlist': !inList}, inList ? 200 : 201);
      }

      // ---------- ORDERS ----------
      if (path == '/orders/checkout' && method == 'POST') {
        final subtotal = _cart.fold<num>(0, (s, c) {
          final p = c['product'];
          final price = (p['salePrice'] ?? p['price']) as num;
          return s + price * (c['quantity'] as int);
        });
        final tax = (subtotal * 0.075);
        const shipping = 25;
        final order = {
          'id': _orderSeq,
          'status': 'paid',
          'subtotal': subtotal,
          'tax': double.parse(tax.toStringAsFixed(2)),
          'shippingFee': shipping,
          'total': double.parse((subtotal + tax + shipping).toStringAsFixed(2)),
          'trackingCode': 'LH-${100000 + Random().nextInt(899999)}',
          'createdAt': DateTime.now().toIso8601String(),
          'items': _cart.map((c) => {
                'quantity': c['quantity'],
                'unitPrice': (c['product']['salePrice'] ?? c['product']['price']),
                'product': {'title': c['product']['title'], 'thumbnailUrl': c['product']['thumbnailUrl']},
              }).toList(),
        };
        _orders.insert(0, order);
        _notifications.insert(0, {'id': _notifications.length + 1, 'title': 'Order confirmed', 'body': 'Your order ${order['trackingCode']} has been placed.', 'isRead': false});
        _orderSeq++;
        _cart.clear();
        return resolve({'data': order}, 201);
      }
      if (path == '/orders' && method == 'GET') return resolve({'data': _orders});
      if (RegExp(r'^/orders/\d+$').hasMatch(path) && method == 'GET') {
        final o = _orders.firstWhere((o) => o['id'] == idFromPath(), orElse: () => {});
        return o.isEmpty ? fail(404, 'Order not found') : resolve({'data': o});
      }

      // ---------- REVIEWS ----------
      if (RegExp(r'^/reviews/product/\d+$').hasMatch(path) && method == 'GET') {
        return resolve({'data': mockReviews(idFromPath())});
      }
      if (path == '/reviews' && method == 'POST') {
        return resolve({'data': {'id': 999, 'rating': body['rating'], 'comment': body['comment'], 'user': mockUser}}, 201);
      }

      // ---------- MISC ----------
      if (path == '/notifications' && method == 'GET') return resolve({'data': _notifications});
      if (path == '/notifications/read-all' && method == 'PUT') {
        for (final n in _notifications) { n['isRead'] = true; }
        return resolve({'message': 'All marked read'});
      }
      if (path == '/addresses' && method == 'GET') return resolve({'data': _addresses});
      if (path == '/addresses' && method == 'POST') {
        final a = {'id': _addrSeq++, 'line1': body['line1'], 'city': body['city'], 'state': body['state'],
                   'postalCode': body['postalCode'], 'country': body['country'], 'isDefault': body['isDefault'] == true};
        if (a['isDefault'] == true) { for (final x in _addresses) { x['isDefault'] = false; } }
        _addresses.add(a);
        return resolve({'data': a}, 201);
      }
      if (path == '/faqs' && method == 'GET') return resolve({'data': mockFaqs});

      // ---------- ADMIN ----------
      if (path == '/admin/dashboard' && method == 'GET') {
        final lowStock = mockProducts.where((p) => (p['stockQty'] as int) <= 5).toList();
        final sessionRevenue = _orders.fold<num>(0, (s, o) => s + (o['total'] as num));
        final sampleOrders = [
          {'trackingCode': 'LH-204881', 'customer': 'Ada Obi', 'status': 'delivered', 'total': 1399.00, 'createdAt': _daysAgo(1)},
          {'trackingCode': 'LH-204790', 'customer': 'Tunde Bello', 'status': 'shipped', 'total': 1750.00, 'createdAt': _daysAgo(1)},
          {'trackingCode': 'LH-204655', 'customer': 'Chidi Okeke', 'status': 'processing', 'total': 680.00, 'createdAt': _daysAgo(2)},
          {'trackingCode': 'LH-204512', 'customer': 'Zainab Musa', 'status': 'paid', 'total': 1299.00, 'createdAt': _daysAgo(3)},
          {'trackingCode': 'LH-204390', 'customer': 'Emeka Eze', 'status': 'delivered', 'total': 999.00, 'createdAt': _daysAgo(4)},
        ];
        final recent = [
          ..._orders.map((o) => {...o, 'customer': 'You (demo)'}),
          ...sampleOrders,
        ].take(6).toList();
        return resolve({
          'metrics': {
            'revenue': 18420.50 + sessionRevenue,
            'orders': _orders.length + 24,
            'users': 137,
            'lowStock': lowStock.length,
          },
          'salesSeries': const [
            {'label': 'Mon', 'value': 2100}, {'label': 'Tue', 'value': 2780},
            {'label': 'Wed', 'value': 1890}, {'label': 'Thu', 'value': 3200},
            {'label': 'Fri', 'value': 2950}, {'label': 'Sat', 'value': 3680},
            {'label': 'Sun', 'value': 2480},
          ],
          'recentOrders': recent,
          'lowStockProducts': lowStock
              .map((p) => {'title': p['title'], 'stockQty': p['stockQty'], 'thumbnailUrl': p['thumbnailUrl']})
              .toList(),
        });
      }

      return fail(404, 'Mock route not found: $method $path');
    } catch (e) {
      return fail(500, 'Mock error: $e');
    }
  }

  Map<String, dynamic> _filterProducts(Map<String, dynamic> q) {
    Iterable<Map<String, dynamic>> list = mockProducts;
    final query = (q['q'] ?? '').toString().toLowerCase();
    if (query.isNotEmpty) list = list.where((p) => (p['title'] as String).toLowerCase().contains(query));
    if (q['categoryId'] != null) list = list.where((p) => p['categoryId'].toString() == q['categoryId'].toString());
    if (q['brandId'] != null) {
      final ids = q['brandId'].toString().split(',');
      list = list.where((p) => ids.contains(p['brandId'].toString()));
    }
    if (q['ram'] != null) {
      final rams = q['ram'].toString().split(',');
      list = list.where((p) => rams.contains(p['ramGb'].toString()));
    }
    if (q['storage'] != null) {
      final st = q['storage'].toString().split(',');
      list = list.where((p) => st.contains(p['storageGb'].toString()));
    }
    if (q['minPrice'] != null) list = list.where((p) => (p['price'] as num) >= _toNum(q['minPrice'], 0));
    if (q['maxPrice'] != null) list = list.where((p) => (p['price'] as num) <= _toNum(q['maxPrice'], 999999));
    if (q['cpu'] != null) list = list.where((p) => (p['cpu'] as String).toLowerCase().contains(q['cpu'].toString().toLowerCase()));
    if (q['minRating'] != null) list = list.where((p) => (p['ratingAvg'] as num) >= _toNum(q['minRating'], 0));
    if (q['sale'] == 'true' || q['sale'] == true) list = list.where((p) => p['salePrice'] != null);

    final out = list.toList();
    switch (q['sort']) {
      case 'price_asc': out.sort((a, b) => (a['price'] as num).compareTo(b['price'] as num)); break;
      case 'price_desc': out.sort((a, b) => (b['price'] as num).compareTo(a['price'] as num)); break;
      case 'rating': out.sort((a, b) => (b['ratingAvg'] as num).compareTo(a['ratingAvg'] as num)); break;
      case 'popular': out.sort((a, b) => (b['ratingCount'] as num).compareTo(a['ratingCount'] as num)); break;
    }
    return {'data': out, 'total': out.length, 'page': 1, 'limit': out.length};
  }
}
