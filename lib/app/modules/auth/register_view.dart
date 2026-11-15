import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'auth_controller.dart';
import '../../widgets/glass.dart';
import 'auth_widgets.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _controller = Get.find<AuthController>();
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    _controller.register(_username.text, _password.text);
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      showBack: true,
      title: 'Buat Akun',
      subtitle: 'Akun disimpan di database lokal perangkat',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              key: const Key('register_username'),
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
                key: const Key('register_password'),
                controller: _password,
                obscureText: _controller.obscurePassword.value,
                textInputAction: TextInputAction.next,
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
                validator: _controller.validatePassword,
              ),
            ),
            const SizedBox(height: 14),
            Obx(
              () => TextFormField(
                key: const Key('register_confirm'),
                controller: _confirm,
                obscureText: _controller.obscurePassword.value,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                decoration: const InputDecoration(
                  hintText: 'Konfirmasi password',
                  prefixIcon: Icon(Icons.lock_reset_outlined),
                ),
                validator: (v) =>
                    v != _password.text ? 'Password tidak sama' : null,
              ),
            ),
            const SizedBox(height: 24),
            Obx(
              () => GradientButton(
                label: 'Register',
                loading: _controller.isLoading.value,
                onPressed: _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
