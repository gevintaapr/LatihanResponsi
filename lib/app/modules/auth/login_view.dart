import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/app_routes.dart';
import 'auth_controller.dart';
import '../../widgets/glass.dart';
import 'auth_widgets.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _controller = Get.find<AuthController>();
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    _controller.login(_username.text, _password.text);
  }

  Future<void> _openRegister() async {
    // Register mengembalikan username yang baru dibuat untuk diisi otomatis.
    final result = await Get.toNamed(Routes.register);
    if (result is String && mounted) {
      _username.text = result;
      _password.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Rick & Morty\nExplorer',
      subtitle: 'Masuk untuk menjelajahi multiverse',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              key: const Key('login_username'),
              controller: _username,
              textInputAction: TextInputAction.next,
              autocorrect: false,
              decoration: const InputDecoration(
                hintText: 'Username',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: _controller.validateUsername,
            ),
            const SizedBox(height: 14),
            Obx(
              () => TextFormField(
                key: const Key('login_password'),
                controller: _password,
                obscureText: _controller.obscurePassword.value,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  hintText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    onPressed: _controller.obscurePassword.toggle,
                    icon: Icon(
                      _controller.obscurePassword.value
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                  ),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Password wajib diisi' : null,
              ),
            ),
            const SizedBox(height: 24),
            Obx(
              () => GradientButton(
                label: 'Login',
                loading: _controller.isLoading.value,
                onPressed: _submit,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Belum punya akun?'),
                TextButton(
                  onPressed: _openRegister,
                  child: const Text('Daftar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
