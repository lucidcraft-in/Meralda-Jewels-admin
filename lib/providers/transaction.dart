import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class TransactionModel {
  final String id;
  final String customerName;
  final String customerId;
  final DateTime date;
  final double amount;
  final int transactionType;
  final String note;
  final String invoiceNo;
  final String category;
  final double discount;
  final String staffId;
  final double gramPriceInvestDay;
  final double gramWeight;
  final int branch;
  final String staffName;
  TransactionModel({
    required this.id,
    required this.customerName,
    required this.customerId,
    required this.date,
    required this.amount,
    required this.transactionType,
    required this.note,
    required this.invoiceNo,
    required this.category,
    required this.discount,
    required this.staffId,
    required this.gramPriceInvestDay,
    required this.gramWeight,
    required this.branch,
    required this.staffName,
  });

  TransactionModel.fromData(Map<String, dynamic> data)
      : id = data['id'],
        customerName = data['customerName'],
        customerId = data['customerId'],
        date = data['date'],
        amount = data['amount'],
        transactionType = data['transactionType'],
        note = data['note'],
        invoiceNo = data['invoiceNo'],
        category = data['category'],
        discount = data['discount'],
        staffId = data['staffId'],
        gramPriceInvestDay = data['gramPriceInvestDay'],
        gramWeight = data['gramWeight'],
        branch = 0,
        staffName = data['staffName'];
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerName': customerName,
      'customerId': customerId,
      'date': date,
      'amount': amount,
      'transactionType': transactionType,
      'note': note,
      'invoiceNo': invoiceNo,
      'category': category,
      'discount': discount,
      'staffId': staffId,
      'gramPriceInvestDay': gramPriceInvestDay,
      'gramWeight': gramWeight,
      // "branch": branch,
      "staffName": staffName,
    };
  }
}

class TransactionProvider with ChangeNotifier {
  late FirebaseFirestore firestore;
  initiliase() {
    firestore = FirebaseFirestore.instance;
  }

  CollectionReference collectionReference =
      FirebaseFirestore.instance.collection('transactions');

  CollectionReference collectionReferenceUser =
      FirebaseFirestore.instance.collection('user');

  CollectionReference collectionReferenceGoldrate =
      FirebaseFirestore.instance.collection('goldrate');

  CollectionReference collectionReferenceCollection =
      FirebaseFirestore.instance.collection('collection');

  late List<TransactionModel> _transaction;
  double newbalance = 0;
  double oldBalance = 0;
  double gramWeight = 0;
  double gramTotalWeight = 0;
  double gramTotalWeightFinal = 0;

  Future create(
      TransactionModel transactionModel, double tax, double amc) async {
    QuerySnapshot querySnapshot;
    QuerySnapshot goldRate;

    String usrId = transactionModel.customerId;

    double averageRate = 0;
    double totalAverageRate = 0;
    try {
      querySnapshot = await collectionReferenceUser.get();
      goldRate = await collectionReferenceGoldrate.get();

      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs
            .where((element) => element.id.toString() == usrId.toString())
            .toList()) {
          oldBalance = doc["balance"].toDouble();
          gramTotalWeight = doc["total_gram"];

          if (doc["balance"] != 0) {
            averageRate = doc["balance"] / doc["total_gram"];
          }
        }
      }

      if (transactionModel.transactionType == 0) {
        if (tax > 0 && amc > 0) {
// find mc value
          double mcValue = (transactionModel.gramPriceInvestDay * amc) / 100;
          // print("---- mcValue");
          // print(mcValue);
// find Gram Included mc
          double gramIncludedMc = transactionModel.gramPriceInvestDay + mcValue;
          // print("---- gramIncludedMc");
          // print(gramIncludedMc);
// find Tax value
          double taxValue = (gramIncludedMc * tax) / 100;
          // print("---- taxValue");
          // print(taxValue);
// find gramwightPrice
          double priceValue = taxValue + gramIncludedMc;
          // print("---- priceValue");
          // print(priceValue);
// find gramwightPrice
          gramWeight = transactionModel.amount / priceValue;
          // print("---- gramWeight");
          // print(gramWeight);
          // gramWeight = (transactionModel.amount -
          //         (transactionModel.amount * tax / 100) -
          //         (transactionModel.amount * amc / 100)) /
          //     transactionModel.gramPriceInvestDay;
        } else {
          gramWeight =
              transactionModel.amount / transactionModel.gramPriceInvestDay;
        }
      } else {
        // gram weight for purchase

        if (averageRate != 0) {
          gramWeight = transactionModel.amount / averageRate;
        }
      }
      num gramWeightFixed = num.parse(gramWeight.toStringAsFixed(4));
      print("---------- gramWeightFixed");
      print(gramWeightFixed);
      if (transactionModel.transactionType == 0) {
        newbalance = oldBalance + transactionModel.amount;
        if (transactionModel.discount != 0) {
          newbalance = newbalance - transactionModel.discount;
        }
        gramTotalWeightFinal = gramTotalWeight + gramWeight;
      } else if (transactionModel.transactionType == 1) {
        newbalance = oldBalance - transactionModel.amount;
        gramTotalWeightFinal = gramTotalWeight - gramWeight;
      }

