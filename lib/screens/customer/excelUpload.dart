import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExcelUploadScreen extends StatefulWidget {
  @override
  _ExcelUploadScreenState createState() => _ExcelUploadScreenState();
}

class _ExcelUploadScreenState extends State<ExcelUploadScreen> {
  bool _isLoading = false;
  String _statusMessage = 'Upload Excel File to Firebase';
  String fileName = "";

  // Function to pick and extract data from the Excel file
  Future<void> pickAndExtractExcelData() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Processing Excel File...';
    });

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null) {
      setState(() {
        fileData = result;
        fileName = result.files.single.name;
        isFileExist = true;
      });

      File file = File(result.files.single.path!);
      var bytes = file.readAsBytesSync();
      var excel = Excel.decodeBytes(bytes);

      for (var table in excel.tables.keys) {
        // print("Reading sheet: $table"); // Sheet name
        var rows = excel.tables[table]!.rows;

        // Assuming the first row is header
        for (int i = 1; i < rows.length; i++) {
          try {
            var row = rows[i];
            if (row.length < 5) continue; // Ensure there are enough columns
            var srNo = row[0]?.value.toString() ?? '';
            String date = row[1]?.value.toString() ?? '';
            // print(date);
            String customerId = row[2]?.value.toString() ?? '';
            String name = row[3]?.value.toString() ?? '';
            String amountw = row[4]?.value.toString() ?? '';
            String note = row[5]?.value.toString() ?? '';
            double amount = double.parse(amountw);
            DateTime dateTime = DateTime.parse(date);
            // print(dateTime);
            // print(
            // 'Date: $date, Customer ID: $customerId, Name: $name, Amount: $amount, Note: $note');

            // Upload to Firestore
            totalList.add({
              'srNo': srNo,
              'date': date,
              'customerId': customerId,
              'name': name,
              'amount': amount,
              'note': note,
            });
            // await uploadDataToFirestore(
            //     srNo, dateTime, customerId, name, amount, note);
          } catch (e) {
            print(e);
            setState(() {
              isError == true;
            });
          }
        }
      }

      setState(() {
        _isLoading = false;
        _statusMessage = 'Excel Data Uploaded Successfully!';
      });
      isError == false
          ? ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("File Pick Successfull...")))
          : ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("File Fields Not Match...!")));
    } else {
      // User canceled the picker
      setState(() {
        _isLoading = false;
        _statusMessage = 'File Picking Cancelled';
      });
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("File Picking Cancelled")));
    }
  }

  bool isError = false;

  List<Map<String, dynamic>> totalList = [];
  List<Map<String, dynamic>> pendingList = [];
  // Function to upload data to Firestore
  // Future<void> uploadDataToFirestore(var srNo, date, String customerId,
  //     String name, double amount, String note) async {
  //   double newbalance = 0;
  //   double oldBalance = 0;
  //   double gramWeight = 0;
  //   double gramTotalWeight = 0;
  //   double gramTotalWeightFinal = 0;
  //   QuerySnapshot querySnapshot;
  //   String usrId = customerId;
  //   var todayGoldRate;
  //   String docId = "";

  //   CollectionReference transactions =
  //       FirebaseFirestore.instance.collection('customers');
  //   CollectionReference collectionReferenceUser =
  //       FirebaseFirestore.instance.collection('user');
  //   CollectionReference collectionReferenceGoldrate =
  //       FirebaseFirestore.instance.collection('goldrate');
  //   CollectionReference collectionReferenceTrans =
  //       FirebaseFirestore.instance.collection('transactions');

  //   QuerySnapshot querySnapshogoldt = await collectionReferenceGoldrate.get();
  //   for (var doc in querySnapshogoldt.docs.toList()) {
  //     todayGoldRate = doc["gram"];
  //   }

  //   querySnapshot = await collectionReferenceUser
  //       .where('custId', isEqualTo: customerId)
  //       .get();
  //   if (querySnapshot.docs.isNotEmpty) {
  //     querySnapshot.docs.forEach((doc) {
  //       docId = doc.id;
  //       print('Document ID: $docId');
  //     });
  //     try {
  //       print("-----");
  //       querySnapshot = await collectionReferenceUser.get();
  //       var goldRate = await collectionReferenceGoldrate.get();

  //       if (querySnapshot.docs.isNotEmpty) {
  //         for (var doc in querySnapshot.docs
  //             .where((element) => element.id.toString() == docId.toString())
  //             .toList()) {
  //           oldBalance = doc["balance"].toDouble();
  //           gramTotalWeight = doc["total_gram"];
  //         }
  //         print("-----------");
  //         print(oldBalance);
  //         // gram wait for recieve
  //         // gramWeight = transactionModel.amount / goldRate.docs[0]['gram'];
  //         gramWeight = amount / todayGoldRate;

  //         num gramWeightFixed = num.parse(gramWeight.toStringAsFixed(4));

  //         newbalance = oldBalance + amount;

  //         gramTotalWeightFinal = gramTotalWeight + gramWeight;

  //         num gramTotalWeightFinalFixed =
  //             num.parse(gramTotalWeightFinal.toStringAsFixed(4));

  //         await collectionReferenceTrans.add({
  //           'customerName': name,
  //           'customerId': docId,
  //           'date': date,
  //           'amount': amount,
  //           'transactionType': 0,
  //           'note': note,
  //           'timestamp': FieldValue.serverTimestamp(),
  //           'invoiceNo': "",
  //           'category': "Gold",
  //           'discount': 0,
  //           'staffId': staffData['id'],
  //           'gramWeight': gramWeightFixed,
  //           'gramPriceInvestDay': todayGoldRate,
  //           'branch': 1,
  //           'staffName': staffData['staffName'],
  //           'transactionMode': "Direct",
  //           "merchentTransactionId": ""
  //         });
  //         print("===================");
  //         print(docId);
  //         print(newbalance);
  //         print(gramTotalWeightFinalFixed);
  //         await collectionReferenceUser.doc(docId).update({
  //           'balance': newbalance,
  //           'total_gram': gramTotalWeightFinalFixed,
  //         });
  //       }
  //     } catch (e) {
  //       print(e);
  //     }
  //     /////////////////////////
  //     await transactions
  //         .add({
  //           'srNo': srNo,
  //           'date': date,
  //           'customerId': customerId,
  //           'name': name,
  //           'amount': amount,
  //           'note': note,
  //         })
  //         .then((value) => print("Transaction Added"))
  //         .catchError((error) => print("Failed to add transaction: $error"));
  //   } else {
  //     print(customerId);
  //     pendingList.add({
  //       'srNo': srNo,
  //       'date': date,
  //       'customerId': customerId,
  //       'name': name,
  //       'amount': amount,
  //       'note': note,
  //     });
  //     print(pendingList);
  //     print("Transaction stored offline as customer was not found");
  //   }
  //   // ScaffoldMessenger.of(context)
  //   //     .showSnackBar(const SnackBar(content: Text("Upload Successfull...")));
  //   setState(() {
  //     isFileExist = false;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recieve Excel Upload '),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      bottomSheet: Container(
        height: 120,
        color: Theme.of(context).primaryColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            fileName != ""
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        fileName,
                        style: TextStyle(
                            fontWeight: FontWeight.w300,
                            fontSize: 13,
                            color: Colors.white),
                      ),
                      SizedBox(width: 10),
                      IconButton(
                          onPressed: () {
                            setState(() {
                              fileData = null;
                              fileName = "";
                              isFileExist = false;
                              totalList = [];
                              pendingList = [];
                            });
                          },
                          icon: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20,
                          ))
                    ],
                  )
                : Container(),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              Text(
                "Select Excel File",
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Colors.white),
              ),
              Container(
                width: MediaQuery.of(context).size.width * .5,
                height: MediaQuery.of(context).size.height * .05,
                decoration: BoxDecoration(
                    color: Color.fromARGB(255, 255, 255, 255),
                    borderRadius: BorderRadius.circular(20)),
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      totalList = [];
                      pendingList = [];
                    });
                    isFileExist != true
                        ? pickAndExtractExcelData()
                        : uploadData(fileData);
                  },
                  child: isFileExist != true
                      ? Text(
                          "Pick File",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: Color.fromARGB(255, 106, 16, 16),
                          ),
                        )
                      : _isLoading
                          ? CircularProgressIndicator()
                          : Text(
                              "Upload Selected file",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: Color.fromARGB(255, 106, 16, 16),
                              ),
                            ),
                ),
              )
            ]),
          ],
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Text(
              //   _statusMessage,
              //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              // ),
              // SizedBox(height: 20),
              // _isLoading
              //     ? CircularProgressIndicator()
              //     : ElevatedButton(
              //         onPressed: pickAndExtractExcelData,
              //         child: Text('Pick and Upload Excel File'),
              //       ),
              // Divider(color: Colors.red),
              Text(
                "Total Recieved List",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              totalList.length > 0
                  ? ListView.separated(
                      separatorBuilder: (context, index) => SizedBox(height: 3),
                      shrinkWrap: true,
                      itemCount: totalList.length,
                      itemBuilder: (context, index) {
                        // print(totalList[index]);
                        return ListTile(
                          tileColor: Color.fromARGB(37, 128, 23, 23),
                          leading:
                              Text(totalList[index]["srNo"].toStringAsFixed(0)),
                          title: Text(totalList[index]["name"]),
                          subtitle: Text(totalList[index]["customerId"]),
                          trailing: Text(totalList[index]["amount"].toString()),
                        );
                      })
                  : Container(
                      height: 100,
                      child: Center(child: Text("No Data Found...."))),
              SizedBox(height: 15),
              Text(
                "Pending List",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              pendingList.length > 0
                  ? ListView.separated(
                      separatorBuilder: (context, index) => SizedBox(height: 3),
                      shrinkWrap: true,
                      itemCount: pendingList.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          tileColor: Color.fromARGB(37, 128, 23, 23),
                          leading: Text(
                              pendingList[index]["srNo"].toStringAsFixed(0)),
                          title: Text(pendingList[index]["name"]),
                          subtitle: Text(pendingList[index]["customerId"]),
                          trailing:
                              Text(pendingList[index]["amount"].toString()),
                        );
                      })
                  : Container(
                      height: 100,
                      child: Center(child: Text("No Data Found...."))),
            ],
          ),
        ),
      ),
    );
  }

  bool isFileExist = false;
  var fileData;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUser();
  }

  var staffData;
  getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      staffData = jsonDecode(prefs.getString('staff')!);
    });
  }

  uploadData(var result) async {
    // print(result);
    File file = File(result.files.single.path!);
    var bytes = file.readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);

    for (var table in excel.tables.keys) {
      // print("Reading sheet: $table"); // Sheet name
      var rows = excel.tables[table]!.rows;

      // Assuming the first row is header
      for (int i = 1; i < rows.length; i++) {
        var row = rows[i];
        // print(row);
        if (row.length < 5) continue; // Ensure there are enough columns
        var srNo = row[0]?.value ?? '';
        String date = row[1]?.value.toString() ?? '';
        // print(date);
        String customerId = row[2]?.value.toString() ?? '';
        String name = row[3]?.value.toString() ?? '';
        String amountw = row[4]?.value.toString() ?? '';
        String note = row[5]?.value.toString() ?? '';
        double amount = double.parse(amountw);
        DateTime dateTime = DateTime.parse(date);
        // print(dateTime);
        // print(
        //     'Date: $date, Customer ID: $customerId, Name: $name, Amount: $amount, Note: $note');

        // Upload to Firestore
        totalList.add({
          'srNo': srNo,
          'date': date,
          'customerId': customerId,
          'name': name,
          'amount': amount,
          'note': note,
        });
        await uploadDataToFirestore(
            srNo, dateTime, customerId, name, amount, note);
      }
    }

    setState(() {
      _isLoading = false;
      _statusMessage = 'Excel Data Uploaded Successfully!';
    });
  }

  Future<void> uploadDataToFirestore(var srNo, DateTime date, String customerId,
      String name, double amount, String note) async {
    double newBalance = 0;
    double oldBalance = 0;
    double gramWeight = 0;
    double gramTotalWeight = 0;
    double gramTotalWeightFinal = 0;
    String docId = "";
    var todayGoldRate;

    // Firestore collections

    CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('user');
    CollectionReference goldRateCollection =
        FirebaseFirestore.instance.collection('goldrate');
    CollectionReference transactionsCollection =
        FirebaseFirestore.instance.collection('transactions');

    // Get today's gold rate
    QuerySnapshot goldRateSnapshot = await goldRateCollection.get();
    for (var doc in goldRateSnapshot.docs) {
      todayGoldRate = doc["gram"];
    }

    // Get customer by ID
    QuerySnapshot userSnapshot = await usersCollection
        .where('custId', isEqualTo: customerId)
        .where("isClosed", isEqualTo: "false")
        .get();
    // print("================-----------------+++++++++++++++++");
    // print(customerId);
    if (userSnapshot.docs.isNotEmpty) {
      docId = userSnapshot.docs.first.id;
      // print('Document ID: $docId');

      try {
        // Fetch user details
        var userDoc = await usersCollection.doc(docId).get();
        if (userDoc.exists) {
          oldBalance = userDoc["balance"].toDouble();
          gramTotalWeight = userDoc["total_gram"].toDouble();

          // Calculate new balances and weights
          gramWeight = amount / todayGoldRate;
          double gramWeightFixed = double.parse(gramWeight.toStringAsFixed(4));
          newBalance = oldBalance + amount;
          gramTotalWeightFinal = gramTotalWeight + gramWeight;
          double gramTotalWeightFinalFixed =
              double.parse(gramTotalWeightFinal.toStringAsFixed(4));

          // Add a new transaction
          await transactionsCollection.add({
            'customerName': name,
            'customerId': docId,
            'date': date,
            'amount': amount,
            'transactionType': 0,
            'note': note,
            'timestamp': FieldValue.serverTimestamp(),
            'invoiceNo': "",
            'category': "Gold",
            'discount': 0,
            'staffId': staffData['id'],
            'gramWeight': gramWeightFixed,
            'gramPriceInvestDay': todayGoldRate,
            'branch': 1,
            'staffName': staffData['staffName'],
            'transactionMode': "Direct",
            'merchentTransactionId': ""
          });

          // Update user balance and weight
          await usersCollection.doc(docId).update({
            'balance': newBalance,
            'total_gram': gramTotalWeightFinalFixed,
          });

          // print("Transaction processed for customer: $docId");
          // print(
          //     "New balance: $newBalance, New total weight: $gramTotalWeightFinalFixed");
        }
      } catch (e) {
        // print("Error processing transaction: $e");
      }
    } else {
      // Handle case when customer is not found
      pendingList.add({
        'srNo': srNo,
        'date': date,
        'customerId': customerId, // Ensure original customerId is used here
        'name': name,
        'amount': amount,
        'note': note,
      });

      // print("Transaction stored offline as customer was not found");
      // print(
      // "Pending list: $pendingList"); // For verification that customerId is correct
    }

    setState(() {
      isFileExist = false;
    });
  }

  // Future<void> uploadDataToFirestore(var srNo, DateTime date, String customerId,
  //     String name, double amount, String note) async {
  //   print("======= ======== ======= =======");
  //   print(customerId);
  //   double newBalance = 0;
  //   double oldBalance = 0;
  //   double gramWeight = 0;
  //   double gramTotalWeight = 0;
  //   double gramTotalWeightFinal = 0;
  //   String docId = "";
  //   var todayGoldRate;

  //   // Firestore collections
  //   CollectionReference customersCollection =
  //       FirebaseFirestore.instance.collection('customers');
  //   CollectionReference usersCollection =
  //       FirebaseFirestore.instance.collection('user');
  //   CollectionReference goldRateCollection =
  //       FirebaseFirestore.instance.collection('goldrate');
  //   CollectionReference transactionsCollection =
  //       FirebaseFirestore.instance.collection('transactions');

  //   // Get today's gold rate
  //   QuerySnapshot goldRateSnapshot = await goldRateCollection.get();
  //   for (var doc in goldRateSnapshot.docs) {
  //     todayGoldRate = doc["gram"];
  //   }

  //   // Get customer by ID
  //   QuerySnapshot userSnapshot = await usersCollection
  //       .where('custId', isEqualTo: customerId)
  //       .where("isClosed", isEqualTo: "false")
  //       .get();
  //   if (userSnapshot.docs.isNotEmpty) {
  //     docId = userSnapshot.docs.first.id;
  //     print('Document ID: $docId');

  //     try {
  //       // Fetch user details
  //       var userDoc = await usersCollection.doc(docId).get();
  //       if (userDoc.exists) {
  //         oldBalance = userDoc["balance"].toDouble();
  //         gramTotalWeight = userDoc["total_gram"].toDouble();

  //         // Calculate new balances and weights
  //         gramWeight = amount / todayGoldRate;
  //         double gramWeightFixed = double.parse(gramWeight.toStringAsFixed(4));
  //         newBalance = oldBalance + amount;
  //         gramTotalWeightFinal = gramTotalWeight + gramWeight;
  //         double gramTotalWeightFinalFixed =
  //             double.parse(gramTotalWeightFinal.toStringAsFixed(4));

  //         // Add a new transaction
  //         await transactionsCollection.add({
  //           'customerName': name,
  //           'customerId': docId,
  //           'date': date,
  //           'amount': amount,
  //           'transactionType': 0,
  //           'note': note,
  //           'timestamp': FieldValue.serverTimestamp(),
  //           'invoiceNo': "",
  //           'category': "Gold",
  //           'discount': 0,
  //           'staffId': staffData['id'],
  //           'gramWeight': gramWeightFixed,
  //           'gramPriceInvestDay': todayGoldRate,
  //           'branch': 1,
  //           'staffName': staffData['staffName'],
  //           'transactionMode': "Direct",
  //           'merchentTransactionId': ""
  //         });

  //         // Update user balance and weight
  //         await usersCollection.doc(docId).update({
  //           'balance': newBalance,
  //           'total_gram': gramTotalWeightFinalFixed,
  //         });

  //         print("Transaction processed for customer: $docId");
  //         print(
  //             "New balance: $newBalance, New total weight: $gramTotalWeightFinalFixed");
  //       }
  //     } catch (e) {
  //       print("Error processing transaction: $e");
  //     }

  //     // Add transaction log for customer
  //     await customersCollection
  //         .add({
  //           'srNo': srNo,
  //           'date': date,
  //           'customerId': customerId,
  //           'name': name,
  //           'amount': amount,
  //           'note': note,
  //         })
  //         .then((value) => print("Transaction log added"))
  //         .catchError(
  //             (error) => print("Failed to add transaction log: $error"));
  //   } else {
  //     // Handle case when customer is not found
  //     pendingList.add({
  //       'srNo': srNo,
  //       'date': date,
  //       'customerId': customerId,
  //       'name': name,
  //       'amount': amount,
  //       'note': note,
  //     });
  //     print("Transaction stored offline as customer was not found");
  //   }

  //   setState(() {
  //     isFileExist = false;
  //   });
  // }
}
