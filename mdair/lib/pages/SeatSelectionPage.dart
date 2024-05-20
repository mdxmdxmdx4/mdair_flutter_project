import 'package:flutter/material.dart';
import 'package:mdair/pages/ConfirmationPage.dart';
import 'package:mdair/database_helper.dart';

class SeatSelectionPage extends StatefulWidget {
  late String _fareType;
  late int _passengersCount;
  late DatabaseHelper _databaseHelper;
  late int _totalSeats;
  late List<int> _places;

  SeatSelectionPage(DatabaseHelper dbhelper, String name, int passengersNumber, int totalSeats, List<int> places){
    _fareType = name;
    _passengersCount = passengersNumber;
    _databaseHelper = dbhelper;
    _totalSeats = totalSeats;
    _places = places;
  }

  @override
  _SeatSelectionPageState createState() => _SeatSelectionPageState();
}

class _SeatSelectionPageState extends State<SeatSelectionPage> {
  late DatabaseHelper dbhelper = widget._databaseHelper;
  late int totalSeats = widget._totalSeats;
  late int passengers = widget._passengersCount;
  late List<bool> selectedSeats = List<bool>.filled(totalSeats, false);
  late List<bool> occupiedSeats = List<bool>.filled(totalSeats, false);

  @override
  void initState() {
    super.initState();
    if (widget._places != null) {
      widget._places.forEach((seat) {
        occupiedSeats[seat - 1] = true;
      });
    }
    else{
      occupiedSeats = List<bool>.filled(totalSeats, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade400,
        title: Text('Pick ${widget._passengersCount} seat(s)'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.info),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Description'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            FilterChip(
                              label: Text('1'),
                              selected: false,
                              onSelected: (bool value) {},
                            ),
                            SizedBox(width: 22),
                            Expanded(child: Text('Place is free')),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            FilterChip(
                              label: Text('1'),
                              selected: true,
                              onSelected: (bool value) {},
                            ),
                            SizedBox(width: 8),
                            Expanded(child: Text('Selected by you')),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            FilterChip(
                              label: Text('1'),
                              backgroundColor: Colors.grey,
                              onSelected: (bool value) {},
                            ),
                            SizedBox(width: 24),
                            Expanded(child: Text('Place is occupied')),
                          ],
                        ),
                      ],
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: Text('ОК'),
                        onPressed: () {
                          Navigator.of(context).pop();
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            SizedBox(height: 16.0),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: 1.0,
                ),
                itemCount: totalSeats,
                itemBuilder: (context, index) {
                  return FilterChip(
                    label: Text(
                      (index + 1).toString().padLeft(2, '0'),
                      style: TextStyle(fontSize: 18.0),
                    ),
                    selected: selectedSeats[index],
                    onSelected: occupiedSeats[index]
                        ? null
                        : (selected) {
                      setState(() {
                        if (selectedSeats.where((seat) => seat).length < passengers) {
                          selectedSeats[index] = selected;
                        } else if (!selected) {
                          selectedSeats[index] = selected;
                        }
                      });
                      },
                    backgroundColor: occupiedSeats[index] ? Colors.grey : null,
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: selectedSeats.where((seat) => seat).length == passengers
                  ? () {
                List<int> selectedSeatNumbers = [];
                for (int i = 0; i < selectedSeats.length; i++) {
                  if (selectedSeats[i]) {
                    selectedSeatNumbers.add(i + 1);
                  }
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>
                      ConfirmationPage(passengers, dbhelper, selectedSeatNumbers!)),
                );
              }
                  : null,
              child: Text('Continue'),
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedSeats.where((seat) => seat).length == passengers
                    ? Colors.blue
                    : Colors.grey,
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
