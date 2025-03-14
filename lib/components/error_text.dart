import 'package:flutter/material.dart';

class ErrorText extends StatelessWidget {
  final String errorMessage;
  final TextAlign textAlign;
  final EdgeInsetsGeometry padding;

  const ErrorText({
    Key? key,
    required this.errorMessage,
    this.textAlign = TextAlign.center,
    this.padding = const EdgeInsets.only(bottom: 16.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (errorMessage.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Padding(
      padding: padding,
      child: Text(
        errorMessage,
        style: const TextStyle(
          color: Colors.red,
          fontSize: 14.0,
        ),
        textAlign: textAlign,
      ),
    );
  }
} 