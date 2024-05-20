CREATE TABLE Airport (
    airport_id INTEGER PRIMARY KEY AUTOINCREMENT,
    airport_name TEXT NOT NULL,
    location_country TEXT NOT NULL,
    location_city TEXT NOT NULL
);

CREATE TABLE Flight_Status (
    status_id INTEGER PRIMARY KEY AUTOINCREMENT,
    status_description TEXT NOT NULL
);

CREATE TABLE Plane (
    plane_id INTEGER PRIMARY KEY AUTOINCREMENT,
    model TEXT NOT NULL,
    business_seats_capacity INTEGER NOT NULL,
    economy_seats_capacity INTEGER NOT NULL
);

CREATE TABLE Flight (
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
    FOREIGN KEY (status) REFERENCES Status(status_id)
);

CREATE TABLE Ticket (
    ticket_num INTEGER PRIMARY KEY AUTOINCREMENT,
    flight_number INTEGER NOT NULL,
    place_number INTEGER NOT NULL,
    price REAL NOT NULL,
    status_id INTEGER NOT NULL,
    system_user_id INTEGER NOT NULL,
    ticket_class TEXT CHECK(ticket_class IN ('Regular', 'Business')) NOT NULL,
    FOREIGN KEY (flight_number) REFERENCES Flight(flight_number),
    FOREIGN KEY (status_id) REFERENCES Status(status_id),
    FOREIGN KEY (system_user_id) REFERENCES Customer(system_user_id)
);

CREATE TABLE Ticket_status (
    status_num INTEGER PRIMARY KEY AUTOINCREMENT,
    status_description TEXT NOT NULL
);

CREATE TABLE Customer (
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
);
