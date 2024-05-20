class Customer {
  int systemUserId;
  String userRealName;
   String userSurname;
   String gender;
   String dateOfBirth;
   String passportSeries;
   String userEmail;
   String userLogin;
   String userPassword;
  final String userRole;

  Customer({
    required this.systemUserId,
    required this.userRealName,
    required this.userSurname,
    required this.gender,
    required this.dateOfBirth,
    required this.passportSeries,
    required this.userEmail,
    required this.userLogin,
    required this.userPassword,
    required this.userRole,
  });

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      systemUserId: map['system_user_id'],
      userRealName: map['user_real_name'],
      userSurname: map['user_surname'],
      gender: map['gender'],
      dateOfBirth: map['date_of_birth'],
      passportSeries: map['passport_series'],
      userEmail: map['user_email'],
      userLogin: map['user_login'],
      userPassword: map['user_password'],
      userRole: map['user_role'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_real_name': userRealName,
      'user_surname': userSurname,
      'gender': gender,
      'date_of_birth': dateOfBirth,
      'passport_series': passportSeries,
      'user_email': userEmail,
      'user_login': userLogin,
      'user_password': userPassword,
      'user_role': userRole,
    };
  }

  @override
  String toString() {
    return 'Customer: $userRealName $userSurname ($userLogin)';
  }
}
