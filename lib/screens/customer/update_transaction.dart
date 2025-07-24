import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constant/colors.dart';
import './customer_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction.dart';
import '../../providers/user.dart';
import './customer_view.dart';

class UpdateTransaction extends StatefulWidget {
  static const routeName = '/update-transaction';

  UpdateTransaction(
      {Key? key,
      required this.db,
      required this.transaction,
      required this.dbUser,
      required this.user,
      required this.staffType})
      : super(key: key);
  Map transaction;
  TransactionProvider db;
  final Map user;
  final User dbUser;
  var staffType;
  @override
  _UpdateTransactionState createState() => _UpdateTransactionState();
}

class _UpdateTransactionState extends State<UpdateTransaction> {
  User? userDb;
  List userList = [];
  TextEditingController _reasonController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  var _isLoading = false;
  String dropdownValue = 'in';
  String transactiontype = '';
  double oldValueFromDb = 0;
  String selectedValue = 'Gold';
  double totalGramBefore = 0;
  double gramPriceInvestDay = 0;
  var _transaction = TransactionModel(
    id: '',
    customerName: '',
    // customerId: '',
    date: DateTime.now(),
    amount: 0,
    // transactionType:1  ,
    note: '',
    category: '',
    invoiceNo: '',
    customerId: '',
    discount: 0,
    gramPriceInvestDay: 0,
    gramWeight: 0,
    staffId: '',
    transactionType: 0,
    branch: 0,
    staffName: '',
  );

  initialise() {
    userDb = User();
    userDb!.initiliase();
    userDb!.readBycustd(widget.transaction['customerId']).then((value) => {
          setState(() {
            userList = value!;
          })
        });
  }

  late int staffType;
  Future loginData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var Staff = jsonDecode(prefs.getString('staff')!);
    setState(() {
      staffType = Staff['type'];
    });
    // print("========");
    // print(staffType);