      num gramTotalWeightFinalFixed =
          num.parse(gramTotalWeightFinal.toStringAsFixed(4));

      DocumentReference docRef = await collectionReference.add({
        'customerName': transactionModel.customerName,
        'customerId': transactionModel.customerId,
        'date': transactionModel.date,
        'amount': transactionModel.amount,
        'transactionType': transactionModel.transactionType,
        'note': transactionModel.note,
        'timestamp': FieldValue.serverTimestamp(),
        'invoiceNo': transactionModel.invoiceNo,
        'category': transactionModel.category,
        'discount': transactionModel.discount,
        'staffId': transactionModel.staffId,
        'gramWeight': gramWeightFixed,
        'gramPriceInvestDay': transactionModel.transactionType == 0
            ? transactionModel.gramPriceInvestDay
            : goldRate.docs[0]['gram'],
        // 'gramPriceInvestDay': goldRate.docs[0]['gram'],

        'staffName': transactionModel.staffName,
        'transactionMode': "Direct",
        "merchentTransactionId": "",
        "currentBalance": newbalance,
        "currentBalanceGram": gramTotalWeightFinalFixed,
        "tax": tax,
        "amc": amc
      });
      await collectionReferenceUser.doc(transactionModel.customerId).update({
        'balance': newbalance,
        'total_gram': gramTotalWeightFinalFixed,
      });
      notifyListeners();

      String documentId = docRef.id;

      // Return the document ID

