import 'package:flutter/material.dart';
import 'package:ww_code/aesthetics/colour_gradient.dart';


class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

@override
 FriendsPageState createState() => FriendsPageState();
}


class FriendsPageState extends State<FriendsPage>{
@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF00A6DF),
        title: const Text("Friends"),
        
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
  

