import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/custom_widgets/error_dialog.dart';
import '../../core/helper.dart';
import '../model/auth_method.dart';
import '../model/auth_status.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
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
      appBar: AppBar(
        title: Text(auth.method == AuthMethod.signup ? "Sign Up" : 'Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
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
                  suffixIcon: auth.isEmailLocked
                      ? const Icon(Icons.lock)
                      : null,
                ),
              ),
              if (auth.method == AuthMethod.emailPassword ||
                  auth.method == AuthMethod.signup)
                TextFormField(
                  controller: _passwordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: auth.isEmailLocked
                        ? const Icon(Icons.lock)
                        : null,
                  ),
                ),
              const SizedBox(height: 16),
              if (auth.method == AuthMethod.magicLink)
                ElevatedButton(
                  onPressed: auth.canResend
                      ? () {
                          if (_formKey.currentState!.validate()) {
                            auth.sendLink(_emailController.text.trim());
                          }
                        }
                      : null,
                  child: auth.status == AuthStatus.sendingLink
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          auth.canResend
                              ? 'Send Login Link'
                              : 'Resend in ${auth.resendSecondsLeft}s',
                        ),
                ),
              if (auth.method == AuthMethod.emailPassword ||
                  auth.method == AuthMethod.signup)
                ElevatedButton(
                  onPressed: auth.canResend
                      ? () {
                          if (_formKey.currentState!.validate()) {
                            auth.method == AuthMethod.emailPassword
                                ? auth.loginWithEmailPassword(
                                    _emailController.text.trim(),
                                    _passwordController.text.trim(),
                                  )
                                : auth.signupWithEmailPassword(
                                    _emailController.text.trim(),
                                    _passwordController.text.trim(),
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
                      : Text(
                          auth.method == AuthMethod.emailPassword
                              ? "Login"
                              : "Signup",
                        ),
                ),
              SizedBox(height: 30),
              Divider(),
              TextButton(
                onPressed: () {
                  _emailController.clear();
                  _passwordController.clear();
                  if (auth.method == AuthMethod.emailPassword ||
                      auth.method == AuthMethod.magicLink) {
                    auth.switchAuthMethod(AuthMethod.signup);
                  } else {
                    auth.switchAuthMethod(AuthMethod.emailPassword);
                  }
                },
                child: Text(
                  auth.method == AuthMethod.emailPassword ||
                          auth.method == AuthMethod.magicLink
                      ? "New here? Create an account"
                      : "Already have an account? Login",
                ),
              ),
              if (auth.method != AuthMethod.magicLink) Text("or"),
              if (auth.method != AuthMethod.magicLink)
                TextButton(
                  onPressed: () {
                    auth.switchAuthMethod(AuthMethod.magicLink);
                  },
                  child: Text("Use Magic Link"),
                ),
              if (auth.isEmailLocked)
                TextButton(
                  onPressed: auth.changeEmail,
                  child: const Text('Change email'),
                ),

              if (auth.status == AuthStatus.linkSent)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18.0),
                  child: Row(
                    children: const [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'We’ve sent a sign-in link to your email. '
                          'Please check your inbox.',
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