      notifyListeners();
      return [
        newbalance,
        gramWeightFixed,
        gramTotalWeightFinalFixed,
        documentId
      ];
    } catch (e) {
      print(e);
    }
  }

  Future<void> update(
      String transId,
      TransactionModel transactionModel,
      String transactionType,
      double oldValueFromDb,
      double gramPriceInvestDay,
      double totalGramBefore) async {
    QuerySnapshot querySnapshot;
    QuerySnapshot querySnapshotTran;
    String usrId = transactionModel.customerId;
    int transType = 0;
    double oldval = 0.0;
    double curtrentBal = 0.0;
    double averageRate = 0;
    double customerTotalGram = 0;

    querySnapshotTran = await collectionReference.get();
    if (querySnapshotTran.docs.isNotEmpty) {
      for (var doc in querySnapshotTran.docs
          .where((element) => element.id.toString() == transId.toString())
          .toList()) {
        transType = doc["transactionType"];
        oldval = doc["amount"];
        usrId = doc['customerId'];
      }
    }
    try {
      querySnapshot = await collectionReferenceUser.get();

      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs
            .where((element) => element.id.toString() == usrId.toString())
            .toList()) {
          if (transType == 0) {
            oldBalance = doc["balance"] - oldValueFromDb;
            customerTotalGram = doc["total_gram"] - totalGramBefore;
          } else {
            oldBalance = doc["balance"] + oldValueFromDb;
            customerTotalGram = doc["total_gram"] + totalGramBefore;
          }
          if (doc["balance"] != 0) {
            averageRate = doc["balance"] / doc["total_gram"];
          }
        }
      }

      if (transType == 0) {
        gramWeight = transactionModel.amount / gramPriceInvestDay;
        newbalance = oldBalance + transactionModel.amount;
        customerTotalGram = customerTotalGram + gramWeight;
      } else if (transType == 1) {
        gramWeight = transactionModel.amount / averageRate;
        newbalance = oldBalance - transactionModel.amount;
        customerTotalGram = customerTotalGram - gramWeight;
      }

      double gramTotalWeightFinalFixed =
          double.parse(customerTotalGram.toStringAsFixed(4));
      num gramWeightFixed = num.parse(gramWeight.toStringAsFixed(4));
      await collectionReferenceUser.doc(transactionModel.customerId).update(
          {'balance': newbalance, 'total_gram': gramTotalWeightFinalFixed});

      if (transType == 0) {
        await collectionReference.doc(transId).update({
          // 'customerName': transactionModel.customerName,
          // 'customerId': transactionModel.customerId,
          'date': transactionModel.date,
          'amount': transactionModel.amount,
          'note': transactionModel.note,
          'invoiceNo': transactionModel.invoiceNo,
          'category': transactionModel.category,
          'gramWeight': gramWeightFixed,
          'gramPriceInvestDay': gramPriceInvestDay,
        });
      } else {
        await collectionReference.doc(transId).update({
          // 'customerName': transactionModel.customerName,
          // 'customerId': transactionModel.customerId,
          'date': transactionModel.date,
          'amount': transactionModel.amount,
          'note': transactionModel.note,
          'invoiceNo': transactionModel.invoiceNo,
          'category': transactionModel.category,
          'gramWeight': gramWeightFixed,
        });
      }
      if (transType == 0) {
        QuerySnapshot querySnapshotCollcet = await collectionReferenceCollection
            .where("transactionId", isEqualTo: transId)
            .get();
        String documentId = querySnapshotCollcet.docs[0].id;
        await collectionReferenceCollection
            .doc(documentId)
            .update({"recievedAmount": transactionModel.amount});
      }
    } catch (e) {
      print(e);
    }
  }

  Future<List?> read(String id) async {
    QuerySnapshot querySnapshot;
    double purchaseAmt = 0;
    double reciptAmt = 0;
    double balance = 0;
    double purchasegram = 0;
    double reciptgram = 0;
    double balancegram = 0;
    List transactionList = [];

    try {
      querySnapshot = await collectionReference
          .where("customerId", isEqualTo: id)
          .orderBy('date', descending: true)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs.toList()) {
          Map a = {
            "id": doc.id,
            'customerName': doc['customerName'],
            'customerId': doc['customerId'],
            'date': doc['date'],
            'amount': doc['amount'],
            'transactionType': doc['transactionType'],
            'note': doc['note'],
            "timestamp": doc["timestamp"],
            'invoiceNo': doc['invoiceNo'],
            'category': doc['category'],
            'discount': doc['discount'],
            'staffId': doc['staffId'],
            'gramWeight': doc['gramWeight'],
            'gramPriceInvestDay': doc['gramPriceInvestDay'],
            // 'branch': doc['branch'],
            'transactionMode': doc['transactionMode'],
            'merchentTransactionId': doc['merchentTransactionId'],
            'staffName':
                doc['transactionMode'] != "online" ? doc['staffName'] : "",
          };
          transactionList.add(a);
          if (doc['transactionType'] == 1) {
            purchaseAmt = purchaseAmt + doc['amount'];
            purchasegram = purchasegram + doc['gramWeight'];
          } else {
            reciptAmt = reciptAmt + doc['amount'];
            reciptgram = reciptgram + doc['gramWeight'];
          }
        }
        balance = reciptAmt - purchaseAmt;
        balancegram = reciptgram - purchasegram;

        return [transactionList, balance, balancegram];
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> delete(
      String transId,
      TransactionModel transactionModel,
      String transactionType,
      double oldValueFromDb,
      double totalGramBefore) async {
    QuerySnapshot querySnapshot;
    QuerySnapshot querySnapshotTran;
    String usrId = "";
    int transType = 0;
    double oldval = 0.0;
    double curtrentBal = 0.0;
    double finalGramWight = 0.0;

    querySnapshotTran = await collectionReference.get();
    if (querySnapshotTran.docs.isNotEmpty) {
      for (var doc in querySnapshotTran.docs
          .where((element) => element.id.toString() == transId.toString())
          .toList()) {
        transType = doc["transactionType"];
        oldval = doc["amount"];
        usrId = doc['customerId'];
        gramWeight = doc['gramWeight'];
      }
    }

    try {
      querySnapshot = await collectionReferenceUser.get();

      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs
            .where((element) => element.id.toString() == usrId.toString())
            .toList()) {
          if (transType == 0) {
            newbalance = doc["balance"] - oldval;
            finalGramWight = doc["total_gram"] - gramWeight;
          } else {
            newbalance = doc["balance"] + oldval;
            finalGramWight = doc["total_gram"] + gramWeight;
          }
        }
      }

      await collectionReferenceUser
          .doc(usrId)
          .update({'balance': newbalance, 'total_gram': finalGramWight});
      await collectionReference.doc(transId).delete();
      if (transType == 0) {
        QuerySnapshot querySnapshotCollcet = await collectionReferenceCollection
            .where("transactionId", isEqualTo: transId)
            .get();
        String documentId = querySnapshotCollcet.docs[0].id;
        await collectionReferenceCollection.doc(documentId).delete();
      }

      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<List?> getAllSales(int branchId) async {
    QuerySnapshot querySnapshot;
    QuerySnapshot querySnapshotCollection;
    double purchaseAmt = 0;
    double reciptAmt = 0;
    double balance = 0;
    double purchasegram = 0;
    double reciptgram = 0;
    double balancegram = 0;
    double recieptPending = 0;
    double totalCOllectionRecive = 0;
    double totalCollectionPaid = 0;
    List transactionList = [];

    try {
      querySnapshot =
          await collectionReference.where("branch", isEqualTo: branchId).get();

      querySnapshotCollection = await collectionReferenceCollection
          // .where("branch", isEqualTo: branchId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs.toList()) {
          // Map a = {
          //   "id": doc.id,
          //   'customerName': doc['customerName'],
          //   'customerId': doc['customerId'],
          //   'date': doc['date'],
          //   'amount': doc['amount'],
          //   'transactionType': doc['transactionType'],
          //   'note': doc['note'],
          //   'invoiceNo': doc['invoiceNo'],
          //   'category': doc['category'],
          //   'discount': doc['discount'],
          //   'staffId': doc['staffId'],
          //   'gramWeight': doc['gramWeight'],
          //   'gramPriceInvestDay': doc['gramPriceInvestDay'],
          //   'branch': doc['branch'],
          // };
          // transactionList.add(a);
          if (doc['transactionType'] == 1) {
            purchaseAmt = purchaseAmt + doc['amount'];
            purchasegram = purchasegram + doc['gramWeight'];
          } else {
            reciptAmt = reciptAmt + doc['amount'];
            reciptgram = reciptgram + doc['gramWeight'];
          }
        }

        balance = reciptAmt - purchaseAmt;
        balancegram = reciptgram - purchasegram;

        if (querySnapshotCollection.docs.isNotEmpty) {
          for (var docColl in querySnapshotCollection.docs.toList()) {
            totalCollectionPaid = totalCollectionPaid + docColl['paidAmount'];
            totalCOllectionRecive =
                totalCOllectionRecive + docColl['recievedAmount'];
          }
          recieptPending = totalCOllectionRecive - totalCollectionPaid;
        }

        return [
          reciptAmt,
          purchaseAmt,
          reciptgram,
          purchasegram,
          balance,
          balancegram,
          recieptPending
        ];
      }
    } catch (e) {
      print(e);
    }
  }

  Future balanceReport(DateTime startDate, DateTime endDate, String branchId,
      String paymentType) async {
    // branch: 1 = Alathur
    // branch : 2= chittur
    // branch : 3= vadakkanchari
    var branchCode = 0;
    // if (branchId == "Alathur") {
    //   branchCode = 1;
    // } else if (branchId == "Chittur") {
    //   branchCode = 2;
    // } else if (branchId == "Vadakkencherri") {
    //   branchCode = 3;
    // } else {
    //   branchCode = 0;
    // }

    if (paymentType == "Payment Proof") {
      paymentType = "online";
    } else if (paymentType == "Direct") {
      paymentType = "Direct";
    } else {
      paymentType;
    }
    List userlist = [];
    double paidAmount = 0;
    double purchase = 0;
    double balancePr = 0;
    double balancePaid = 0;
    QuerySnapshot querySnapshot;
    QuerySnapshot querySnapshot1;
    List transactionList = [];
    String customerId = "";
    try {
      querySnapshot1 = await collectionReferenceUser.get();
      if (branchId == "All" && paymentType == "All") {
        print("------- both All-----------");

        querySnapshot = await collectionReference
            .where("date", isGreaterThanOrEqualTo: startDate)
            .where("date", isLessThan: endDate)
            .get();

        for (var doc in querySnapshot.docs.toList()) {
          // DocumentSnapshot documentSnapshot =
          //     await collectionReferenceUser.doc(doc['customerId']).get();

          for (var doc1 in querySnapshot1.docs.toList()) {
            if (doc['customerId'] == doc1.id) {
              // print("------ ------- ------- -------- ---------");
              customerId = doc1["custId"];
              // print(doc1["custId"]);
            }
          }

          Map a = {
            "id": doc.id,
            'customerName': doc['customerName'],
            'customerId': doc['customerId'],
            'date': doc['date'],
            'amount': doc['amount'],
            'transactionType': doc['transactionType'],
            'note': doc['note'],
            'invoiceNo': doc['invoiceNo'],
            'category': doc['category'],
            'discount': doc['discount'],
            'staffId': doc['staffId'],
            'gramWeight': doc['gramWeight'],
            'gramPriceInvestDay': doc['gramPriceInvestDay'],
            // 'branch': doc['branch'],
            'staffName':
                doc['transactionMode'] != "online" ? doc['staffName'] : "",
            "custID": customerId
          };
          transactionList.add(a);
        }
      } else if (branchId != "All" && paymentType == "All") {
        querySnapshot = await collectionReference
            .where("date", isGreaterThanOrEqualTo: startDate)
            .where("date", isLessThanOrEqualTo: endDate)
            // .where("branch", isEqualTo: branchCode)
            .get();
        for (var doc in querySnapshot.docs.toList()) {
          for (var doc1 in querySnapshot1.docs.toList()) {
            if (doc['customerId'] == doc1.id) {
              // print("------ ------- ------- -------- ---------");
              customerId = doc1["custId"];
              // print(doc1["custId"]);
            }
          }
          Map a = {
            "id": doc.id,
            'customerName': doc['customerName'],
            'customerId': doc['customerId'],
            'date': doc['date'],
            'amount': doc['amount'],
            'transactionType': doc['transactionType'],
            'note': doc['note'],
            'invoiceNo': doc['invoiceNo'],
            'category': doc['category'],
            'discount': doc['discount'],
            'staffId': doc['staffId'],
            'gramWeight': doc['gramWeight'],
            'gramPriceInvestDay': doc['gramPriceInvestDay'],
            // 'branch': doc['branch'],
            'staffName':
                doc['transactionMode'] != "online" ? doc['staffName'] : "",
            "custID": customerId
          };
          transactionList.add(a);
        }
      } else if (branchId == "All" && paymentType != "All") {
        // print("-------branch all && payment not all-----------");

        querySnapshot = await collectionReference
            .where("date", isGreaterThanOrEqualTo: startDate)
            .where("date", isLessThanOrEqualTo: endDate)
            .where("transactionMode", isEqualTo: paymentType)
            .get();
        for (var doc in querySnapshot.docs.toList()) {
          for (var doc1 in querySnapshot1.docs.toList()) {
            if (doc['customerId'] == doc1.id) {
              // print("------ ------- ------- -------- ---------");
              customerId = doc1["custId"];
              // print(doc1["custId"]);
            }
          }
          Map a = {
            "id": doc.id,
            'customerName': doc['customerName'],
            'customerId': doc['customerId'],
            'date': doc['date'],
            'amount': doc['amount'],
            'transactionType': doc['transactionType'],
            'note': doc['note'],
            'invoiceNo': doc['invoiceNo'],
            'category': doc['category'],
            'discount': doc['discount'],
            'staffId': doc['staffId'],
            'gramWeight': doc['gramWeight'],
            'gramPriceInvestDay': doc['gramPriceInvestDay'],
            // 'branch': doc['branch'],
            'staffName':
                doc['transactionMode'] != "online" ? doc['staffName'] : "",
            "custID": customerId
          };
          transactionList.add(a);
        }
      } else {
        print("------- both not All-----------");

        querySnapshot = await collectionReference
            .where("date", isGreaterThanOrEqualTo: startDate)
            .where("date", isLessThanOrEqualTo: endDate)
            // .where("branch", isEqualTo: branchCode)
            .where("transactionMode", isEqualTo: paymentType)
            .get();
        for (var doc in querySnapshot.docs.toList()) {
          for (var doc1 in querySnapshot1.docs.toList()) {
            if (doc['customerId'] == doc1.id) {
              // print("------ ------- ------- -------- ---------");
              customerId = doc1["custId"];
              // print(doc1["custId"]);
            }
          }
          Map a = {
            "id": doc.id,
            'customerName': doc['customerName'],
            'customerId': doc['customerId'],
            'date': doc['date'],
            'amount': doc['amount'],
            'transactionType': doc['transactionType'],
            'note': doc['note'],
            'invoiceNo': doc['invoiceNo'],
            'category': doc['category'],
            'discount': doc['discount'],
            'staffId': doc['staffId'],
            'gramWeight': doc['gramWeight'],
            'gramPriceInvestDay': doc['gramPriceInvestDay'],
            // 'branch': doc['branch'],
            'staffName':
                doc['transactionMode'] != "online" ? doc['staffName'] : "",
            "custID": customerId
          };
          transactionList.add(a);
        }
      }

      // for (var docTran in querySnapshot!.docs.toList()) {
      //   // if (dbDate.isBefore(onlyDateEnd) &&
      //   //     dbDate.isAfter(onlyDateStart)) {
      //   if (docTran["transactionType"] == 0) {
      //     paidAmount = paidAmount + docTran["amount"];
      //   } else {
      //     purchase = purchase + docTran["amount"];
      //   }
      //   // }

      // }

      for (var doc in querySnapshot.docs.toList()) {
        // print(doc["transactionType"]);

        // print(doc["amount"]);
        // print("-");
        if (doc["transactionType"] == 1) {
          balancePr = balancePr + doc["amount"];
        } else {
          balancePaid = balancePaid + doc["amount"];
        }
      }

      return [transactionList, balancePaid, balancePr];
    } catch (e) {
      print(e);
    }
  }

  // Future getAllData() async {
  //   List custData = [];
  //   QuerySnapshot querySnapshotcust = await collectionReferenceUser.get();
  //   for (var doc in querySnapshotcust.docs.toList()) {
  //     Map a = {
  //       "id": doc.id,
  //       'customerName': doc['name'],
  //     };
  //     custData.add(a);
  //   }
  //   // print(custData);
  //   QuerySnapshot querySnapshot = await collectionReference.get();
  //   for (var doc in querySnapshot.docs.toList()) {
  //     print(
  //       doc['customerId'],
  //     );

  //     var data =
  //         custData.indexWhere((element) => element["id"] == doc['customerId']);
  //     if (data != -1) {
  //       print(custData[data]);
  //       await collectionReference
  //           .doc(doc.id)
  //           .update({"customerName": custData[data]["customerName"]});
  //     }
  //   }
  // }

  readByStaff(DateTime selectDate, String staffId) async {
    List transactionList = [];
    print(selectDate);
    DateTime startOfDay =
        DateTime(selectDate.year, selectDate.month, selectDate.day, 0, 0, 0, 0);
    DateTime endOfDay = DateTime(
        selectDate.year, selectDate.month, selectDate.day, 23, 59, 59, 999);

    QuerySnapshot querySnapshot = await collectionReference
        .where("staffId", isEqualTo: staffId)
        .where("transactionType", isEqualTo: 0)
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .where('date', isLessThanOrEqualTo: endOfDay)
        .orderBy('date', descending: true)
        .get();
    print(querySnapshot.docs.length);
    for (var doc in querySnapshot.docs.toList()) {
      // for (var doc1 in querySnapshot.docs.toList()) {
      Map a = {
        "id": doc.id,
        'customerName': doc['customerName'],
        'customerId': doc['customerId'],
        'date': doc['date'],
        'amount': doc['amount'],
        'transactionType': doc['transactionType'],
        'note': doc['note'],
        'invoiceNo': doc['invoiceNo'],
        'category': doc['category'],
        'discount': doc['discount'],
        'staffId': doc['staffId'],
        'gramWeight': doc['gramWeight'],
        'gramPriceInvestDay': doc['gramPriceInvestDay'],
        // 'branch': doc['branch'],
        "timestamp": doc["timestamp"],
        'staffName': doc['transactionMode'] != "online" ? doc['staffName'] : "",
      };
      transactionList.add(a);
      // }
    }

    return transactionList;
  }
}
