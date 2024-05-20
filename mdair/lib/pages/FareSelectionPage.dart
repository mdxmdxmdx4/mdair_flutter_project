import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import 'SeatSelectionPage.dart';

import 'package:mdair/database_helper.dart';

class FareSelectionPage extends StatefulWidget {

  late int _flightId;
  late int _price;
  late int _passengersCount;
  FareSelectionPage(int flightId, String price, int passengersCount) {
    _flightId = flightId;
    _price = int.tryParse(price)!;
    _passengersCount = passengersCount;
  }

  @override
  _FareSelectionPageState createState() => _FareSelectionPageState();
}

class _FareSelectionPageState extends State<FareSelectionPage> {
  late int price = widget._price;
  late int passengersCount = widget._passengersCount;
  int _currentIndex = 0;
  late final List<FlightClass> _flightClasses = [
    FlightClass(name: 'Economy', price: price.toString(), seats: 'Regular seats type', service: 'Regular service support',convinience: 'Suites short distance flight', passendersNumber: passengersCount),
    FlightClass(name: 'Business', price: ((price * 1.4).truncate()).toString(), seats: 'Spacious and convinient seating',service: 'Upgraded service support', convinience: 'Suites long distance flights',  passendersNumber: passengersCount),
  ];
  late DatabaseHelper databaseHelper;
  @override
  Widget build(BuildContext context) {
    databaseHelper = Provider.of<DatabaseHelper>(context);
    databaseHelper.selectedFlightid = widget._flightId;
    databaseHelper.price = price;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow.shade400,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Fare for ${passengersCount} passenger(s)'),
      ),
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Image.network('https://wallup.net/wp-content/uploads/2016/01/68375-clouds-nature-sunrise-sunlight-sky.jpg', fit: BoxFit.cover),
              ),
              Expanded(
                flex: 1,
                child: Container(),
              ),
            ],
          ),
          Positioned(
            top: MediaQuery.of(context).size.height / 3,
            left: 0,
            right: 0,
            child: CarouselSlider.builder(
              itemCount: _flightClasses.length,
              itemBuilder: (context, index, realIdx) {
                return FlightClassTile(flightClass: _flightClasses[index]);
              },
              options: CarouselOptions(
                height: MediaQuery.of(context).size.height / 3,
                enlargeCenterPage: true,
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: () async {
                String fareType = _flightClasses[_currentIndex].name == "Economy" ? "Regular" : "Business";
                databaseHelper.fareType = fareType;
                int totalSeatsCountByClass = await databaseHelper.getSeatsByClass(databaseHelper.selectedFlightid, _flightClasses[_currentIndex].name);
                List<int> places = await databaseHelper.getOccupiedSeats(databaseHelper.selectedFlightid, fareType);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SeatSelectionPage(databaseHelper,
                      _flightClasses[_currentIndex].name,
                      _flightClasses[_currentIndex].passendersNumber,
                      totalSeatsCountByClass,
                      places)),
                );
              },
              child: Text('Select this fare', style: TextStyle(color: Colors.yellow.shade400, fontSize: 18),),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                backgroundColor: Color.fromRGBO(0, 0, 0, 0.8)
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FlightClass {
  final String name;
  final String price;
  final String seats;
  final String service;
  final String convinience;
  final int passendersNumber;

  FlightClass({
    required this.name,
    required this.price,
    required this.seats,
    required this.service,
    required this.convinience,
    required this.passendersNumber
  });
}

class FlightClassTile extends StatelessWidget {
  final FlightClass flightClass;

  FlightClassTile({required this.flightClass});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(horizontal: 5.0),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(flightClass.name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text("\$${flightClass.price} X ${flightClass.passendersNumber}", style: TextStyle(fontSize: 20)),
          Row(
            children: [
            Icon(Icons.airline_seat_legroom_extra_outlined),
            SizedBox(width: 10),
            Text(flightClass.seats, style: TextStyle(fontSize: 16))
          ],
          ),
          Row(
            children: [
            Icon(Icons.room_service_rounded),
            SizedBox(width: 10),
            Text(flightClass.service, style: TextStyle(fontSize: 16)),
          ],
          ),
          Row(
            children: [
            Icon(Icons.check),
            SizedBox(width: 10),
            Text(flightClass.convinience, style: TextStyle(fontSize: 16)),
          ]
          ),
        ],
      ),
    );
  }
}
