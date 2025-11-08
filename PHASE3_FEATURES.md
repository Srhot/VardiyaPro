# Phase 3 Features - TimeEntry & Holiday

## Overview

Phase 3 implementation adds two critical features to VardiyaPro:
1. **Time Entry** - Clock in/out tracking for shift attendance
2. **Holiday** - System-defined holidays for shift planning

## TimeEntry Feature

### Purpose
Track actual employee clock in/out times for shifts, calculate worked hours, and automatically complete assignments.

### Endpoints

#### 1. Clock In
```
POST /api/v1/assignments/:assignment_id/clock_in
Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "notes": "Starting shift (optional)"
}
```

**Response (201):**
```json
{
  "data": {
    "id": 1,
    "assignment_id": 5,
    "assignment": {
      "id": 5,
      "status": "confirmed",
      "shift": {
        "id": 10,
        "title": "Morning Shift",
        "shift_type": "morning",
        "start_time": "2025-01-15T08:00:00Z",
        "end_time": "2025-01-15T16:00:00Z"
      }
    },
    "employee": {
      "id": 3,
      "name": "John Doe",
      "email": "john@example.com"
    },
    "clock_in_time": "2025-01-15T08:02:35Z",
    "clock_out_time": null,
    "worked_hours": 0,
    "notes": "Starting shift",
    "created_at": "2025-01-15T08:02:35Z"
  }
}
```

**Authorization:**
- Employee (own assignment)
- Admin
- Manager

**Validations:**
- Assignment must be `confirmed`
- Time entry must not already exist for assignment
- Must be the assignment's employee, admin, or manager

#### 2. Clock Out
```
PATCH /api/v1/time_entries/:id/clock_out
Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "notes": "Finished shift (optional)"
}
```

**Response (200):**
```json
{
  "data": {
    "id": 1,
    "assignment_id": 5,
    "clock_in_time": "2025-01-15T08:02:35Z",
    "clock_out_time": "2025-01-15T16:05:12Z",
    "worked_hours": 8.05,
    "notes": "Finished shift",
    "created_at": "2025-01-15T08:02:35Z",
    "updated_at": "2025-01-15T16:05:12Z"
  }
}
```

**Side Effects:**
- Assignment status updated to `completed`
- Assignment `completed_at` timestamp set

**Authorization:**
- Employee (own time entry)
- Admin
- HR

#### 3. List Time Entries
```
GET /api/v1/time_entries
Authorization: Bearer {token}
```

**Query Parameters:**
- `status`: `clocked_in` | `clocked_out`
- `start_date`: YYYY-MM-DD (filter by clock_in_time >= start_date)
- `end_date`: YYYY-MM-DD (filter by clock_in_time <= end_date)
- `page`: integer (default: 1)
- `per_page`: integer (default: 25)

**Response (200):**
```json
{
  "data": [
    {
      "id": 1,
      "assignment_id": 5,
      "employee": { "id": 3, "name": "John Doe" },
      "clock_in_time": "2025-01-15T08:02:35Z",
      "clock_out_time": "2025-01-15T16:05:12Z",
      "worked_hours": 8.05
    }
  ],
  "meta": {
    "current_page": 1,
    "next_page": null,
    "prev_page": null,
    "total_pages": 1,
    "total_count": 15
  }
}
```

**Authorization:**
- Employee (own time entries only)
- Admin (all time entries)
- HR (all time entries)

#### 4. Update Time Entry (Admin/HR)
```
PATCH /api/v1/time_entries/:id
Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "clock_in_time": "2025-01-15T08:00:00Z",
  "clock_out_time": "2025-01-15T16:00:00Z",
  "notes": "Time correction"
}
```

**Authorization:** Admin, HR only

#### 5. Delete Time Entry (Admin)
```
DELETE /api/v1/time_entries/:id
Authorization: Bearer {token}
```

**Response:** 204 No Content

**Authorization:** Admin only

---

## Holiday Feature

### Purpose
Define system-wide holidays for shift planning, warnings, and calendar displays.

### Endpoints

#### 1. List Holidays
```
GET /api/v1/holidays
Authorization: Bearer {token}
```

**Query Parameters:**
- `upcoming`: `true` (holidays from today onwards)
- `past`: `true` (holidays before today)
- `year`: integer (e.g., 2025)
- `month`: integer (1-12, requires year)
- `start_date`: YYYY-MM-DD
- `end_date`: YYYY-MM-DD
- `page`: integer (default: 1)
- `per_page`: integer (default: 25)

