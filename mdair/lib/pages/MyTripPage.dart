import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mdair/pages/SearchResultPage.dart';
import 'package:mdair/models/flight_info.dart';
import 'package:provider/provider.dart';

import '../database_helper.dart';

class MyTripPage extends StatefulWidget {

  final Function onLogin;
  MyTripPage({required this.onLogin});

  @override
  _MyTripPageState createState() => _MyTripPageState();
}

class _MyTripPageState extends State<MyTripPage> {
  bool _isUserLoggedIn = false;
  late DatabaseHelper databaseHelper;

  @override
  Widget build(BuildContext context) {
    databaseHelper = Provider.of<DatabaseHelper>(context);
    if(databaseHelper.getLoggedInUser() != null){
      _isUserLoggedIn = true;
    }
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.yellow.shade400,
          title: Text('My Trips'),
          bottom: TabBar(
            indicatorColor: Colors.red,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            dividerColor: Colors.grey,
            tabs: [

              Tab(text: 'Active',),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: _isUserLoggedIn ? _buildTripsList() : _buildLoginPrompt(),
      ),
    );
  }

  Widget _buildTripsList() {
    return TabBarView(
      children: [
        FutureBuilder<List<FlightResult>>(
          future: databaseHelper.getActiveBookings(databaseHelper.getLoggedInUser()!.systemUserId),
          builder: (BuildContext context, AsyncSnapshot<List<FlightResult>> snapshot) {
            if (snapshot.hasData) {
              List<FlightResult> flightResults = snapshot.data!;
              List<Widget> bookings = flightResults.map((flightResult) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _buildBookingCard(flightResult),
                );
              }).toList();
              return SingleChildScrollView(
                child: Column(children: bookings),
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
        FutureBuilder<List<FlightResult>>(
          future: databaseHelper.getInactiveBookings(databaseHelper.getLoggedInUser()!.systemUserId),
          builder: (BuildContext context, AsyncSnapshot<List<FlightResult>> snapshot) {
            if (snapshot.hasData) {
              List<FlightResult> flightResults = snapshot.data!;
              List<Widget> bookings = flightResults.map((flightResult) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _buildHistoryCard(flightResult
                  ),
                );
              }).toList();
              return SingleChildScrollView(
                child: Column(children: bookings),
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
      ],
    );
  }


  Widget _buildLoginPrompt() {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        height: 200,
        child: Card(
          color: Color.fromRGBO(107, 105, 54, 0.12),
          margin: EdgeInsets.all(16.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 2.0),
                  child: Container(
                      padding: const EdgeInsets.only(left: 2.0),
                      child: Icon(Icons.person_4, size: 80)
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text('Please log in to view your bookings'),
                      SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          widget.onLogin(3);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(0, 0, 0, 0.7),
                        ),
                        child: Text('Go to Log In',style: TextStyle(color:Colors.yellow),),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookingCard(FlightResult flightResult) {
    return Card(
      color: Color.fromRGBO(107, 105, 54, 0.22),
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: ListTile(
        title: Text('#${flightResult.flightNumber} ${flightResult.departureAirport.split(',')[0]} -> ${flightResult.arrivalAirport.split(',')[0]}', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),),
        subtitle: Text('${flightResult.departureDate}\nSeat №${flightResult.seatNumber}, ${flightResult.ticketClass} Class\nPrice: ${flightResult.price} | Ticket #${flightResult.ticketNum}', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16, color: Colors.black),),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.info_outline, size: 30,),
              onPressed: () {
                double screenWidth = MediaQuery.of(context).size.width;
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return FlightDetailsBottomSheet(flightResult: flightResult, screenWidth: screenWidth,);
                  },
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.cancel, size: 30,),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Cancel Booking'),
                      content: Text('Do you really want to cancel the booking?'),
                      actions: <Widget>[
                        TextButton(
                          child: Text('No'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: Text('Yes'),
                          onPressed: () async {
                            await databaseHelper.cancelBooking(flightResult.ticketNum);
                            Navigator.of(context).pop();
                            setState(() {

                            });
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildHistoryCard(FlightResult flightResult) {
    return Card(
      color: Color.fromRGBO(107, 105, 54, 0.32),
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: ListTile(
        title: Text('#${flightResult.flightNumber} ${flightResult.departureAirport.split(',')[0]} -> ${flightResult.arrivalAirport.split(',')[0]}', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),),
        subtitle: Text('${flightResult.departureDate}\nSeat №${flightResult.seatNumber}, ${flightResult.ticketClass} Class\nPrice: ${flightResult.price} | Ticket #${flightResult.ticketNum}', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16, color: Colors.black),),
        trailing: IconButton(
          icon: Icon(Icons.info_outline, size: 30,),
          onPressed: () {
            double screenWidth = MediaQuery.of(context).size.width;
            showModalBottomSheet(
              context: context,
              builder: (context) {
                return FlightDetailsBottomSheet(flightResult: flightResult,screenWidth:screenWidth );
              },
            );
          },
        ),
      ),
    );
  }

}

class FlightDetailsBottomSheet extends StatelessWidget {
  final FlightResult flightResult;
  final double screenWidth;

  FlightDetailsBottomSheet({required this.flightResult, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(25.0)),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        height: 350,
        width: screenWidth,
        color: Colors.grey[200],
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  margin: EdgeInsets.only(top: 2.0, bottom: 20.0),
                  width: 120,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
              ),
              Text('Flight Details', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
              const SizedBox(height: 10),
              Text('Departure: ${flightResult.departureAirport}\n'
                  'Destination: ${flightResult.arrivalAirport}\n'
                  'Seat Number: ${flightResult.seatNumber}\n'
                  'Date and Time: ${flightResult.departureDate}\n'
                  'Ticket Class: ${flightResult.ticketClass}\n'
                  'Price: \$${flightResult.price}\n'
                  'Ticket Number: ${flightResult.ticketNum}\n'
                  'Flight Number: ${flightResult.flightNumber}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),),
            ],
          ),
        ),
      ),
    );
  }
}


