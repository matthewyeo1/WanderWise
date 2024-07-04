import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ww_code/auth/auth_service.dart'; // Replace with your actual import path
import 'package:logging/logging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ww_code/auth/user_class.dart';
import 'package:ww_code/aesthetics/textfield_style.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  FriendsPageState createState() => FriendsPageState();
}

class FriendsPageState extends State<FriendsPage> {
  TextEditingController searchController = TextEditingController();
  List<UserClass> searchResults = [];

  final AuthServiceItinerary _authServiceItinerary = AuthServiceItinerary(); // Initialize your AuthServiceItinerary
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final Logger _logger = Logger('FriendsPage');

  void _performSearch(String query) {
  searchResults.clear();
  firestore
      .collection('Users')
      .where('Username', isGreaterThanOrEqualTo: query)
      .where('Username', isLessThan: query + '\uf8ff')
      .get()
      .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          // Assuming you have a User model or class
          UserClass user = UserClass(
            uid: doc.id, // Assuming doc.id is the user ID
            displayName: data['Username'], // Replace with your actual field name
            // Add more fields as needed
          );
          searchResults.add(
        user
          ); // Add the user object to the search results list
        });
        setState(() {});
      })
      .catchError((error) {
        _logger.warning('Error searching users: $error');
      });
}


  @override
  void initState() {
    super.initState();
    _loadFriends(); // Load friends when page initializes
  }

  void _loadFriends() async {
    try {
      User? currentUser = await _authServiceItinerary.getCurrentUser();
      if (currentUser != null) {
        // Fetch friends or perform any initialization
        // Example: Fetch friends from Firestore or another database
      } else {
        // Handle case where current user is not authenticated
        _logger.warning('User not authenticated.');
      }
    } catch (e) {
      _logger.warning('Failed to load friends: $e');
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Friends"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              cursorColor: Colors.black,
              style: const TextStyle(color: Colors.black),
              controller: searchController,
              onChanged: (value) {
                _performSearch(value);
              },
              decoration: TextFieldConfig.buildInputDecoration(
                hintText: 'Search friends...',
                prefixIcon: const Icon(Icons.search,
                color: Colors.black45,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  // Replace with your user display logic
                  return ListTile(
                    title: Text(searchResults[index].displayName),
                    // Add functionality like adding friend, viewing profile, etc.
                    onTap: () {
                      // Handle tapping on search result
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

  

