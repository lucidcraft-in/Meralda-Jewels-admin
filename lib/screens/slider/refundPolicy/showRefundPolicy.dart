import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';

import '../../../constant/colors.dart';
import '../termsAndCondition/showTermsAndCond.dart';

class Showrefundpolicy extends StatefulWidget {
  const Showrefundpolicy({super.key});

  @override
  State<Showrefundpolicy> createState() => _ShowrefundpolicyState();
}

class _ShowrefundpolicyState extends State<Showrefundpolicy> {
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
        FirebaseFirestore.instance.collection('offers');
    QuerySnapshot querySnapshot;

    try {
      querySnapshot = await collectionReference.get();

      for (var doc in querySnapshot.docs.toList()) {
        Map a = {
          "id": doc.id,
          "url": doc['name'],
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
        title: const Text('Offers'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : userlist.isEmpty
              ? Center(child: Text('No data found'))
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: userlist.length,
                    itemBuilder: (context, index) {
                      String fileUrl = userlist[index]['url'];

                      return Card(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ImageFullScreen(
                                  imageUrl: userlist[index]['url'],
                                ),
                              ),
                            );
                          },
                          onLongPress: () =>
                              confirmDelete(context, userlist[index]['id']),
                          child: Image.network(
                            fileUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              }
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
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
                    },
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
        type: FileType.image,
      );

      if (result == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('No file selected')));
        return;
      }

      String filePath = result.files.single.path!;
      String fileName = result.files.single.name;

      String? downloadUrl = await uploadFile(filePath, fileName);

      if (downloadUrl != null) {
        await FirebaseFirestore.instance.collection('offers').add({
          'name': downloadUrl,
        });

        await getData();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File uploaded successfully')),
        );
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
    final firebase_storage.FirebaseStorage storage =
        firebase_storage.FirebaseStorage.instance;

    try {
      firebase_storage.TaskSnapshot taskSnapshot =
          await storage.ref('images/$fileName').putFile(file);
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  void confirmDelete(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Confirmation'),
        content: Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('offers')
                  .doc(docId)
                  .delete();
              await getData();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Item deleted successfully')),
              );
            },
            child: Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
