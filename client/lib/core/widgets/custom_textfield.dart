import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextFormField extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final bool isObscureText;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final List<String> autofillHints;
  final List<TextInputFormatter> inputFormatters;
  final bool readOnly;
  final VoidCallback? onTap;
  const CustomTextFormField({
    super.key,
    required this.hintText,
    this.controller,
    this.isObscureText = false,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints = const [],
    this.inputFormatters = const [],
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      autofillHints: autofillHints,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        hintText: hintText,
      ),
      obscureText: isObscureText,
      validator: (value) {
        if (value?.trim().isEmpty ?? true) {
          return "$hintText is missing!";
        }
        return null;
      },
    );
  }
}
