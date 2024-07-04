import 'package:flutter/material.dart';

class TextFieldConfig {
  static InputDecoration buildInputDecoration({
    required String hintText,
    Icon? prefixIcon,
    FocusNode? focusNode,
    TextEditingController? controller,
    bool? obscureText,
    
  }) {
    return InputDecoration(
      filled: true,
      fillColor: const Color.fromARGB(255, 208, 208, 208),
      prefixIcon: prefixIcon,
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.black45),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      
    );
  }
}
