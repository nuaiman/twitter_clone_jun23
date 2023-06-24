import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/rounded_small_button.dart';
import '../../../constants/ui_constants.dart';
import '../../../theme/pallete.dart';
import '../controller/auth_controller.dart';
import '../widgets/auth_field.dart';
import 'signup_view.dart';

class LoginView extends ConsumerStatefulWidget {
  static route() => MaterialPageRoute(
        builder: (context) => const LoginView(),
      );
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final appBar = UIConstants.appBar();
  final _formKey = GlobalKey<FormState>();
  var _enteredEmail = '';
  var _enteredPassword = '';

  void _onSubmit() {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    _formKey.currentState!.save();
    ref.watch(authControllerProvider.notifier).login(
          context: context,
          email: _enteredEmail,
          password: _enteredPassword,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                AuthField(
                  hintText: 'Email',
                  onSaved: (fieldValue) {
                    _enteredEmail = fieldValue;
                  },
                ),
                const SizedBox(height: 20),
                AuthField(
                  isPasswordField: true,
                  hintText: 'Password',
                  onSaved: (fieldValue) {
                    _enteredPassword = fieldValue;
                  },
                ),
                const SizedBox(height: 30),
                Align(
                  alignment: Alignment.centerRight,
                  child: RoundedSmallButton(
                    labeltext: 'Done',
                    onTap: _onSubmit,
                  ),
                ),
                const SizedBox(height: 20),
                RichText(
                  text: TextSpan(
                    text: 'Don\'t have an account? ',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                    children: [
                      TextSpan(
                        text: 'Signup',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Pallete.blueColor,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.of(context).push(SignupView.route());
                          },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
