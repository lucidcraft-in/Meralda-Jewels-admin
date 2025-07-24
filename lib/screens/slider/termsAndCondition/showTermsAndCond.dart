import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:firebase_storage/firebase_storage.dart' as firbase_storage;
import '../../../constant/colors.dart';

class TermsAndCondition extends StatefulWidget {
  @override
  _TermsAndConditionState createState() => _TermsAndConditionState();
}

class _TermsAndConditionState extends State<TermsAndCondition> {
  List userlist = [];
  bool isLoading = true;
  bool isUploading = false;
  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    setState(() {
      userlist = [];
    });
    CollectionReference collectionReference =
        FirebaseFirestore.instance.collection('terms&condition');
    QuerySnapshot querySnapshot;

    try {
      querySnapshot = await collectionReference.get();

      for (var doc in querySnapshot.docs.toList()) {
        Map a = {
          "id": doc.id,
          "url": doc['name'],
          "fileType": doc["fileType"],
        };
        userlist.add(a);
      }
    } catch (e) {
      print('Error: $e');
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: useColor.homeIconColor,
        title: const Text('Terms And Conditions'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : userlist.isEmpty
              ? Center(child: Text('No data found'))
              : !isUploading
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: userlist.length,
                        itemBuilder: (context, index) {
                          String fileUrl = userlist[index]['url'];

                          return Column(
                            children: [
                              SizedBox(
                                width: 200,
                                height: 300,
                                child: GestureDetector(
                                  onTap: () {
                                    if (userlist[index]['fileType'] != "pdf") {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ImageFullScreen(
                                            imageUrl: fileUrl,
                                          ),
                                        ),
                                      );
                                    } else if (userlist[index]['fileType'] ==
                                        "pdf") {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => PdfViewerScreen(
                                            pdfUrl: fileUrl,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  child: userlist[index]['fileType'] != "pdf"
                                      ? Image.network(
                                          fileUrl,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (context, child,
                                              loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child;
                                            }
                                            return Center(
                                              child: CircularProgressIndicator(
                                                value: loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        (loadingProgress
                                                            .expectedTotalBytes!)
                                                    : null,
                                              ),
                                            );
                                          },
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Center(
                                              child: Text(
                                                'Failed to load image',
                                                style: TextStyle(
                                                    color: Colors.red),
                                              ),
                                            );
                                          },
                                        )
                                      : Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.picture_as_pdf,
                                                  size: 50, color: Colors.red),
                                              SizedBox(height: 10),
                                              Text(
                                                'Open PDF',
                                                style: TextStyle(fontSize: 16),
                                              ),
                                            ],
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    )
                  : Container(
                      color: Colors.black.withOpacity(0.5),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: useColor.homeIconColor,
        onPressed: isUploading ? null : pickAndUploadFile,
        child: isUploading
            ? CircularProgressIndicator(color: Colors.white)
            : Icon(
                Icons.add,
                color: Colors.white,
              ),
      ),
    );
  }

  Future<void> pickAndUploadFile() async {
    try {
      setState(() {
        isUploading = true;
      });

      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['png', 'jpg', 'pdf'],
      );

      if (result == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('No file selected')));
        return null;
      }

      if (result != null) {
        String filePath = result.files.single.path!;
        String fileName = result.files.single.name;
        String fileType = result.files.single.extension ?? '';

        // Upload file to Firebase Storage
        String? downloadUrl = await uploadFile(filePath, fileName);

        if (downloadUrl != null) {
          // Check if document exists
          QuerySnapshot existing = await FirebaseFirestore.instance
              .collection('terms&condition')
              .get();

          if (existing.docs.isNotEmpty) {
            // Update existing document
            await FirebaseFirestore.instance
                .collection('terms&condition')
                .doc(existing.docs.first.id)
                .update({
              'name': downloadUrl,
              'fileType': fileType,
            });
          } else {
            // Add new document
            await FirebaseFirestore.instance.collection('terms&condition').add({
              'name': downloadUrl,
              'fileType': fileType,
            });
          }

          // Refresh the list
          await getData();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('File uploaded successfully')),
          );
        }
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading file')),
      );
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }

  Future<String?> uploadFile(String filePath, String fileName) async {
    File file = File(filePath);
    final firbase_storage.FirebaseStorage storage =
        firbase_storage.FirebaseStorage.instance;
    if (fileName == "") return null;

    try {
      firbase_storage.TaskSnapshot taskSnapshot =
          await storage.ref('images/$fileName').putFile(file);
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }
}

class PdfViewerScreen extends StatelessWidget {
  final String pdfUrl;

  const PdfViewerScreen({Key? key, required this.pdfUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("PDF Viewer"),
        backgroundColor: Colors.black,
      ),
      body: const PDF().cachedFromUrl(
        pdfUrl,
        placeholder: (progress) =>
            Center(child: CircularProgressIndicator(value: progress / 100)),
        errorWidget: (error) => Center(
            child: Text("Failed to load PDF",
                style: TextStyle(color: Colors.red))),
      ),
    );
  }
}

class ImageFullScreen extends StatelessWidget {
  final String imageUrl;

  const ImageFullScreen({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: useColor.homeIconColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Image.network(
          imageUrl,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        (loadingProgress.expectedTotalBytes!)
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Text(
                'Failed to load image',
                style: TextStyle(color: Colors.red),
              ),
            );
          },
        ),
      ),
    );
  }
}
