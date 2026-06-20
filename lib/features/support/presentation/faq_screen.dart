import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../../shared/widgets/empty_state.dart';

final faqProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final Dio dio = ref.read(dioProvider);
  final res = await dio.get('/faqs');
  return (res.data['data'] as List).cast<Map<String, dynamic>>();
});

class FaqScreen extends ConsumerWidget {
  const FaqScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final faqs = ref.watch(faqProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Help & FAQ')),
      body: faqs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const EmptyState(icon: Icons.cloud_off, title: 'Could not load FAQs'),
        data: (list) => ListView(
          padding: const EdgeInsets.all(8),
          children: list
              .map((f) => Card(
                    child: ExpansionTile(
                      title: Text(f['question'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(f['answer'] ?? '')),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}
