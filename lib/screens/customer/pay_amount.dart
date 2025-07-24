import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../../constant/colors.dart';
import '../../providers/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import '../../providers/transaction.dart';
import 'package:provider/provider.dart';
import '../../providers/collections.dart';
import '../../providers/staff.dart';
import 'package:intl/intl.dart';
import '../../providers/goldrate.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class PayAmountScreen extends StatefulWidget {
  static const routeName = "/pay-amount";
  final String? userid;
  final String? token;
  final double? balance;
  final Map? user;
  final User? dbUser;
  final String? custName;
  const PayAmountScreen(
      {Key? key,
      this.userid,
      this.token,
      this.balance,
      this.dbUser,
      this.user,
      this.custName})
      : super(key: key);

  @override
  _PayAmountScreenState createState() => _PayAmountScreenState();
}

class _PayAmountScreenState extends State<PayAmountScreen> {
  Staff? db;
  Goldrate? dbGoldrate;
  final _formKey = GlobalKey<FormState>();

  DateTime? selectedDate;
  DateTime now = DateTime.now();
  List staffList = [];
  AndroidNotificationChannel? channel;
  FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;
  var _isLoading = false;
  var _isInit = true;
  String selectedValue = 'Gold';
  int? branchId;
  TextEditingController taxCntrl = TextEditingController();
  TextEditingController amcCntrl = TextEditingController();

