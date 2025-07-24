import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constant/colors.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/goldrate.dart';
import '../../providers/paymentBill.dart';
import '../../providers/transaction.dart';

class SendPaymentRec extends StatefulWidget {
  final String documentId;

  SendPaymentRec({required this.documentId});

  @override
  _SendPaymentRecState createState() => _SendPaymentRecState();
}

class _SendPaymentRecState extends State<SendPaymentRec> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  DateTime? _selectedDate;
  String? _pickedFile;
  File? selectedFile;
  bool checkValue = false;
  var user;
  TextEditingController _amountController = TextEditingController();
  TextEditingController _noteController = TextEditingController();
  TextEditingController _gramRateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getStaff();
    getDocumentData();
  }

  bool isLoad = false;

  var data;
  getDocumentData() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('paymentRequst') // Replace with your collection name
        .doc(widget.documentId)
        .get();

    if (doc.exists) {
      data = doc.data() as Map<String, dynamic>;
      setState(() {
        _amountController.text = data['amount'].toString();
        _noteController.text = data['note'];
        _selectedDate = (data['date'] as Timestamp).toDate();

        _gramRateController.text = data['goldRate'] != null
            ? data['goldRate'].toString()
            : 0.toString();
        isLoad = true;
      });
      if (data['goldRate'] != null && data['goldRate'] != 0) {
        goldRate = data['goldRate'];
      } else {
        getGoldRate();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          title: Text('Upload Screenshot'),
          backgroundColor: useColor.homeIconColor),
      body: isLoad
          ? Padding(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text('Customer Name : '),
                        Text(data['userName']),
                      ],
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      readOnly: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter valid amount';
                        }
                        return null;
                      },
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Amount",
                        labelStyle:
                            TextStyle(color: Theme.of(context).primaryColor),
                        hintText: 'Enter Amount',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromARGB(255, 185, 185, 185)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromARGB(255, 185, 185, 185)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromARGB(255, 185, 185, 185)),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      readOnly: true,
                      controller: _noteController,
                      decoration: InputDecoration(
                        labelText: "Note",
                        labelStyle:
                            TextStyle(color: Theme.of(context).primaryColor),
                        hintText: 'Enter Note',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromARGB(255, 185, 185, 185)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromARGB(255, 185, 185, 185)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromARGB(255, 185, 185, 185)),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      readOnly: true,
                      controller: _gramRateController,
                      decoration: InputDecoration(
                        labelText: "Gram Rate",
                        labelStyle:
                            TextStyle(color: Theme.of(context).primaryColor),
                        hintText: 'Gram Rate',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromARGB(255, 185, 185, 185)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromARGB(255, 185, 185, 185)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromARGB(255, 185, 185, 185)),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: () async {
                        // DateTime? pickedDate = await showDatePicker(
                        //   context: context,
                        //   initialDate: _selectedDate ?? DateTime.now(),
                        //   firstDate: DateTime(2000),
                        //   lastDate: DateTime(2101),
                        // );
                        // if (pickedDate != null) {
                        //   setState(() {
                        //     _selectedDate = pickedDate;
                        //   });
                        // }
                      },
                      child: Container(
                        height: 60,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Color.fromARGB(255, 185, 185, 185)),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_selectedDate == null
                                ? 'Select Date'
                                : DateFormat('yyyy-MM-dd')
                                    .format(_selectedDate!)),
                            Icon(Icons.calendar_month)
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    GestureDetector(
                      onTap: () async {},
                      child: Container(
                          height: MediaQuery.of(context).size.height * .25,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: Color.fromARGB(255, 185, 185, 185)),
                          ),
                          child: PhotoView(
                            imageProvider: NetworkImage(data['image']),
                            backgroundDecoration: BoxDecoration(
                              color: Color.fromARGB(255, 255, 255, 255),
                            ),
                          )

                          //  Column(
                          //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          //   children: [
                          //     Image(
                          //       height: 200,
                          //       image: NetworkImage(data['image']),
                          //     ),
                          //   ],
                          // ),
                          ),
                    ),
                    SizedBox(height: 20),
                    SizedBox(height: 16.0),
                    data['status'] == "Request"
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                width: 100,
                                height: 50,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    // primary: Colors.red, // Background color
                                    // onPrimary: Colors.white, // Text color
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          10), // Rounded corners
                                    ),
                                  ),
                                  onPressed: _isSubmitting ? null : decline,
                                  // _submitForm,

                                  child: _isSubmitting
                                      ? CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        )
                                      : Text('Decline'),
                                ),
                              ),
                              Container(
                                width: 100,
                                height: 50,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    // primary: Theme.of(context)
                                    //     .primaryColor, // Background color
                                    // onPrimary: Colors.white, // Text color
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          10), // Rounded corners
                                    ),
                                  ),
                                  onPressed: _isSubmitting ? null : submit
                                  // _submitForm,
                                  ,
                                  child: _isSubmitting
                                      ? CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        )
                                      : Text('Approve'),
                                ),
                              ),
                            ],
                          )
                        : Container(),
                  ],
                ),
              ),
            )
          : Container(),
    );
  }

  void submit() async {
    setState(() {
      _isSubmitting = true;
    });
    try {
      var _transaction = TransactionModel(
          customerName: data['userName'],
          customerId: data['userId'],
          date: _selectedDate!,
          amount: data['amount'],
          transactionType: 0,
          note: data['note'],
          invoiceNo: "",
          category: "Gold",
          discount: 0,
          staffId: StaffData['id'],
          gramPriceInvestDay: goldRate,
          gramWeight: 0,
          id: "",
          branch: 1,
          staffName: StaffData['staffName']);

      // print(_transaction.customerName);
      // print(_transaction.customerId);
      // print(_transaction.amount);
      // print(_transaction.note);
      // print(_transaction.staffId);
      // print(_transaction.staffName);
      // print(_transaction.gramPriceInvestDay);
      // print(_transaction.staffName);
      Provider.of<PaymentBillProvider>(context, listen: false)
          .createPayment(_transaction, widget.documentId, 'approve')
          .then((val) {
        if (val == 200) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("Payment Approved")));
        } else {
          setState(() {
            _isSubmitting = false;
          });
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("Error Occur")));
        }
      });
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  var goldRate;
  List goldrateList = [];
  Goldrate? dbGoldrate;
  var StaffData;
  getStaff() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      StaffData = jsonDecode(prefs.getString('staff')!);
    });
  }

  void decline() async {
    var _transaction = TransactionModel(
        customerName: data['userName'],
        customerId: data['userId'],
        date: _selectedDate!,
        amount: data['amount'],
        transactionType: 0,
        note: data['note'],
        invoiceNo: "",
        category: "Gold",
        discount: 0,
        staffId: StaffData['id'],
        gramPriceInvestDay: goldRate,
        gramWeight: 0,
        id: "",
        branch: 1,
        staffName: StaffData['staffName']);

    Provider.of<PaymentBillProvider>(context, listen: false)
        .createPayment(_transaction, widget.documentId, "Decline")
        .then((val) {
      if (val == 200) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Payment Approved")));
      }
    });
  }

  getGoldRate() async {
    dbGoldrate = Goldrate();
    dbGoldrate!.initiliase();
    dbGoldrate!.read().then((value) => {
          setState(() {
            goldrateList = value!;

            goldRate = goldrateList[0]['gram'].toString();
          }),
        });
  }
}
