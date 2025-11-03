# Database Normalization — Case Study

**Target students:** Intro to Databases / DBMS (beginner)

**Learning objectives**

* Understand the concepts of 1NF, 2NF, and 3NF
* Identify partial and transitive dependencies
* Decompose a given unnormalized table into normalized tables
* Write `CREATE TABLE` and `INSERT` SQL statements for each normal form

---

## Problem statement (base data — unnormalized)

You are given an unnormalized table `flight_bookings_unnormalized` that stores flight booking details, passenger information, seat details, and multiple destinations in one cell.

```sql
CREATE TABLE flight_bookings_unnormalized (
    BookingID INT,
    PassengerName VARCHAR(50),
    PassengerEmail VARCHAR(100),
    FlightNumber VARCHAR(20),
    SeatNumber VARCHAR(10),
    TicketType VARCHAR(20),
    Price DECIMAL(10,2),
    Destinations VARCHAR(200),  -- Multiple destinations in one cell!
    MealPreference VARCHAR(50)
);

INSERT INTO flight_bookings_unnormalized VALUES
(1, 'Alice Johnson', 'alice@email.com', 'AI202', '12A', 'Economy', 320.00, 'Delhi,Paris,London', 'Vegetarian'),
(2, 'Bob Smith', 'bob@email.com', 'AI305', '15B', 'Business', 980.00, 'New York,Chicago', 'Non-Veg'),
(3, 'Alice Johnson', 'alice@email.com', 'AI408', '9C', 'Economy', 250.00, 'Mumbai,Dubai', 'Vegetarian');
```

---

## Assignment tasks (for students)

1. **Explain in one sentence** why the `Destinations` column violates 1NF.
2. **Convert the table into 1NF**: write `CREATE TABLE flight_bookings_1nf` and `INSERT` statements that make `Destination` atomic (one destination per row).
3. **Identify the primary key** of your `flight_bookings_1nf` table and explain if any partial dependencies exist.
4. **Convert to 2NF**: Show how to split data to remove partial dependencies. Provide `CREATE TABLE` and `INSERT` statements for the tables you design. Explain why your decomposition removes partial dependencies.
5. **Convert to 3NF**: Identify any transitive dependencies in the 2NF design. Decompose into 3NF tables with `CREATE TABLE` and `INSERT` statements. Explain why the final design is in 3NF.
6. **Write two sample queries** on the 3NF schema:

   * a) Find all destinations for `BookingID = 1`.
   * b) Find ticket type and price for the passenger who has seat `9C`.

---

## Hints (for students)

* 1NF requires *atomic* values: split comma-separated destinations into separate rows.
* In 1NF, if the key is composite (for example `(BookingID, Destination)`), check whether any non-key attribute depends only on part of that key — that indicates a **partial dependency**.
* 2NF: move attributes that depend only on part of the composite key into their own table(s).
* 3NF: ensure that non-key attributes do not depend on other non-key attributes (transitive dependency). If they do, separate them.

---

## Step-by-step solution (answer key)

> **Note to instructors:** below is a stepwise solution you can show after students attempt the exercise.

### 1) Why `Destinations` violates 1NF

* Because `Destinations` contains multiple location names in one cell (non-atomic). 1NF requires every field to have a single, indivisible value.

---

### 2) Convert to **1NF** — SQL and explanation

**Design choice:** keep all booking and passenger fields but ensure `Destination` is atomic. Table name: `flight_bookings_1nf`.

```sql
CREATE TABLE flight_bookings_1nf (
    BookingID INT,
    PassengerName VARCHAR(50),
    PassengerEmail VARCHAR(100),
    FlightNumber VARCHAR(20),
    SeatNumber VARCHAR(10),
    TicketType VARCHAR(20),
    Price DECIMAL(10,2),
    Destination VARCHAR(50),
    MealPreference VARCHAR(50)
);

INSERT INTO flight_bookings_1nf VALUES
(1, 'Alice Johnson', 'alice@email.com', 'AI202', '12A', 'Economy', 320.00, 'Delhi', 'Vegetarian'),
(1, 'Alice Johnson', 'alice@email.com', 'AI202', '12A', 'Economy', 320.00, 'Paris', 'Vegetarian'),
(1, 'Alice Johnson', 'alice@email.com', 'AI202', '12A', 'Economy', 320.00, 'London', 'Vegetarian'),
(2, 'Bob Smith', 'bob@email.com', 'AI305', '15B', 'Business', 980.00, 'New York', 'Non-Veg'),
(2, 'Bob Smith', 'bob@email.com', 'AI305', '15B', 'Business', 980.00, 'Chicago', 'Non-Veg'),
(3, 'Alice Johnson', 'alice@email.com', 'AI408', '9C', 'Economy', 250.00, 'Mumbai', 'Vegetarian'),
(3, 'Alice Johnson', 'alice@email.com', 'AI408', '9C', 'Economy', 250.00, 'Dubai', 'Vegetarian');
```

