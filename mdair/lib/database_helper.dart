import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:mdair/models/customer.dart';
import 'package:mdair/models/ticket.dart';
import 'package:intl/intl.dart';

import 'models/airport.dart';
import 'models/flight.dart';
import 'models/flight_info.dart';
import 'models/plane.dart';

class DatabaseHelper  {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('mdair.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  late String _departureCity;
  late String _destingationCity;
  late int _selectedFlightid;
  late int _price;
  Customer? _loggedInUser;
  bool _isAdmin = false;
  late int _passengersCount;
  late int _seatsCountByClass;

  void setLoggedInUser(Customer user) {
    _loggedInUser = user;
    _isAdmin = (user.userRole == 'admin');
  }

  Customer? getLoggedInUser() {
    return _loggedInUser;
  }

  Future<void> logout() async {
    _loggedInUser = null;
    _isAdmin = false;
  }

  int get selectedFlightid => _selectedFlightid;

  set selectedFlightid(int value) {
    _selectedFlightid = value;
  }

  int get passengersCount => _passengersCount;

  set passengersCount(int value) {
    _passengersCount = value;
  }

  int get price => _price;

  set price(int value) {
    _price = value;
  }

  String get departureCity => _departureCity;

  set departureCity(String value) {
    _departureCity = value;
  }

  Future<List<FlightInfo>> findFlights(String departureCity, String destinationCity, DateTime departureDate, int passengerCount) async {
    final db = await database;
    var departureAirports = await db.rawQuery('SELECT airport_id FROM Airport WHERE location_city = ?', [departureCity]);
    var destinationAirports = await db.rawQuery('SELECT airport_id FROM Airport WHERE location_city = ?', [destinationCity]);
    String formattedDate = DateFormat('dd-MM-yyyy').format(departureDate);
    List<FlightInfo> flightInfos = [];

    for (var departureAirport in departureAirports) {
      for (var destinationAirport in destinationAirports) {
        var flights = await db.rawQuery('''
        SELECT 
          Flight.flight_number, 
          Flight.departure_datetime, 
          Flight.arrive_datetime, 
          Flight.available_seats, 
          DepartureAirport.airport_name AS departure_airport, 
          DestinationAirport.airport_name AS destination_airport
        FROM Flight 
        INNER JOIN Airport AS DepartureAirport ON Flight.departure_airport_id = DepartureAirport.airport_id
        INNER JOIN Airport AS DestinationAirport ON Flight.destination_airport_id = DestinationAirport.airport_id
        WHERE Flight.departure_airport_id = ? 
        AND Flight.destination_airport_id = ? 
        AND substr(Flight.departure_datetime, 1, 10) = ? 
        AND Flight.available_seats >= ?
      ''', [
          departureAirport['airport_id'],
          destinationAirport['airport_id'],
          formattedDate,
          passengerCount
        ]);

        for (var flight in flights) {
          final places = int.parse(flight["available_seats"].toString());
          final durationString = flight["arrive_datetime"].toString().substring(11, 16);
          final durationHours = durationString.split("h")[0] == "0" ? 3 : 8;
          final int dynamicPrice = (49 + ((durationHours + 7) / 3)  * 2 + ((places + 1) / 13) * 3).toInt() ;

          flightInfos.add(FlightInfo(
            flightId: int.parse(flight["flight_number"].toString()),
            departureTime: flight["departure_datetime"].toString().substring(11, 16),
            arrivalTime: flight["arrive_datetime"].toString().substring(11, 16),
            duration: calculateTimeDifference(flight["departure_datetime"].toString().substring(11, 16),
                flight["arrive_datetime"].toString().substring(11, 16)),
            price: dynamicPrice.toString(),
            departureAirport: flight["departure_airport"].toString(),
            destinationAirport: flight["destination_airport"].toString(),
            availableSeats: int.parse(flight["available_seats"].toString()),
          ));
        }
      }
    }

    return flightInfos;
  }


  Future<List<int>> getOccupiedSeats(int flightNumber, String ticketClass) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
    SELECT DISTINCT place_number
    FROM Ticket
    WHERE flight_number = ? AND ticket_class = ? AND status_id = 1
  ''', [flightNumber, ticketClass]);

    return List.generate(maps.length, (i) {
      return maps[i]['place_number'];
    });
  }


  Future<void> bookTicket(int place_number,double price, fareType) async {
    Ticket ticket = Ticket(ticketNum: 1, flightNumber: selectedFlightid, placeNumber: place_number, price: price, statusId: 1, systemUserId: _loggedInUser!.systemUserId, ticketClass: fareType);
    final db = await database;
    await db.transaction((txn) async {
      await txn.insert(
        'Ticket',
        ticket.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      List<Map<String, dynamic>> flights = await txn.query(
        'Flight',
        where: 'flight_number = ?',
        whereArgs: [ticket.flightNumber],
      );
      int availableSeats = flights[0]['available_seats'] - 1;
      await txn.update(
        'Flight',
        {'available_seats': availableSeats},
        where: 'flight_number = ?',
        whereArgs: [ticket.flightNumber],
      );
    });
  }

  Future<List<FlightResult>> getActiveBookings(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
  SELECT 
    Ticket.ticket_num,
    Ticket.place_number,
    Ticket.price,
    Flight.departure_datetime,
    DepartureAirport.location_city || ', ' || DepartureAirport.location_country || ', ' || DepartureAirport.airport_name AS departure_airport,
    ArrivalAirport.location_city || ', ' || ArrivalAirport.location_country || ', ' || ArrivalAirport.airport_name AS arrival_airport,
    Flight.flight_number,
    Ticket.ticket_class
  FROM Ticket
  INNER JOIN Flight ON Ticket.flight_number = Flight.flight_number
  INNER JOIN Airport AS DepartureAirport ON Flight.departure_airport_id = DepartureAirport.airport_id
  INNER JOIN Airport AS ArrivalAirport ON Flight.destination_airport_id = ArrivalAirport.airport_id
  WHERE Ticket.system_user_id = ? AND Ticket.status_id = 1
  ORDER BY Ticket.ticket_num desc
''', [userId]);

