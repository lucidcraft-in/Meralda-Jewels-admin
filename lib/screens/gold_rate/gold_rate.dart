import 'package:flutter/material.dart';
import '../../constant/colors.dart';
import 'dart:convert';

import '../../providers/goldrate.dart';
import '../../providers/user.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GoldRateScreen extends StatefulWidget {
  static const routeName = '/gold-rate';
  const GoldRateScreen({Key? key}) : super(key: key);

  @override
  _GoldRateScreenState createState() => _GoldRateScreenState();
}

class _GoldRateScreenState extends State<GoldRateScreen> {
  final _formKey = GlobalKey<FormState>();
  AndroidNotificationChannel? channel;
  FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;
  final pavanController = TextEditingController();
  final upController = TextEditingController();
  final downController = TextEditingController();
  final gramController = TextEditingController();
  final eighteenKCntrl = TextEditingController();
  var _isLoading = false;
  var _goldRate = GoldrateModel(
    id: '',
    gram: 0,
    pavan: 0,
    up: 0,
    down: 0,
  );
  Goldrate? db;
  User? dbUser;
  double oldGoldRate = 0;
  List goldrateList = [];
  List userList = [];
  int? branchId;
  initialise() {
    db = Goldrate();
    dbUser = User();
    db!.initiliase();
    db!.read().then((value) {
      print(value);
      if (value != null) {
        setState(() {
          goldrateList = value!;
          gramController.text = goldrateList[0]['gram'].toString();
          pavanController.text = goldrateList[0]['pavan'].toString();
          upController.text = goldrateList[0]['up'].toString();
          downController.text = goldrateList[0]['down'].toString();
          eighteenKCntrl.text = goldrateList[0]['18gram'].toString();

          oldGoldRate = goldrateList[0]['gram'].toDouble();
        });
      }
    });
    dbUser!.read(branchId!).then((value) => {
          if (value != null)
            {
              setState(() {
                userList = value!;
              })
            }
        });
  }

  @override
  void initState() {
    loginData();
    super.initState();

    requestPermission();
  }

  double pavanCalc = 0;
  double newGramDiff = 0;
  double upCalc = 0;
  double downCalc = 0;
  goldrateCalculate(gramVal) {
    pavanCalc = gramVal * 8;
    newGramDiff = oldGoldRate - gramVal;

    if (newGramDiff < 0) {
      upCalc = newGramDiff.abs();
      downCalc = 0.0;
    } else if (newGramDiff > 0) {
      downCalc = newGramDiff;
      upCalc = 0.0;
    } else if (newGramDiff == 0) {
      downCalc = 0;
      upCalc = 0;
    }
    setState(() {
      // initialpavanValue = pavanCalc;
      pavanController.text = pavanCalc.toString();
      upController.text = upCalc.toString();
      downController.text = downCalc.toString();
    });

    _goldRate = GoldrateModel(
      id: _goldRate.id,
      gram: _goldRate.gram,
      pavan: pavanCalc,
      up: upCalc,
      down: downCalc,
    );
  }