  List goldrateList = [];
  TextEditingController grampPerdayController = TextEditingController()
    ..text = '0.0';
  var _transaction = TransactionModel(
    id: '',
    customerName: '',
    customerId: '',
    date: DateTime.now(),
    amount: 0,
    transactionType: 0,
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

  var _collection = CollectionModel(
    staffId: '',
    staffname: '',
    recievedAmount: 0,
    paidAmount: 0,
    balance: 0,
    date: DateTime.now(),
    type: 0,
    branch: 0,
  );
  initialise() {
    dbGoldrate = Goldrate();
    dbGoldrate!.initiliase();
    setState(() {
      amcCntrl.text = widget.user!["amc"].toString();
      taxCntrl.text = widget.user!["tax"].toString();
    });
    db = Staff();
    db!.initiliase();
    db!.getAdminStaffToken(branchId!).then((value) => {
          setState(() {
            staffList = value!;

            // isLoading = false;
          })
        });
    dbGoldrate!.read().then((value) => {
          setState(() {
            goldrateList = value!;
            grampPerdayController.text = goldrateList[0]['gram'].toString();
          }),
        });
  }

  var staffDetails;
  int? staffType;
  Future loginData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    staffDetails = jsonDecode(prefs.getString('staff')!);
    staffType = staffDetails['type'];
    setState(() {
      branchId = staffDetails['branch'];
    });
    // print("-------------");
    // print(widget.custName);
    // print(widget.userid!);
    // print(widget.custName);
    // print(widget.userid!);
    _transaction = TransactionModel(
        customerName: widget.custName!,
        customerId: widget.userid!,
        date: selectedDate == null ? DateTime.now() : selectedDate!,
        amount: _transaction.amount,
        transactionType: _transaction.transactionType,
        note: _transaction.note,
        invoiceNo: _transaction.invoiceNo,
        category: selectedValue,
        discount: _transaction.discount,
        staffId: staffDetails['id'],
        gramPriceInvestDay: _transaction.gramPriceInvestDay,
        gramWeight: _transaction.gramWeight,
        id: _transaction.id,
        branch: _transaction.branch,
        staffName: staffDetails['staffName']);
    _collection = CollectionModel(
      staffId: staffDetails['id'],
      staffname: staffDetails['staffName'],
      recievedAmount: _collection.recievedAmount,
      paidAmount: _collection.paidAmount,
      balance: _collection.balance,
      date: selectedDate == null ? DateTime.now() : selectedDate!,
      type: _collection.type,
      branch: branchId!,
    );

    initialise();
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

      print(selectedDate); // Now includes current time
    });
  }

  void listenFCM() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification!;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null && !kIsWeb) {
        flutterLocalNotificationsPlugin!.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel!.id,
              channel!.name,
              // channel!.description,

              icon: 'launch_background',
            ),
          ),
        );
      }
    });
  }

  loadFCM() async {
    if (!kIsWeb) {
      channel = const AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // title
        // 'This channel is used for important notifications.', // description
        importance: Importance.high,
        enableVibration: true,
      );

      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      /// Create an Android Notification Channel.
      ///
      /// We use this channel in the `AndroidManifest.xml` file to override the
      /// default FCM channel to enable heads up notifications.
      await flutterLocalNotificationsPlugin!
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel!);

      /// Update the iOS foreground notification presentation options to allow
      /// heads up notifications.
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

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
    loginData();
    print("=====");
    print(widget.user!["schemeType"]);
    super.initState();

    // initialise();
    requestPermission();
  }

  sendNotification(String title, String token, double amt) async {
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
                  'body': 'Add RS $amt to your account'
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

  sendNotificationToAdmin(String title, double amt) async {
    var token = "";
    var satffname = "";

    if (staffList != null) {
      setState(() {
        token = staffList[0]["token"];
      });
    }
    satffname = staffDetails["staffName"];
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
                  'body': 'Collect amount $amt by $satffname'
                },
                'priority': 'high',
                'data': data,
                'to': "$token"
              }));

      if (response.statusCode == 200) {
        // print("notification is sended");
      } else {
        print("error");
      }
    } catch (e) {}
  }

  // Future _saveForm() async {
  //   if (isLoad) return; // Prevent multiple calls

  //   final isValid = _formKey.currentState!.validate();
  //   if (!isValid) {
  //     setState(() {
  //       isLoad = false;
  //     });
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Please fill all required fields correctly!'),
  //         backgroundColor: useColor.homeIconColor, // Red color for error
  //       ),
  //     );
  //     return;
  //   }
  //   _formKey.currentState!.save();

  //   setState(() {
  //     _isLoading = true;
  //   });
  //   try {
  //     _collection = CollectionModel(
  //       staffId: _collection.staffId,
  //       staffname: _collection.staffname,
  //       recievedAmount: _transaction.amount,
  //       paidAmount: _collection.paidAmount,
  //       balance: _collection.balance,
  //       date: selectedDate == null
  //           ? DateTime(now.year, now.month, now.day)
  //           : selectedDate!,
  //       type: 0,
  //       branch: branchId!,
  //       // type 0 is recive amount
  //     );
  //     Provider.of<TransactionProvider>(context, listen: false)
  //         .create(
  //       _transaction,
  //     )
  //         .then((val) {
  //       var data;
  //       setState(() {
  //         data = val;
  //       });
  //       print(data);
  //       Provider.of<Collection>(context, listen: false)
  //           .create(_collection, data[3])
  //           .then(((value) {}));
  //       // printReceipt("Recieve", widget.custName!, _transaction.amount, value);
  //       setState(() {});
  //       print(widget.token);
  //       if (widget.token != null) {
  //         sendNotification(
  //             "Transaction Completed", widget.token!, _transaction.amount);
  //       }

  //       final snackBar = SnackBar(content: const Text("add Successfully...."));

  //       ScaffoldMessenger.of(context).showSnackBar(snackBar);
  //       Navigator.pop(context, true);
  //     });
  //   } catch (err) {
  //     setState(() {
  //       isLoad = false;
  //     });
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
  //   setState(() {
  //     _isLoading = false;
  //   });
  // }

  Future<void> _saveForm() async {
    if (isLoad) return; // Prevent multiple taps
    setState(() => isLoad = true); // Set before validation

    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      setState(() => isLoad = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all required fields correctly!'),
          backgroundColor: useColor.homeIconColor, // Red color for error
        ),
      );
      return;
    }

    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    try {
      _collection = CollectionModel(
        staffId: _collection.staffId,
        staffname: _collection.staffname,
        recievedAmount: _transaction.amount,
        paidAmount: _collection.paidAmount,
        balance: _collection.balance,
        date: selectedDate ?? DateTime.now(),
        type: 0,
        branch: branchId!,
      );
      // print(selectedDate);
      // Await the transaction creation
      var data = await Provider.of<TransactionProvider>(context, listen: false)
          .create(_transaction, double.parse(taxCntrl.text),
              double.parse(amcCntrl.text));

      // print(data);

      // Await collection creation
      await Provider.of<Collection>(context, listen: false)
          .create(_collection, data[3]);

      if (widget.token != null) {
        sendNotification(
            "Transaction Completed", widget.token!, _transaction.amount);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Added Successfully...."),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
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
        isLoad = false; // Reset flag in finally block
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        backgroundColor: Colors.blueGrey.shade50,
        appBar: AppBar(
          backgroundColor: useColor.homeIconColor,
          title: Text('Reciept'),
          actions: [],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Container(
              // height: 700,
              child: new SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                          "Recieve Staff : ${staffDetails != null ? staffDetails['staffName'] : ""}"),
                      SizedBox(
                        height: 10,
                      ),
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
                                  ? DateTime.now()
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
                              gramPriceInvestDay:
                                  _transaction.gramPriceInvestDay,
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
                      SizedBox(
                        height: 30,
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
                                ? DateTime.now()
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
                      SizedBox(
                        height: 30,
                      ),
                      TextFormField(
                        controller: grampPerdayController,
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
                            date: selectedDate == null
                                ? DateTime.now()
                                : selectedDate!,
                            amount: _transaction.amount,
                            transactionType: _transaction.transactionType,
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
                      SizedBox(
                        height: 10,
                      ),
                      if (widget.user!["schemeType"] == "Swarna Samridhi")
                        TextFormField(
                          keyboardType: TextInputType.number,
                          // initialValue: widget.user!['tax'].toString(),
                          controller: taxCntrl,

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
                            labelText: 'Tax',
                          ),
                        ),
                      if (widget.user!["schemeType"] == "Swarna Samridhi")
                        SizedBox(
                          height: 10,
                        ),
                      if (widget.user!["schemeType"] == "Swarna Samridhi")
                        TextFormField(
                          keyboardType: TextInputType.number,
                          // initialValue: widget.user!['amc'].toString(),
                          controller: amcCntrl,

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
                            labelText: 'AMC',
                          ),
                        ),
                      if (widget.user!["schemeType"] == "Swarna Samridhi")
                        SizedBox(
                          height: 30,
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
                      SizedBox(
                        height: 30,
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                            width: MediaQuery.of(context).size.width * .4,
                            height: MediaQuery.of(context).size.height * .06,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: useColor.homeIconColor),
                            child: TextButton(
                              onPressed: isLoad
                                  ? null
                                  : _saveForm, // Disable button when loading
                              child: isLoad
                                  ? Text('Saving...',
                                      style: TextStyle(color: Colors.white))
                                  : Text('Save',
                                      style: TextStyle(color: Colors.white)),
                            )),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        )
        // ),
        );
  }

  bool isLoad = false;
}
