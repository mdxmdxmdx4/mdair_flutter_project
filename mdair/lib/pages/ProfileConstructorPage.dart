import 'package:flutter/material.dart';
import 'package:mdair/pages/LoginPage.dart';
import 'package:mdair/pages/ProfilePage.dart';
import 'package:provider/provider.dart';

import 'package:mdair/database_helper.dart';

class ProfileConstructorPage extends StatefulWidget {
  @override
  _ProfileConstructorPageState createState() => _ProfileConstructorPageState();
}

class _ProfileConstructorPageState extends State<ProfileConstructorPage> {
  bool showFirstLayout = true;
  late DatabaseHelper databaseHelper;

  void toggleLayout() {
    setState(() {
      showFirstLayout = !showFirstLayout;
    });
  }

  @override
  Widget build(BuildContext context) {
    databaseHelper = Provider.of<DatabaseHelper>(context);
    if(databaseHelper.getLoggedInUser() != null){
      showFirstLayout = false;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Profile'),
        backgroundColor: Colors.yellow.shade400,
      ),
      body: Center(
        child: showFirstLayout
            ? LoginPage(toggleCallback: toggleLayout)
            : ProfilePage(toggleCallback: toggleLayout),
      ),
    );
  }
}

