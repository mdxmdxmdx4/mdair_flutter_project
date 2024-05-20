import 'package:flutter/material.dart';
import 'package:mdair/pages/FareSelectionPage.dart';
import 'package:provider/provider.dart';

import 'package:mdair/database_helper.dart';
import 'package:mdair/models/customer.dart';
import 'package:mdair/models/flight_info.dart';

class SearchResultPage extends StatefulWidget {
  String _departureAirport = '';
  String _destinationAirport = '';
  DateTime? _departureDate;
  DateTime? _returnDate;
  bool _isRoundTrip = false;
  int _passengerCount = 1;
  String _classType = 'Economy';
  late DatabaseHelper _dbhelper;

  SearchResultPage(DatabaseHelper dbhelper, String departureAirport, String destinationAirport, DateTime? departureDate, DateTime? returnDate, bool isRoundTrip, int passengerCount, String classType){
    _dbhelper = dbhelper;
    _departureAirport = departureAirport;
    _destinationAirport = destinationAirport;
    _departureDate = departureDate;
    _returnDate = returnDate;
    _isRoundTrip  = isRoundTrip;
    _passengerCount = passengerCount;
    _classType = classType;
  }

  @override
  _SearchResultPageState createState() => _SearchResultPageState();
}


class _SearchResultPageState extends State<SearchResultPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 1;
  late DatabaseHelper databaseHelper = widget._dbhelper;
  late Customer? current_user = databaseHelper.getLoggedInUser();

  final List<List<FlightInfo>> _flightInfoLists = [[], [], []];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: _currentIndex);
    _tabController.addListener(_handleTabSelection);
    _loadFlights(_currentIndex);
  }

  void _handleTabSelection() {
    setState(() {
      _currentIndex = _tabController.index;
    });
    if (_flightInfoLists[_currentIndex].isEmpty) {
      _loadFlights(_currentIndex);
    }
  }

  Future<void> _loadFlights(int index) async {
    DateTime searchDate = widget._departureDate!.add(Duration(days: index - 1));
    List<FlightInfo> flights = (await databaseHelper.findFlights(
      widget._departureAirport,
      widget._destinationAirport,
      searchDate,
      widget._passengerCount,
    )).cast<FlightInfo>();
    setState(() {
      _flightInfoLists[index] = flights;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow.shade400,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: <Widget>[
            Text(widget._departureAirport.substring(0,3).toUpperCase(),
              style:TextStyle(fontWeight: FontWeight.w600) ,),
            Icon(Icons.arrow_forward),
            Text(widget._destinationAirport.substring(0,3).toUpperCase() + (widget._isRoundTrip ? ' (Round Trip)' : ' (One-way)'),
                style:TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.red,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          dividerColor: Colors.grey,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          tabs: [
            Tab(text: "${_getMonthAbbreviation(widget._departureDate!.add(Duration(days: -1)).month)} ${widget._departureDate!.add(Duration(days: -1)).day}"),
            Tab(text: "${_getMonthAbbreviation(widget._departureDate!.month)} ${widget._departureDate!.day}"),
            Tab(text: "${_getMonthAbbreviation(widget._departureDate!.add(Duration(days: 1)).month)} ${widget._departureDate!.add(Duration(days: 1)).day}"),
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Select your departure',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Text(
              'Found ${_flightInfoLists[_currentIndex].length} results',
              style: TextStyle(fontSize: 18),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: ListView.builder(
                itemCount: _flightInfoLists[_currentIndex].length,
                itemBuilder: (context, index) {
                  return FlightResultTile(flightInfo: _flightInfoLists[_currentIndex][index],passengerCount: widget._passengerCount,customer: current_user);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}



class FlightResultTile extends StatelessWidget {
  final FlightInfo flightInfo;
  final int passengerCount;
  final Customer? customer;

  FlightResultTile({required this.flightInfo,
  required this.passengerCount,
  required this.customer});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Text(flightInfo.departureTime, style: TextStyle(fontSize: 18)),
                ),
                Text('Duration: ${flightInfo.duration}', style: TextStyle(fontSize: 12, color: Colors.grey)),
                SizedBox(width: 85),
                Text(flightInfo.arrivalTime, style: TextStyle(fontSize: 18)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Text(flightInfo.departureAirport, style: TextStyle(fontSize: 14,fontWeight: FontWeight.w600)),
                ),
                Text('------>', style: TextStyle(fontSize: 18, color: Color.fromRGBO(107, 105, 54, 1), fontWeight: FontWeight.bold),),
                SizedBox(width: 16,),
                Text(flightInfo.destinationAirport, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Text('${flightInfo.price}\$', style: TextStyle(fontSize: 26, color: Colors.red, fontWeight: FontWeight.bold)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow.shade400,
                  ),
                  onPressed: () {
                    if(customer != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>
                            FareSelectionPage(flightInfo.flightId,
                                flightInfo.price, passengerCount)),
                      );
                    }
                    else{
                      showAlertDialogNotLoggedIn(context,"Your are not logged in", "Please, log in to book a flight ticket!");
                    }
                  },
                  child: Text(
                    'Book now',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


String _getMonthAbbreviation(int month) {
  switch (month) {
    case 1:
      return "JAN";
    case 2:
      return "FEB";
    case 3:
      return "MAR";
    case 4:
      return "APR";
    case 5:
      return "MAY";
    case 6:
      return "JUN";
    case 7:
      return "JUL";
    case 8:
      return "AUG";
    case 9:
      return "SEP";
    case 10:
      return "OCT";
    case 11:
      return "NOV";
    case 12:
      return "DEC";
    default:
      return "";
  }
}
void showAlertDialogNotLoggedIn(BuildContext context, String errorTitle, String errorMessage) {
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
              Navigator.of(context).pop();
            },
            child: Text('ОК'),
          ),
        ],
      );
    },
  );
}
