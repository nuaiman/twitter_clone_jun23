import 'package:flutter/material.dart';

import '../../../theme/pallete.dart';

class AuthField extends StatelessWidget {
  const AuthField({
    super.key,
    this.isPasswordField = false,
    required this.hintText,
    required this.onSaved,
  });
  final bool isPasswordField;
  final String hintText;
  final void Function(String fieldValue) onSaved;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: isPasswordField,
      onSaved: (newValue) {
        onSaved(newValue!);
      },
      onTapOutside: (event) {
        FocusManager.instance.primaryFocus!.unfocus();
      },
      validator: isPasswordField
          ? (value) {
              if (value!.trim().isEmpty || value.length < 8) {
                return 'Password must be atleast 8 units long.';
              }
              return null;
            }
          : (value) {
              if (value!.trim().isEmpty || !value.contains('@')) {
                return 'Please enter a valid Email.';
              }
              return null;
            },
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(fontSize: 18),
        contentPadding: const EdgeInsets.all(22),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(
            width: 3,
            color: Pallete.blueColor,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(
            color: Pallete.greyColor,
          ),
        ),
      ),
    );
  }
}
