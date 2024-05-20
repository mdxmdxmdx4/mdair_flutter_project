import 'package:flutter/material.dart';
import 'package:mdair/pages/AirportCRUPage.dart';
import 'package:mdair/pages/UserRUPage.dart';

import 'FlightCRUPage.dart';
import 'PlaneCRUPage.dart';

class AdminPanelPage extends StatefulWidget {
  const AdminPanelPage({Key? key}) : super(key: key);

  @override
  State<AdminPanelPage> createState() => _AdminPanelPage();
}

class _AdminPanelPage extends State<AdminPanelPage> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = [
    PlaneCRUPage(),
    AirportCRUPage(),
    FlightCRUPage(),
    UserRUPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Panel'),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.flight),
            label: 'Plane',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.connecting_airports_rounded),
            label: 'Airport',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flight_land_rounded),
            label: 'Flight',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Users',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.blueGrey,
        onTap: _onItemTapped,
          showUnselectedLabels: true
      ),
    );
  }
}
