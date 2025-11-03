## Recap of 3NF Structure (from your flight booking example)

We had tables like:

### `Passengers`

| PassengerID | PassengerName | PassengerEmail                            |
| ----------- | ------------- | ----------------------------------------- |
| 1           | Alice         | [alice@email.com](mailto:alice@email.com) |
| 2           | Bob           | [bob@email.com](mailto:bob@email.com)     |

### `Flights`

| FlightID | FlightNumber | Source | Destination |
| -------- | ------------ | ------ | ----------- |
| 101      | AI203        | Delhi  | Mumbai      |
| 102      | AI204        | Delhi  | Bangalore   |

### `Bookings`

| BookingID | PassengerID | FlightID | SeatNo | BookingDate |
| --------- | ----------- | -------- | ------ | ----------- |
| 1         | 1           | 101      | 12A    | 2025-11-02  |
| 2         | 2           | 102      | 15C    | 2025-11-02  |

In 3NF — all non-key columns depend directly on the key (no transitive dependencies).

---

## Now, what’s BCNF?

### Definition:

A table is in **Boyce–Codd Normal Form (BCNF)** if:

> For **every functional dependency (X → Y)**,
> **X must be a superkey** (a candidate key or a key that can uniquely identify a row).

That means **no non-trivial dependency** should exist where the determinant (X) is not a key.

---

## Example: When 3NF is *not enough*

Let’s modify our case slightly to see **why BCNF is needed**.

### New Table: `FlightCrew`

| FlightNumber | Pilot | AircraftType |
| ------------ | ----- | ------------ |
| AI203        | John  | Boeing 737   |
| AI204        | Sarah | Airbus A320  |
| AI205        | John  | Boeing 737   |

---

### Dependencies:

1. `FlightNumber → Pilot, AircraftType`  (Each flight has one pilot & aircraft type)
2. `Pilot → AircraftType`  (Each pilot always flies the same type of aircraft — *dependency between non-key attributes!*)

Now, the **primary key** is `FlightNumber`,
but here we have a functional dependency **Pilot → AircraftType**,
and **Pilot** is *not* a key!

That violates BCNF, even though the table is still in 3NF.

---

## Step: Convert to BCNF

To fix this, we decompose the table into two:

### `Flights_BCNF`

| FlightNumber | Pilot |
| ------------ | ----- |
| AI203        | John  |
| AI204        | Sarah |
| AI205        | John  |

### `Pilot_Aircraft`

| Pilot | AircraftType |
| ----- | ------------ |
| John  | Boeing 737   |
| Sarah | Airbus A320  |

Now:

* `FlightNumber` uniquely identifies the pilot
* `Pilot` uniquely identifies the aircraft type 
* Every determinant is a candidate key 

Hence, the schema is now in **BCNF**.

---

## Summary of Normal Forms

| Normal Form | Removes                 | Example Problem Solved                     |
| ----------- | ----------------------- | ------------------------------------------ |
| **1NF**     | Repeating groups        | Multiple tags in one cell                  |
| **2NF**     | Partial dependencies    | Attribute depends on part of composite key |
| **3NF**     | Transitive dependencies | Non-key depends on another non-key         |
| **BCNF**    | Non-key determinants    | Non-key determining another attribute      |

---

Would you like me to add this **BCNF explanation + example** as an additional section at the end of your **flight booking assignment document** (with SQL examples and solution)?
