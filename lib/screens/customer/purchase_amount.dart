import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../../constant/colors.dart';
import '../../providers/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import '../../providers/transaction.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class PurchaseAmountScreen extends StatefulWidget {
  static const routeName = "/purchase-amount";
  const PurchaseAmountScreen(
      {Key? key,
      this.userid,
      this.token,
      this.balance,
      this.dbUser,
      this.user,
      this.custName})
      : super(key: key);

  final String? userid;
  final String? token;
  final double? balance;
  final Map? user;
  final User? dbUser;
  final String? custName;

  @override
  _PurchaseAmountScreenState createState() => _PurchaseAmountScreenState();
}

class _PurchaseAmountScreenState extends State<PurchaseAmountScreen> {
  final _formKey = GlobalKey<FormState>();
  var Staff;
  AndroidNotificationChannel? channel;
  FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;
  var _isLoading = false;
  var _isInit = true;
  String selectedValue = 'Gold';
  DateTime? selectedDate;
  DateTime now = DateTime.now();
  var _transaction = TransactionModel(
    id: '',
    customerName: '',
    customerId: '',
    date: DateTime.now(),
    amount: 0,
    transactionType: 1,
    note: '',
    invoiceNo: '',
    category: '',
    discount: 0,
    staffId: '',
    gramPriceInvestDay: 0,
    gramWeight: 0,
    branch: 0,
    staffName: '',
  );

  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // print("user granted permission");
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      // print("user granted provisional permission");
    } else {
      // print('user declained or has not accepted permission');
    }
  }

  @override
  void initState() {
    super.initState();

    requestPermission();
  }

  sendNotification(String title, String token, double amt) async {
    // print("check notification");
    // print(token);
    final data = {
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      'id': 1,
      'status': 'done',
      'message': title,
    };
    try {
      http.Response response =
          await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
              headers: <String, String>{
                'Content-Type': 'application/json',
                'Authorization':
                    'key=AAAAYxF4bUQ:APA91bE-vvHQIfOI27flf420DjMEb1fkc0rlrFLz6N5HqVKvstpVEl-HzVmubii6ZDHDO5AYHVdvauIbGC0T-dS9yXskwgi4XVd38HOaix_hwBt7riU3tjDBdYx4mGAgglXPP3cEp5jX'
              },
              body: jsonEncode(<String, dynamic>{
                'notification': <String, dynamic>{
                  'title': title,
                  'body': 'Reduce RS  $amt from your account'
                },
                'priority': 'high',
                'data': data,
                'to': "$token"
              }));

      if (response.statusCode == 200) {
        // print("notification is sended");
      } else {
        // print("error");
      }
    } catch (e) {}
  }

  @override
  void didChangeDependencies() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      Staff = jsonDecode(prefs.getString('staff')!);
    });
    if (_isInit) {
      // final userId = ModalRoute.of(context).settings.arguments as String;

      _transaction = TransactionModel(
          customerName: widget.custName!,
          customerId: widget.userid!,
          date: selectedDate == null
              ? DateTime(now.year, now.month, now.day)
              : selectedDate!,
          amount: _transaction.amount,
          transactionType: _transaction.transactionType,
          note: _transaction.note,
          invoiceNo: _transaction.invoiceNo,
          category: selectedValue,
          discount: _transaction.discount,
          staffId: Staff['id'],
          gramPriceInvestDay: _transaction.gramPriceInvestDay,
          gramWeight: _transaction.gramWeight,
          id: _transaction.id,
          branch: _transaction.branch,
          staffName: Staff['staffName']);
    }
    _isInit = false;

    super.didChangeDependencies();
  }

  // Future<void> _saveForm() async {
  //   final isValid = _formKey.currentState!.validate();
  //   if (!isValid) {
  //     return;
  //   }
  //   _formKey.currentState!.save();
  //   setState(() {
  //     _isLoading = true;
  //     isLoad = false;
  //   });
  //   try {
  //     Provider.of<TransactionProvider>(context, listen: false)
  //         .create(
  //       _transaction,
  //     )
  //         .then((value) {
  //       setState(() {});
  //       sendNotification(
  //           "Transaction Completed", widget.token!, _transaction.amount);
  //       final snackBar = SnackBar(content: const Text("add Successfully...."));

  //       ScaffoldMessenger.of(context).showSnackBar(snackBar);

  //       Navigator.of(context).pop(true);
  //     });
  //   } catch (err) {
  //     print(err);
  //     await showDialog(
  //       context: context,
  //       builder: (ctx) => AlertDialog(
  //         title: Text('An error occurred!'),
  //         content: Text('Something went wrong. ${err}'),
  //         actions: <Widget>[
  //           OutlinedButton(
  //             child: Text('Okay'),
  //             onPressed: () {
  //               Navigator.of(ctx).pop();
  //             },
  //           )
  //         ],
  //       ),
  //     );
  //   }
  //   // setState(() {
  //   //   _isLoading = false;
  //   // });
  // }

  Future<void> _saveForm() async {
    if (isLoad) return; // Prevent multiple taps
    setState(() => isLoad = true); // Set before validation

    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      setState(() => isLoad = false); // Reset on invalid form

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all required fields correctly!'),
          backgroundColor: Colors.red, // Red for errors
        ),
      );
      return;
    }

    _formKey.currentState!.save();
    setState(() => _isLoading = true);

    try {
      await Provider.of<TransactionProvider>(context, listen: false)
          .create(_transaction, 0, 0);

      if (widget.token != null) {
        sendNotification(
            "Transaction Completed", widget.token!, _transaction.amount);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Added Successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop(true);
    } catch (err) {
      print(err);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Something went wrong: $err'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
        isLoad = false; // Reset after process
      });
    }
  }

  _selectDate() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate == null) return;

      // Get the current time
      TimeOfDay currentTime = TimeOfDay.now();

      // Merge picked date with current time
      DateTime finalDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        currentTime.hour,
        currentTime.minute,
        0, // Keeping seconds as 0
      );

      setState(() {
        now = finalDateTime;
        selectedDate = now;
      });

      // print(selectedDate); // Now includes current time
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blueGrey.shade50,
        appBar: AppBar(
          title: Text('Purchase'),
          backgroundColor: useColor.homeIconColor,
          actions: [],
        ),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * .7,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    TextFormField(
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Amount';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _transaction = TransactionModel(
                            customerName: _transaction.customerName,
                            customerId: _transaction.customerId,
                            date: selectedDate == null
                                ? DateTime(now.year, now.month, now.day)
                                : selectedDate!,
                            amount: value != ""
                                ? double.parse(value!)
                                : double.parse(0.0.toString()),
                            transactionType: _transaction.transactionType,
                            note: _transaction.note,
                            invoiceNo: _transaction.invoiceNo,
                            category: _transaction.category,
                            discount: _transaction.discount,
                            staffId: _transaction.staffId,
                            gramPriceInvestDay: _transaction.gramPriceInvestDay,
                            gramWeight: _transaction.gramWeight,
                            id: _transaction.id,
                            branch: _transaction.branch,
                            staffName: _transaction.staffName);
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
                    TextFormField(
                      onSaved: (value) {
                        _transaction = TransactionModel(
                          customerName: _transaction.customerName,
                          customerId: _transaction.customerId,
                          date: selectedDate == null
                              ? DateTime(now.year, now.month, now.day)
                              : selectedDate!,
                          amount: _transaction.amount,
                          transactionType: _transaction.transactionType,
                          note: _transaction.note,
                          invoiceNo: value!,
                          category: _transaction.category,
                          discount: _transaction.discount,
                          staffId: _transaction.staffId,
                          gramPriceInvestDay: _transaction.gramPriceInvestDay,
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
                        labelText: 'Enter Invoice No',
                      ),
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Note';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _transaction = TransactionModel(
                          customerName: _transaction.customerName,
                          customerId: _transaction.customerId,
                          date: selectedDate == null
                              ? DateTime(now.year, now.month, now.day)
                              : selectedDate!,
                          amount: _transaction.amount,
                          transactionType: _transaction.transactionType,
                          note: value!,
                          invoiceNo: _transaction.invoiceNo,
                          category: _transaction.category,
                          discount: _transaction.discount,
                          staffId: _transaction.staffId,
                          gramPriceInvestDay: _transaction.gramPriceInvestDay,
                          gramWeight: _transaction.gramWeight,
                          id: _transaction.id,
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
                    GestureDetector(
                      onTap: () async {
                        _selectDate();
                      },
                      child: Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * .074,
                        decoration: BoxDecoration(
                            // color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: Colors.black)),
                        padding: EdgeInsets.only(left: 10, right: 10, top: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 19,
                            ),
                            Text(selectedDate == null
                                ? DateFormat(' MMM dd yyyy').format(now)
                                : DateFormat(' MMM dd yyyy')
                                    .format(selectedDate!)),
                          ],
                        ),
                      ),
                    ),
                    Container(
                        width: MediaQuery.of(context).size.width * .4,
                        height: MediaQuery.of(context).size.height * .07,
                        decoration: BoxDecoration(
                            color: useColor.homeIconColor,
                            borderRadius: BorderRadius.circular(20)),
                        child: TextButton(
                          onPressed: isLoad
                              ? null
                              : _saveForm, // Disable button when processing
                          child: isLoad
                              ? Text('Saving...',
                                  style: TextStyle(color: Colors.white))
                              : Text('Save',
                                  style: TextStyle(color: Colors.white)),
                        ))
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  bool isLoad = false;
}
