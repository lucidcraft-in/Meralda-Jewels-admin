import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// import './database.dart';

class UserModel {
  final String id;
  final String name;
  final String custId;
  final String phoneNo;
  final String address;
  final String place;
  final double balance;
  final String staffId;
  final String token;
  final String schemeType;
  final double totalGram;
  final int branch;
  final DateTime dateofBirth;
  final String nominee;
  final String nomineePhone;
  final String? nomineeRelation;
  final String adharCard;
  final String? panCard;
  final String? pinCode;
  final String? staffName;
  final String? mailId;
  final double? tax;
  final double? amc;

  UserModel(
      {required this.id,
      required this.name,
      required this.custId,
      required this.phoneNo,
      required this.address,
      required this.place,
      required this.balance,
      required this.staffId,
      required this.token,
      required this.schemeType,
      required this.totalGram,
      required this.branch,
      required this.dateofBirth,
      required this.nominee,
      required this.nomineePhone,
      this.nomineeRelation,
      required this.adharCard,
      this.panCard,
      this.pinCode,
      this.staffName,
      required this.mailId,
      required this.tax,
      required this.amc});

  UserModel.fromData(Map<String, dynamic> data)
      : id = data['id'],
        name = data['name'],
        custId = data['custId'],
        phoneNo = data['phonne_no'],
        address = data['address'],
        place = data['place'],
        balance = data['balance'],
        staffId = data['staffId'],
        token = data['token'],
        schemeType = data['schemeType'],
        totalGram = data['total_gram'],
        branch = data['branch'],
        dateofBirth = data['dateofBirth'],
        nominee = data['nominee'],
        nomineePhone = data['nomineePhone'],
        nomineeRelation = data['nomineeRelation'],
        adharCard = data['adharCard'],
        panCard = data['panCard'],
        pinCode = data['pinCode'],
        staffName = data['staffName'],
        mailId = data['mailId'],
        amc = data["amc"],
        tax = data["tax"];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'custId': custId,
      'phone_no': phoneNo,
      'address': address,
      'place': place,
      'balance': balance,
      'staffId': staffId,
      'token': token,
      'schemeType': schemeType,
      'total_gram': totalGram,
      'branch': branch,
      'dateofBirth': dateofBirth,
      'nominee': nominee,
      'nomineePhone': nomineePhone,
      'nomineeRelation': nomineeRelation,
      'adharCard': adharCard,
      'panCard': panCard,
      'pinCode': pinCode,
      'staffName': staffName,
      "amc": amc,
      "tax": tax
    };
  }
}

class User with ChangeNotifier {
  late FirebaseFirestore firestore;
  initiliase() {
    firestore = FirebaseFirestore.instance;
  }

  CollectionReference collectionReference =
      FirebaseFirestore.instance.collection('user');

  CollectionReference collectionReferenceTrans =
      FirebaseFirestore.instance.collection('transactions');

  CollectionReference collectionReferenceCollection =
      FirebaseFirestore.instance.collection('collection');

  late List<UserModel> _user;
  late List<UserModel> user;

  set listStaff(List<UserModel> val) {
    _user = val;
    notifyListeners();
  }

  List<UserModel> get listUsers => _user;

  int get userCount {
    return _user.length;
  }

