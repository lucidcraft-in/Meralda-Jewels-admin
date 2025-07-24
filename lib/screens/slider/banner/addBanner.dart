import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firbase_storage;

class AddBannerDialog extends StatefulWidget {
  @override
  _AddBannerDialogState createState() => _AddBannerDialogState();
}

class _AddBannerDialogState extends State<AddBannerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _photoNameController = TextEditingController();
  File? _imageFile;
  bool _isLoading = false;
  String fileName = "";
  var path;
  String fileType = "";
  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg'],
    );

    if (result == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('No file selected')));
      return null;
    }
    String fileExtension = result.files.single.extension ?? '';
    setState(() {
      path = result.files.single.path;
      fileName = result.files.single.name;
      fileType = fileExtension;
    });
  }

  Future _uploadImage() async {
    File file = File(path);
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Banner'),
      // content: SingleChildScrollView(
      //   child: Form(
      //     key: _formKey,
      //     child: Column(
      //       mainAxisSize: MainAxisSize.min,
      //       children: [
      //         GestureDetector(
      //           onTap: _isLoading ? null : _pickImage,
      //           child: Container(
      //             height: 200,
      //             width: double.infinity,
      //             decoration: BoxDecoration(
      //               border: Border.all(color: Colors.grey),
      //               borderRadius: BorderRadius.circular(8),
      //             ),
      //             child: _imageFile != null
      //                 ? Image.file(_imageFile!, fit: BoxFit.cover)
      //                 : Column(
      //                     mainAxisAlignment: MainAxisAlignment.center,
      //                     children: const [
      //                       Icon(Icons.add_photo_alternate, size: 50),
      //                       SizedBox(height: 8),
      //                       Text('Tap to select image'),
      //                     ],
      //                   ),
      //           ),
      //         ),
      //         const SizedBox(height: 16),
      //         TextFormField(
      //           controller: _photoNameController,
      //           decoration: const InputDecoration(
      //             labelText: 'Photo Name',
      //             hintText: 'Enter photo name',
      //           ),
      //           validator: (value) {
      //             if (value == null || value.isEmpty) {
      //               return 'Please enter a photo name';
      //             }
      //             return null;
      //           },
      //         ),
      //       ],
      //     ),
      //   ),
      // ),
      content: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            color: Color.fromARGB(255, 240, 236, 236),
            border: Border.all()),
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              path != null ? "Image Added" : "Add Image",
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: path != null ? Colors.green : Colors.black),
            ),
            SizedBox(
              height: 10,
            ),
            Icon(Icons.add_a_photo_outlined),
            SizedBox(
              height: 10,
            ),
            GestureDetector(
              onTap: () {
                _pickImage();
              },
              child: Container(
                height: 40,
                width: 100,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    color: Color.fromARGB(255, 240, 236, 236),
                    border: Border.all()),
                child: Center(
                    child: Text(
                  "Select Image",
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.blue,
                      fontSize: 13),
                )),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            path != null ? Text(fileName) : Text(""),
          ],
        )),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _isLoading
              ? null
              : () async {
                  if (fileName.isNotEmpty) {
                    setState(() => _isLoading = true);

                    String? photoUrl = await _uploadImage();

                    setState(() => _isLoading = false);

                    if (photoUrl != null) {
                      // Navigator.of(context).pop({
                      //   'photoName': _photoNameController.text,
                      //   'photo': photoUrl,
                      // });
                      CollectionReference collectionReferenceBanner =
                          FirebaseFirestore.instance.collection("Banner");
                      await collectionReferenceBanner.add({
                        "photo": photoUrl,
                        "photoName": fileName,
                        "imageType": "Banner",
                      });
                      Navigator.pop(context);
                    } else {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to upload image')),
                      );
                    }
                  } else if (_imageFile == null) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select an image')),
                    );
                  }
                },
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Add'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _photoNameController.dispose();
    super.dispose();
  }
}
