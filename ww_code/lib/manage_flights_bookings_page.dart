import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class ManageFlightsBookingsPage extends StatefulWidget {
  const ManageFlightsBookingsPage({super.key});

  @override
  ManageFlightsBookingsPageState createState() =>
      ManageFlightsBookingsPageState();
}

class ManageFlightsBookingsPageState extends State<ManageFlightsBookingsPage> {
  File? file;                             // file to be uploaded
  String? url;                            // url of file to be uploaded
  String? fileName;                       // name of file to be uploaded
  bool isPDF = false;                     
  bool isLoading = true;
  late String userId;                     // ID of authenticated user
  List<DocumentSnapshot> files = [];      // document(s) of authenticated user

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
      setState(() {
        isLoading = true;
      });
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection("Users")
          .doc(userId)
          .collection('Documents')
          .get();
      setState(() {
        files = snapshot.docs;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
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
        });

        loadFileUrl();


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
    final file =
        File('${dir.path}/${DateTime.now().millisecondsSinceEpoch}.pdf');
    return file.writeAsBytes(response.bodyBytes);
  }

  void viewFile(DocumentSnapshot fileDoc) {
    String fileUrl = fileDoc['url'];
    bool fileIsPDF = fileDoc['isPDF'];

    if (fileIsPDF) {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          insetPadding: const EdgeInsets.all(10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: FutureBuilder<File>(
              future: downloadFile(fileUrl),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData) {
                    return Scaffold(
                      appBar: AppBar(
                        title: const Text(
                          'View PDF',
                          style: TextStyle(color: Color(0xFF00A6DF)),
                        ),
                        backgroundColor: Colors.white,
                        iconTheme:
                            const IconThemeData(color: Color(0xFF00A6DF)),
                        leading: IconButton(
                          icon:
                              const Icon(Icons.close, color: Color(0xFF00A6DF)),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      body: PDFView(
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
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.blue,
                    ),
                  );
                }
              },
            ),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Document type not supported for viewing'),
        ),
      );
    }
  }

  Future<void> deleteFile(DocumentSnapshot fileDoc) async {
    String fileUrl = fileDoc['url'];
    String fileName = fileDoc['fileName'];
    try {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('Documents')
          .doc(fileName)
          .delete();
      await FirebaseStorage.instance.refFromURL(fileUrl).delete();
      loadFileUrl(); 
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Delete successful!'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
        ),
      );
    }
  }

  Future<void> confirmDelete(DocumentSnapshot fileDoc) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this document?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF00A6DF))),
          ),
          TextButton(
            onPressed: () {
              deleteFile(fileDoc);
              Navigator.of(context).pop();
            },
            child: const Text('Delete',
                style: TextStyle(color: Color(0xFF00A6DF))),
          ),
        ],
      ),
    );
  }

  Widget buildFileList() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.lightBlue,
        ),
      );
    }
    return files.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'images/upload.png',
                  width: 250,
                  height: 250,
                ),
                const SizedBox(height: 10),
                const Text('Upload flights/bookings documents here!',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black45,
                    )),
              ],
            ),
          )
        : ListView.builder(
            itemCount: files.length,
            itemBuilder: (context, index) {
              DocumentSnapshot fileDoc = files[index];
              return ListTile(
                title: Text(fileDoc['fileName']),
                subtitle: Text(fileDoc['isPDF'] ? 'PDF Document' : 'Document'),
                onTap: () => viewFile(fileDoc),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.black45),
                  onPressed: () => confirmDelete(fileDoc),
                ),
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
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          children: [
            Expanded(child: buildFileList()),
          ],
        ),
      ),
    );
  }
}
