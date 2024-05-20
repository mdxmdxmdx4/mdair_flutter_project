import 'package:flutter/material.dart';
import 'package:mdair/models/airport.dart';

import 'package:mdair/database_helper.dart';

class AirportCRUPage extends StatefulWidget {
  @override
  _CRUPageState createState() => _CRUPageState();
}

Airport airportToInsert = Airport(airportId: 0, airportName: "", locationCountry: "", locationCity: "");
Airport airportToUpdate = Airport(airportId: 0, airportName: "", locationCountry: "", locationCity: "");
String dropdownValue = 'Country';
String filterValue = "";
int idToSearchFlight = 0;

class _CRUPageState extends State<AirportCRUPage> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final DatabaseHelper databaseHelper = DatabaseHelper.instance;
  List<Airport> _airports = [];

  final idControllerUpdate = TextEditingController();
  final airportNameControllerUpdate = TextEditingController();
  final locationCountryControllerUpdate = TextEditingController();
  final locationCityControllerUpdate = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAirports();
  }

  void _loadAirports() async {
    List<Airport> airports = await databaseHelper.getAirports();
    setState(() {
      _airports = airports;
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    idControllerUpdate.dispose();
    airportNameControllerUpdate.dispose();
    locationCountryControllerUpdate.dispose();
    locationCityControllerUpdate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(75),
        child: AppBar(
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
      body: TabBarView(
        controller: _tabController,
        children: [
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: _airports.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text('№${_airports[index].airportId} ${_airports[index].airportName}'),
                      subtitle: Text('${_airports[index].locationCountry}, ${_airports[index].locationCity}'),
                      onTap: (){
                        idControllerUpdate.text = _airports[index].airportId.toString();
                        airportNameControllerUpdate.text = _airports[index].airportName;
                        locationCountryControllerUpdate.text = _airports[index].locationCountry;
                        locationCityControllerUpdate.text = _airports[index].locationCity;
                        _loadAirports();
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
                        items: <String>['Country', 'City', 'ID'].map((String value) {
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
                              _airports = await databaseHelper.getAirportsFilteredByCountry(filterValue);
                            } else if (dropdownValue == 'City') {
                              _airports = await databaseHelper.getAirportsFilteredByCity(filterValue);
                            }
                            else if (dropdownValue == 'ID'){
                              idToSearchFlight = int.tryParse(filterValue)!;
                              _airports = await databaseHelper.getAirportsFilteredByID(idToSearchFlight);
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
                            _loadAirports();
                          },
                          child: Icon(Icons.filter_alt_off_sharp),
                        ),
                      ),
                    ],
                  ),
                ],
                )
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Airport Name',
                  ),
                  onChanged: (value) {
                    airportToInsert.airportName = value;
                  },
                ),
                SizedBox(height: 8),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Location Country',
                  ),
                  onChanged: (value) {
                    airportToInsert.locationCountry = value;
                  },
                ),
                SizedBox(height: 8),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Location City',
                  ),
                  onChanged: (value) {
                    airportToInsert.locationCity = value;
                  },
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                      backgroundColor: Colors.blueGrey
                  ),
                  onPressed: () async {
                    await databaseHelper.insertAirport(airportToInsert);
                    _loadAirports();
                    airportToInsert = Airport(airportId: 0, airportName: "", locationCountry: "", locationCity: "");
                  },
                  child: Text('Add Airport', style: TextStyle(color: Colors.white),),
                ),
              ],
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
                  TextField(
                    controller: airportNameControllerUpdate,
                    decoration: InputDecoration(
                      labelText: 'New Airport Name',
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: locationCountryControllerUpdate,
                    decoration: InputDecoration(
                      labelText: 'New Location Country',
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: locationCityControllerUpdate,
                    decoration: InputDecoration(
                      labelText: 'New Location City',
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                        backgroundColor: Colors.blueGrey
                    ),
                    onPressed: () async {
                      airportToUpdate.airportName = airportNameControllerUpdate.text;
                      airportToUpdate.airportId = int.parse(idControllerUpdate.text);
                      airportToUpdate.locationCountry = locationCountryControllerUpdate.text;
                      airportToUpdate.locationCity = locationCityControllerUpdate.text;
                      await databaseHelper.updateAirport(airportToUpdate);
                      airportToUpdate = Airport(airportId: 0, airportName: "", locationCountry: "", locationCity: "");
                      _loadAirports();
                      idControllerUpdate.clear();
                      airportNameControllerUpdate.clear();
                      locationCountryControllerUpdate.clear();
                      locationCityControllerUpdate.clear();
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


