import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:mdair/models/plane.dart';

import '../database_helper.dart';
import '../models/flight.dart';

class FlightCRUPage extends StatefulWidget {
  @override
  _FlightAdminPanelState createState() => _FlightAdminPanelState();
}

String dropdownValue = 'City';
String filterValue = "";
int idToSearchFlight = 0;

Flight flightToInsert = Flight(flightNumber: 0, planeId: 0, departureAirportId: 0, destinationAirportId: 0, departureDatetime: '', arriveDatetime: '', availableSeats: 100, status: 1);

class _FlightAdminPanelState extends State<FlightCRUPage> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final DatabaseHelper databaseHelper = DatabaseHelper.instance;
  List<Flight> _flights = [];
  List<String> _statuses = [];
  final List<Map<String, dynamic>> _flightStatusOptions = [
    {'text': 'Scheduled', 'value': 1},
    {'text': 'Delayed', 'value': 3},
    {'text': 'Cancelled', 'value': 4},
  ];
  int? _selectedStatus = 1;
  int _selectedIndex = -1;

  final idControllerUpdate = TextEditingController();
  final dateTimeControllerUpdate = TextEditingController();

  TextEditingController _departureAirportController = TextEditingController();
  TextEditingController _destinationAirportController = TextEditingController();
  TextEditingController _departureDateTimeController = TextEditingController();
  TextEditingController _arrivalDateTimeController = TextEditingController();
  TextEditingController _planeIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadFlights();
  }

  void _loadFlights() async {
    List<Flight> flights = await databaseHelper.getFlights();
    List<String> statuses = await databaseHelper.getFlightStatusDescriptions();
    setState(() {
      _flights = flights;
      _statuses = statuses;
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    idControllerUpdate.dispose();
    _planeIdController.dispose();
    _arrivalDateTimeController.dispose();
    _departureDateTimeController.dispose();
    _destinationAirportController.dispose();
    _departureAirportController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(75),
      child:
      AppBar(
        automaticallyImplyLeading: false,
        title: null,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.list), text: 'Retrieve'),
            Tab(icon: Icon(Icons.add), text: 'Insert'),
            Tab(icon: Icon(Icons.edit), text: 'Update'),
          ],
        ),
      ),
      ),
      body:
      TabBarView(
        controller: _tabController,
        children: [
          Column(
            children: [
            Expanded(
            child:
             ListView.builder(
             itemCount: _flights.length,
              itemBuilder: (context, index) {
                return ListTile(
                title: Text('Flight ID: ${_flights[index].flightNumber}, Airports: ${_flights[index].departureAirportId} -> ${_flights[index].destinationAirportId}'),
                subtitle: Text('${_flights[index].departureDatetime}, Seats: ${_flights[index].availableSeats} | ${_statuses[index]}'),
                onTap: (){
                  idControllerUpdate.text = _flights[index].flightNumber.toString();
                  dateTimeControllerUpdate.text = _flights[index].departureDatetime.toString();
                  if(_flights[index].status == 1 || _flights[index].status == 3 || _flights[index].status == 4) {
                    _selectedStatus = _flights[index].status;
                    setState(() {

                    });
                    }
                  _selectedIndex = index;
                  _tabController?.animateTo(2);
                   },
                    );
                   },
                 ),
               ),
              Container(
                  color: Colors.grey.shade300,
                  child:
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          margin: EdgeInsets.symmetric(horizontal: 10.0),
                          child: DropdownButton<String>(
                            value: dropdownValue,
                            items: <String>['ID', 'City', 'Country'].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                dropdownValue = newValue!;
                              });
                            },
                          )
                      ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.all(10.0),
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: 'Filter value',
                            ),
                            onChanged: (value) {
                              filterValue = value;
                            },
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          Container(
                            margin: EdgeInsets.all(2.0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade400,
                              ),
                              onPressed: () async {
                                if (dropdownValue == 'Country') {
                                  _flights = await databaseHelper.getFlightsByDestinationCountry(filterValue);
                                } else if (dropdownValue == 'City') {
                                  _flights = await databaseHelper.getFlightsByDepartureCity(filterValue);
                                }
                                else if (dropdownValue == 'ID'){
                                  idToSearchFlight = int.tryParse(filterValue)!;
                                  _flights = await databaseHelper.getFlightsFilteredByID(idToSearchFlight);
                                }
                                setState(() {});
                              },
                              child: Icon(Icons.filter_alt,),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.all(2.0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade400,
                              ),
                              onPressed: () {
                                _loadFlights();
                              },
                              child: Icon(Icons.filter_alt_off_sharp),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
              ),
              ]
          ),
        Padding(
          padding: EdgeInsets.all(16.0),
          child:SingleChildScrollView(
          child:
          Column(
            children: [
              TextField(
                controller: _departureAirportController,
                decoration: InputDecoration(labelText: 'Departure Airport ID'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 8),
              TextField(
                controller: _destinationAirportController,
                decoration: InputDecoration(labelText: 'Destination Airport ID'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 8),
              TextField(
                controller: _departureDateTimeController,
                decoration: InputDecoration(labelText: 'Departure Date and Time'),
                ),
              SizedBox(height: 8),
              TextField(
                      controller: _arrivalDateTimeController,
                      decoration: InputDecoration(labelText: 'Arrival Date and Time'),
                    ),
              SizedBox(height: 8),
              TextField(
                controller: _planeIdController,
                decoration: InputDecoration(labelText: 'Plane ID'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    backgroundColor: Colors.blueGrey
                ),
                onPressed: () async {
                    flightToInsert.departureAirportId = int.tryParse(_departureAirportController.text)!;
                    flightToInsert.destinationAirportId = int.tryParse(_destinationAirportController.text)!;
                    flightToInsert.departureDatetime = _departureDateTimeController.text;
                    flightToInsert.arriveDatetime = _arrivalDateTimeController.text;
                    flightToInsert.planeId = int.tryParse(_planeIdController.text)!;
                    await databaseHelper.insertFlight(flightToInsert);
                    _departureAirportController.clear();
                    _destinationAirportController.clear();
                    _departureDateTimeController.clear();
                    _arrivalDateTimeController.clear();
                    _planeIdController.clear();
                    _loadFlights();
                },
                child: Text('Insert Flight', style: TextStyle(color: Colors.white),),
              ),
            ],
          ),
          ),
        ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: idControllerUpdate,
                    decoration: InputDecoration(
                      labelText: 'Airport ID to update',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 8),
                Row(
                  children: [
                 Text("Status", style: TextStyle(fontSize: 16),),
                    SizedBox(width: 10),
                 DropdownButton<int>(
                  value: _selectedStatus,
                  items: _flightStatusOptions.map((option) {
                    return DropdownMenuItem<int>(
                      value: option['value'],
                      child: Text(option['text']),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedStatus = newValue;
                    });
                  },
                    ),
                  ]
                ),
                  SizedBox(height: 8),
                  TextField(
                    controller: dateTimeControllerUpdate,
                    decoration: InputDecoration(
                      labelText: 'Departure Date and Time',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                        backgroundColor: Colors.blueGrey
                    ),
                    onPressed: () async {
                      if(_selectedIndex != -1) {
                        _flights[_selectedIndex].status = _selectedStatus!;
                        _flights[_selectedIndex].departureDatetime = dateTimeControllerUpdate.text;
                        await databaseHelper.updateFlight(_flights[_selectedIndex]);
                        _selectedIndex = -1;
                        _loadFlights();
                      }
                      idControllerUpdate.clear();
                      dateTimeControllerUpdate.clear();
                    },
                    child: Text('Update Information', style: TextStyle(color: Colors.white),),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
