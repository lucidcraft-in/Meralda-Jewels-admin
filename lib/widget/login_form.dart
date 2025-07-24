import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/staff.dart';
import '../screens/home_screen.dart';
import '../screens/staff/create_staff_screen.dart';

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  Staff? db;

  List staffList = [];
  List filterList = [];
  var index;

  readData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.containsKey("logPhone"))
      setState(() {
        _staffPhoneNo.text = sharedPreferences.getString("logPhone") ?? "";
        _passwordController.text =
            sharedPreferences.getString("logPassword") ?? "";
      });
  }

  initialise() {
    db = Staff();
    db!.initiliase();
    db!.readforLogin().then((value) {
      if (value != null) {
        setState(() {
          staffList = value!;
          print(staffList);
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    readData();
    initialise();
  }

  TextEditingController _staffPhoneNo = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  final _form = GlobalKey<FormState>();
  TextStyle style = TextStyle(
    fontFamily: 'latto',
    fontSize: 20.0,
    color: Colors.white,
  );

  login() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    filterList = staffList
        .where((element) => (element['phoneNo']
            .toLowerCase()
            .contains(_staffPhoneNo.text.toLowerCase())))
        .toList();

    if (filterList.isNotEmpty &&
        filterList[0]['phoneNo'] == _staffPhoneNo.text) {
      if (filterList[0]['password'] == _passwordController.text) {
        sharedPreferences.setString("staff", json.encode(filterList[0]));
        sharedPreferences.setString("logPhone", filterList[0]["phoneNo"]);
        sharedPreferences.setString("logPassword", filterList[0]['password']);
        if (filterList[0]["type"] == 1) {
          if (filterList[0]["token"] == "" || filterList[0]["token"] == null) {
            String? token = await FirebaseMessaging.instance.getToken();

            FirebaseFirestore.instance
                .collection('staffs')
                .doc(filterList[0]['id'])
                .set({'token': token}, SetOptions(merge: true));
          }
        }
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (BuildContext context) => HomeScreen()),
            (Route<dynamic> route) => false);
        setState(() {
          isClick = false;
        });
      } else {
        setState(() {
          isClick = false;
        });
        final snackBar = SnackBar(
          content: const Text('Wrong password!'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } else {
      setState(() {
        isClick = false;
      });
      final snackBar = SnackBar(
        content: const Text('Staff phone number is invalid!'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * .4,
            child: Form(
              key: _form,
              child: Container(
                padding: EdgeInsets.only(left: 25, right: 25),
                child: Column(children: <Widget>[
                  TextFormField(
                    controller: _staffPhoneNo,
                    textAlign: TextAlign.left,
                    // controller: _emailController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please provide Valid Phone No.';
                      }
                      return null;
                    },
                    obscureText: false,
                    style: TextStyle(
                        color: const Color.fromARGB(255, 62, 62, 62),
                        fontSize: 18),
                    decoration: InputDecoration(
                      hintText: "Phone Number",
                      hintStyle: TextStyle(
                          color: const Color.fromARGB(179, 152, 99, 99)),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white70),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.orangeAccent),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: _passwordController,
                    textAlign: TextAlign.left,
                    // controller: _emailController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please provide a value.';
                      }
                      return null;
                    },
                    obscureText: false,
                    style: TextStyle(
                        color: const Color.fromARGB(255, 62, 62, 62),
                        fontSize: 18),
                    decoration: InputDecoration(
                      hintText: "Password",
                      hintStyle: TextStyle(
                          color: const Color.fromARGB(179, 152, 99, 99)),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white70),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.orangeAccent),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  Material(
                    elevation: 1.0,
                    borderRadius: BorderRadius.circular(12.0),
                    color: Color(0xFF073531),
                    child: MaterialButton(
                      minWidth: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                      onPressed: () {
                        setState(() {
                          isClick = true;
                        });
                        isClick ? login() : null;
                      },
                      child: Text(!isClick ? "Login" : "Login....",
                          textAlign: TextAlign.center,
                          style: style.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  if (staffList.isEmpty)
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CreateStaffScreen(
                                      staffType: 1,
                                    ))).then((onValue) {
                          initialise();
                        });
                      },
                      child: Text(
                        "Register as an admin",
                        style: TextStyle(color: Colors.black),
                      ),
                    )
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool isClick = false;
}
