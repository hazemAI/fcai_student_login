import 'package:flutter/material.dart';

class CustomRadioGroup<T> extends StatelessWidget {
  final String title;
  final T? groupValue;
  final Map<T, String> options;
  final void Function(T?) onChanged;
  final bool isOptional;

  const CustomRadioGroup({
    Key? key,
    required this.title,
    required this.groupValue,
    required this.options,
    required this.onChanged,
    this.isOptional = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title ${isOptional ? '(Optional)' : ''}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Row(
          children: options.entries.map((entry) {
            return Expanded(
              child: RadioListTile<T>(
                title: Text(entry.value),
                value: entry.key,
                groupValue: groupValue,
                onChanged: onChanged,
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                dense: true,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
} 