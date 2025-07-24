import 'package:flutter/material.dart';
import '../../widget/login_form.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login-screen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Theme.of(context).primaryColor,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 100,
              ),
              Container(
                width: 250,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Image.asset(
                      "assets/images/icon1.png",
                      // 'assets/images/thrissur app.png',
                      fit: BoxFit.contain,
                      height: MediaQuery.of(context).size.height * .25,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 80,
              ),
              Container(child: LoginForm()),
            ],
          ),
        ),
      ),
    );
  }
}