    // initialise();
  }

  @override
  void initState() {
    super.initState();
    loginData();
    // initialise();

    oldValueFromDb = widget.transaction['amount'].toDouble();

    selectedValue = widget.transaction['category'];

    gramPriceInvestDay = widget.transaction['gramPriceInvestDay'].toDouble();
    totalGramBefore = widget.transaction['gramWeight'];

    _transaction = TransactionModel(
      customerName: widget.transaction["customerName"],
      customerId: widget.transaction['customerId'],
      date: _transaction.date,
      amount: _transaction.amount,
      transactionType: widget.transaction['transactionType'],
      note: _transaction.note,
      invoiceNo: _transaction.invoiceNo,
      category: selectedValue,
      discount: _transaction.discount,
      gramPriceInvestDay: _transaction.gramPriceInvestDay,
      gramWeight: _transaction.gramWeight,
      id: _transaction.id,
      staffId: _transaction.staffId,
      branch: _transaction.branch,
      staffName: _transaction.staffName,
    );
  }

  Future<void> _saveForm() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      setState(() {
        isLoad = false;
      });
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<TransactionProvider>(context, listen: false)
          .update(widget.transaction['id'], _transaction, transactiontype,
              oldValueFromDb, _transaction.gramPriceInvestDay, totalGramBefore)
          .then((value) {
        setState(() {});

        final snackBar = SnackBar(content: const Text("add Successfully...."));

        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => CustomerViewScreen(
                      user: widget.user,
                      dbUser: widget.dbUser,
                    )));
      });
    } catch (err) {
      setState(() {
        isLoad = false;
      });
      print(err);
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('An error occurred!'),
          content: Text('Something went wrong. ${err}'),
          actions: <Widget>[
            OutlinedButton(
              child: Text('Okay'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            )
          ],
        ),
      );
    }
    setState(() {
      _isLoading = false;
      Navigator.of(context).pop();
    });
  }

  Future<void> _delete(String deleteText) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<TransactionProvider>(context, listen: false).delete(
          widget.transaction['id'],
          _transaction,
          transactiontype,
          oldValueFromDb,
          totalGramBefore);
      userDb = User();
      userDb!.initiliase();
      await userDb!.readBycustd(widget.transaction['customerId']).then((value) {
        setState(() {
          userList = value!;
        });
      });
      CollectionReference collectionReference =
          FirebaseFirestore.instance.collection('historyDltTransaction');
      await collectionReference.add({
        'customerName': _transaction.customerName,
        'customerId': _transaction.customerId,
        'date': widget.transaction['date'],
        'amount': widget.transaction['amount'],
        'transactionType': widget.transaction['transactionType'],
        'note': widget.transaction['note'],
        'invoiceNo': widget.transaction['invoiceNo'],
        'category': widget.transaction['category'],
        'discount': widget.transaction['discount'],
        'staffId': widget.transaction['staffId'],
        'gramWeight': widget.transaction['gramWeight'],
        'gramPriceInvestDay': widget.transaction['gramPriceInvestDay'],
        'staffName': widget.transaction['staffName'],
        'transactionMode': widget.transaction['transactionMode'],
        "merchentTransactionId": widget.transaction['merchentTransactionId'],
        "deletedDate": FieldValue.serverTimestamp(),
        "deleteNote": deleteText != "" ? deleteText : "nothing entered"
      });
      setState(() {
        _isLoading = false;
      });
      final snackBar =
          SnackBar(content: const Text("Deleted Successfully...."));

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => CustomerViewScreen(
                    user: widget.user,
                    dbUser: widget.dbUser,
                  )));
    } catch (err) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('An error occurred!'),
          content: Text('Something went wrong. ${err}'),
          actions: <Widget>[
            OutlinedButton(
              child: Text('Okay'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blueGrey.shade50,
        appBar: AppBar(
          backgroundColor: useColor.homeIconColor,
          title: Text('Transaction Edit'),
          actions: [],
        ),
        body: _isLoading == false
            ? Padding(
                padding: const EdgeInsets.all(15.0),
                child: Container(
                  child: new SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height * .7,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              TextFormField(
                                keyboardType: TextInputType.number,
                                initialValue:
                                    widget.transaction['amount'].toString(),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Amount';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _transaction = TransactionModel(
                                    customerName: _transaction.customerName,
                                    customerId:
                                        widget.transaction['customerId'],
                                    date: _transaction.date,
                                    amount: value != ""
                                        ? double.parse(value!)
                                        : double.parse(0.0.toString()),
                                    transactionType:
                                        widget.transaction['transactionType'],
                                    note: _transaction.note,
                                    invoiceNo: _transaction.invoiceNo,
                                    category: _transaction.category,
                                    discount: _transaction.discount,
                                    gramPriceInvestDay:
                                        _transaction.gramPriceInvestDay,
                                    gramWeight: _transaction.gramWeight,
                                    id: _transaction.id,
                                    staffId: _transaction.staffId,
                                    branch: _transaction.branch,
                                    staffName: _transaction.staffName,
                                  );
                                },
                                decoration: const InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.red,
                                      width: 1.0,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.black,
                                      width: 1.0,
                                    ),
                                  ),
                                  labelText: 'Enter amount given',
                                ),
                              ),
                              InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Select Category',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0)),
                                  contentPadding: EdgeInsets.all(10),
                                ),
                                child: ButtonTheme(
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.padded,
                                  child: DropdownButton<String>(
                                    hint: const Text("Category"),
                                    isExpanded: true,
                                    value: selectedValue,
                                    elevation: 16,
                                    underline: DropdownButtonHideUnderline(
                                      child: Container(),
                                    ),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        selectedValue = newValue!;
                                      });

                                      _transaction = TransactionModel(
                                        customerName: _transaction.customerName,
                                        customerId:
                                            widget.transaction['customerId'],
                                        date: _transaction.date,
                                        amount: _transaction.amount,
                                        transactionType: widget
                                            .transaction['transactionType'],
                                        note: _transaction.note,
                                        invoiceNo: _transaction.invoiceNo,
                                        category: selectedValue,
                                        discount: _transaction.discount,
                                        gramPriceInvestDay:
                                            _transaction.gramPriceInvestDay,
                                        gramWeight: _transaction.gramWeight,
                                        id: _transaction.id,
                                        staffId: _transaction.staffId,
                                        branch: _transaction.branch,
                                        staffName: _transaction.staffName,
                                      );
                                    },
                                    items: <String>[
                                      'Gold',
                                      'Silver',
                                    ].map<DropdownMenuItem<String>>(
                                        (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                              TextFormField(
                                initialValue: widget.transaction['invoiceNo'],
                                onSaved: (value) {
                                  _transaction = TransactionModel(
                                    customerName: _transaction.customerName,
                                    customerId:
                                        widget.transaction['customerId'],
                                    date: _transaction.date,
                                    amount: _transaction.amount,
                                    transactionType:
                                        widget.transaction['transactionType'],
                                    note: _transaction.note,
                                    invoiceNo: value!,
                                    category: _transaction.category,
                                    discount: _transaction.discount,
                                    gramPriceInvestDay:
                                        _transaction.gramPriceInvestDay,
                                    gramWeight: _transaction.gramWeight,
                                    id: _transaction.id,
                                    staffId: _transaction.staffId,
                                    branch: _transaction.branch,
                                    staffName: _transaction.staffName,
                                  );
                                },
                                decoration: const InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.red,
                                      width: 1.0,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.black,
                                      width: 1.0,
                                    ),
                                  ),
                                  labelText: 'Enter Invoice No',
                                ),
                              ),
                              TextFormField(
                                //  controller: grampPerdayController,
                                initialValue: gramPriceInvestDay.toString(),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'gramprice';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _transaction = TransactionModel(
                                    customerName: _transaction.customerName,
                                    customerId: _transaction.customerId,
                                    date: _transaction.date,
                                    amount: _transaction.amount,
                                    transactionType:
                                        _transaction.transactionType,
                                    note: _transaction.note,
                                    invoiceNo: _transaction.invoiceNo,
                                    category: _transaction.category,
                                    discount: _transaction.discount,
                                    staffId: _transaction.staffId,
                                    gramPriceInvestDay: value != ""
                                        ? double.parse(value!)
                                        : double.parse(0.0.toString()),
                                    gramWeight: _transaction.gramWeight,
                                    id: _transaction.id,
                                    branch: _transaction.branch,
                                    staffName: _transaction.staffName,
                                  );
                                },
                                decoration: const InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.red,
                                      width: 1.0,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.black,
                                      width: 1.0,
                                    ),
                                  ),
                                  labelText: 'Enter gram rate',
                                ),
                              ),
                              TextFormField(
                                initialValue: widget.transaction['note'],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Note';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _transaction = TransactionModel(
                                    customerName: _transaction.customerName,
                                    customerId:
                                        widget.transaction['customerId'],
                                    date: _transaction.date,
                                    amount: _transaction.amount,
                                    transactionType:
                                        widget.transaction['transactionType'],
                                    note: value!,
                                    invoiceNo: _transaction.invoiceNo,
                                    category: _transaction.category,
                                    discount: _transaction.discount,
                                    gramPriceInvestDay:
                                        _transaction.gramPriceInvestDay,
                                    gramWeight: _transaction.gramWeight,
                                    id: _transaction.id,
                                    staffId: _transaction.staffId,
                                    branch: _transaction.branch,
                                    staffName: _transaction.staffName,
                                  );
                                },
                                maxLines: 8,
                                decoration: const InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.red,
                                      width: 1.0,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.black,
                                      width: 1.0,
                                    ),
                                  ),
                                  labelText: 'Enter Description',
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  widget.staffType == 1
                                      ? Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .25,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              .05,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              color: Colors.redAccent),
                                          child: TextButton(
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title: Text("Delete"),
                                                    content: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Text(
                                                            "Are you sure you want to delete this transaction?"),
                                                        SizedBox(height: 5),
                                                        TextField(
                                                          controller:
                                                              _reasonController,
                                                          decoration:
                                                              InputDecoration(
                                                            labelText:
                                                                "Reason for delete",
                                                            border:
                                                                OutlineInputBorder(),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        child: Text("Cancel"),
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop(); // Close the dialog
                                                        },
                                                      ),
                                                      TextButton(
                                                        child: Text("Delete"),
                                                        onPressed: () {
                                                          _delete(_reasonController
                                                              .text); // Call the delete function
                                                          Navigator.of(context)
                                                              .pop(); // Close the dialog
                                                        },
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                            child: const Text(
                                              'Delete',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        )
                                      : Container(),
                                  widget.staffType == 1
                                      ? SizedBox(width: 30)
                                      : Container(),
                                  Container(
                                      width: MediaQuery.of(context).size.width *
                                          .25,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              .05,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: Colors.blueGrey),
                                      child: TextButton(
                                        onPressed: isLoad
                                            ? null
                                            : _saveForm, // Disable button when loading
                                        child: isLoad
                                            ? Text('Saving...',
                                                style: TextStyle(
                                                    color: Colors.white))
                                            : Text('Save',
                                                style: TextStyle(
                                                    color: Colors.white)),
                                      )),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : Center(
                child: CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(Colors.blue),
              )));
  }

  bool isLoad = false;
}
