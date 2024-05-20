import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mdair/database_helper.dart';
import 'package:provider/provider.dart';

import '../models/customer.dart';
import 'LoginPage.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  String _selectedGender = 'Male';
  DateTime? _dateOfBirth;
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  late DatabaseHelper databaseHelper;
  Customer _newCustomer = Customer(
    systemUserId: 1,
    userRealName: '',
    userSurname: '',
    gender: '',
    dateOfBirth: '',
    passportSeries: '',
    userEmail: '',
    userLogin: '',
    userPassword: '',
    userRole: 'user',
  );


  @override
  Widget build(BuildContext context) {
    databaseHelper = Provider.of<DatabaseHelper>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text('Registration'),
          automaticallyImplyLeading: false,
          backgroundColor: Colors.yellow,
          actions: [
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () async {
                final backNavigationAllowed = await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Confirmation'),
                    content: Text(
                        'Are you sure you want to cancel the registration process? All data will be lost.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text('Stay'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text('Leave'),
                      ),
                    ],
                  ),
                );
                if (backNavigationAllowed) {
                  if (mounted) Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
          body: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Card(
                color: Colors.grey.shade200,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: <Widget>[
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Real Name',
                        ),
                        onChanged: (value) => _newCustomer.userRealName = value,
                      ),
                      SizedBox(height: 16),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Surname',
                        ),
                        onChanged: (value) => _newCustomer.userSurname = value,
                      ),
                      SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 14.0, right: 10),
                            child: Text('Gender'),
                          ),
                          DropdownButton<String>(
                            value: _selectedGender,
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedGender = newValue!;
                                _newCustomer.gender = newValue;
                              });
                            },
                            items: <String>['Male', 'Female', 'Other']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      _buildDatePicker(context, 'Date of Birth', _dateOfBirth,
                              (date) {
                            setState(() {
                              _dateOfBirth = date;
                              _newCustomer.dateOfBirth =
                                  DateFormat('yyyy-MM-dd').format(date!);
                            });
                          }),
                      SizedBox(height: 16),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Passport Series',
                        ),
                        onChanged: (value) =>
                        _newCustomer.passportSeries = value,
                      ),
                      SizedBox(height: 16),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Email',
                        ),
                        onChanged: (value) => _newCustomer.userEmail = value,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              Card(
                color: Colors.grey.shade200,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: <Widget>[
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Login',
                        ),
                        onChanged: (value) => _newCustomer.userLogin = value,
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                        ),
                        obscureText: true,
                        onChanged: (value) =>
                        _newCustomer.userPassword = value,
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: _confirmPasswordController,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                        ),
                        obscureText: true,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if(_newCustomer.userRealName.length > 3 && _newCustomer.userSurname.length > 3 && _newCustomer.dateOfBirth != '' && _newCustomer.userEmail.contains('@')){
                      if(_newCustomer.userPassword == _confirmPasswordController.text) {
                        databaseHelper.insertCustomer(_newCustomer);
                        Navigator.of(context).pop();
                      }
                      else{
                        showAlertDialog(context, "Registration Error!", "Password doesen't match!");
                      }
                    }
                    else{
                      showAlertDialog(context, "Registration Error!", "You must specify all the data!");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                      backgroundColor: Colors.yellow.shade400
                  ),
                  child: Text('Register',
                    style: TextStyle(color: Colors.black, fontSize: 18) ,),
                ),
              ),
            ],
          ),
        ),
      );
    }
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
