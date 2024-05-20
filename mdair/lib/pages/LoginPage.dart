import 'package:flutter/material.dart';
import 'package:mdair/pages/RegistrationPage.dart';
import 'package:provider/provider.dart';

import '../database_helper.dart';

class LoginPage extends StatelessWidget {

  final VoidCallback toggleCallback;

  LoginPage({required this.toggleCallback});

  String usernname = '';
  String password = '';

  late DatabaseHelper databaseHelper;
  @override
  Widget build(BuildContext context) {
    databaseHelper = Provider.of<DatabaseHelper>(context);
    databaseHelper.getLoggedInUser();
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 35.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text.rich(
                TextSpan(
                  text: 'Welcome Back',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(
                      text: ' !',
                      style: TextStyle(color: Colors.yellow.shade400, fontSize: 36, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: TextField(
                  onChanged: (value) => usernname = value,
                  decoration: InputDecoration(
                    labelText: 'Email or Username',
                    labelStyle: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: TextField(
                  onChanged: (value) => password = value,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: Colors.grey),
                  ),
                  obscureText: true,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: ElevatedButton(
                  onPressed: () async {
                    if((usernname.length > 2) && (password.length > 2) ) {
                      await databaseHelper.authenticateUser(
                          usernname, password);
                      if(databaseHelper.getLoggedInUser() != null) {
                        toggleCallback();
                      }
                      else{
                        showAlertDialog(context, 'Login Failuer', 'Ivalid credentials');
                      }
                    }
                    else{
                        showAlertDialog(context, 'Login Error', 'Invalid credentials, check your input!');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    backgroundColor: Colors.yellow.shade400
                  ),
                  child: Text('Log In',
                  style: TextStyle(color: Colors.black,
                      fontSize: 18),
                  ),
                ),
              ),
              Spacer(),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegistrationPage()),
                  );
                },
                child: Text('Don\'t have an account? Sign up, click here!',
                style: TextStyle(fontSize: 14, color: Colors.black54)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



void showAlertDialog(BuildContext context, errorTitle, errorMessage) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(errorTitle),
        content: Text(errorMessage),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('ОК'),
          ),
        ],
      );
    },
  );
}