  late int staffType;
  Future loginData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var Staff = jsonDecode(prefs.getString('staff')!);
    setState(() {
      staffType = Staff['type'];
      branchId = Staff['branch'];
      initialise();
    });
  }

  void listenFCM() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
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
              // TODO add a proper drawable resource to android, for now using
              //      one that already exists in example app.
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
      print("user granted permission");
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print("user granted provisional permission");
    } else {
      print('user declained or has not accepted permission');
    }
  }

  sendNotification(String title, String token) async {
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
                  'body':
                      'Today gold rate ${goldrateList[0]['pavan'].toString()}'
                },
                'priority': 'high',
                'data': data,
                'to': "$token"
              }));

      if (response.statusCode == 200) {
        print("notification is sended");
      } else {
        print("error");
      }
    } catch (e) {}
  }

  Future<void> _saveForm(String id) async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    try {
      Provider.of<Goldrate>(context, listen: false)
          .update(id, _goldRate, double.parse(eighteenKCntrl.text));
      if (userList.length > 0) {
        for (var i = 0; i < userList.length; i++) {
          if (userList[i]["token"] != "") {
            sendNotification("Gold Rate Updated", userList[i]["token"]);
          }
        }
        initialise();
      }

      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Succes!'),
          content: Text('Updated Successfully'),
          actions: <Widget>[
            OutlinedButton(
              child: Text('Okay'),
              onPressed: () {
                Navigator.pushReplacementNamed(
                    context, GoldRateScreen.routeName);
              },
            )
          ],
        ),
      );
    } catch (err) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blueGrey.shade50,
        appBar: AppBar(
          backgroundColor: useColor.homeIconColor,
          title: Text('Gold Rate'),
          actions: [],
        ),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Container(
            child: goldrateList.isNotEmpty
                ? new SingleChildScrollView(
                    child: Column(
                      children: [
                        Form(
                          key: _formKey,
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    "Update Amount 22K",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 10),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      width: double.infinity,
                                      height: 50,
                                      child: TextFormField(
                                        keyboardType: TextInputType.number,
                                        initialValue:
                                            goldrateList[0]['gram'].toString(),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Rate in gram';
                                          }
                                          return null;
                                        },
                                        onChanged: (value) {
                                          if (value != "") {}
                                          goldrateCalculate(
                                              double.tryParse(value));
                                        },
                                        onSaved: (value) {
                                          _goldRate = GoldrateModel(
                                            gram: value != ""
                                                ? double.parse(value!)
                                                : double.parse(0.0.toString()),
                                            pavan: _goldRate.pavan,
                                            up: _goldRate.up,
                                            down: _goldRate.down,
                                            id: _goldRate.id,
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
                                          labelText: 'Enter rate in gram',
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      width: double.infinity,
                                      height: 50,
                                      child: TextFormField(
                                        controller: pavanController,
                                        keyboardType: TextInputType.number,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Rate in 8 gram';
                                          }
                                          return null;
                                        },
                                        onSaved: (value) {
                                          _goldRate = GoldrateModel(
                                            gram: _goldRate.gram,
                                            pavan: value != ""
                                                ? double.parse(value!)
                                                : double.parse(0.0.toString()),
                                            up: _goldRate.up,
                                            down: _goldRate.down,
                                            id: _goldRate.id,
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
                                          labelText: 'Enter rate 8 in gram',
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: <Widget>[
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    .4,
                                                height: 50,
                                                child: TextFormField(
                                                  controller: upController,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  // initialValue: goldrateList[0]
                                                  //             ['up'] !=
                                                  //         null
                                                  //     ? goldrateList[0]['up']
                                                  //         .toString()
                                                  //     : 0.0.toString(),
                                                  onSaved: (value) {
                                                    _goldRate = GoldrateModel(
                                                      gram: _goldRate.gram,
                                                      pavan: _goldRate.pavan,
                                                      up: value != ""
                                                          ? double.parse(value!)
                                                          : double.parse(
                                                              0.0.toString()),
                                                      down: _goldRate.down,
                                                      id: _goldRate.id,
                                                    );
                                                  },
                                                  decoration:
                                                      const InputDecoration(
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: Colors.red,
                                                        width: 1.0,
                                                      ),
                                                    ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: Colors.black,
                                                        width: 1.0,
                                                      ),
                                                    ),
                                                    labelText: 'Up',
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 10),
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    .3,
                                                height: 50,
                                                child: TextFormField(
                                                  controller: downController,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  // initialValue: goldrateList[0]
                                                  //             ['down'] !=
                                                  //         null
                                                  //     ? goldrateList[0]['down']
                                                  //         .toString()
                                                  //     : 0.0.toString(),
                                                  onSaved: (value) {
                                                    _goldRate = GoldrateModel(
                                                      gram: _goldRate.gram,
                                                      pavan: _goldRate.pavan,
                                                      up: _goldRate.up,
                                                      down: value != ""
                                                          ? double.parse(value!)
                                                          : double.parse(
                                                              0.0.toString()),
                                                      id: _goldRate.id,
                                                    );
                                                  },
                                                  decoration:
                                                      const InputDecoration(
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: Colors.red,
                                                        width: 1.0,
                                                      ),
                                                    ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: Colors.black,
                                                        width: 1.0,
                                                      ),
                                                    ),
                                                    labelText: 'Down',
                                                  ),
                                                ),
                                              )
                                            ])
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    "Update Amount 18K",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 10),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      width: double.infinity,
                                      height: 50,
                                      child: TextFormField(
                                        controller: eighteenKCntrl,
                                        keyboardType: TextInputType.number,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Rate of 18K gram';
                                          }
                                          return null;
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
                                          labelText: 'Enter rate in gram',
                                        ),
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .4,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                .06,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            color: useColor.homeIconColor),
                                        child: TextButton(
                                          onPressed: () {
                                            _saveForm(goldrateList[0]['id']);
                                          },
                                          child: const Text(
                                            'Update',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            Form(
                              key: _formKey,
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.white,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      Text(
                                        "Add Amount 22K",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 10),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          width: double.infinity,
                                          height: 50,
                                          child: TextFormField(
                                            keyboardType: TextInputType.number,
                                            controller: gramController,
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Rate in gram';
                                              }
                                              return null;
                                            },
                                            onChanged: (value) {
                                              if (value != "") {}
                                              goldrateCalculate(
                                                  double.tryParse(value));
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
                                              labelText: 'Enter rate in gram',
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          width: double.infinity,
                                          height: 50,
                                          child: TextFormField(
                                            controller: pavanController,
                                            keyboardType: TextInputType.number,
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Rate in 8 gram';
                                              }
                                              return null;
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
                                              labelText: 'Enter rate 8 in gram',
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          children: <Widget>[
                                            Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: <Widget>[
                                                  Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            .4,
                                                    height: 50,
                                                    child: TextFormField(
                                                      controller: upController,
                                                      keyboardType:
                                                          TextInputType.number,
                                                      // initialValue: goldrateList[0]
                                                      //             ['up'] !=
                                                      //         null
                                                      //     ? goldrateList[0]['up']
                                                      //         .toString()
                                                      //     : 0.0.toString(),

                                                      decoration:
                                                          const InputDecoration(
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color: Colors.red,
                                                            width: 1.0,
                                                          ),
                                                        ),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color: Colors.black,
                                                            width: 1.0,
                                                          ),
                                                        ),
                                                        labelText: 'Up',
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 10),
                                                  Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            .3,
                                                    height: 50,
                                                    child: TextFormField(
                                                      controller:
                                                          downController,
                                                      keyboardType:
                                                          TextInputType.number,
                                                      // initialValue: goldrateList[0]
                                                      //             ['down'] !=
                                                      //         null
                                                      //     ? goldrateList[0]['down']
                                                      //         .toString()
                                                      //     : 0.0.toString(),

                                                      decoration:
                                                          const InputDecoration(
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color: Colors.red,
                                                            width: 1.0,
                                                          ),
                                                        ),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color: Colors.black,
                                                            width: 1.0,
                                                          ),
                                                        ),
                                                        labelText: 'Down',
                                                      ),
                                                    ),
                                                  )
                                                ])
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        "Add Amount 18K",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 10),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          width: double.infinity,
                                          height: 50,
                                          child: TextFormField(
                                            keyboardType: TextInputType.number,
                                            controller: eighteenKCntrl,
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
                                              labelText: 'Enter rate in gram',
                                            ),
                                          ),
                                        ),
                                      ),
                                      Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .4,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                .06,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                color: useColor.homeIconColor),
                                            child: TextButton(
                                              onPressed: () {
                                                final isValid = _formKey
                                                    .currentState!
                                                    .validate();
                                                if (!isValid) {
                                                  return;
                                                }

                                                _goldRate = GoldrateModel(
                                                  gram: double.parse(
                                                      gramController.text),
                                                  pavan: double.parse(
                                                      pavanController.text),
                                                  up: double.parse(
                                                      upController.text),
                                                  down: double.parse(
                                                      downController.text),
                                                  id: "",
                                                );
                                                Provider.of<Goldrate>(context,
                                                        listen: false)
                                                    .create(
                                                        _goldRate,
                                                        double.parse(
                                                            eighteenKCntrl
                                                                .text))
                                                    .then((onValue) {
                                                  initialise();
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(const SnackBar(
                                                          content: Text(
                                                              'Successfully add goldrate')));
                                                });
                                              },
                                              child: const Text(
                                                'Add Goldrate',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
          ),
        ));
  }
}
