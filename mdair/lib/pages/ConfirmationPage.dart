import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:mdair/database_helper.dart';
import 'package:mdair/models/customer.dart';

class ConfirmationPage extends StatefulWidget {
  late int _passengerCount;
  late DatabaseHelper dbhelper;
  late List<int> _selectedSeats;
  ConfirmationPage(int passengers, databaseHelper, List<int> selectedSeatNumbers){
   _passengerCount = passengers;
   dbhelper = databaseHelper;
   _selectedSeats = selectedSeatNumbers;
  }

  @override
  _ConfirmationPageState createState() => _ConfirmationPageState();
}

class _ConfirmationPageState extends State<ConfirmationPage> {
  late List<int> selectedSeatNumbers = widget._selectedSeats;
  late int price = widget.dbhelper.price;
  late int passengersCount = widget._passengerCount;
  late DatabaseHelper databaseHelper = widget.dbhelper;
  late Customer? loggedInCustomer = databaseHelper.getLoggedInUser();
  int _currentIndex = 0;

  late final List<Customer> _customers = List<Customer>.generate(
    widget._passengerCount,
        (index) => Customer(
      systemUserId: index + 1000,
      userRealName: '',
      userSurname: '',
      gender: '',
      dateOfBirth: '',
      passportSeries: '',
      userEmail: '',
      userLogin: '',
      userPassword: '',
      userRole: '',
    ),
  );

  late Customer _currentCustomer = _customers.first;
  DateTime? _dateOfBirth;
  final TextEditingController _realNameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _passportController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _idController = TextEditingController();

  @override
  initState() {
    super.initState();
    if (loggedInCustomer != null) {
      _customers[0] = loggedInCustomer!;
      _realNameController.text = loggedInCustomer!.userRealName;
      _surnameController.text = loggedInCustomer!.userSurname;
      _passportController.text = loggedInCustomer!.passportSeries;
      _emailController.text = loggedInCustomer!.userEmail;
      _idController.text = loggedInCustomer!.systemUserId.toString();
      _dateOfBirth = DateTime.parse(loggedInCustomer!.dateOfBirth);
    }
  }

  @override
  Widget build(BuildContext context) {
    Customer? currentUser = databaseHelper.getLoggedInUser();
    if(widget.dbhelper.fareType == 'Business'){
      price = (price * 1.4).toInt();
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow.shade400,
        title: const Text('Confirmation Page'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              const Text('Flight Information', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Card(
                color: Color.fromRGBO(107, 105, 54, 0.12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Flight Number:${databaseHelper.selectedFlightid}', style: TextStyle(fontSize: 18)),
                      Text('From:${databaseHelper.destingationCity}', style: TextStyle(fontSize: 18)),
                      Text('To:${databaseHelper.departureCity}', style: TextStyle(fontSize: 18)),
                      Text('Passengers: ${widget._passengerCount}', style: TextStyle(fontSize: 18)),
                      Text('Total Price: \$${price * widget._passengerCount}', style: TextStyle(fontSize: 18)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Passenger Information', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              DropdownButton<Customer>(
                value: _currentCustomer,
                onChanged: (Customer? newValue) {
                  setState(() {
                    _currentCustomer = newValue!;
                    _realNameController.text = _currentCustomer.userRealName;
                    _surnameController.text = _currentCustomer.userSurname;
                    _passportController.text = _currentCustomer.passportSeries;
                    _emailController.text = _currentCustomer.userEmail;
                    _idController.text = _currentCustomer.systemUserId.toString();
                    _dateOfBirth = DateTime.tryParse(_currentCustomer.dateOfBirth);
                  });
                },
                items: _customers.map<DropdownMenuItem<Customer>>((Customer customer) {
                  return DropdownMenuItem<Customer>(
                    value: customer,
                    child: Text('Passenger ${_customers.indexOf(customer) + 1}'),
                  );
                }).toList(),
              ),
              Column(
                children: <Widget>[
                  TextField(
                    controller: _realNameController,
                    decoration: InputDecoration(
                      labelText: 'First Name',
                    ),
                    onChanged: (value) {
                      setState(() {
                        _currentCustomer.userRealName = value;
                      });
                    },
                  ),
                  TextField(
                    controller: _surnameController,
                    decoration: InputDecoration(
                      labelText: 'Last Name',
                    ),
                    onChanged: (value) {
                      setState(() {
                        _currentCustomer.userSurname = value;
                      });
                    },
                  ),
                  _buildDatePicker(context, 'Date of Birth', _dateOfBirth,
                          (date) {
                        setState(() {
                          _dateOfBirth = date;
                          _currentCustomer.dateOfBirth =
                              DateFormat('yyyy-MM-dd').format(date!);
                        });
                      }),
                  TextField(
                    controller: _passportController,
                    decoration: InputDecoration(
                      labelText: 'Passport Number',
                    ),
                    onChanged: (value) {
                      setState(() {
                        _currentCustomer.passportSeries = value;
                      });
                    },
                  ),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                    ),
                    onChanged: (value) {
                      setState(() {
                        _currentCustomer.userEmail = value;
                      });
                    },
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30.0, bottom: 10),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                      backgroundColor: Colors.black87
                  ),
                  onPressed: () async {
                    if(currentUser != null){
                    await databaseHelper.bookTicket(selectedSeatNumbers[0], price.toDouble(), databaseHelper.fareType);
                    }
                    popMultiple(4);
                  },
                  child: Text('Confirm', style: TextStyle(color:Colors.yellow, fontSize: 20),),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context, String label, DateTime? date,
      Function(DateTime?) onDateSelected) {
    final DateTime currentDate = DateTime.now();
    final DateTime maxDate = currentDate.subtract(Duration(days: 365 * 18));

    return Row(
      children: <Widget>[
        Text(label),
        TextButton(
          onPressed: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: date ?? maxDate,
              firstDate: DateTime(1900),
              lastDate: maxDate,
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

  void popMultiple(int count) {
    for (int i = 0; i < count; i++) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      } else {
        break;
      }
    }
  }

}








