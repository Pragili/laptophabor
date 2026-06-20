import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/dev_config.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../auth_notifier.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController(text: 'ada@example.com');
  final _password = TextEditingController(text: 'user123');

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    await ref.read(authProvider.notifier).login(_email.text.trim(), _password.text);
    final state = ref.read(authProvider);
    if (!mounted) return;
    state.when(
      data: (u) { if (u != null) context.go(RouteNames.home); },
      loading: () {},
      error: (e, _) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(_authError(e)))),
    );
  }

  String _authError(Object e) {
    if (e is DioException) {
      if (e.response?.statusCode == 401) return 'Invalid email or password';
      if (e.response != null) {
        final m = e.response?.data;
        return m is Map && m['message'] != null
            ? m['message'].toString()
            : 'Login failed (${e.response?.statusCode}).';
      }
      return 'Could not reach the server. Turn on demo mode '
          '(flutter run, no --dart-define), or start the backend API.';
    }
    return 'Login failed: $e';
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(authProvider).isLoading;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _form,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 24),
              Text('Welcome Back', style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 4),
              Text('Sign in to continue shopping',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 16),
              if (kUseMockBackend)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFF59E0B)),
                  ),
                  child: const Text(
                    'Demo mode is ON — no backend needed. Tap “Log In” (any '
                    'details work), or use the demo buttons below. Log in with '
                    'an email containing “admin” to see the admin pages.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF92400E)),
                  ),
                ),
              AppTextField(label: 'Email', controller: _email, icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress, validator: Validators.email),
              const SizedBox(height: 16),
              AppTextField(label: 'Password', controller: _password,
                  icon: Icons.lock_outline, obscure: true, validator: Validators.password),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.push(RouteNames.forgot),
                  child: const Text('Forgot?'),
                ),
              ),
              const SizedBox(height: 8),
              PrimaryButton(label: 'Log In', loading: loading, onPressed: _submit),
              if (kUseMockBackend) ...[
                const SizedBox(height: 12),
                SecondaryButton(
                  label: 'Continue in demo mode',
                  onPressed: () {
                    ref.read(authProvider.notifier).enterDemo();
                    context.go(RouteNames.home);
                  },
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  icon: const Icon(Icons.admin_panel_settings_outlined, size: 18),
                  label: const Text('Continue as demo admin'),
                  onPressed: () {
                    ref.read(authProvider.notifier).enterDemo(admin: true);
                    context.go(RouteNames.adminDashboard);
                  },
                ),
              ],
              const SizedBox(height: 24),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text("New here? "),
                TextButton(
                  onPressed: () => context.push(RouteNames.register),
                  child: const Text('Create account'),
                ),
              ]),
            ]),
          ),
        ),
      ),
    );
  }
}
