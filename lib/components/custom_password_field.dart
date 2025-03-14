import 'package:flutter/material.dart';

class CustomPasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final bool isVisible;
  final VoidCallback toggleVisibility;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;

  const CustomPasswordField({
    Key? key,
    required this.controller,
    required this.labelText,
    this.hintText,
    required this.isVisible,
    required this.toggleVisibility,
    this.validator,
    this.textInputAction = TextInputAction.next,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: toggleVisibility,
        ),
        border: const OutlineInputBorder(),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
      ),
      obscureText: !isVisible,
      validator: validator,
      textInputAction: textInputAction,
    );
  }
} 