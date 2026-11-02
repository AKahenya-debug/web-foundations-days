# TicketHub – System Design

## 1. Requirements

TicketHub is an online ticketing platform where users can browse concerts and events, view available seats, reserve seats, make payments and access purchased tickets.

### Functional Requirements

The system should allow users to:

1. Register, log in and manage their accounts.
2. Browse upcoming concerts and events.
3. Search and filter events by date, location and category.
4. View event details, ticket prices and available seats.
5. Select and temporarily hold available seats.
6. Pay for reserved tickets using a payment gateway.
7. Receive booking confirmation and electronic tickets.
8. View their purchased tickets and order history.
9. Allow administrators to create events and manage ticket availability.

### Non-Functional Requirements

**Performance (Speed)**

- Event pages should load within 2 seconds under normal conditions.
- Seat availability should update quickly.
- The system should handle sudden increases in traffic during popular ticket sales.

**Correctness (Consistency)**

- A seat must never be sold to two different users.
- Payments and ticket orders must be accurately recorded.
- Seat availability must reflect confirmed bookings.

**Fairness**

- Users should be placed in a fair waiting queue during popular sales.
- Users should not be able to hold the same seat multiple times.
- The system should limit automated requests and bots.
- Users should receive a reasonable opportunity to purchase tickets.

**Availability and Reliability**

- The platform should remain available during major ticket sales.
- Failed payments should not result in confirmed ticket purchases.
- The system should recover from service failures without losing confirmed orders.

**Security**

- User passwords and payment information must be protected.
- Users should only access their own orders and tickets.
- APIs should use authentication and authorization.

---

## 2. Traffic Estimates

TicketHub has 2 million registered users.

### Normal Traffic

Given:

- 50,000 visitors per day.
- Each visitor views 10 pages.
- 5,000 tickets sold per day.

Calculations:

**Daily page views:**

50,000 × 10 = 500,000 page views per day.

**Average page views per second:**

500,000 ÷ 86,400 = approximately 5.8 page views per second.

**Average ticket sales per second:**

5,000 ÷ 86,400 = approximately 0.058 ticket sales per second.

Normal traffic is manageable using a few application servers, caching and a database.

### Big Sale Traffic

Given:

- 200,000 people trying to purchase tickets.
- 20,000 available seats.
- The sale happens within 10 minutes.

Calculations:

**Average incoming users per second:**

200,000 ÷ 600 = approximately 333 users per second.

**Demand compared to available seats:**

200,000 ÷ 20,000 = 10 people competing for every seat.

**Ticket availability:**

20,000 seats are available for 200,000 interested buyers. Only 10% of these users can successfully purchase one seat if each buys one.

### Comparison

| Measurement            |        Normal Day |                                  Big Sale |
| ---------------------- | ----------------: | ----------------------------------------: |
| Visitors               |        50,000/day |                            200,000/10 min |
| Page views             |       500,000/day | Depends on browsing and purchase requests |
| Average incoming users |       0.58/second |                                333/second |
| Tickets available/sold |    5,000 sold/day |                          20,000 available |
| Traffic pattern        | Relatively steady |                      Sudden traffic spike |

The big sale creates a major traffic spike. The system must scale application servers, use caching, introduce a waiting queue and protect the database from too many simultaneous requests.

---

## 3. API Design

The API allows the frontend website to communicate with the backend.

| Method | Endpoint                    | Purpose                            |
| ------ | --------------------------- | ---------------------------------- |
| GET    | /api/events                 | Browse and search events           |
| GET    | /api/events/{eventId}       | View event details                 |
| GET    | /api/events/{eventId}/seats | View available seats               |
| POST   | /api/holds                  | Temporarily reserve selected seats |
| POST   | /api/orders                 | Create an order from held seats    |
| POST   | /api/payments               | Process payment for an order       |
| GET    | /api/tickets                | View a user's purchased tickets    |

### API Explanation

1. **GET /api/events:** Returns a list of available events.
2. **GET /api/events/{eventId}:** Returns details about a specific concert or event.
3. **GET /api/events/{eventId}/seats:** Shows available, held and sold seats.
4. **POST /api/holds:** Temporarily holds seats for a user for a limited period, such as five minutes.
5. **POST /api/orders:** Creates an order linked to the user's seat holds.
6. **POST /api/payments:** Sends payment information to a payment provider and processes the transaction.
7. **GET /api/tickets:** Returns confirmed tickets belonging to the authenticated user.

All purchase-related requests should verify the user's identity and the current status of the seats.

---

## 4. Database Design

TicketHub will use a relational database such as PostgreSQL because it supports transactions, relationships and database constraints.

### Table 1: Users

Stores registered customer information.

| Column        | Data Type | Description             |
| ------------- | --------- | ----------------------- |
| user_id       | INTEGER   | Primary key             |
| name          | VARCHAR   | Customer name           |
| email         | VARCHAR   | Customer email          |
| password_hash | VARCHAR   | Encrypted password hash |
| created_at    | TIMESTAMP | Registration date       |

### Table 2: Events

Stores information about concerts and events.

| Column      | Data Type | Description         |
| ----------- | --------- | ------------------- |
| event_id    | INTEGER   | Primary key         |
| event_name  | VARCHAR   | Event name          |
| location    | VARCHAR   | Event venue         |
| event_date  | TIMESTAMP | Event date and time |
| description | TEXT      | Event description   |

### Table 3: Seats

Stores individual seats for each event.

| Column          | Data Type | Description                     |
| --------------- | --------- | ------------------------------- |
| seat_id         | INTEGER   | Primary key                     |
| event_id        | INTEGER   | Foreign key referencing Events  |
| seat_number     | VARCHAR   | Seat identification             |
| price           | DECIMAL   | Ticket price                    |
| status          | VARCHAR   | Available, held or sold         |
| held_by         | INTEGER   | User currently holding the seat |
| hold_expires_at | TIMESTAMP | Time when the hold expires      |

A unique constraint on `(event_id, seat_number)` ensures that a seat number cannot be duplicated within the same event.

### Table 4: Orders

Stores customer purchases.

| Column            | Data Type | Description                        |
| ----------------- | --------- | ---------------------------------- |
| order_id          | INTEGER   | Primary key                        |
| user_id           | INTEGER   | Foreign key referencing Users      |
| order_date        | TIMESTAMP | Order creation date                |
| total_amount      | DECIMAL   | Total purchase amount              |
| status            | VARCHAR   | Pending, paid, failed or cancelled |
| payment_reference | VARCHAR   | Payment provider reference         |

### Table 5: Order_Items

Connects orders to the seats purchased.

| Column        | Data Type | Description                    |
| ------------- | --------- | ------------------------------ |
| order_item_id | INTEGER   | Primary key                    |
| order_id      | INTEGER   | Foreign key referencing Orders |
| seat_id       | INTEGER   | Foreign key referencing Seats  |
| ticket_code   | VARCHAR   | Unique electronic ticket code  |

### Relationships

- One user can create many orders.
- One order belongs to one user.
- One event can have many seats.
- One order can contain multiple seats through
