import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firbase_storage;
import 'transaction.dart';

class PaymentBillProvider with ChangeNotifier {
  late FirebaseFirestore firestore;
  initiliase() {
    firestore = FirebaseFirestore.instance;
  }

  final firbase_storage.FirebaseStorage storage =
      firbase_storage.FirebaseStorage.instance;

  CollectionReference collectionReference =
      FirebaseFirestore.instance.collection('paymentRequst');
  CollectionReference collectionReferenceTrans =
      FirebaseFirestore.instance.collection('transactions');
  CollectionReference collectionReferenceUser =
      FirebaseFirestore.instance.collection('user');

  CollectionReference collectionReferenceGoldrate =
      FirebaseFirestore.instance.collection('goldrate');

  Stream<QuerySnapshot> getAllData() {
    return collectionReference.snapshots();
  }

  createPayment(
      TransactionModel transactionModel, String billId, String stauts) async {
    double newbalance = 0;
    double oldBalance = 0;
    double gramWeight = 0;
    double gramTotalWeight = 0;
    double gramTotalWeightFinal = 0;
    QuerySnapshot querySnapshot;
    QuerySnapshot goldRate;
    QuerySnapshot transactionQuerySnapshot;
    int tranCount = 0;
    List userlist = [];
    String usrId = transactionModel.customerId;
    double averageRate = 0;
    double totalAverageRate = 0;
    int custBranch = 0;
    try {
      if (stauts == "Decline") {
        collectionReference.doc(billId).update({
          "status": stauts

          // "approve"
        });
      } else {
        querySnapshot = await collectionReferenceUser.get();
        goldRate = await collectionReferenceGoldrate.get();

        if (querySnapshot.docs.isNotEmpty) {
          for (var doc in querySnapshot.docs
              .where((element) => element.id.toString() == usrId.toString())
              .toList()) {
            oldBalance = doc["balance"].toDouble();
            gramTotalWeight = doc["total_gram"];
            custBranch = doc['branch'];
            if (doc["balance"] != 0) {
              averageRate = doc["balance"] / doc["total_gram"];
            }
          }
        }

        if (transactionModel.transactionType == 0) {
          // gram wait for recieve
          // gramWeight = transactionModel.amount / goldRate.docs[0]['gram'];
          gramWeight =
              transactionModel.amount / transactionModel.gramPriceInvestDay;
        } else {
          // gram weight for purchase
          transactionQuerySnapshot = await collectionReferenceTrans
              .orderBy('timestamp', descending: true)
              .get();

          if (averageRate != 0) {
            gramWeight = transactionModel.amount / averageRate;
          }
        }
        num gramWeightFixed = num.parse(gramWeight.toStringAsFixed(4));
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

        await collectionReferenceTrans.add({
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
          'branch': 1,
          'staffName': transactionModel.staffName,
          'transactionMode': "Payment Proof",
          "merchentTransactionId": ""
        });
        await collectionReferenceUser.doc(transactionModel.customerId).update({
          'balance': newbalance,
          'total_gram': gramTotalWeightFinalFixed,
        });
        notifyListeners();
        final newGoldrate = TransactionModel(
          id: transactionModel.id,
          customerName: transactionModel.customerName,
          customerId: transactionModel.customerId,
          date: transactionModel.date,
          amount: transactionModel.amount,
          transactionType: transactionModel.transactionType,
          note: transactionModel.note,
          invoiceNo: transactionModel.invoiceNo,
          category: transactionModel.category,
          discount: transactionModel.discount,
          staffId: transactionModel.staffId,
          gramWeight: transactionModel.gramWeight,
          gramPriceInvestDay: transactionModel.gramPriceInvestDay,
          branch: 1,
          staffName: transactionModel.staffName,
        );

        notifyListeners();

        collectionReference.doc(billId).update({"status": stauts});
      }
      return 200;
    } catch (e) {
      print(e);
    }
  }
}
