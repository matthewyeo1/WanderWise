import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'aesthetics/colour_gradient.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class ManageFlightsBookingsPage extends StatefulWidget {
  const ManageFlightsBookingsPage({Key? key}) : super(key: key);

  @override
  ManageFlightsBookingsPageState createState() =>
      ManageFlightsBookingsPageState();
}

class ManageFlightsBookingsPageState extends State<ManageFlightsBookingsPage> {
  File? file;
  String? url;
  String? fileName;
  bool isPDF = false;
  late String userId;
  List<DocumentSnapshot> files = [];

  @override
  void initState() {
    super.initState();
    _initializeUserId();
  }

  Future<void> _initializeUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
        loadFileUrl();
      });
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> loadFileUrl() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection("Users")
          .doc(userId)
          .collection('Documents')
          .get();
      setState(() {
        files = snapshot.docs;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error loading document"),
        ),
      );
    }
  }

  Future<void> getFile() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'doc']);
    if (result != null) {
      File selectedFile = File(result.files.single.path!);
      setState(() {
        file = selectedFile;
        fileName = result.files.single.name;
        isPDF = result.files.single.extension == 'pdf';
        url = null;
      });
      uploadFile();
    }
  }

  Future<void> uploadFile() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null && file != null && fileName != null) {
        var myFile =
            FirebaseStorage.instance.ref('Users/${user.uid}/$fileName');
        UploadTask task = myFile.putFile(file!);
        TaskSnapshot snapshot = await task;
        String downloadUrl = await snapshot.ref.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .collection('Documents')
            .doc(fileName!)
            .set({
          "url": downloadUrl,
          "fileName": fileName,
          "isPDF": isPDF,
        });

        setState(() {
          url = downloadUrl;
          loadFileUrl(); // Reload files to update the list
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Upload successful!'),
          ),
        );
      } else {
        throw Exception("User not authenticated or file is null");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
        ),
      );
    }
  }

  Future<File> downloadFile(String url) async {
    final response = await http.get(Uri.parse(url));
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/${DateTime.now().millisecondsSinceEpoch}.pdf');
    return file.writeAsBytes(response.bodyBytes);
  }

  Widget viewFile(DocumentSnapshot fileDoc) {
    String fileUrl = fileDoc['url'];
    bool fileIsPDF = fileDoc['isPDF'];

    if (fileIsPDF) {
      return FutureBuilder<File>(
        future: downloadFile(fileUrl),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              return Expanded(
                child: PDFView(
                  filePath: snapshot.data!.path,
                  enableSwipe: true,
                  swipeHorizontal: true,
                  autoSpacing: false,
                  pageFling: true,
                  onError: (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error loading PDF: $error'),
                      ),
                    );
                  },
                  onRender: (pages) {
                    print('Rendered $pages pages');
                  },
                  onPageError: (page, error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error on page $page: $error'),
                      ),
                    );
                  },
                ),
              );
            } else {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      );
    } else {
      return InkWell(
        onTap: () async {
          if (await canLaunch(fileUrl)) {
            await launch(fileUrl);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Could not open file.'),
              ),
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child:
              const Text('View Document', style: TextStyle(color: Colors.blue)),
        ),
      );
    }
  }

  Widget buildFileList() {
    return files.isEmpty
        ? const Center(child: Text('No files uploaded.'))
        : ListView.builder(
            itemCount: files.length,
            itemBuilder: (context, index) {
              DocumentSnapshot fileDoc = files[index];
              return ListTile(
                title: Text(fileDoc['fileName']),
                subtitle: Text(fileDoc['isPDF'] ? 'PDF Document' : 'Document'),
                onTap: () {
                  setState(() {
                    url = fileDoc['url'];
                    isPDF = fileDoc['isPDF'];
                  });
                },
              );
            },
          );
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
        child: Column(
          children: [
            Expanded(child: buildFileList()),
            if (url != null) viewFile(files.firstWhere((file) => file['url'] == url)),
          ],
        ),
      ),
    );
  }
}

