import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'aesthetics/colour_gradient.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart'; 
import 'package:firebase_auth/firebase_auth.dart';

class ManageFlightsBookingsPage extends StatefulWidget {
  const ManageFlightsBookingsPage({Key? key}) : super(key: key); // Fixed key constructor

  @override
  ManageFlightsBookingsPageState createState() =>
      ManageFlightsBookingsPageState();
}

class ManageFlightsBookingsPageState extends State<ManageFlightsBookingsPage> {
  late String userId;
  File? file;
  String? url;
  var name;

  bool isPDF = false;

  @override
  void initState() {
    super.initState();
    loadFileUrl();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void loadFileUrl() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection("Users")
          .doc("file")
          .get();
      if (doc.exists) {
        setState(() {
          url = doc['url'];
          file = File(doc['filePath']);
          isPDF = doc['isPDF'];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Add documents here"),
        ),
      );
    }
  }

  getFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom, allowedExtensions: ['pdf', 'doc']);
    if (result != null) {
      File document = File(result.files.single.path.toString());
      setState(() {
        file = document;
        name = result.names.toString();
        isPDF = result.files.single.extension == 'pdf';
        url = null;
      });
      uploadFile();
    }
  }

  uploadFile() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
      var myFile =
          FirebaseStorage.instance.ref().child("Users").child(user.uid).child('/$name');
      UploadTask task = myFile.putFile(file!);
      TaskSnapshot snapshot = await task;
      String? downloadurl = await snapshot.ref.getDownloadURL();
      FirebaseFirestore.instance.collection('Users').doc("file").set({
        "url": downloadurl,
        "filePath": file!.path,
        "isPDF": isPDF,
      });
      setState(() {
        url = downloadurl;
      });
      print(url);
      if (url != null && file != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Upload successful!'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred'),
          ),
        );
      }
      }
    } on Exception catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred'),
        ),
      );
    }
  }

  Widget viewFile() {
    if (url != null && isPDF) {
      return Expanded(
        child: PDFView(
          filePath: file?.path ?? '', // Added null check for file path
        ),
      );
    } else if (url != null) {
      return InkWell(
        onTap: () async {
          if (await canLaunch(url!)) {
            await launch(url!);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Could not open file.'),
              ),
            );
          }
        },
        child: Container(
          // Add your child widget here
          // This could be an icon or text to indicate the file is not a PDF
        ),
      );
    } else {
      return Container(); // Return an empty container if url is null
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Upload Docs',
          style: TextStyle(color: Color(0xFF00A6DF)),
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFF00A6DF),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: getFile,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: getAppGradient(),
        ),
        child: viewFile(), // Use viewFile method to display file
      ),
    );
  }
}
