class ProductFilters {
  final String? query;
  final int? categoryId;
  final Set<int> brandIds;
  final double minPrice;
  final double maxPrice;
  final Set<int> ram;
  final Set<int> storage;
  final String? cpu;
  final double minRating;
  final bool onSale;
  final String sort;

  const ProductFilters({
    this.query,
    this.categoryId,
    this.brandIds = const {},
    this.minPrice = 0,
    this.maxPrice = 4000,
    this.ram = const {},
    this.storage = const {},
    this.cpu,
    this.minRating = 0,
    this.onSale = false,
    this.sort = 'newest',
  });

  ProductFilters copyWith({
    String? query,
    int? categoryId,
    Set<int>? brandIds,
    double? minPrice,
    double? maxPrice,
    Set<int>? ram,
    Set<int>? storage,
    String? cpu,
    double? minRating,
    bool? onSale,
    String? sort,
  }) =>
      ProductFilters(
        query: query ?? this.query,
        categoryId: categoryId ?? this.categoryId,
        brandIds: brandIds ?? this.brandIds,
        minPrice: minPrice ?? this.minPrice,
        maxPrice: maxPrice ?? this.maxPrice,
        ram: ram ?? this.ram,
        storage: storage ?? this.storage,
        cpu: cpu ?? this.cpu,
        minRating: minRating ?? this.minRating,
        onSale: onSale ?? this.onSale,
        sort: sort ?? this.sort,
      );

  Map<String, dynamic> toQuery() {
    final m = <String, dynamic>{'sort': sort};
    if (query != null && query!.isNotEmpty) m['q'] = query;
    if (categoryId != null) m['categoryId'] = categoryId;
    if (brandIds.isNotEmpty) m['brandId'] = brandIds.join(',');
    if (minPrice > 0) m['minPrice'] = minPrice;
    if (maxPrice < 4000) m['maxPrice'] = maxPrice;
    if (ram.isNotEmpty) m['ram'] = ram.join(',');
    if (storage.isNotEmpty) m['storage'] = storage.join(',');
    if (cpu != null) m['cpu'] = cpu;
    if (minRating > 0) m['minRating'] = minRating;
    if (onSale) m['sale'] = 'true';
    return m;
  }
}
