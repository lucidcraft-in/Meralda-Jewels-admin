import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';

import '../../../constant/colors.dart';
import '../termsAndCondition/showTermsAndCond.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  List<Map<String, dynamic>> eventList = [];
  bool isLoading = true;
  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    setState(() => isLoading = true);
    CollectionReference collectionReference =
        FirebaseFirestore.instance.collection('events');

    try {
      QuerySnapshot querySnapshot = await collectionReference.get();
      eventList = querySnapshot.docs.map((doc) {
        return {
          "id": doc.id,
          "url": doc['name'],
          "eventName": doc['eventName'],
        };
      }).toList();
    } catch (e) {
      print('Error: $e');
    }

    setState(() => isLoading = false);
  }

  Future<void> pickAndUploadFile() async {
    setState(() {
      isUploading = true;
    });
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.image,
      );

      if (result == null) return;

      String? eventName = await _showEventNameDialog();
      if (eventName == null || eventName.isEmpty) return;

      String filePath = result.files.single.path!;
      String fileName = result.files.single.name;

      String? downloadUrl = await uploadFile(filePath, fileName);

      if (downloadUrl != null) {
        await FirebaseFirestore.instance.collection('events').add({
          'name': downloadUrl,
          'eventName': eventName,
        });
        await getData();
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }

  Future<String?> uploadFile(String filePath, String fileName) async {
    File file = File(filePath);
    final storage = firebase_storage.FirebaseStorage.instance;

    try {
      firebase_storage.TaskSnapshot taskSnapshot =
          await storage.ref('images/$fileName').putFile(file);
      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> deleteEvent(String docId) async {
    await FirebaseFirestore.instance.collection('events').doc(docId).delete();
    await getData();
  }

  Future<String?> _showEventNameDialog() async {
    String? eventName;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Event Name'),
        content: TextField(
          onChanged: (value) => eventName = value,
          decoration: const InputDecoration(hintText: 'e.g., Holy, Diwali'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, eventName),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    return eventName;
  }

  void _showDeleteDialog(String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await deleteEvent(docId);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: useColor.homeIconColor, title: const Text('Events')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : eventList.isEmpty
              ? const Center(child: Text('No events found'))
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                  ),
                  itemCount: eventList.length,
                  itemBuilder: (context, index) => GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ImageFullScreen(
                            imageUrl: eventList[index]['url'],
                          ),
                        ),
                      );
                    },
                    onLongPress: () =>
                        _showDeleteDialog(eventList[index]['id']),
                    child: Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Image.network(
                              eventList[index]['url'],
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              eventList[index]['eventName'] ?? 'Unknown',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: isUploading ? null : pickAndUploadFile,
        child: isUploading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Icon(Icons.add),
      ),
    );
  }
}
