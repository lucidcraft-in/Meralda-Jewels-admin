import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';

import '../../../constant/colors.dart';
import 'addDetails.dart';

// Import AddDetails screen

class Showaboutus extends StatefulWidget {
  const Showaboutus({super.key});

  @override
  State<Showaboutus> createState() => _ShowaboutusState();
}

class _ShowaboutusState extends State<Showaboutus> {
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
      isLoading = true;
      userlist = [];
    });

    // CollectionReference collectionReference =
    //     FirebaseFirestore.instance.collection('aboutUs');
    // QuerySnapshot querySnapshot;

    // try {
    //   querySnapshot = await collectionReference.get();
    //   for (var doc in querySnapshot.docs.toList()) {
    //     Map a = {
    //       "id": doc.id,
    //       "jewelleryName": doc['jewelleryName'],
    //       "address": doc['address'],
    //       "place": doc['place'],
    //       "phone": doc['phone'],
    //       "email": doc['email'],
    //       "whatsapp": doc['whatsapp'],
    //     };
    //     userlist.add(a);
    //   }
    // } catch (e) {
    //   print('Error: $e');
    // }

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
        title: const Text('About Us'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userlist.isEmpty
              ? const Center(child: Text('No data found'))
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.builder(
                    itemCount: userlist.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(userlist[index]['jewelleryName']),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Address: ${userlist[index]['address']}'),
                              Text('Place: ${userlist[index]['place']}'),
                              Text('Phone: ${userlist[index]['phone']}'),
                              Text('Email: ${userlist[index]['email']}'),
                              Text('WhatsApp: ${userlist[index]['whatsapp']}'),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          bool? isUpdated = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Adddetails()),
          );

          if (isUpdated == true) {
            getData(); // Refresh list if new data is added
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
