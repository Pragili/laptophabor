/// In-memory dataset for the dev-bypass mock backend.
/// Mirrors the server seed so the app behaves the same offline.
library;

final mockBrands = [
  {'id': 1, 'name': 'Dell'}, {'id': 2, 'name': 'HP'}, {'id': 3, 'name': 'Apple'},
  {'id': 4, 'name': 'Lenovo'}, {'id': 5, 'name': 'Asus'}, {'id': 6, 'name': 'Acer'},
  {'id': 7, 'name': 'Razer'}, {'id': 8, 'name': 'MSI'}, {'id': 9, 'name': 'Microsoft'},
  {'id': 10, 'name': 'Samsung'},
];

final mockCategories = [
  {'id': 1, 'name': 'Gaming'}, {'id': 2, 'name': 'Ultrabook'},
  {'id': 3, 'name': 'Business'}, {'id': 4, 'name': '2-in-1'}, {'id': 5, 'name': 'Budget'},
];

// title, brandId, categoryId, price, salePrice, cpu, ram, storage, screen, featured
const _raw = [
  ['Dell Alienware m16', 1, 1, 1499, 1299, 'Intel Core i7-13700H', 16, 1024, 16.0, true],
  ['Lenovo Legion 5 Pro', 4, 1, 1199, null, 'AMD Ryzen 7 7745HX', 16, 512, 16.0, true],
  ['Asus ROG Zephyrus G14', 5, 1, 1750, 1575, 'AMD Ryzen 9 7940HS', 32, 1024, 14.0, true],
  ['Apple MacBook Air M3', 3, 2, 1299, null, 'Apple M3', 16, 512, 13.6, true],
  ['Apple MacBook Pro 14', 3, 2, 1999, null, 'Apple M3 Pro', 18, 512, 14.2, false],
  ['Dell XPS 15', 1, 2, 1499, 1349, 'Intel Core i7-13700H', 16, 512, 15.6, true],
  ['HP Spectre x360', 2, 4, 1150, null, 'Intel Core i7-1355U', 16, 512, 13.5, false],
  ['Lenovo ThinkPad X1 Carbon', 4, 3, 1620, 1450, 'Intel Core i7-1365U', 16, 1024, 14.0, false],
  ['HP Pavilion 15', 2, 5, 680, 599, 'Intel Core i5-1335U', 8, 512, 15.6, false],
  ['Acer Aspire 5', 6, 5, 549, null, 'AMD Ryzen 5 7530U', 8, 256, 15.6, false],
  ['Asus Zenbook 14 OLED', 5, 2, 999, 899, 'Intel Core i7-1360P', 16, 512, 14.0, false],
  ['Acer Predator Helios 16', 6, 1, 1899, null, 'Intel Core i9-13900HX', 32, 2048, 16.0, false],
  ['Microsoft Surface Laptop 5', 9, 2, 1299, 1149, 'Intel Core i7-1255U', 16, 512, 13.5, true],
  ['Razer Blade 15', 7, 1, 2299, 1999, 'Intel Core i7-13800H', 16, 1024, 15.6, true],
  ['MSI Stealth 16', 8, 1, 1999, null, 'Intel Core i9-13900H', 32, 1024, 16.0, false],
  ['Dell Inspiron 15', 1, 5, 649, 549, 'Intel Core i5-1334U', 8, 512, 15.6, false],
  ['HP Omen 16', 2, 1, 1399, 1249, 'Intel Core i7-13700HX', 16, 1024, 16.1, true],
  ['Lenovo Yoga 9i', 4, 4, 1399, null, 'Intel Core i7-1360P', 16, 1024, 14.0, false],
  ['Apple MacBook Air M2', 3, 2, 1099, 999, 'Apple M2', 8, 256, 13.6, false],
  ['Asus TUF Gaming A15', 5, 1, 1099, null, 'AMD Ryzen 7 7735HS', 16, 512, 15.6, false],
  ['Acer Swift 3', 6, 2, 749, 649, 'Intel Core i5-1240P', 16, 512, 14.0, false],
  ['Samsung Galaxy Book3', 10, 2, 1049, null, 'Intel Core i5-1340P', 16, 512, 15.6, false],
];

const _stock = [3, 8, 12, 20, 2, 15];

Map<String, dynamic> _brand(int id) => mockBrands.firstWhere((b) => b['id'] == id);
Map<String, dynamic> _cat(int id) => mockCategories.firstWhere((c) => c['id'] == id);

/// Full product list (index i -> id i+1, image laptop-i).
final List<Map<String, dynamic>> mockProducts = List.generate(_raw.length, (i) {
  final r = _raw[i];
  final id = i + 1;
  final thumb = '/uploads/laptop-$i.png';
  return {
    'id': id,
    'title': r[0],
    'brandId': r[1],
    'categoryId': r[2],
    'price': r[3],
    'salePrice': r[4],
    'stockQty': _stock[i % 6],
    'cpu': r[5],
    'ramGb': r[6],
    'storageGb': r[7],
    'screenSize': r[8],
    'isFeatured': r[9],
    'ratingAvg': (3.8 + (i % 5) * 0.25),
    'ratingCount': 12 + i * 7,
    'thumbnailUrl': thumb,
    'description':
        '${r[0]} — ${r[5]}, ${r[6]}GB RAM, ${r[7]}GB SSD, ${r[8]}" display. '
            'A great choice for ${(_cat(r[2] as int)['name'] as String).toLowerCase()} users.',
    'brand': _brand(r[1] as int),
    'category': _cat(r[2] as int),
    'images': [
      {'imageUrl': '/uploads/laptop-$i.png'},
      {'imageUrl': '/uploads/laptop-$i-b.png'},
      {'imageUrl': '/uploads/laptop-$i-c.png'},
    ],
  };
});

Map<String, dynamic> mockProductById(int id) =>
    mockProducts.firstWhere((p) => p['id'] == id, orElse: () => mockProducts.first);

List<Map<String, dynamic>> mockReviews(int productId) => [
      {
        'id': productId * 10 + 1,
        'rating': 5,
        'comment': 'Excellent build quality and performance. Highly recommend.',
        'user': {'id': 2, 'fullName': 'Ada Obi', 'avatarUrl': null},
      },
      {
        'id': productId * 10 + 2,
        'rating': 4,
        'comment': 'Great value, though the fans can get loud under load.',
        'user': {'id': 3, 'fullName': 'Tunde Bello', 'avatarUrl': null},
      },
    ];

final mockFaqs = [
  {'id': 1, 'category': 'Orders', 'question': 'How do I track my order?', 'answer': 'Open Profile → My Orders, select an order and view its status timeline.'},
  {'id': 2, 'category': 'Payment', 'question': 'What payment methods are supported?', 'answer': 'This demo uses a simulated mock gateway supporting card and bank-transfer flows.'},
  {'id': 3, 'category': 'Returns', 'question': 'How do refunds work?', 'answer': 'Refunds are issued to the original payment method within 5–7 business days.'},
  {'id': 4, 'category': 'Account', 'question': 'How do I reset my password?', 'answer': 'On the Login screen tap “Forgot?”, enter your email and follow the instructions.'},
];

final mockUser = {
  'id': 2, 'fullName': 'Ada Obi', 'email': 'ada@example.com',
  'phone': null, 'avatarUrl': null, 'role': 'customer',
};

final mockAdmin = {
  'id': 1, 'fullName': 'Site Admin', 'email': 'admin@laptopharbor.com',
  'phone': null, 'avatarUrl': null, 'role': 'admin',
};
