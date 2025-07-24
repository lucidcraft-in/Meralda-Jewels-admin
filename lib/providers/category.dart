import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firbase_storage;

class SliderModel {
  final String name;

  SliderModel({required this.name});
}

class Category with ChangeNotifier {
  final firbase_storage.FirebaseStorage storage =
      firbase_storage.FirebaseStorage.instance;
  late FirebaseFirestore firestore;
  initiliase() {
    firestore = FirebaseFirestore.instance;
  }

  CollectionReference collectionReference =
      FirebaseFirestore.instance.collection("Category");

  Future addCategory(String category, String fileName, File file) async {
    try {
      firbase_storage.TaskSnapshot taskSnapshot =
          await storage.ref('categoryImage/$fileName').putFile(file);
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      collectionReference.add({"name": category, "image": downloadUrl});
      notifyListeners();
    } catch (e) {}
  }

  Future getCategory() async {
    var categories = [];
    try {
      QuerySnapshot querySnapshot = await collectionReference.get();

      for (var doc in querySnapshot.docs.toList()) {
        Map a = {
          "id": doc.id,
          "name": doc["name"],
        };
        categories.add(a);
      }
      return categories;
    } catch (e) {}
  }

  Future<void> delete(String id) async {
    await collectionReference.doc(id).delete();

    // Rebuild the UI
  }
}
