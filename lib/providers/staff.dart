import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class StaffModel {
  final String id;
  final String staffName;
  final String location;
  final String address;
  final String phoneNo;
  final String password;
  final String token;
  final double commission;
  final int type;
  final int branch;
  StaffModel({
    required this.id,
    required this.staffName,
    required this.location,
    required this.address,
    required this.phoneNo,
    required this.password,
    required this.type,
    required this.token,
    required this.commission,
    required this.branch,
  });
}

class Staff with ChangeNotifier {
  late FirebaseFirestore firestore;
  initiliase() {
    firestore = FirebaseFirestore.instance;
  }

  CollectionReference collectionReference =
      FirebaseFirestore.instance.collection('staffs');

  late List<StaffModel> _staffModel;

  // note
  // ======================
  //  type : 0 is staff,
  //  type : 1 is admin,
  // ============================
  // branch: 1 = Alathur
  // branch : 2= chittur
  // branch : 3= vadakkanchari

  Future<void> create(StaffModel staffModel, String staffId) async {
    try {
      await collectionReference.add({
        'staffName': staffModel.staffName,
        'location': staffModel.location,
        'address': staffModel.address,
        'phoneNo': staffModel.phoneNo,
        'password': staffModel.password,
        'type': 0,
        'timestamp': FieldValue.serverTimestamp(),
        'token': "",
        'commission': staffModel.commission,
        "branch": 1,
        "staff_code": staffId
        // 'branch': staffModel.branch
      });
      notifyListeners();
      final newStaffModel = StaffModel(
          id: staffModel.id,
          staffName: staffModel.staffName,
          location: staffModel.location,
          address: staffModel.address,
          phoneNo: staffModel.phoneNo,
          password: staffModel.password,
          type: 0,
          commission: staffModel.commission,
          token: '',
          branch: staffModel.branch);

      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<void> update(String id, StaffModel staffModel) async {
    try {
      await collectionReference.doc(id).update({
        'staffName': staffModel.staffName,
        'location': staffModel.location,
        'address': staffModel.address,
        'phoneNo': staffModel.phoneNo,
        'password': staffModel.password,
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> updatePassword(String id, StaffModel staffModel) async {
    try {
      await collectionReference.doc(id).update({
        'password': staffModel.password,
      });
    } catch (e) {
      print(e);
    }
  }

  // Future<List?> read(int brnachId) async {
  //   QuerySnapshot querySnapshot;
  //   List userlist = [];
  //   try {
  //     // if (brnachId != 0) {
  //     //   print("is equal");
  //     //   querySnapshot = await collectionReference
  //     //       .where("branch", isEqualTo: brnachId)
  //     //       .get();
  //     // } else {
  //     querySnapshot = await collectionReference.get();
  //     // }

  //     if (querySnapshot.docs.isNotEmpty) {
  //       for (var doc in querySnapshot.docs.toList()) {
  //         Map a = {
  //           "id": doc.id,
  //           "staffName": doc['staffName'],
  //           "location": doc["location"],
  //           "address": doc["address"],
  //           "phoneNo": doc["phoneNo"],
  //           "password": doc["password"],
  //           "type": doc["type"],
  //           "token": doc['token'],
  //           "commission": doc['commission'],
  //           "branch": doc['branch'],
  //         };
  //         userlist.add(a);
  //       }

  //       return userlist;
  //     }
  //   } catch (e) {
  //     print(e);
  //   }
  // }
  Future<List?> read() async {
    QuerySnapshot querySnapshot;
    List userlist = [];
    try {
      // if (brnachId != 0) {
      //   print("is equal");
      //   querySnapshot = await collectionReference
      //       .where("branch", isEqualTo: brnachId)
      //       .get();
      // } else {
      querySnapshot = await collectionReference.get();
      // }

      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs.toList()) {
          Map a = {
            "id": doc.id,
            "staffName": doc['staffName'],
            "location": doc["location"],
            "address": doc["address"],
            "phoneNo": doc["phoneNo"],
            "password": doc["password"],
            // "type": doc["type"],
            "token": doc['token'],
            "commission": doc['commission'],
            "branch": doc['branch'],
          };
          userlist.add(a);
        }

        return userlist;
      }
    } catch (e) {
      print(e);
    }
  }

  Future<List?> readforLogin() async {
    QuerySnapshot querySnapshot;
    List userlist = [];
    try {
      // .where("branch",isEqualTo: 0)
      querySnapshot = await collectionReference.orderBy('timestamp').get();

      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs.toList()) {
          Map a = {
            "id": doc.id,
            "staffName": doc['staffName'],
            "location": doc["location"],
            "address": doc["address"],
            "phoneNo": doc["phoneNo"],
            "password": doc["password"],
            "type": doc["type"],
            "token": doc['token'],
            "commission": doc['commission'],
            "branch": doc['branch'],
          };
          userlist.add(a);
        }

        return userlist;
      }
    } catch (e) {
      print(e);
    }
  }

  Future<List?> getAdminStaffToken(int branchId) async {
    QuerySnapshot querySnapshot;
    List userlist = [];
    try {
      querySnapshot = await collectionReference
          .where("branch", isEqualTo: branchId)
          .orderBy('timestamp')
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs.toList()) {
          if (doc["type"] == 1) {
            Map a = {
              "id": doc.id,
              "token": doc['token'],
            };
            userlist.add(a);
          }
        }

        return userlist;
      }
    } catch (e) {
      print(e);
    }
  }

  Future getStaffById(String id) async {
    List allData = [];
    try {
      QuerySnapshot querySnapshot = await collectionReference.get();

      for (var doc in querySnapshot.docs.toList()) {
        if (id == doc.id) {
          Map a = {
            "id": doc.id,
            "staffName": doc['staffName'],
            "location": doc["location"],
            "address": doc["address"],
            "phoneNo": doc["phoneNo"],
            "password": doc["password"],
            "type": doc["type"],
            "token": doc['token'],
            "commission": doc['commission'],
            "branch": doc['branch'],
          };
          // print("true");
          allData.add(a);
        }
      }
      return allData;
    } catch (e) {}
  }

  Future<void> delete(String id) async {
    try {
      await collectionReference.doc(id).delete();
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }
}
