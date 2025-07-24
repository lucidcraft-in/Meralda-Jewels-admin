import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firbase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String productName;
  final String productCode;
  final String description;
  final String photoName;
  final String photo;
  final String category;
  final String gram;
  final int branch;

  ProductModel({
    required this.id,
    required this.productName,
    required this.productCode,
    required this.description,
    required this.photoName,
    required this.photo,
    required this.category,
    required this.gram,
    required this.branch,
  });
}

class Product with ChangeNotifier {
  final firbase_storage.FirebaseStorage storage =
      firbase_storage.FirebaseStorage.instance;

  CollectionReference collectionReference =
      FirebaseFirestore.instance.collection('product');

  late FirebaseFirestore firestore;
  initiliase() {
    firestore = FirebaseFirestore.instance;
  }

  Future<void> uploadFile(File compressImage, String fileName,
      ProductModel productModel, String category) async {
    try {
      final Directory systemTempDir = Directory.systemTemp;

      firbase_storage.TaskSnapshot taskSnapshot =
          await storage.ref('products/$fileName').putFile(compressImage);
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      await collectionReference.add({
        "photo": downloadUrl,
        "photoName": fileName,
        "productName": productModel.productName,
        "category": category,
        "productCode": productModel.productCode,
        "description": productModel.description,
        "gram": productModel.gram,
        "branch": productModel.branch,
      });

      await storage.ref('products/$fileName').putFile(compressImage);
    } on firebase_core.FirebaseException catch (e) {
      print(e);
    }
  }

  Future<void> updateProductWithImage(File compressImage, String fileName,
      ProductModel productModel, String id, String ref) async {
    try {
      final Directory systemTempDir = Directory.systemTemp;

      firbase_storage.TaskSnapshot taskSnapshot =
          await storage.ref('products/$fileName').putFile(compressImage);
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      await collectionReference.doc(id).update({
        "photo": downloadUrl,
        "photoName": fileName,
        "productName": productModel.productName,
        "productCode": productModel.productCode,
        "description": productModel.description,
        "gram": productModel.gram,
      });

      await storage.ref('products/$fileName').putFile(compressImage);
      await storage.ref('products/${ref}').delete();
    } on firebase_core.FirebaseException catch (e) {
      print(e);
    }
  }

  Future<void> updateProduct(
      ProductModel productModel, String id, String ref) async {
    try {
      await collectionReference.doc(id).update({
        "productName": productModel.productName,
        "productCode": productModel.productCode,
        "description": productModel.description,
        "gram": productModel.gram,
      });
    } on firebase_core.FirebaseException catch (e) {
      print(e);
    }
  }

  Future<List?> read(String category, int brnachId) async {
    QuerySnapshot querySnapshot;
    List userlist = [];
    try {
      if (brnachId == 0) {
        querySnapshot = await collectionReference
            .where("category", isEqualTo: category)
            .get();
      } else {
        querySnapshot = await collectionReference
            .where("branch", isEqualTo: 0)
            .where("category", isEqualTo: category)
            .get();
      }

      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs.toList()) {
          Map a = {
            "id": doc.id,
            "photoName": doc['photoName'],
            "photo": doc["photo"],
            "productName": doc["productName"],
            "productCode": doc["productCode"],
            "description": doc["description"],
            "gram": doc["gram"],
            "category": doc["category"],
            "branch": doc["branch"],
          };
          userlist.add(a);
        }

        return userlist;
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> delete(String id, String ref) async {
    await collectionReference.doc(id).delete();
    await storage.ref(ref).delete();

    // Rebuild the UI
  }
}
