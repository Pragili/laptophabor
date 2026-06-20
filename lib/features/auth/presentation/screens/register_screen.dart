import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../auth_notifier.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    for (final c in [_name, _email, _password, _confirm]) { c.dispose(); }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    if (_password.text != _confirm.text) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }
    await ref.read(authProvider.notifier)
        .register(_name.text.trim(), _email.text.trim(), _password.text);
    if (!mounted) return;
    ref.read(authProvider).when(
          data: (u) { if (u != null) context.go(RouteNames.home); },
          loading: () {},
          error: (e, _) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(e is DioException && e.response == null
                  ? 'Could not reach the server. Turn on demo mode, or start the backend API.'
                  : 'Registration failed: $e'))),
        );
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(authProvider).isLoading;
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _form,
            child: Column(children: [
              AppTextField(label: 'Full name', controller: _name,
                  icon: Icons.person_outline,
                  validator: (v) => Validators.required(v, 'Name')),
              const SizedBox(height: 16),
              AppTextField(label: 'Email', controller: _email,
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress, validator: Validators.email),
              const SizedBox(height: 16),
              AppTextField(label: 'Password', controller: _password,
                  icon: Icons.lock_outline, obscure: true, validator: Validators.password),
              const SizedBox(height: 16),
              AppTextField(label: 'Confirm password', controller: _confirm,
                  icon: Icons.lock_outline, obscure: true, validator: Validators.password),
              const SizedBox(height: 24),
              PrimaryButton(label: 'Sign Up', loading: loading, onPressed: _submit),
            ]),
          ),
        ),
      ),
    );
  }
}