    return List.generate(maps.length, (i) {
      return FlightResult(
        ticketNum: maps[i]['ticket_num'],
        seatNumber: maps[i]['place_number'],
        price: maps[i]['price'],
        departureDate: maps[i]['departure_datetime'],
        departureAirport: maps[i]['departure_airport'],
        arrivalAirport: maps[i]['arrival_airport'],
        flightNumber: maps[i]['flight_number'],
        ticketClass: maps[i]['ticket_class'],
      );
    });
  }


  Future<List<FlightResult>> getInactiveBookings(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
    SELECT 
      Ticket.ticket_num,
      Ticket.place_number,
      Ticket.price,
      Flight.departure_datetime,
    DepartureAirport.location_city || ', ' || DepartureAirport.location_country || ', ' || DepartureAirport.airport_name AS departure_airport,
    ArrivalAirport.location_city || ', ' || ArrivalAirport.location_country || ', ' || ArrivalAirport.airport_name AS arrival_airport,
      Flight.flight_number,
      Ticket.ticket_class
    FROM Ticket
    INNER JOIN Flight ON Ticket.flight_number = Flight.flight_number
    INNER JOIN Airport AS DepartureAirport ON Flight.departure_airport_id = DepartureAirport.airport_id
    INNER JOIN Airport AS ArrivalAirport ON Flight.destination_airport_id = ArrivalAirport.airport_id
    WHERE Ticket.system_user_id = ? AND Ticket.status_id != 1 
    ORDER BY Ticket.ticket_num DESC
    LIMIT 20
  ''', [userId]);

    return List.generate(maps.length, (i) {
      return FlightResult(
        ticketNum: maps[i]['ticket_num'],
        seatNumber: maps[i]['place_number'],
        price: maps[i]['price'],
        departureDate: maps[i]['departure_datetime'],
        departureAirport: maps[i]['departure_airport'],
        arrivalAirport: maps[i]['arrival_airport'],
        flightNumber: maps[i]['flight_number'],
        ticketClass: maps[i]['ticket_class'],
      );
    });
  }


  Future<void> cancelBooking(int ticketNum) async {
    final db = await database;

    await db.update(
      'Ticket',
      {'status_id': 2},
      where: 'ticket_num = ?',
      whereArgs: [ticketNum],
    );
  }

  bool isAdmin() {
    return _isAdmin;
  }

  Future<Customer?> authenticateUser(String login, String password) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Customer',
      where: 'user_login = ? AND user_password = ?',
      whereArgs: [login, password],
    );

    if (maps.isNotEmpty) {
      final customerMap = maps.first;
      final customer = Customer.fromMap(customerMap);

      if(customer.userRole == "admin"){
        _isAdmin = true;
        }
      else{
        _isAdmin = false;
      }

      DatabaseHelper.instance.setLoggedInUser(customer);

      return customer;
    } else {
      return null;
    }
  }

  Future<int> getSeatsByClass(int flightId, String classType) async {
    final db = await database;
    var result = await db.rawQuery('''
    SELECT Plane.${classType.toLowerCase()}_seats_capacity
    FROM Flight
    INNER JOIN Plane ON Flight.plane_id = Plane.plane_id
    WHERE Flight.flight_number = ?
  ''', [flightId]);

    if (result.isNotEmpty) {
      int totalSeats = int.parse(result.first["${classType.toLowerCase()}_seats_capacity"].toString());
      _seatsCountByClass = totalSeats;
      return totalSeats;
    } else {
      throw Exception('Flight not found');
    }
  }

  late String _fareType;


  String get fareType => _fareType;

  set fareType(String value) {
    _fareType = value;
  }

  Future<void> insertCustomer(Customer customer) async {
    final db = await database;
    await db.insert('Customer', customer.toMap());
  }

  Future<List<Plane>> getPlanes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('Plane');

    return List.generate(maps.length, (i) {
      return Plane.fromMap(maps[i]);
    });
  }

  Future<void> insertPlane(Plane plane) async {
    final db = await database;
    await db.insert(
      'Plane',
      plane.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updatePlane(Plane plane) async {
    final db = await database;
    await db.update(
      'Plane',
      plane.toMap(),
      where: "plane_id = ?",
      whereArgs: [plane.planeId],
    );
  }
  Future<void> insertAirport(Airport airport) async {
    final db = await database;
    await db.insert(
      'Airport',
      airport.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateAirport(Airport airport) async {
    final db = await database;
    await db.update(
      'Airport',
      airport.toMap(),
      where: "airport_id = ?",
      whereArgs: [airport.airportId],
    );
  }

  Future<List<Airport>> getAirports() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('Airport');

    return List.generate(maps.length, (i) {
      return Airport.fromMap(maps[i]);
    });
  }


  Future<List<Airport>> getAirportsFilteredByCountry(String country) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Airport',
      where: 'location_country = ?',
      whereArgs: [country],
    );

    return List.generate(maps.length, (i) {
      return Airport.fromMap(maps[i]);
    });
  }

  Future<List<Airport>> getAirportsFilteredByCity(String city) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Airport',
      where: 'location_city = ?',
      whereArgs: [city],
    );

    return List.generate(maps.length, (i) {
      return Airport.fromMap(maps[i]);
    });
  }

  Future<List<Airport>> getAirportsFilteredByID(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Airport',
      where: 'airport_id = ?',
      whereArgs: [id],
    );

    return List.generate(maps.length, (i) {
      return Airport.fromMap(maps[i]);
    });
  }


  Future<List<Customer>> getCustomers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('Customer');

    return List.generate(maps.length, (i) {
      return Customer.fromMap(maps[i]);
    });
  }

  Future<void> updateCustomer(Customer customer) async {
    final db = await database;
    await db.update(
      'Customer',
      customer.toMap(),
      where: "system_user_id = ?",
      whereArgs: [customer.systemUserId],
    );
  }

  Future<List<Customer>> getCustomersFilteredById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Customer',
      where: 'system_user_id = ?',
      whereArgs: [id],
    );

    return List.generate(maps.length, (i) {
      return Customer.fromMap(maps[i]);
    });
  }

  Future<List<Customer>> getCustomersFilteredBySurname(String surname) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Customer',
      where: 'user_surname = ?',
      whereArgs: [surname],
    );

    return List.generate(maps.length, (i) {
      return Customer.fromMap(maps[i]);
    });
  }

  Future<List<Customer>> getCustomersFilteredByName(String name) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Customer',
      where: 'user_real_name = ?',
      whereArgs: [name],
    );

    return List.generate(maps.length, (i) {
      return Customer.fromMap(maps[i]);
    });
  }

  Future<List<Flight>> getFlights() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('Flight');

    return List.generate(maps.length, (i) {
      return Flight.fromMap(maps[i]);
    });
  }

  Future<void> updateFlight(Flight flight) async {
    final db = await database;
    await db.update(
      'Flight',
      flight.toMap(),
      where: "flight_number = ?",
      whereArgs: [flight.flightNumber],
    );
  }

  Future<List<String>> getFlightStatusDescriptions() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery('''
    SELECT Flight_status.status_description
    FROM Flight
    INNER JOIN Flight_status ON Flight.status = Flight_status.status_id
  ''');
    return result.map((row) => row['status_description'] as String).toList();
  }

  Future<void> insertFlight(Flight flight) async {
    final db = await database;
    final plane = await getPlaneById(flight.planeId);
    final avSeats = plane.businessSeatsCapacity + plane.economySeatsCapacity;

    flight.availableSeats = avSeats;

    await db.insert(
      'Flight',
      flight.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Plane> getPlaneById(int planeId) async {
    final db = await database;
    final maps = await db.query(
      'Plane',
      where: 'plane_id = ?',
      whereArgs: [planeId],
    );

    if (maps.isNotEmpty) {
      return Plane.fromMap(maps.first);
    } else {
      throw Exception('Plane not found for plane_id: $planeId');
    }
  }

  Future<Flight?> getFlightById(int flightNumber) async {
    final db = await database;
    final maps = await db.query(
      'Flight',
      where: 'flight_number = ?',
      whereArgs: [flightNumber],
    );

    if (maps.isNotEmpty) {
      return Flight.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<List<Flight>> getFlightsByDestinationCountry(String city) async {
    final db = await database;
    final maps = await db.query(
      'Flight',
      where: 'departure_airport_id IN (SELECT airport_id FROM Airport WHERE location_country = ?)',
      whereArgs: [city],
    );

    return List.generate(maps.length, (i) {
      return Flight.fromMap(maps[i]);
    });
  }

  Future<List<Flight>> getFlightsByDepartureCity(String city) async {
    final db = await database;
    final maps = await db.query(
      'Flight',
      where: 'departure_airport_id IN (SELECT airport_id FROM Airport WHERE location_city = ?)',
      whereArgs: [city],
    );

    return List.generate(maps.length, (i) {
      return Flight.fromMap(maps[i]);
    });
  }

  Future<List<Flight>> getFlightsFilteredByID(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Flight',
      where: 'flight_number = ?',
      whereArgs: [id],
    );

    return List.generate(maps.length, (i) {
      return Flight.fromMap(maps[i]);
    });
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''CREATE TABLE Airport (
          airport_id INTEGER PRIMARY KEY AUTOINCREMENT,
          airport_name TEXT,
          location_country TEXT,
          location_city TEXT
        )
''');
    await db.execute('''CREATE TABLE Flight_status (
          status_id INTEGER PRIMARY KEY AUTOINCREMENT,
          status_description TEXT
        )
''');
    await db.execute('''CREATE TABLE Plane (
          plane_id INTEGER PRIMARY KEY AUTOINCREMENT,
          model TEXT NOT NULL,
          business_seats_capacity INTEGER NOT NULL,
          economy_seats_capacity INTEGER NOT NULL
        )
''');
    await db.execute('''CREATE TABLE Flight (
          flight_number INTEGER PRIMARY KEY AUTOINCREMENT,
          plane_id INTEGER NOT NULL,
          departure_airport_id INTEGER NOT NULL,
          destination_airport_id INTEGER NOT NULL,
          departure_datetime TEXT NOT NULL,
          arrive_datetime TEXT NOT NULL,
          available_seats INTEGER NOT NULL,
          status INTEGER NOT NULL,
          FOREIGN KEY (plane_id) REFERENCES Plane(plane_id),
          FOREIGN KEY (departure_airport_id) REFERENCES Airport(airport_id),
          FOREIGN KEY (destination_airport_id) REFERENCES Airport(airport_id),
          FOREIGN KEY (status) REFERENCES Flight_status(status_id)
        )
''');
    await db.execute('''CREATE TABLE Ticket (
          ticket_num INTEGER PRIMARY KEY AUTOINCREMENT,
          flight_number INTEGER NOT NULL,
          place_number INTEGER NOT NULL,
          price REAL NOT NULL,
          status_id INTEGER NOT NULL,
          system_user_id INTEGER NOT NULL,
          ticket_class TEXT CHECK(ticket_class IN ('Regular', 'Business')) NOT NULL,
          FOREIGN KEY (flight_number) REFERENCES Flight(flight_number),
          FOREIGN KEY (status_id) REFERENCES Ticket_status(status_num),
          FOREIGN KEY (system_user_id) REFERENCES Customer(system_user_id)
        )
''');
    await db.execute('''CREATE TABLE Ticket_status (
          status_num INTEGER PRIMARY KEY AUTOINCREMENT,
          status_description TEXT NOT NULL
        )
''');
    await db.execute('''CREATE TABLE Customer (
          system_user_id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_real_name TEXT NOT NULL,
          user_surname TEXT NOT NULL,
          gender TEXT CHECK(gender IN ('Male', 'Female', 'Other')) NOT NULL,
          date_of_birth TEXT NOT NULL,
          passport_series TEXT NOT NULL,
          user_email TEXT NOT NULL UNIQUE,
          user_login TEXT NOT NULL UNIQUE,
          user_password TEXT NOT NULL,
          user_role TEXT CHECK(user_role IN ('user', 'admin')) NOT NULL
        )
''');
  }

  String get destingationCity => _destingationCity;

  set destingationCity(String value) {
    _destingationCity = value;
  }
}
