import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/custom_widgets/error_dialog.dart';
import '../../core/helper.dart';
import '../model/auth_status.dart';
import '../providers/auth_provider.dart';

class EmailVerifyScreen extends StatefulWidget {
  const EmailVerifyScreen({super.key});

  @override
  State<EmailVerifyScreen> createState() => _EmailVerifyScreenState();
}

class _EmailVerifyScreenState extends State<EmailVerifyScreen> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final error = auth.consumeError();
      if (error != null) {
        showErrorDialog(context, error);
      }
    });
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text("Please confirm your email to continue"),
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _emailController,
                readOnly: auth.isEmailLocked,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  } else if (!isValidEmail(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'you@example.com',
                ),
              ),
            ),
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: auth.canResend
                  ? () {
                      if (_formKey.currentState!.validate()) {
                        auth.authenticate(
                          confirmedEmail: _emailController.text,
                        );
                      }
                    }
                  : null,
              child: auth.status == AuthStatus.authenticating
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}
