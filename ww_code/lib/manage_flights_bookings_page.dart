import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io'; // Import the dart:io package for File class
import 'aesthetics/colour_gradient.dart';
import 'hotel_bookings_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ManageFlightsBookingsPage extends StatefulWidget {
  const ManageFlightsBookingsPage({super.key});

  @override
  ManageFlightsBookingsPageState createState() =>
      ManageFlightsBookingsPageState();
}

class ManageFlightsBookingsPageState extends State<ManageFlightsBookingsPage> {
  int _selectedIndex = 0;
  late String userId;
  List<Reference> files = [];

  @override
  void initState() {
    super.initState();
    _initializeUserId();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // load flight documents
  }

  Future<void> _initializeUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
      });
      await _loadFiles();
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> _loadFiles() async {
    final ListResult result =
        await FirebaseStorage.instance.ref(userId).listAll();
    setState(() {
      files = result.items;
    });
  }

  Future<void> _uploadFile() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Upload a document:'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final filePickerResult = await FilePicker.platform.pickFiles();
                if (filePickerResult != null &&
                    filePickerResult.files.single.path != null) {
                  final file = File(filePickerResult.files.single.path!);
                  final fileRef = FirebaseStorage.instance
                      .ref('$userId/${file.uri.pathSegments.last}');
                  await fileRef.putFile(file);
                  await _loadFiles(); // Reload files to update the list
                }
                Navigator.pop(context, true);
              },
              child: const Text('Upload'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _viewFile(String url) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('View Document'),
          ),
          body: Center(
            child: Image.network(url),
          ),
        ),
      ),
    );
  }

  Future<void> _renameFile(Reference ref) async {
    TextEditingController _controller = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rename Document'),
          content: TextField(
            controller: _controller,
            decoration: const InputDecoration(hintText: "Enter new name"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final newName = _controller.text;
                if (newName.isNotEmpty) {
                  final newRef = FirebaseStorage.instance
                      .ref('$userId/$newName');
                  await newRef.putFile(File(await ref.getDownloadURL()));
                  await ref.delete();
                  await _loadFiles(); // Reload files to update the list
                }
                Navigator.pop(context);
              },
              child: const Text('Rename'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteFile(Reference ref) async {
    final shouldDelete = await _showDeleteConfirmationDialog();
    if (shouldDelete) {
      await ref.delete();
      await _loadFiles(); // Reload files to update the list
    }
  }

  Future<bool> _showDeleteConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Document'),
          content: const Text('Delete this document?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    ).then((value) => value ?? false);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          _selectedIndex == 0 ? 'Flights' : 'Accommodation',
          style: const TextStyle(color: Color(0xFF00A6DF)),
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFF00A6DF),
        ),
        actions: _selectedIndex == 0
            ? [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _uploadFile,
                ),
              ]
            : [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: null,
                ),
              ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: getAppGradient(),
        ),
        child: Center(
          child: _selectedIndex == 0 ? _buildFileList() : const Text('bye'),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.airplanemode_active),
            label: 'Flights',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.hotel),
            label: 'Accommodation',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF00A6DF),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 0.0,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildFileList() {
    return ListView.builder(
      itemCount: files.length,
      itemBuilder: (context, index) {
        final fileRef = files[index];
        return GestureDetector(
          onTap: () async {
            final url = await fileRef.getDownloadURL();
            _viewFile(url);
          },
          child: Container(
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: ListTile(
              title: Text(fileRef.name),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _renameFile(fileRef),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteFile(fileRef),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
