import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firbase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

CollectionReference collectionReferenceTerms =
    FirebaseFirestore.instance.collection("terms&condition");

class Storage with ChangeNotifier {
  final firbase_storage.FirebaseStorage storage =
      firbase_storage.FirebaseStorage.instance;

  CollectionReference collectionReference =
      FirebaseFirestore.instance.collection('slide');
  CollectionReference collectionReferenceBanner =
      FirebaseFirestore.instance.collection("Banner");

  late FirebaseFirestore firestore;
  initiliase() {
    firestore = FirebaseFirestore.instance;
  }

  Future<List?> read() async {
    QuerySnapshot querySnapshot;
    List userlist = [];
    try {
      querySnapshot = await collectionReference.get();

      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs.toList()) {
          Map a = {
            "id": doc.id,
            "name": doc['name'],
            "photo": doc["photo"],
          };
          userlist.add(a);
        }

        return userlist;
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> uploadFile(String filePath, String fileName, String imageType,
      String fileType) async {
    File file = File(filePath);

    // try {
    //   firbase_storage.TaskSnapshot taskSnapshot =
    //       await storage.ref('images/$fileName').putFile(file);
    //   final String downloadUrl = await taskSnapshot.ref.getDownloadURL();

    //   if (imageType == "Banner") {
    //     QuerySnapshot querySnapshotBanner =
    //         await collectionReferenceTerms.limit(1).get();
    //     if (querySnapshotBanner.docs.length > 0) {
    //       String documentId = querySnapshotBanner.docs[0].id;
    //       collectionReference.doc(documentId).update({
    //         "photo": downloadUrl,
    //         "photoName": fileName,
    //         "imageType": imageType,
    //       });
    //     } else {
    //       await collectionReferenceBanner.add({
    //         "photo": downloadUrl,
    //         "photoName": fileName,
    //         "imageType": imageType,
    //       });
    //     }

    //     if (imageType == "Banner") {
    //       await collectionReference
    //           .add({"photo": downloadUrl, "name": fileName});
    //     }
    //   } else {
    //     print("--");
    //     QuerySnapshot querySnapshot =
    //         await collectionReferenceTerms.limit(1).get();
    //     String documentId = querySnapshot.docs[0].id;
    //     QuerySnapshot querySnapshotslider =
    //         await collectionReference.limit(1).get();
    //     String documentIdSlider = querySnapshot.docs[0].id;
    //     if (querySnapshot.docs.length > 0) {
    //       await collectionReferenceTerms
    //           .doc(documentId)
    //           .update({"fileType": fileType, "name": downloadUrl});
    //       await collectionReference
    //           .doc(documentIdSlider)
    //           .update({"photo": downloadUrl, "name": fileName});
    //     } else {
    //       collectionReferenceTerms
    //           .add({"fileType": fileType, "name": downloadUrl});
    //       await collectionReference
    //           .add({"photo": downloadUrl, "name": fileName});
    //     }
    //   }
    // } on firebase_core.FirebaseException catch (e) {
    //   print(e);
    // }

    try {
      // Upload file to Firebase Storage
      firbase_storage.TaskSnapshot taskSnapshot =
          await storage.ref('images/$fileName').putFile(file);
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      // Firestore references

      QuerySnapshot querySnapshotBanner =
          await collectionReferenceBanner.limit(1).get();
      QuerySnapshot querySnapshotTerms =
          await collectionReferenceTerms.limit(1).get();
      QuerySnapshot querySnapshotSlider = await collectionReference
          .where("imageType", isEqualTo: imageType)
          .limit(1)
          .get();

      if (imageType == "Banner") {
        if (querySnapshotBanner.docs.isNotEmpty) {
          String documentId = querySnapshotBanner.docs.first.id;
          await collectionReferenceBanner.doc(documentId).update({
            "photo": downloadUrl,
            "photoName": fileName,
            "imageType": imageType,
          });
        } else {
          await collectionReferenceBanner.add({
            "photo": downloadUrl,
            "photoName": fileName,
            "imageType": imageType,
          });
        }
      } else {
        if (querySnapshotTerms.docs.isNotEmpty) {
          String documentIdTerms = querySnapshotTerms.docs.first.id;
          await collectionReferenceTerms.doc(documentIdTerms).update({
            "fileType": fileType,
            "name": downloadUrl,
          });
        } else {
          await collectionReferenceTerms.add({
            "fileType": fileType,
            "name": downloadUrl,
          });
        }
      }

      // Common slider update
      // Slider update: Check if imageType already exists, update or add new entry
      if (querySnapshotSlider.docs.isNotEmpty) {
        String documentIdSlider = querySnapshotSlider.docs.first.id;
        await collectionReference.doc(documentIdSlider).update({
          "photo": downloadUrl,
          "photoName": fileName,
        });
      } else {
        await collectionReference.add({
          "photo": downloadUrl,
          "photoName": fileName,
          "imageType": imageType,
        });
      }
    } on FirebaseException catch (e) {
      // print("Firebase Exception: ${e.message}");
    } catch (e) {
      print("General Error: $e");
    }
  }

  Future<firbase_storage.ListResult> listFiles() async {
    firbase_storage.ListResult result = await storage.ref('images').listAll();
    result.items.forEach((firbase_storage.Reference ref) {});

    return result;
  }

  Future<String> downloadUrl(String ImageName) async {
    String downloadUrl =
        await storage.ref('images/$ImageName').getDownloadURL();
    return downloadUrl;
  }

  Future<List<Map<String, dynamic>>> loadImages() async {
    List<Map<String, dynamic>> files = [];

    final firbase_storage.ListResult result =
        await storage.ref('images').list();
    final List<firbase_storage.Reference> allFiles = result.items;

    await Future.forEach<firbase_storage.Reference>(allFiles, (file) async {
      final String fileUrl = await file.getDownloadURL();
      final firbase_storage.FullMetadata fileMeta = await file.getMetadata();
      files.add({
        "url": fileUrl,
        "path": file.fullPath,
      });
    });

    return files;
  }

  Future getSlide(String type) async {
    List sliderList = [];
    QuerySnapshot querySnapshot = await collectionReferenceBanner
        .where("imageType", isEqualTo: type)
        .get();

    for (var doc in querySnapshot.docs.toList()) {
      Map a = {
        "id": doc.id,
        "photo": doc['photo'],
        "photoName": doc["photoName"],
        "imageType": doc["imageType"]
      };
      sliderList.add(a);
    }

    return sliderList;
  }

  Future<void> delete(String id, String ref, String type) async {
    await collectionReferenceBanner.doc(id).delete();

    // if (type == "Banner") {
    //   QuerySnapshot querySnapshot =
    //       await collectionReference.where("name", isEqualTo: ref).get();
    //   for (var doc in querySnapshot.docs.toList()) {
    //     await collectionReference.doc(doc.id).delete();
    //   }
    // }
    await storage.ref(ref).delete();
    // Rebuild the UI
  }
}
