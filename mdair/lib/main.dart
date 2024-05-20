import 'package:flutter/material.dart';
import 'package:mdair/pages/LoginPage.dart';
import 'package:mdair/pages/MyTripPage.dart';
import 'package:mdair/pages/ProfilePage.dart';
import 'package:mdair/pages/TicketSearchPage.dart';
import 'package:mdair/pages/GreetingsPage.dart';
import 'package:mdair/pages/ProfileConstructorPage.dart';
import 'package:provider/provider.dart';

import 'database_helper.dart';

void main() {
  runApp(
    Provider(
      create: (context) => DatabaseHelper.instance,
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.yellow,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  late DatabaseHelper databaseHelper;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    databaseHelper = Provider.of<DatabaseHelper>(context);
    final List<Widget> _widgetOptions = [
      GreetingsPage(),
      TicketSearchPage(),
      MyTripPage(
        onLogin: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
        ProfileConstructorPage()
    ];

    return Scaffold(
      backgroundColor: Colors.white70,
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFF1F1F1F),
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.grey),
            activeIcon: Icon(Icons.home, color: Colors.yellow.shade600),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search, color: Colors.grey),
            activeIcon: Icon(Icons.search, color: Colors.yellow.shade600),
            label: 'Book',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.airplanemode_active, color: Colors.grey),
            activeIcon: Icon(Icons.airplanemode_active, color: Colors.yellow.shade600),
            label: 'My Trips',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Colors.grey),
            activeIcon: Icon(Icons.person, color: Colors.yellow.shade600),
            label:'Profile',
          ),
        ],
        currentIndex:_selectedIndex,
        selectedItemColor : Colors.yellow.shade600,
        unselectedItemColor : Colors.grey,
        onTap:_onItemTapped,
          showUnselectedLabels: true
      ),
    );
  }
}
