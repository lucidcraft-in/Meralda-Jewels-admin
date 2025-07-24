import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firbase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;

class CompanyService with ChangeNotifier {
  final firbase_storage.FirebaseStorage storage =
      firbase_storage.FirebaseStorage.instance;

  CollectionReference collectionReference =
      FirebaseFirestore.instance.collection('QRdetails');

  late FirebaseFirestore firestore;
  initiliase() {
    firestore = FirebaseFirestore.instance;
  }

  Future<int> createQrcode(String id, File compressImage, String fileName,
      String upiId, String oldName, String acNo, String ifsc) async {
    try {
      String downloadUrl = "";

      // Only upload new image if provided
      if (compressImage.path.isNotEmpty) {
        // If updating and there's an old image, delete it
        if (id.isNotEmpty && oldName.isNotEmpty) {
          try {
            firbase_storage.Reference storageRef =
                storage.ref().child('QRCODE/$oldName');

            // Delete the old file
            await storageRef.delete();
          } catch (e) {
            print("Error deleting old image: $e");
            // Continue even if delete fails
          }
        }

        // Upload the new image
        firbase_storage.TaskSnapshot taskSnapshot =
            await storage.ref('QRCODE/$fileName').putFile(compressImage);
        downloadUrl = await taskSnapshot.ref.getDownloadURL();
      }

      // Build data map with only the fields that have values
      Map<String, dynamic> data = {
        "timestamp": FieldValue.serverTimestamp(),
      };

      if (upiId.isNotEmpty) {
        data["upiId"] = upiId;
      }

      if (acNo.isNotEmpty) {
        data["ac_no"] = acNo;
      }

      if (ifsc.isNotEmpty) {
        data["ifsc"] = ifsc;
      }

      if (downloadUrl.isNotEmpty) {
        data["qrcode"] = downloadUrl;
        data["qrname"] = fileName;
      }

      // Check if we're updating or creating
      if (id.isNotEmpty) {
        // Update existing document
        await collectionReference.doc(id).update(data);
      } else {
        // Create new document
        await collectionReference.add(data);
      }

      return 200;
    } on firebase_core.FirebaseException catch (e) {
      print("Firebase error: $e");
      return 500;
    } catch (e) {
      print("General error: $e");
      return 400;
    }
  }

  readQr() async {
    try {
      List qrData = [];
      QuerySnapshot querySnapshot = await collectionReference.get();
      for (var doc in querySnapshot.docs.toList()) {
        Map a = {
          "id": doc.id,
          "upiId": doc["upiId"],
          "qrcode": doc["qrcode"],
          "qrname": doc["qrname"],
          "acNo": doc["ac_no"],
          "ifsc": doc["ifsc"],
          "timestamp": FieldValue.serverTimestamp(),
        };
        qrData.add(a);
      }
      // print(qrData);
      return qrData;
    } catch (e) {}
  }
}