**Response (200):**
```json
{
  "data": [
    {
      "id": 1,
      "name": "New Year's Day",
      "date": "2025-01-01",
      "is_upcoming": false,
      "is_past": true,
      "is_today": false,
      "created_at": "2025-01-10T10:00:00Z",
      "updated_at": "2025-01-10T10:00:00Z"
    }
  ],
  "meta": {
    "current_page": 1,
    "total_pages": 1,
    "total_count": 6
  }
}
```

**Authorization:** All authenticated users

#### 2. Get Holiday
```
GET /api/v1/holidays/:id
Authorization: Bearer {token}
```

**Response (200):**
```json
{
  "data": {
    "id": 1,
    "name": "New Year's Day",
    "date": "2025-01-01",
    "is_upcoming": false,
    "is_past": true,
    "is_today": false
  }
}
```

#### 3. Create Holiday (Admin)
```
POST /api/v1/holidays
Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "name": "Republic Day",
  "date": "2025-10-29"
}
```

**Response (201):**
```json
{
  "data": {
    "id": 7,
    "name": "Republic Day",
    "date": "2025-10-29",
    "is_upcoming": true
  }
}
```

**Validations:**
- `name`: required
- `date`: required, unique

**Authorization:** Admin only

#### 4. Update Holiday (Admin)
```
PATCH /api/v1/holidays/:id
Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "name": "Updated Name",
  "date": "2025-10-29"
}
```

**Authorization:** Admin only

#### 5. Delete Holiday (Admin)
```
DELETE /api/v1/holidays/:id
Authorization: Bearer {token}
```

**Response:** 204 No Content

**Authorization:** Admin only

#### 6. Check if Date is Holiday
```
GET /api/v1/holidays/check?date=2025-01-01
Authorization: Bearer {token}
```

**Query Parameters:**
- `date`: YYYY-MM-DD (optional, defaults to today)

**Response (200) - Is Holiday:**
```json
{
  "is_holiday": true,
  "holiday": {
    "id": 1,
    "name": "New Year's Day",
    "date": "2025-01-01",
    "is_today": false
  }
}
```

**Response (200) - Not Holiday:**
```json
{
  "is_holiday": false,
  "holiday": null
}
```

**Authorization:** All authenticated users

---

## Database Schema

### time_entries
```sql
CREATE TABLE time_entries (
  id BIGSERIAL PRIMARY KEY,
  assignment_id BIGINT NOT NULL UNIQUE REFERENCES assignments(id),
  clock_in_time TIMESTAMP NOT NULL,
  clock_out_time TIMESTAMP,
  notes TEXT,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);

CREATE UNIQUE INDEX idx_time_entries_assignment ON time_entries(assignment_id);
CREATE INDEX idx_time_entries_clock_in ON time_entries(clock_in_time);
CREATE INDEX idx_time_entries_clock_out ON time_entries(clock_out_time);
```

### holidays
```sql
CREATE TABLE holidays (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR NOT NULL,
  date DATE NOT NULL,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);

CREATE UNIQUE INDEX idx_holidays_date ON holidays(date);
```

---

## Model Validations

### TimeEntry
- `assignment`: presence, uniqueness
- `clock_in_time`: presence
- `clock_out_time`: must be after clock_in_time (if present)

**Methods:**
- `worked_hours`: Returns hours worked (0 if not clocked out)
- `clocked_in?`: Returns true if clocked in but not clocked out
- `clocked_out?`: Returns true if clocked out

**Scopes:**
- `clocked_in`: Entries with no clock_out_time
- `clocked_out`: Entries with clock_out_time
- `for_date_range(start_date, end_date)`: Entries within date range

### Holiday
- `name`: presence
- `date`: presence, uniqueness

**Class Methods:**
- `is_holiday?(date)`: Returns true if date is a holiday
- `holidays_between(start_date, end_date)`: Returns holidays in range

**Instance Methods:**
- `past?`: Returns true if date is before today
- `upcoming?`: Returns true if date is today or later
- `today?`: Returns true if date is today

**Scopes:**
- `upcoming`: Holidays from today onwards
- `past`: Holidays before today
- `for_year(year)`: Holidays in specific year
- `for_month(year, month)`: Holidays in specific month

---

## Seed Data (Turkish National Holidays)

```ruby
Holiday.create!([
  { name: "New Year's Day", date: Date.new(2025, 1, 1) },
  { name: 'National Sovereignty Day', date: Date.new(2025, 4, 23) },
  { name: 'Labor Day', date: Date.new(2025, 5, 1) },
  { name: 'Youth and Sports Day', date: Date.new(2025, 5, 19) },
  { name: 'Victory Day', date: Date.new(2025, 8, 30) },
  { name: 'Republic Day', date: Date.new(2025, 10, 29) }
])
```

