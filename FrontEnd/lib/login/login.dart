import 'package:attendance/login/loginForm.dart';
import 'package:attendance/login/logo.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});
 @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          reverse: true,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: const <Widget>[
              Logo(),
              SizedBox(height:30),
              SizedBox(
                height:300,
                width:400,
                child: LoginForm()) 
            ],
          ),
        ),
      )
    );
  }
}