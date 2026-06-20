import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../data/address_repository.dart';
import '../../domain/address.dart';
import '../cart_notifier.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});
  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  int _step = 0;
  Address? _selectedAddress;
  String _payment = 'card';
  bool _placing = false;

  // new-address fields
  final _line1 = TextEditingController();
  final _city = TextEditingController();
  final _country = TextEditingController(text: 'Nigeria');

  @override
  void dispose() {
    for (final c in [_line1, _city, _country]) { c.dispose(); }
    super.dispose();
  }

  Future<void> _addAddress() async {
    if (_line1.text.isEmpty || _city.text.isEmpty) return;
    final addr = await ref.read(addressRepositoryProvider).create({
      'line1': _line1.text, 'city': _city.text,
      'country': _country.text, 'isDefault': true,
    });
    ref.invalidate(addressesProvider);
    setState(() => _selectedAddress = addr);
  }

  Future<void> _placeOrder() async {
    if (_selectedAddress == null) return;
    setState(() => _placing = true);
    try {
      final order =
          await ref.read(cartProvider.notifier).checkout(_selectedAddress!.id, _payment);
      if (!mounted) return;
      context.pushReplacement('${RouteNames.orderSuccess}?code=${order['trackingCode'] ?? ''}');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Checkout failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _placing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final summary = ref.watch(cartSummaryProvider);
    final addresses = ref.watch(addressesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Stepper(
        currentStep: _step,
        type: StepperType.horizontal,
        onStepContinue: () {
          if (_step == 0 && _selectedAddress == null) return;
          if (_step < 2) setState(() => _step++);
        },
        onStepCancel: () => _step > 0 ? setState(() => _step--) : null,
        controlsBuilder: (context, details) {
          if (_step == 2) {
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: PrimaryButton(
                  label: 'Place Order', isCta: true, loading: _placing, onPressed: _placeOrder),
            );
          }
          return Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(children: [
              Expanded(child: PrimaryButton(label: 'Continue', onPressed: details.onStepContinue)),
              if (_step > 0) ...[
                const SizedBox(width: 12),
                Expanded(
                    child: OutlinedButton(
                        onPressed: details.onStepCancel, child: const Text('Back'))),
              ],
            ]),
          );
        },
        steps: [
          Step(
            title: const Text('Shipping'),
            isActive: _step >= 0,
            content: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              addresses.when(
                data: (list) => Column(
                  children: list
                      .map((a) => RadioListTile<int>(
                            value: a.id,
                            groupValue: _selectedAddress?.id,
                            onChanged: (_) => setState(() => _selectedAddress = a),
                            title: Text(a.oneLine),
                            contentPadding: EdgeInsets.zero,
                          ))
                      .toList(),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text('Could not load addresses'),
              ),
              const Divider(),
              const Text('Add a new address',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              AppTextField(label: 'Street address', controller: _line1),
              const SizedBox(height: 8),
              AppTextField(label: 'City', controller: _city),
              const SizedBox(height: 8),
              AppTextField(label: 'Country', controller: _country),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                  onPressed: _addAddress,
                  icon: const Icon(Icons.add),
                  label: const Text('Save address')),
            ]),
          ),
          Step(
            title: const Text('Payment'),
            isActive: _step >= 1,
            content: Column(children: [
              RadioListTile<String>(
                value: 'card', groupValue: _payment,
                onChanged: (v) => setState(() => _payment = v!),
                title: const Text('Credit / Debit Card'),
                secondary: const Icon(Icons.credit_card),
              ),
              RadioListTile<String>(
                value: 'transfer', groupValue: _payment,
                onChanged: (v) => setState(() => _payment = v!),
                title: const Text('Bank Transfer'),
                secondary: const Icon(Icons.account_balance),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text('A simulated mock gateway processes this payment.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ),
            ]),
          ),
          Step(
            title: const Text('Review'),
            isActive: _step >= 2,
            content: Column(children: [
              _summaryRow('Subtotal', money(summary.subtotal)),
              _summaryRow('Tax (7.5%)', money(summary.tax)),
              _summaryRow('Shipping', money(summary.shipping)),
              const Divider(),
              _summaryRow('Total', money(summary.total), bold: true),
              const SizedBox(height: 8),
              if (_selectedAddress != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Ship to: ${_selectedAddress!.oneLine}',
                      style: const TextStyle(color: AppColors.textSecondary)),
                ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String k, String v, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(k, style: TextStyle(fontWeight: bold ? FontWeight.w700 : FontWeight.w400)),
          Text(v, style: TextStyle(fontWeight: bold ? FontWeight.w700 : FontWeight.w500)),
        ]),
      );
}