---

## Testing

### Test Coverage
- ✅ TimeEntry model specs (validations, scopes, methods)
- ✅ Holiday model specs (validations, scopes, class methods)
- ✅ TimeEntries API specs (clock_in, clock_out, CRUD, authorization)
- ✅ Holidays API specs (CRUD, check endpoint, authorization)

### Factories
- `time_entry` with traits: `:clocked_out`, `:with_notes`, `:yesterday`, `:long_shift`
- `holiday` with traits: `:past`, `:today`, `:upcoming`, `:new_year`, `:christmas`

---

## Postman Collection Updates

### New Folders

#### 9. Time Entries
- **List Time Entries** - GET /time_entries
- **Show Time Entry** - GET /time_entries/:id
- **Clock In** - POST /assignments/:assignment_id/clock_in
- **Clock Out** - PATCH /time_entries/:id/clock_out
- **Update Time Entry (Admin)** - PATCH /time_entries/:id
- **Delete Time Entry (Admin)** - DELETE /time_entries/:id

#### 10. Holidays
- **List Holidays** - GET /holidays
- **List Upcoming Holidays** - GET /holidays?upcoming=true
- **List Holidays by Year** - GET /holidays?year=2025
- **Show Holiday** - GET /holidays/:id
- **Check if Date is Holiday** - GET /holidays/check?date=2025-01-01
- **Create Holiday (Admin)** - POST /holidays
- **Update Holiday (Admin)** - PATCH /holidays/:id
- **Delete Holiday (Admin)** - DELETE /holidays/:id

---

## Example Workflow

### Employee Clocking In/Out

1. **Employee arrives at work and clocks in:**
```bash
POST /api/v1/assignments/5/clock_in
Authorization: Bearer {employee_token}
Body: { "notes": "Starting morning shift" }

Response: 201 Created
{
  "data": {
    "id": 1,
    "clock_in_time": "2025-01-15T08:02:35Z",
    "clock_out_time": null,
    "worked_hours": 0
  }
}
```

2. **Employee finishes work and clocks out:**
```bash
PATCH /api/v1/time_entries/1/clock_out
Authorization: Bearer {employee_token}
Body: { "notes": "Completed shift" }

Response: 200 OK
{
  "data": {
    "id": 1,
    "clock_in_time": "2025-01-15T08:02:35Z",
    "clock_out_time": "2025-01-15T16:05:12Z",
    "worked_hours": 8.05
  }
}

# Assignment automatically marked as 'completed'
```

3. **Admin generates timesheet report:**
```bash
GET /api/v1/time_entries?start_date=2025-01-01&end_date=2025-01-31
Authorization: Bearer {admin_token}

Response: 200 OK
{
  "data": [
    { "employee": "John Doe", "worked_hours": 8.05, ... },
    { "employee": "Jane Smith", "worked_hours": 7.92, ... }
  ],
  "meta": { "total_count": 120 }
}
```

### Admin Managing Holidays

1. **Add a new holiday:**
```bash
POST /api/v1/holidays
Authorization: Bearer {admin_token}
Body: {
  "name": "Company Anniversary",
  "date": "2025-06-15"
}

Response: 201 Created
```

2. **Check if a date is a holiday before scheduling:**
```bash
GET /api/v1/holidays/check?date=2025-06-15
Authorization: Bearer {token}

Response: 200 OK
{
  "is_holiday": true,
  "holiday": {
    "name": "Company Anniversary",
    "date": "2025-06-15"
  }
}
```

3. **List upcoming holidays for planning:**
```bash
GET /api/v1/holidays?upcoming=true
Authorization: Bearer {token}

Response: 200 OK
{
  "data": [
    { "name": "Labor Day", "date": "2025-05-01" },
    { "name": "Company Anniversary", "date": "2025-06-15" },
    { "name": "Victory Day", "date": "2025-08-30" }
  ]
}
```

---

## Phase 3 Status: ✅ COMPLETE

All 5 tasks from Phase 3 are now complete:
- ✅ Task 3.1: Notification Model and API
- ✅ Task 3.2: Integrate Notifications
- ✅ Task 3.3: Reports API
- ✅ Task 3.4: Time Tracking (TimeEntry)
- ✅ Task 3.5: Holiday Model

**Next:** Phase 4 is already complete (tests, Postman, README, security, production config)

**VardiyaPro is now feature-complete per the POML specification! 🎉**
