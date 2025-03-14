import 'package:flutter/material.dart';

class CustomDropdown<T> extends StatelessWidget {
  final String labelText;
  final IconData prefixIcon;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final String? hintText;
  final void Function(T?)? onChanged;

  const CustomDropdown({
    Key? key,
    required this.labelText,
    required this.prefixIcon,
    required this.value,
    required this.items,
    this.hintText,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(prefixIcon),
        border: const OutlineInputBorder(),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
        ),
      ),
      value: value,
      hint: hintText != null ? Text(hintText!) : null,
      items: items,
      onChanged: onChanged,
      isExpanded: true,
      icon: const Icon(Icons.arrow_drop_down),
      iconSize: 24,
      elevation: 16,
      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
    );
  }
} 