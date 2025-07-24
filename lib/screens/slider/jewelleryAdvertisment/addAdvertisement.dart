import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../constant/colors.dart';

class Addadvertisement extends StatefulWidget {
  const Addadvertisement({super.key});

  @override
  State<Addadvertisement> createState() => _AddadvertisementState();
}

class _AddadvertisementState extends State<Addadvertisement> {
  final TextEditingController _linkController = TextEditingController();
  bool _isSaving = false;

  // Function to save YouTube link to Firebase
  void _saveYouTubeLink() async {
    String link = _linkController.text.trim();
    if (link.isNotEmpty) {
      setState(() {
        _isSaving = true;
      });

      await FirebaseFirestore.instance.collection('advertisements').add({
        'youtubeLink': link,
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        _isSaving = false;
        _linkController.clear();
      });

      Navigator.pop(context); // Close the bottom sheet
    }
  }

  // Function to show bottom sheet for adding new link
  void _showAddAdSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Enter YouTube Advertisement Link",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _linkController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Paste YouTube link here",
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveYouTubeLink,
                child: _isSaving
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("Save Advertisement"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: useColor.homeIconColor,
          title: Text("YouTube Advertisements")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('advertisements')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No advertisements added yet."));
          }

          var ads = snapshot.data!.docs;

          return ListView.builder(
            itemCount: ads.length,
            itemBuilder: (context, index) {
              var ad = ads[index];
              String youtubeLink = ad['youtubeLink'];

              return ListTile(
                leading: Icon(Icons.video_library, color: Colors.red),
                title: Text(
                  youtubeLink,
                  style: TextStyle(fontSize: 14, color: Colors.blue),
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    FirebaseFirestore.instance
                        .collection('advertisements')
                        .doc(ad.id)
                        .delete();
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAdSheet,
        child: Icon(Icons.add),
      ),
    );
  }
}
