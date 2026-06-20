import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/product_card.dart';
import '../../data/catalog_repository.dart';
import '../../domain/product.dart';
import '../../domain/product_filters.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});
  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;
  List<Product> _results = [];
  bool _loading = false;
  bool _searched = false;

  static const _popular = ['Gaming', 'MacBook', 'Dell', 'Lenovo', 'Ultrabook'];

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () => _run(q));
  }

  Future<void> _run(String q) async {
    if (q.trim().isEmpty) {
      setState(() { _results = []; _searched = false; });
      return;
    }
    setState(() { _loading = true; _searched = true; });
    try {
      final res = await ref
          .read(catalogRepositoryProvider)
          .products(ProductFilters(query: q.trim()));
      if (mounted) setState(() => _results = res);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _controller,
          autofocus: true,
          onChanged: _onChanged,
          decoration: const InputDecoration(
            hintText: 'Search laptops...',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
          ),
        ),
        actions: [
          if (_controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () { _controller.clear(); _run(''); },
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : !_searched
              ? _Suggestions(onTap: (t) { _controller.text = t; _run(t); })
              : _results.isEmpty
                  ? const EmptyState(
                      icon: Icons.search_off, title: 'No results',
                      subtitle: 'Try a different keyword.')
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _results.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, childAspectRatio: 0.62,
                          crossAxisSpacing: 12, mainAxisSpacing: 12),
                      itemBuilder: (_, i) => ProductCard(
                        product: _results[i],
                        onTap: () => context.push('${RouteNames.product}/${_results[i].id}'),
                      ),
                    ),
    );
  }
}

class _Suggestions extends StatelessWidget {
  final ValueChanged<String> onTap;
  const _Suggestions({required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Popular searches', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final t in _SearchScreenState._popular)
            ActionChip(
              avatar: const Icon(Icons.trending_up, size: 16, color: AppColors.primary),
              label: Text(t),
              onPressed: () => onTap(t),
            ),
        ]),
      ]),
    );
  }
}