  Future<bool?> create(
      UserModel userModel,
      String customerId,
      String schemeType,
      String assignStaff,
      String assignStaffName,
      String orderAdv) async {
    try {
      QuerySnapshot querySnapshot;

      querySnapshot = await collectionReference.orderBy('custId').get();
      var user = querySnapshot.docs.where((doc) => doc['custId'] == customerId);
      // print(scheme);
      // print('Selected Scheme ID: ${scheme!.id}');
      // print('Selected Scheme Name: ${scheme!.name}');

      if (user.length == 0) {
        await collectionReference.add({
          'name': userModel.name,
          'custId': customerId,
          'phone_no': userModel.phoneNo,
          'address': userModel.address,
          'place': userModel.place,
          'balance': 0.00,
          'staffId': assignStaff,
          //  userModel.staffId,
          'timestamp': FieldValue.serverTimestamp(),
          'token': "",
          'schemeType': schemeType,
          // "scheme": {"id": scheme.id, "name": scheme.name},
          'total_gram': 0.0000,
          'branch': userModel.branch,
          'dateofBirth': userModel.dateofBirth,
          'nominee': userModel.nominee,
          'nomineePhone': userModel.nomineePhone,
          'nomineeRelation': userModel.nomineeRelation,
          'adharCard': userModel.adharCard,
          'panCard': userModel.panCard,
          'pinCode': userModel.pinCode,
          'staffName': assignStaffName,

          //  userModel.staffName,
          "otp": 0,
          "isClosed": "false",
          "otpExp": FieldValue.serverTimestamp(),
          "otpGen": FieldValue.serverTimestamp(),
          "mail": userModel.mailId,
          "orderAdvance": orderAdv,
          "profileImage": "",
          "tax": userModel.tax,
          "amc": userModel.amc
          // "staffAssigneeId": assignStaff,
          // "staffAssigneeName": assignStaffName
        });

        return Future<bool>.value(false);
      } else {
        return Future<bool>.value(true);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<bool?> update(
      String id,
      UserModel userModel,
      bool changeCustIdIS,
      String balance,
      String tax,
      String amc,
      String staffId,
      String staffName) async {
    try {
      QuerySnapshot querySnapshot;

      querySnapshot = await collectionReference.orderBy('custId').get();
      var user =
          querySnapshot.docs.where((doc) => doc['custId'] == userModel.custId);

      if (changeCustIdIS == true) {
        if (user.length == 0) {
          await collectionReference.doc(id).update({
            'name': userModel.name,
            // 'custId': userModel.custId,
            'phone_no': userModel.phoneNo,
            'address': userModel.address,
            'place': userModel.place,
            "balance": double.parse(balance),
            'schemeType': userModel.schemeType,
            'dateofBirth': userModel.dateofBirth,
            'nominee': userModel.nominee,
            'nomineePhone': userModel.nomineePhone,
            'nomineeRelation': userModel.nomineeRelation,
            'adharCard': userModel.adharCard,
            'panCard': userModel.panCard,
            'pinCode': userModel.pinCode,
            "tax": double.parse(tax),
            "amc": double.parse(amc),
            'staffName': staffName,
            'staffId': staffId,
          });
          notifyListeners();
          return Future<bool>.value(false);
        } else {
          return Future<bool>.value(true);
        }
      } else {
        await collectionReference.doc(id).update({
          'name': userModel.name,
          // 'custId': userModel.custId,
          'phone_no': userModel.phoneNo,
          'address': userModel.address,
          'place': userModel.place,
          "balance": double.parse(balance),
          'schemeType': userModel.schemeType,
          'dateofBirth': userModel.dateofBirth,
          'nominee': userModel.nominee,
          'nomineePhone': userModel.nomineePhone,
          'nomineeRelation': userModel.nomineeRelation,
          'adharCard': userModel.adharCard,
          'panCard': userModel.panCard,
          'pinCode': userModel.pinCode,
          "tax": double.parse(tax),
          "amc": double.parse(amc),
          'staffName': staffName,
          'staffId': staffId,
        });
        notifyListeners();
        return Future<bool>.value(false);
      }
    } catch (e) {
      print(e);
    }
  }

  Future read(int branchId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    QuerySnapshot? querySnapshot;
    List userlist = [];

    try {
      // if (branchId != 0) {
      //   print("is equal");
      //   querySnapshot = await collectionReference
      //       .where("branch", isEqualTo: branchId)
      //       .orderBy("custId", descending: false)
      //       .where("isClosed", isEqualTo: "false")
      //       // .orderBy("balance", descending: false)
      //       .get();
      // } else {
      querySnapshot = await collectionReference
          .orderBy("custId", descending: false)
          .where("isClosed", isEqualTo: "false")
          // .orderBy("balance", descending: false)
          .get();
      // }

      // if (staffType == 1) {
      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs.toList()) {
          Map a = {
            "id": doc.id,
            "name": doc['name'],
            "custId": doc["custId"],
            'isClosed': doc["isClosed"],
            "balance": doc["balance"],
            "phoneNo": doc["phone_no"],
            "address": doc["address"],
            "place": doc["place"],
            "staffId": doc["staffId"],
            "token": doc["token"],
            "schemeType": doc["schemeType"],
            "total_gram": doc["total_gram"],
            "branch": doc['branch'],
            "dateofBirth": doc['dateofBirth'],
            "nominee": doc['nominee'],
            "nomineePhone": doc['nomineePhone'],
            "nomineeRelation": doc['nomineeRelation'],
            "adharCard": doc['adharCard'],
            "panCard": doc['panCard'],
            "pinCode": doc['pinCode'],
            "staffName": doc['staffName'],
          };
          userlist.add(a);
        }

        return userlist;
      }
    } catch (e) {
      print(e);
    }
  }

  Future readByStaff(int staffType, String staffId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    QuerySnapshot? querySnapshot;
    List userlist = [];
    print("---");
    print(staffType);
    try {
      if (staffType == 1) {
        querySnapshot = await collectionReference
            .orderBy("custId", descending: false)
            .where("isClosed", isEqualTo: "false")
            // .orderBy("balance", descending: false)
            .get();
      } else {
        querySnapshot = await collectionReference
            .where("staffId", isEqualTo: staffId)
            .orderBy("custId", descending: false)
            .where("isClosed", isEqualTo: "false")
            // .orderBy("balance", descending: false)
            .get();
      }

      // if (staffType == 1) {
      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs.toList()) {
          Map a = {
            "id": doc.id,
            "name": doc['name'],
            "custId": doc["custId"],
            'isClosed': doc["isClosed"],
            "balance": doc["balance"],
            "phoneNo": doc["phone_no"],
            "address": doc["address"],
            "place": doc["place"],
            "staffId": doc["staffId"],
            "token": doc["token"],
            "schemeType": doc["schemeType"],
            "total_gram": doc["total_gram"],
            "branch": doc['branch'],
            "dateofBirth": doc['dateofBirth'],
            "nominee": doc['nominee'],
            "nomineePhone": doc['nomineePhone'],
            "nomineeRelation": doc['nomineeRelation'],
            "adharCard": doc['adharCard'],
            "panCard": doc['panCard'],
            "pinCode": doc['pinCode'],
            "staffName": doc['staffName'],
            "tax": doc["tax"],
            "amc": doc["amc"],
            "profileImage": doc['profileImage']
          };
          userlist.add(a);
        }

        return userlist;
      }
    } catch (e) {
      print(e);
    }
  }

  Future<List?> readbyBranchId(int branchId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var Staff = jsonDecode(prefs.getString('staff')!);

    QuerySnapshot querySnapshot;
    List userlist = [];
    String staffid = Staff['id'];
    int staffType = Staff['type'];

    try {
      querySnapshot = await collectionReference
          .where("branch", isEqualTo: branchId)
          // .snapshots()
          // .last;
          .orderBy("timestamp", descending: true)
          .limit(1)
          .get();

      // if (staffType == 1) {
      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs.toList()) {
          Map a = {
            "id": doc.id,
            "name": doc['name'],
            "custId": doc["custId"],
            "branch": doc['branch'],
          };
          userlist.add(a);
        }

        return userlist;
      } else {
        return userlist;
      }
    } catch (e) {
      print(e);
    }
  }

  Future<List?> customerRportRead(staffId, DateTime startDate, DateTime endDate,
      String paymentType, int staffType) async {
    DateTime newStartDate =
        DateTime(startDate.year, startDate.month, startDate.day, 0, 0, 0, 0);
    DateTime newEndDate =
        DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59, 999);

    QuerySnapshot querySnapshot;
    QuerySnapshot querySnapshotTrans;
    List userlist = [];

    double paidAmount = 0;
    double purchase = 0;
    double balance = 0;

    try {
      // if (branchId != 0) {
      //   querySnapshot = await collectionReference
      //       // .where("branch", isEqualTo: branchId)
      //       .where("staffId", isEqualTo: staffId)
      //       .orderBy("balance", descending: true)
      //       .get();
      // } else {
      if (staffType == 1) {
        querySnapshot = await collectionReference
            .orderBy("balance", descending: true)
            // .where("staffId", isEqualTo: staffId)
            .get();
      } else {
        querySnapshot = await collectionReference
            .orderBy("balance", descending: true)
            .where("staffId", isEqualTo: staffId)
            .get();
      }

      // }

      if (paymentType == "All") {
        querySnapshotTrans = await collectionReferenceTrans
            .where("date", isGreaterThanOrEqualTo: newStartDate)
            .where("date", isLessThanOrEqualTo: newEndDate)
            .get();
      } else {
        if (paymentType == "Payment Proof") {
          paymentType = "Payment Proof";
          querySnapshotTrans = await collectionReferenceTrans
              .where("transactionMode", isEqualTo: paymentType)
              .where("date", isGreaterThanOrEqualTo: newStartDate)
              .where("date", isLessThanOrEqualTo: newEndDate)
              .get();
        } else {
          paymentType = "Direct";
          querySnapshotTrans = await collectionReferenceTrans
              .where("transactionMode", isEqualTo: paymentType)
              .where("date", isGreaterThanOrEqualTo: newStartDate)
              .where("date", isLessThanOrEqualTo: newEndDate)
              .get();
        }
      }
      // print("----------- Tranaction Data -----------");
      // print(querySnapshotTrans.docs.length);
      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs) {
          // print(" === c====");

          double paidAmount = 0, purchase = 0;

          // Filter transactions that belong to the current user
          var userTransactions = querySnapshotTrans.docs
              .where((docTran) => docTran["customerId"] == doc.id)
              .toList();

          // If no transactions exist for this user, skip to the next user
          // if (userTransactions.isEmpty) continue;

          // Calculate paid and purchase amounts
          for (var docTran in userTransactions) {
            if (docTran["transactionType"] == 0) {
              paidAmount += docTran["amount"];
            } else {
              purchase += docTran["amount"];
            }
          }

          double balance = paidAmount - purchase;

          // if (doc["balance"] != 0) {
          userlist.add({
            "id": doc.id,
            "name": doc['name'],
            "custId": doc["custId"],
            "phoneNo": doc["phone_no"],
            "address": doc["address"],
            "place": doc["place"],
            "balance": doc["balance"],
            "staffId": doc["staffId"],
            "token": doc["token"],
            "schemeType": doc["schemeType"],
            "paidAmount": paidAmount,
            "total_gram": doc["total_gram"],
            "purchase": purchase,
            "custBalance": balance,
            "branch": doc['branch'],
            "dateofBirth": doc['dateofBirth'],
            "nominee": doc['nominee'],
            "nomineePhone": doc['nomineePhone'],
            "nomineeRelation": doc['nomineeRelation'],
            "adharCard": doc['adharCard'],
            "panCard": doc['panCard'],
            "pinCode": doc['pinCode'],
            "staffName": doc['staffName'],
          });
          // }
        }

        return userlist;
      }

      // if (querySnapshot.docs.isNotEmpty) {
      //   for (var doc in querySnapshot.docs) {
      //     print(" === c====");

      //     double paidAmount = 0, purchase = 0;

      //     // Process transactions related to this customer
      //     for (var docTran in querySnapshotTrans.docs) {
      //       if (docTran["customerId"] == doc.id) {
      //         if (docTran["transactionType"] == 0) {
      //           paidAmount += docTran["amount"];
      //         } else {
      //           purchase += docTran["amount"];
      //         }
      //       }
      //     }
      //     print("paid amount");
      //     print(paidAmount);
      //     print(purchase);

      //     double balance = paidAmount - purchase;

      //     if (doc["balance"] != 0) {
      //       print("@@@@@@@@@@@@@@@@@@");
      //       userlist.add({
      //         "id": doc.id,
      //         "name": doc['name'],
      //         "custId": doc["custId"],
      //         "phoneNo": doc["phone_no"],
      //         "address": doc["address"],
      //         "place": doc["place"],
      //         "balance": doc["balance"],
      //         "staffId": doc["staffId"],
      //         "token": doc["token"],
      //         "schemeType": doc["schemeType"],
      //         "paidAmount": paidAmount,
      //         "total_gram": doc["total_gram"],
      //         "purchase": purchase,
      //         "custBalance": balance,
      //         "branch": doc['branch'],
      //         "dateofBirth": doc['dateofBirth'],
      //         "nominee": doc['nominee'],
      //         "nomineePhone": doc['nomineePhone'],
      //         "nomineeRelation": doc['nomineeRelation'],
      //         "adharCard": doc['adharCard'],
      //         "panCard": doc['panCard'],
      //         "pinCode": doc['pinCode'],
      //         "staffName": doc['staffName'],
      //       });
      //     }
      //   }

      //   return userlist;
      // }
    } catch (e) {
      print(e);
    }
  }

  Future<List?> readBystaffId(String staffId) async {
    QuerySnapshot querySnapshot;
    List userlist = [];
    double totalBalance = 0;
    try {
      querySnapshot = await collectionReference.orderBy('timestamp').get();

      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs.toList()) {
          if (staffId == doc['staffId']) {
            Map a = {
              "id": doc.id,
              "name": doc['name'],
              "custId": doc["custId"],
              "phoneNo": doc["phone_no"],
              "address": doc["address"],
              "place": doc["place"],
              "balance": doc["balance"],
              "staffId": doc["staffId"],
              "schemeType": doc["schemeType"],
              "branch": doc['branch'],
              "dateofBirth": doc['dateofBirth'],
              "nominee": doc['nominee'],
              "nomineePhone": doc['nomineePhone'],
              "nomineeRelation": doc['nomineeRelation'],
              "adharCard": doc['adharCard'],
              "panCard": doc['panCard'],
              "pinCode": doc['pinCode'],
              "staffName": doc['staffName'],
            };

            userlist.add(a);
            totalBalance = totalBalance + doc["balance"];
          }
        }

        return [userlist, totalBalance];
      }
    } catch (e) {
      print(e);
    }
  }

  Future<List?> readBystaffIdAndDate(
      String staffId, DateTime selectedDate) async {
    QuerySnapshot querySnapshot;
    QuerySnapshot querySnapshotTrans;
    QuerySnapshot querySnapshotCollection;
    double totalAmount = 0;
    double amountReciveFromStaff = 0;
    List userlist = [];
    List staffIds = [];
    List transList = [];
    DateTime passedDate = selectedDate;
    final lastDayOfMonth =
        DateTime(selectedDate.year, selectedDate.month + 1, 0, 23, 59, 59, 999);
    final firstDayofMonth = DateTime(selectedDate.year, selectedDate.month);

    try {
      querySnapshot = await collectionReferenceTrans
          .where('date', isGreaterThanOrEqualTo: firstDayofMonth)
          .where('date', isLessThanOrEqualTo: lastDayOfMonth)
          .where('staffId', isEqualTo: staffId)
          .where("transactionType", isEqualTo: 0)
          .orderBy('date', descending: true)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        for (var docss in querySnapshot.docs.toList()) {
          totalAmount = totalAmount + docss['amount'];
          staffIds.add(docss['customerId']);
          Map tra = {
            "custId": docss['customerId'],
            "amount": docss['amount'],
          };
          transList.add(tra);
        }
      }

      var filteredCustIds = staffIds.toSet().toList();
      // print("---- ----- ------");
      // print(transList);
      List userTotalbalnaceList = [];
      double tempbalance = 0;
      // if (filteredCustIds.length > 0) {
      //   for (var k = 0; k < filteredCustIds.length; k++) {
      //     for (var j = 0; j < transList.length; j++) {
      //       if (filteredCustIds[k] == transList[j]["custId"]) {
      //         tempbalance = tempbalance + transList[j]["amount"];
      //       }
      //     }
      //     userTotalbalnaceList
      //         .add({"custId": filteredCustIds[k], "totalAmount": tempbalance});
      //     tempbalance = 0;
      //   }
      // }

      Map<String, double> userBalanceMap = {};

      for (var trans in transList) {
        userBalanceMap[trans["custId"]] =
            (userBalanceMap[trans["custId"]] ?? 0) + trans["amount"];
      }

// Convert to list
      userTotalbalnaceList = userBalanceMap.entries
          .map((entry) => {"custId": entry.key, "totalAmount": entry.value})
          .toList();
      // print(userTotalbalnaceList);

      // querySnapshotCollection = await collectionReferenceCollection
      //     .where('timestamp', isGreaterThanOrEqualTo: firstDayofMonth)
      //     .where('timestamp', isLessThanOrEqualTo: lastDayOfMonth)
      //     .where('staffId', isEqualTo: staffId)
      //     .orderBy('timestamp')
      //     .get();

      QuerySnapshot querySnapshot1 =
          await collectionReference.orderBy('timestamp').get();
      if (querySnapshot1.docs.isNotEmpty) {
        print("ok");
        for (var doc in querySnapshot1.docs.toList()) {
          if (staffId == doc['staffId']) {
            for (var i = 0; i < userTotalbalnaceList.length; i++) {
              if (userTotalbalnaceList[i]["custId"] == doc.id) {
                Map a = {
                  "id": doc.id,
                  "name": doc['name'],
                  "custId": doc["custId"],
                  "phoneNo": doc["phone_no"],
                  "balance": doc["balance"],
                  "staffId": doc["staffId"],
                  "schemeType": doc["schemeType"],
                  "totalAmount": totalAmount,
                  "userMonthcollection": userTotalbalnaceList[i]["totalAmount"],
                  "recivedFromStaff": amountReciveFromStaff,
                  "staffName": doc['staffName'],
                };
                userlist.add(a);
              }
            }
          }
        }
        // print(userlist);
        return userlist;
      }
    } catch (e) {
      print(e);
    }
  }

  Future<List?> readBycustd(String custId) async {
    QuerySnapshot querySnapshot;
    List userlist = [];

    try {
      querySnapshot = await collectionReference.orderBy('timestamp').get();

      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs.toList()) {
          if (custId == doc.id) {
            Map a = {
              "id": doc.id,
              "name": doc['name'],
              "custId": doc["custId"],
              "phoneNo": doc["phone_no"],
              "address": doc["address"],
              "place": doc["place"],
              "balance": doc["balance"],
              "staffId": doc["staffId"],
              "schemeType": doc["schemeType"],
              "branch": doc['branch'],
              "dateofBirth": doc['dateofBirth'],
              "nominee": doc['nominee'],
              "nomineePhone": doc['nomineePhone'],
              "nomineeRelation": doc['nomineeRelation'],
              "adharCard": doc['adharCard'],
              "panCard": doc['panCard'],
              "pinCode": doc['pinCode'],
              "staffName": doc['staffName'],
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

  Future<void> delete(String id) async {
    try {
      await collectionReference.doc(id).delete();
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  void removeItem(String productId) {
    _user.remove(productId);
    notifyListeners();
  }

  void clear() {
    _user = [];
    notifyListeners();
  }

  upldateCloseUser(String userId, double balance, double blanceGram,
      DateTime closeDate) async {
    collectionReference.doc(userId).update({
      'balaceAtClose': balance,
      'closeTotal_gram': blanceGram,
      'closedAt': closeDate,
      'isClosed': "true",
      'balance': 0,
      'total_gram': 0
    });
  }

  ReactivityCloseUser(String userId, double balance, double blanceGram,
      DateTime closeDate) async {
    collectionReference.doc(userId).update({
      'balaceAtClose': 0,
      'closeTotal_gram': 0,
      'closedAt': closeDate,
      'isClosed': "false",
      'balance': balance,
      'total_gram': blanceGram
    });
  }

  getClosedUser(DateTime selectDate) async {
    List userList = [];
    DateTime passedDate = selectDate;
    final lastDayOfMonth =
        DateTime(selectDate.year, selectDate.month + 1, 0, 23, 59, 59, 999);
    final firstDayofMonth = DateTime(selectDate.year, selectDate.month);

    QuerySnapshot querySnapshot =
        await collectionReference.where("isClosed", isEqualTo: "true").get();
    for (var doc in querySnapshot.docs.toList()) {
      DateTime dbDate = doc['closedAt'].toDate();

      if (dbDate.isBefore(lastDayOfMonth) && dbDate.isAfter(firstDayofMonth)) {
        Map a = {
          "id": doc.id,
          "name": doc['name'],
          "custId": doc["custId"],
          "phoneNo": doc["phone_no"],
          'balaceAtClose': doc["balaceAtClose"],
          'closeTotal_gram': doc["closeTotal_gram"],
          'closedAt': doc["closedAt"],
          'isClosed': doc["isClosed"],
          "address": doc["address"],
          "place": doc["place"],
          "balance": doc["balance"],
          "staffId": doc["staffId"],
          "schemeType": doc["schemeType"],
          "branch": doc['branch'],
          "dateofBirth": doc['dateofBirth'],
          "nominee": doc['nominee'],
          "nomineePhone": doc['nomineePhone'],
          "nomineeRelation": doc['nomineeRelation'],
          "adharCard": doc['adharCard'],
          "panCard": doc['panCard'],
          "pinCode": doc['pinCode'],
          "staffName": doc['staffName'],
        };
        userList.add(a);
      }
    }
    return userList;
  }

  // Function to update all customers
  Future<void> updateAllCustomers() async {
    try {
      // Get all customers
      QuerySnapshot querySnapshot = await collectionReference.get();
      WriteBatch batch = FirebaseFirestore.instance.batch();

      // Loop through all documents in the collection and update each one
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        batch.update(doc.reference, {
          'isClosed': "false",
          'closedAt': FieldValue.serverTimestamp(),
          'balanceAtClose': 0,
          'closeTotal_gram': 0,
        });
      }

      // Commit the batch update
      await batch.commit();
      // print('All customers updated successfully');
    } catch (e) {
      print('Error updating all customers: $e');
    }
  }

  getStatus(String custId) async {
    // print("--------");
    // print(custId);

    QuerySnapshot querySnapshot =
        await collectionReference.where('custId', isEqualTo: custId).get();
    if (querySnapshot.docs.isNotEmpty) {
      // Assuming there's only one document for the customer
      var customerData =
          querySnapshot.docs.first.data() as Map<String, dynamic>;
      String isClosed = customerData['isClosed'];
      double balance = customerData['balance'];
      double blanacegramm = customerData['total_gram'];

      return [isClosed, balance, blanacegramm];
    } else {
      print('No customer found with custId: $custId');
    }
  }

  createUserFromExcel(Customer data) async {
    try {
      await collectionReference.add({
        'name': data.name,
        'custId': data.customerId,
        'phone_no': data.phone,
        'address': data.address,
        'place': "",
        'balance': double.parse(data.balance),
        'staffId': data.agentId,
        "agentCode": data.agentCode,
        'timestamp': data.startDate,
        'token': "",
        'schemeType': data.customerType,
        'total_gram': 0.0000,
        'branch': 1,
        'dateofBirth': FieldValue.serverTimestamp(),
        'nominee': "",
        'nomineePhone': "",
        'nomineeRelation': "",
        'adharCard': "",
        'panCard': "",
        'pinCode': "",
        'staffName': "",
        'isClosed': "false",
        'closedAt': FieldValue.serverTimestamp(),
        'balaceAtClose': 0,
        'closeTotal_gram': 0,
        "otpExp": FieldValue.serverTimestamp(),
        "otpGen": FieldValue.serverTimestamp(),
        "mail": "",
      });
    } catch (e) {}
  }

  getUserBalance(String custId) async {
    List userlist = [];
    QuerySnapshot querySnapshot =
        await collectionReference.where('custId', isEqualTo: custId).get();

    for (var doc in querySnapshot.docs.toList()) {
      Map a = {
        "id": doc.id,
        "name": doc['name'],
        "custId": doc["custId"],
        "phoneNo": doc["phone_no"],
        "schemeType": doc["schemeType"],
        "balance": doc["balance"],
        "staffName": doc['staffName'],
        "total_gram": doc["total_gram"]
      };
      userlist.add(a);
    }
    return userlist;
  }
}

class Customer {
  final int srNo;
  final String customerId;
  final String name;
  final String address;
  final String phone;
  final String balance;
  final String agentId;
  final String agentCode;
  final DateTime? startDate;
  final String customerType;

  Customer({
    required this.srNo,
    required this.customerId,
    required this.name,
    required this.address,
    required this.phone,
    required this.balance,
    required this.agentId,
    required this.agentCode,
    required this.startDate,
    required this.customerType,
  });

  // Create a method to convert customer data to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'srNo': srNo,
      'custId': customerId,
      'name': name,
      'address': address,
      'phone': phone,
      'balance': balance,
      'agent_id': agentId,
      'agent_code': agentCode,
      'startDate': startDate?.toIso8601String(),
      'custType': customerType,
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      srNo: map['srNo'],
      customerId: map['custId'],
      name: map['name'],
      address: map['address'],
      phone: map['phone'],
      balance: map['balance'],
      agentId: map['agent_id'],
      agentCode: map['agent_code'],
      startDate: DateTime.parse(map['startDate']), // Parse the date
      customerType: map['custType'],
    );
  }
}
