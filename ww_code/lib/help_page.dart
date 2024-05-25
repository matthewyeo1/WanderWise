import 'package:flutter/material.dart';
import 'package:ww_code/aesthetics/colour_gradient.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF13438B),
        title: const Text("Help"),
        
      ),
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: getAppGradient(),
        ),
      )
    );
  }
}
