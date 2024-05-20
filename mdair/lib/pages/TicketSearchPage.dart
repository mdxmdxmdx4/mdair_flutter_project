import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mdair/pages/LoginPage.dart';
import 'package:mdair/database_helper.dart';
import 'package:provider/provider.dart';

import 'SearchResultPage.dart';
import 'package:mdair/models/flight_info.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';

class TicketSearchPage extends StatefulWidget {
  @override
  _TicketSearchPageState createState() => _TicketSearchPageState();
}

class _TicketSearchPageState extends State<TicketSearchPage> {
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  String _departureAirport = '';
  String _destinationAirport = '';
  DateTime? _departureDate;
  DateTime? _returnDate;
  bool _isRoundTrip = false;
  int _passengerCount = 1;
  String _classType = 'Regular';
  late DatabaseHelper databaseHelper;

  @override
  Widget build(BuildContext context) {
    databaseHelper = Provider.of<DatabaseHelper>(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Flight Search'),
          backgroundColor: Colors.yellow.shade400,
          bottom: TabBar(
            indicatorColor: Colors.red,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            dividerColor: Colors.grey,
            tabs: [
              Tab(text: 'One-way',),
              Tab(text: 'Return'),
            ],
            onTap: (index) => setState(() => _isRoundTrip = index == 1),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Card(
                    color: Colors.grey.shade100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        children: <Widget>[
                          TextField(
                            controller: _fromController,
                            decoration: InputDecoration(
                              labelText: 'From',
                              hintText: 'Enter departure city',
                              labelStyle: TextStyle(fontSize: 20),
                            ),
                            onChanged: (value) => _departureAirport = value,
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(height: 8),
                          TextField(
                            controller: _toController,
                            decoration: InputDecoration(
                              labelText: 'To',
                              hintText: 'Enter destination city',
                              labelStyle: TextStyle(fontSize: 20),
                            ),
                            onChanged: (value) => _destinationAirport = value,
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    bottom: 0,
                    child: Transform.rotate(
                        angle: 90 * 3.141592653589793 / 180,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          minimumSize: Size(1, 1),
                          backgroundColor: Colors.yellow.shade400
                      ),
                       child: Icon(Icons.swap_horiz, size: 30, color: Colors.blueGrey,),
                        onPressed: () {
                        _swapLocations();
                      },
                    ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Card(
                color: Colors.grey.shade100,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: <Widget>[
                      _buildDatePicker(context, 'Departure Date', _departureDate,
                              (date) => setState(() => _departureDate = date)),
                      if (_isRoundTrip)
                        _buildDatePicker(context, 'Return Date', _returnDate,
                                (date) => setState(() => _returnDate = date)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          DropdownButton<int>(
                            value: _passengerCount,
                            items: [1, 2, 3, 4, 5].map((int value) {
                              return DropdownMenuItem<int>(
                                value: value,
                                child: Text('$value Passenger(s)'),
                              );
                            }).toList(),
                            onChanged: (value) =>
                                setState(() => _passengerCount = value ?? 1),
                          ),
                          DropdownButton<String>(
                            value: _classType,
                            items: ['Regular', 'Business'].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (value) =>
                                setState(() => _classType = value ?? 'Economy'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: _isRoundTrip ? 78 : 126),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: Colors.yellow.shade400
                ),
                onPressed: () async{
                  if(_departureDate != null && _departureAirport.length > 3 && _destinationAirport.length > 3) {
                    databaseHelper.departureCity = _departureAirport;
                    databaseHelper.destingationCity = _destinationAirport;
                    databaseHelper.passengersCount = _passengerCount;
                    _searchFlights(databaseHelper);
                  }
                  else
                    showAlertDialog(context, 'Search Failure', 'Please, fill all input fields!');
                },
                child: Text('Find Flights', style: TextStyle(color: Colors.black, fontSize: 16),),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _swapLocations() {
    String temp = _fromController.text;
    _fromController.text = _toController.text;
    _toController.text = temp;
    temp = _destinationAirport;
    _destinationAirport = _departureAirport;
    _departureAirport = temp;
  }

  Widget _buildDatePicker(BuildContext context, String label, DateTime? date,
      Function(DateTime?) onDateSelected) {
    return Row(
      children: <Widget>[
        Text(label),
        TextButton(
          onPressed: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: date ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(2100),
            );
            onDateSelected(pickedDate);
          },
          child: Text(date != null
              ? DateFormat('yyyy-MM-dd').format(date)
              : 'Select Date'),
        ),
      ],
    );
  }

  void _searchFlights(DatabaseHelper dbhelper) async {
    var ids = await dbhelper.findFlights(_departureAirport, _destinationAirport, _departureDate!, _passengerCount);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) =>
          SearchResultPage(databaseHelper, _departureAirport, _destinationAirport, _departureDate, _returnDate, _isRoundTrip,_passengerCount,_classType)),
    );
  }
}
