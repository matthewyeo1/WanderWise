import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:logging/logging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ww_code/user/user_class.dart';
import 'package:ww_code/aesthetics/textfield_style.dart';
import 'package:ww_code/friend_profile.dart';
import 'package:ww_code/pending_invites.dart';
import 'package:ww_code/aesthetics/themes.dart';
import 'localization/locales.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  FriendsPageState createState() => FriendsPageState();
}

class FriendsPageState extends State<FriendsPage> {
  TextEditingController searchController = TextEditingController();
  List<UserClass> searchResults = [];
  User? currentUser;
  int pendingInvitesCount = 0;
  bool isSearching = false;
  bool hasSearched = false;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final Logger _logger = Logger('FriendsPage');

  // Search logic
  void _performSearch(String query) {
    setState(() {
      isSearching = true;
      searchResults.clear();
    });
    // Convert searched name to lower case
    String queryLowerCase = query.toLowerCase();

    firestore
        .collection('Users')
        .where('UsernameLowerCase', isGreaterThanOrEqualTo: queryLowerCase)
        .where('UsernameLowerCase', isLessThan: queryLowerCase + '\uf8ff')
        .get()
        .then((QuerySnapshot querySnapshot) {
      if (mounted) {
        setState(() {
          searchResults.clear();
          querySnapshot.docs.forEach((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

            UserClass user = UserClass(
              uid: doc.id,
              displayName: data['Username'],
              profileImageUrl: data['profileImageUrl'],
            );

            searchResults.add(user);
          });

          isSearching = false;
          hasSearched = true;
        });
      }
    }).catchError((error) {
      _logger.warning('Error searching users: $error');
      if (mounted) {
        setState(() {
          isSearching = false;
          hasSearched = true;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  void _loadCurrentUser() async {
    currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      _loadPendingInvites();
    }
  }

  void _loadPendingInvites() async {
    if (currentUser != null) {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser!.uid)
          .collection('PendingInvites')
          .get();

      setState(() {
        pendingInvitesCount = snapshot
            .size; // Update count based on query result, ie. how many pending request docs in the collection
      });
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

  void onSearchChanged(String value) {
    if (value.isNotEmpty) {
      _performSearch(value);
    } else {
      setState(() {
        searchResults.clear();
        isSearching = false;
        hasSearched = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleData.friendsPageTitle.getString(context)),
        actions: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PendingInvitesPage(
                        userId: currentUser!.uid,
                      ),
                    ),
                  ).then((_) {
                    _loadPendingInvites();
                  });
                },
                icon: const Icon(Icons.mail),
              ),
              if (pendingInvitesCount > 0)
                Positioned(
                  right: 6,
                  top: 5,
                  child: Container(
                    padding: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      maxHeight: 18,
                      maxWidth: 18,
                    ),
                    child: Center(
                      child: Text(
                        '$pendingInvitesCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
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
                    onChanged: onSearchChanged,
                    decoration: TextFieldConfig.buildInputDecoration(
                      hintText: LocaleData.hintTextSearchUsers.getString(context),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.black45,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: isSearching
                  ? Center(
                      child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).brightness == Brightness.light
                            ? Theme.of(context)
                                .customColors
                                .circularProgressIndicatorLight
                            : Theme.of(context)
                                .customColors
                                .circularProgressIndicatorDark,
                      ),
                    ))
                  : searchResults.isEmpty && hasSearched
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'images/cannot_find_username.png',
                                height: 100,
                                width: 100,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                LocaleData.noUsersFound.getString(context),
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : searchController.text.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'images/find_friends.png',
                                    height: 250,
                                    width: 250,
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    LocaleData.backgroundText6.getString(context),
                                    style: const TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: searchResults.length,
                              itemBuilder: (context, index) {
                                if (index < searchResults.length) {
                                  String displayName =
                                      searchResults[index].displayName;
                                  if (searchResults[index].uid ==
                                      currentUser?.uid) {
                                    displayName += LocaleData.userIndicator.getString(context);
                                  }
                                  String? profileImageUrl =
                                      searchResults[index].profileImageUrl;

                                  return ListTile(
                                    leading: profileImageUrl != null
                                        ? CircleAvatar(
                                            backgroundImage:
                                                NetworkImage(profileImageUrl),
                                          )
                                        : const CircleAvatar(
                                            backgroundColor: Colors.white,
                                            foregroundColor: Colors.black45,
                                            child: Icon(Icons.person),
                                          ),
                                    title: Text(displayName),
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
