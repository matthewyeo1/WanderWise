import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ww_code/auth/auth_service.dart';
import 'package:logging/logging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ww_code/auth/user_class.dart';
import 'package:ww_code/aesthetics/textfield_style.dart';
import 'package:ww_code/friend_profile.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  FriendsPageState createState() => FriendsPageState();
}

class FriendsPageState extends State<FriendsPage> {
  TextEditingController searchController = TextEditingController();
  List<UserClass> searchResults = [];
  User? currentUser;

  final AuthServiceItinerary _authServiceItinerary =
      AuthServiceItinerary(); // Initialize your AuthServiceItinerary
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final Logger _logger = Logger('FriendsPage');

  void _performSearch(String query) {
    searchResults.clear();

    // Convert searched name to lower case 
    String queryLowerCase = query.toLowerCase();

    firestore
        .collection('Users')
        .where('UsernameLowerCase', isGreaterThanOrEqualTo: queryLowerCase)
        .where('UsernameLowerCase', isLessThan: queryLowerCase + '\uf8ff')
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
        setState(() {
          searchResults.add(user);
        }); // Add the user object to the search results list
      });
    }).catchError((error) {
      _logger.warning('Error searching users: $error');
    });
  }

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadFriends(); // Load friends when page initializes
  }

  void _loadCurrentUser() async {
    currentUser = FirebaseAuth.instance.currentUser;
  }

  void _loadFriends() async {
    try {
      User? currentUser = await _authServiceItinerary.getCurrentUser();
      if (currentUser != null) {
        // Fetch friends or perform any initialization
        firestore
            .collection('Friends')
            .where('userId', isEqualTo: currentUser.uid)
            .get()
            .then((QuerySnapshot querySnapshot) {
          querySnapshot.docs.forEach((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            UserClass friend = UserClass(
              uid: doc.id,
              displayName: data['Username'],
            );
          });
          setState(() {});
        }).catchError((error) {
          _logger.warning('Error fetching friends: $error');
        });

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

  void _handleTapOnFriend(UserClass friend) {
    if (friend.uid != FirebaseAuth.instance.currentUser!.uid) {
      
    
      Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FriendProfilePage(friend: friend),
      ),
    );
    }
    
  }

  void _handleSearchButtonPressed() {
    String query = searchController.text.trim();
    if (query.isNotEmpty) {
      _performSearch(query);
    }
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
            Row(
              children: [
                Expanded(
                  child: TextField(
                    cursorColor: Colors.black,
                    style: const TextStyle(color: Colors.black),
                    controller: searchController,
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        _performSearch(value);
                      } else {
                        setState(() {
                          searchResults.clear();
                        });
                      }
                    },
                    decoration: TextFieldConfig.buildInputDecoration(
                      hintText: 'Search friends...',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.black45,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _handleSearchButtonPressed,
                  child: const Text('Search'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  // Replace with your user display logic
                  if (index < searchResults.length) {
                    String displayName = searchResults[index].displayName;

                    if (searchResults[index].uid == currentUser?.uid) {
                      displayName += " (you)";
                    }
                    return ListTile(
                    title: Text(displayName),
                    // Add functionality like adding friend, viewing profile, etc.
                    onTap: () {
                      _handleTapOnFriend(searchResults[index]);
                    },
                  );
                  } else {
                    return Container();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
