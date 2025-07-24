import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import '../../providers/staff.dart';
import '../home_screen.dart';
import './login_screen.dart';

class PasswordChangeScreen extends StatefulWidget {
  const PasswordChangeScreen({Key? key}) : super(key: key);
  static const routeName = '/password-change-screen';

  @override
  State<PasswordChangeScreen> createState() => _PasswordChangeScreenState();
}

class _PasswordChangeScreenState extends State<PasswordChangeScreen> {
  bool _obscureText = true;
  TextEditingController p1Controller = TextEditingController();
  TextEditingController p2Controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var _isLoading = false;
  var staff;
  var _staff = StaffModel(
    password: '',
    address: '',
    commission: 0,
    id: '',
    location: '',
    phoneNo: '',
    staffName: '',
    token: '',
    type: 0,
    branch:0,
  );
  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  void didChangeDependencies() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      staff = jsonDecode(prefs.getString('staff')!);
    });

    super.didChangeDependencies();
  }

  Future<void> _saveForm() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    try {
      Provider.of<Staff>(context, listen: false)
          .updatePassword(staff['id'], _staff);

      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Succes!'),
          content: Text(' password Change Successfully'),
          actions: <Widget>[
            OutlinedButton(
              child: Text('Okay'),
              onPressed: () {
                Navigator.pushNamed(context, LoginScreen.routeName);
                setState(() {});
              },
            )
          ],
        ),
      );
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
          centerTitle: true,
          elevation: 0,
          title: Text(
            "Change Password",
            style: TextStyle(fontFamily: 'latto', fontWeight: FontWeight.bold),
          ),
        ),
        body: new SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * .3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    TextFormField(
                      controller: p1Controller,
                      validator: (value) {
                        if (value!.isEmpty) return 'Empty';
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
                        labelText: 'Password',
                      ),
                      obscureText: true,
                    ),
                    TextFormField(
                      controller: p2Controller,
                      validator: (value) {
                        if (value!.isEmpty) return 'Empty';
                        if (value != p2Controller.text) return 'Not Match';
                        return null;
                      },
                      onSaved: (value) {
                        _staff = StaffModel(
                          staffName: _staff.staffName,
                          location: _staff.location,
                          address: _staff.address,
                          phoneNo: _staff.phoneNo,
                          password: value!,
                          commission: _staff.commission,
                          id: _staff.id,
                          token: _staff.token,
                          type: _staff.type,
                          branch:_staff.branch
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
                        labelText: 'Password',
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * .5,
                      height: MediaQuery.of(context).size.height * .06,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Color(0xff8a172e),
                      ),
                      child: TextButton(
                        onPressed: () {
                          p1Controller.text == p2Controller.text
                              ? _saveForm()
                              : ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("password Doesn't match")));
                        },
                        child: const Text(
                          'Update',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