**Key point:** `Destination` is now atomic. However, passenger and ticket information repeat — further normalization is needed.

---

### 3) Primary key and partial dependency

* **Primary key candidate:** `(BookingID, Destination)`.
* **Partial dependency:** Attributes like `PassengerName`, `PassengerEmail`, `FlightNumber`, `SeatNumber`, `TicketType`, `Price`, and `MealPreference` depend only on `BookingID`, not on `Destination`. Hence partial dependencies exist.

---

### 4) Convert to **2NF**

Split data into booking-level and destination-level tables.

```sql
CREATE TABLE flight_bookings_2nf (
    BookingID INT PRIMARY KEY,
    PassengerName VARCHAR(50),
    PassengerEmail VARCHAR(100),
    FlightNumber VARCHAR(20),
    SeatNumber VARCHAR(10),
    TicketType VARCHAR(20),
    Price DECIMAL(10,2),
    MealPreference VARCHAR(50)
);

INSERT INTO flight_bookings_2nf VALUES
(1, 'Alice Johnson', 'alice@email.com', 'AI202', '12A', 'Economy', 320.00, 'Vegetarian'),
(2, 'Bob Smith', 'bob@email.com', 'AI305', '15B', 'Business', 980.00, 'Non-Veg'),
(3, 'Alice Johnson', 'alice@email.com', 'AI408', '9C', 'Economy', 250.00, 'Vegetarian');

CREATE TABLE flight_destinations_2nf (
    BookingID INT,
    Destination VARCHAR(50),
    FOREIGN KEY (BookingID) REFERENCES flight_bookings_2nf(BookingID)
);

INSERT INTO flight_destinations_2nf VALUES
(1, 'Delhi'),(1, 'Paris'),(1, 'London'),
(2, 'New York'),(2, 'Chicago'),
(3, 'Mumbai'),(3, 'Dubai');
```

Now all non-key attributes depend on the whole key in each table — partial dependencies removed.

---

### 5) Convert to **3NF**

Passenger information (`PassengerName`, `PassengerEmail`) is repeated — transitive dependency. Split it into a separate table.

```sql
CREATE TABLE passengers_3nf (
    PassengerID INT PRIMARY KEY,
    PassengerName VARCHAR(50),
    PassengerEmail VARCHAR(100)
);

INSERT INTO passengers_3nf VALUES
(1, 'Alice Johnson', 'alice@email.com'),
(2, 'Bob Smith', 'bob@email.com');

CREATE TABLE flight_bookings_3nf (
    BookingID INT PRIMARY KEY,
    PassengerID INT,
    FlightNumber VARCHAR(20),
    SeatNumber VARCHAR(10),
    TicketType VARCHAR(20),
    Price DECIMAL(10,2),
    MealPreference VARCHAR(50),
    FOREIGN KEY (PassengerID) REFERENCES passengers_3nf(PassengerID)
);

INSERT INTO flight_bookings_3nf VALUES
(1, 1, 'AI202', '12A', 'Economy', 320.00, 'Vegetarian'),
(2, 2, 'AI305', '15B', 'Business', 980.00, 'Non-Veg'),
(3, 1, 'AI408', '9C', 'Economy', 250.00, 'Vegetarian');

CREATE TABLE flight_destinations_3nf (
    BookingID INT,
    Destination VARCHAR(50),
    FOREIGN KEY (BookingID) REFERENCES flight_bookings_3nf(BookingID)
);

INSERT INTO flight_destinations_3nf VALUES
(1, 'Delhi'),(1, 'Paris'),(1, 'London'),
(2, 'New York'),(2, 'Chicago'),
(3, 'Mumbai'),(3, 'Dubai');
```

**Why this is 3NF:** each non-key attribute depends only on its table’s primary key, and there are no transitive dependencies.

---

### 6) Sample queries

**a) Find all destinations for BookingID = 1:**

```sql
SELECT Destination FROM flight_destinations_3nf WHERE BookingID = 1;
```

**b) Find ticket type and price for the passenger who has seat 9C:**

```sql
SELECT TicketType, Price
FROM flight_bookings_3nf
WHERE SeatNumber = '9C';
```

---

### Grading rubric (suggested)

* 1NF violation explanation: 5 points
* 1NF SQL correct: 20 points
* PK & partial dependency identified: 10 points
* 2NF decomposition: 25 points
* 3NF decomposition: 25 points
* Queries: 15 points

**Total: 100 points**

---

### Optional challenges

* Extend the schema to 4NF or BCNF.
* Add a `Flights` table with origin, departure time, and arrival time.
* Write a query listing each passenger and the total cost of their bookings.

---

**End of assignment document.**
