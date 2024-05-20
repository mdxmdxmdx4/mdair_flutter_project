import 'package:flutter/material.dart';
import 'package:mdair/pages/AdminPanelPage.dart';
import 'package:provider/provider.dart';

import '../database_helper.dart';
import '../models/customer.dart';

class ProfilePage extends StatefulWidget {
  final VoidCallback toggleCallback;

  ProfilePage({required this.toggleCallback});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  void widgetCallback() {
    widget.toggleCallback();
  }

  Customer? user;

  bool _isEditingName = false;
  bool _isEditingSurname = false;
  bool _isEditingGender = false;
  bool _isEditingPassport = false;
  bool _isEditingEmail = false;
  bool _isResettingPassword = false;
  String? _selectedGender;

  late DatabaseHelper databaseHelper;

  @override
  void initState() {
    super.initState();
    _selectedGender = user?.gender;
  }

  @override
  Widget build(BuildContext context) {
    databaseHelper = Provider.of<DatabaseHelper>(context);
    this.user = databaseHelper.getLoggedInUser();

    TextEditingController _nameController = TextEditingController(text: user?.userRealName);
    TextEditingController _surnameController = TextEditingController(text: user?.userSurname);
    TextEditingController _genderController = TextEditingController(text: user?.gender);
    TextEditingController _passportController = TextEditingController(text: user?.passportSeries);
    TextEditingController _emailController = TextEditingController(text: user?.userEmail);
    TextEditingController _passwordController = TextEditingController();
    TextEditingController _confirmPasswordController = TextEditingController();
    TextEditingController _currentPasswordController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: Text('Greetings, ${user!.userRealName}'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              _buildEditableField(_nameController, 'Name', (value) {
                setState(() {
                  _isEditingName = value;
                  if (!value) {
                    user!.userRealName = _nameController.text;
                  }
                });
              }, _isEditingName),
              _buildEditableField(_surnameController, 'Surname', (value) {
                setState(() {
                  _isEditingSurname = value;
                  if (!value) {
                    user!.userSurname = _surnameController.text;
                  }
                });
              }, _isEditingSurname),
              _buildEditableField(_genderController, 'Gender', (value) {
                setState(() {
                  _isEditingGender = value;
                  if (!value) {
                    user!.gender = _genderController.text;
                  }
                });
              }, _isEditingGender),
              _buildEditableField(_passportController, 'Passport Series', (value) {
                setState(() {
                  _isEditingPassport = value;
                  if (!value) {
                    user!.passportSeries = _passportController.text;
                  }
                });
              }, _isEditingPassport),
              _buildEditableField(_emailController, 'E-mail', (value) {
                setState(() {
                  _isEditingEmail = value;
                  if (!value) {
                    user!.userEmail = _emailController.text;
                  }
                });
              }, _isEditingEmail),
              SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isResettingPassword = true;
                  });
                },
                child: Text('Reset password', style: TextStyle(color: Colors.grey, fontSize: 16),),
              ),
              SizedBox(height: 15),
              ElevatedButton(
                onPressed: () async{
                await databaseHelper.logout();
                widgetCallback();
                },
                style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    backgroundColor: Colors.yellow.shade400
                ),
                child: Text('Log out', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),),
              ),
              SizedBox(height: 10),
              if (_isResettingPassword)
                ...[
                  TextField(
                    controller: _currentPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Current password',
                    ),
                    obscureText: true,
                  ),
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'New password',
                    ),
                    obscureText: true,
                  ),
                  TextField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Confirm password',
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                        backgroundColor: Colors.yellow
                    ),
                    onPressed: () async {
                      if (_passwordController.text == _confirmPasswordController.text && _currentPasswordController.text == user!.userPassword) {
                        user!.userPassword = _passwordController.text;
                        await databaseHelper.updateCustomer(user!);
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Password is successfully changed!'),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('Оk'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                        _passwordController.clear();
                        _confirmPasswordController.clear();
                        setState(() {
                          _isResettingPassword = false;
                        });
                      } else {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Password doesn\'t match'),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('Ok'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    child: const Text('Save new password', style: TextStyle(color:Colors.black, fontSize: 18),),
                  ),
                ],
              SizedBox(height: _isResettingPassword ? 12 : 0),
              if (databaseHelper.isAdmin())
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      minimumSize: Size(double.infinity, 50),
                      backgroundColor: Color.fromRGBO(0, 0, 0, 0.8)
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) =>
                          AdminPanelPage()),
                    );
                  },
                  child: const Text('Open Admin Panel',
                    style: TextStyle(color:Colors.yellow,fontSize: 18),),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableField(TextEditingController controller, String label, Function(bool) onEditingComplete, bool isEditing) {
    return Row(
      children: <Widget>[
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
            ),
            readOnly: !isEditing,
          ),
        ),
        IconButton(
          icon: Icon(isEditing ? Icons.check : Icons.edit, color: Colors.blueGrey,),
          onPressed: () async {
            if (isEditing) {
              switch (label) {
                case 'Name':
                  user!.userRealName = controller.text;
                  break;
                case 'Surname':
                  user!.userSurname = controller.text;
                  break;
                case 'Gender':
                  user!.gender = controller.text;
                  break;
                case 'Passport Series':
                  user!.passportSeries = controller.text;
                  break;
                case 'E-mail':
                  user!.userEmail = controller.text;
                  break;
              }
              await databaseHelper.updateCustomer(user!);
            }
            onEditingComplete(!isEditing);
          },
        ),
      ],
    );
  }
}
