import 'package:flutter/material.dart';

import '../database_helper.dart';
import '../models/customer.dart';

class UserRUPage extends StatefulWidget {
  @override
  _RUPageState createState() => _RUPageState();
}
String dropdownValue = 'ID';
String filterValue = "";
Customer customerToUpdate = Customer(systemUserId: 0, userRealName: "", userSurname: "", gender: "", dateOfBirth: "", passportSeries: "", userEmail: "", userLogin: "", userPassword: "", userRole: "");

class _RUPageState extends State<UserRUPage> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final DatabaseHelper databaseHelper = DatabaseHelper.instance;
  List<Customer> _customers = [];

  final idControllerUpdate = TextEditingController();
  final realNameControllerUpdate = TextEditingController();
  final surnameControllerUpdate = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCustomers();
  }

  void _loadCustomers() async {
    List<Customer> customers = await databaseHelper.getCustomers();
    setState(() {
      _customers = customers;
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    idControllerUpdate.dispose();
    realNameControllerUpdate.dispose();
    surnameControllerUpdate.dispose();
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
                  itemCount: _customers.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text('№${_customers[index].systemUserId} ${_customers[index].userRealName} ${_customers[index].userSurname}'),
                      subtitle: Text('${_customers[index].userEmail}, ${_customers[index].userLogin}'),
                      onTap: (){
                        idControllerUpdate.text = _customers[index].systemUserId.toString();
                        realNameControllerUpdate.text = _customers[index].userRealName;
                        surnameControllerUpdate.text = _customers[index].userSurname;
                        _tabController?.animateTo(1);
                      },
                    );
                  },
                ),
              ),
              Container(
                color: Colors.grey.shade300,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 10.0),
                      child: DropdownButton<String>(
                        value: dropdownValue,
                        items: <String>['ID', 'Surname', 'Name'].map((String value) {
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
                      ),
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
                              if (dropdownValue == 'ID') {
                                _customers = await databaseHelper.getCustomersFilteredById(int.tryParse(filterValue)!);
                              } else if (dropdownValue == 'Surname') {
                                _customers = await databaseHelper.getCustomersFilteredBySurname(filterValue);
                              } else if (dropdownValue == 'Name') {
                                _customers = await databaseHelper.getCustomersFilteredByName(filterValue);
                              }
                              setState(() {});
                            },
                            child: Icon(Icons.filter_alt),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.all(2.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade400,
                            ),
                            onPressed: () {
                              _loadCustomers();
                            },
                            child: Icon(Icons.filter_alt_off_sharp),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: idControllerUpdate,
                    decoration: InputDecoration(
                      labelText: 'User ID to update',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: realNameControllerUpdate,
                    decoration: InputDecoration(
                      labelText: 'New Real Name',
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: surnameControllerUpdate,
                    decoration: InputDecoration(
                      labelText: 'New Surname',
                    ),
                  ),
                  SizedBox(height: 8),
                  SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                        backgroundColor: Colors.blueGrey
                    ),
                    onPressed: () async {
                      customerToUpdate.systemUserId = int.parse(idControllerUpdate.text);
                      customerToUpdate.userRealName = realNameControllerUpdate.text;
                      customerToUpdate.userSurname = surnameControllerUpdate.text;
                      await databaseHelper.updateCustomer(customerToUpdate);
                      customerToUpdate = Customer(systemUserId: 0, userRealName: "", userSurname: "", gender: "", dateOfBirth: "", passportSeries: "", userEmail: "", userLogin: "", userPassword: "", userRole: "");
                      _loadCustomers();
                      idControllerUpdate.clear();
                      realNameControllerUpdate.clear();
                      surnameControllerUpdate.clear();
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
