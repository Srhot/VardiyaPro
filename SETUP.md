# VardiyaPro - Local Setup Instructions

## Prerequisites

Before running VardiyaPro locally, ensure you have:

- **Ruby 3.3.6** (check with `ruby --version`)
- **PostgreSQL 15** (check with `psql --version`)
- **Bundler** (install with `gem install bundler`)

---

## Installation Steps

### 1. Clone the Repository

```bash
# GitHub'dan projeyi klonla
git clone https://github.com/Srhot/VardiyaPro.git
cd VardiyaPro
```

**Not:** Branch'i kontrol et, çalışma branch'i `claude/spec-driven-poml-issues-011CUu83CoBa4DLyCiPmNEkg`

```bash
# Doğru branch'e geç
git checkout claude/spec-driven-poml-issues-011CUu83CoBa4DLyCiPmNEkg
```

### 2. Install Dependencies

```bash
bundle install
```

This will install 119 gems including:
- Rails 8.1.0
- PostgreSQL adapter (pg gem)
- JWT authentication (bcrypt, jwt)
- Solid Stack (solid_cache, solid_queue, solid_cable)
- Testing framework (rspec-rails, factory_bot, faker)
- Code quality tools (rubocop, brakeman, bullet)

### 3. Setup Environment Variables

```bash
cp .env.example .env
```

Edit `.env` file and update with your local PostgreSQL credentials:

```env
DATABASE_USER=postgres
DATABASE_PASSWORD=2113-Oney
DATABASE_HOST=localhost
DB_POOL=5

JWT_SECRET=vardiyapro-development-secret-key-change-in-production
JWT_EXPIRY_HOURS=24

RAILS_ENV=development
RAILS_MAX_THREADS=5
PORT=3000
```

**⚠️ POSTGRESQL ŞİFRESİ ÖNEMLİ:**
- Yukarıdaki `.env` dosyasında `DATABASE_PASSWORD=2113-Oney` olarak ayarlandı
- Eğer PostgreSQL şifreniz farklıysa, `.env` dosyasında değiştirin
- PostgreSQL kullanıcı adı genellikle `postgres`'tir

**⚠️ IMPORTANT:** Never commit `.env` file to git. It's already in `.gitignore`.

### 4. Create and Setup Database

```bash
# Create databases (development and test)
bundle exec rails db:create

# Run migrations (Solid Gems + Core Models)
bundle exec rails db:migrate

# Load seed data (creates comprehensive test data)
bundle exec rails db:seed
```

**Expected Output:**
- Creates `vardiyapro_development` and `vardiyapro_test` databases
- Runs 7 migrations:
  1. `CreateSolidCacheEntries` - PostgreSQL-backed caching (1 table)
  2. `CreateSolidQueueTables` - Background jobs (9 tables)
  3. `CreateSolidCableTables` - WebSocket support (1 table)
  4. `CreateUsers` - User authentication (1 table)
  5. `CreateDepartments` - Organizational structure (1 table)
  6. `CreateShifts` - Shift management (1 table)
  7. `CreateAssignments` - Employee shift assignments (1 table)
- **Total: 15 tables** (11 Solid + 4 VardiyaPro)
- Seeds database with:
  - 3 Departments (Sales, Operations, Support)
  - 10 Users (1 admin, 1 HR, 3 managers, 5 employees)
  - **~100+ Shifts** (14 days across all departments)
  - **~200+ Assignments** (with overlap validation)

### 5. Verify Setup

```bash
# Check if Rails boots successfully
bundle exec rails console

# In the console, run:
ActiveRecord::Base.connection.active?
# Should return: true

# Check tables exist
ActiveRecord::Base.connection.tables
# Should include: users, departments, solid_cache_entries, solid_queue_jobs, solid_cable_messages

# Verify seed data
User.count
# Should return: 10

Department.count
# Should return: 3

# Test user retrieval
User.find_by(email: 'admin@vardiyapro.com')
# Should return the admin user
```

### 6. Start the Server

```bash
# Start Puma web server (port 3000)
bundle exec rails server

# Or use Procfile (web + worker)
bundle exec foreman start
```

**Server will be available at:** http://localhost:3000

### 7. Test Health Check

```bash
curl http://localhost:3000/up
```

Should return HTTP 200 OK.

### 8. Test API Endpoints

**Test JWT Authentication:**
```bash
# Login as admin
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@vardiyapro.com","password":"password123"}'
```

**Expected Response:**
```json
{
  "data": {
    "token": "eyJhbGciOiJIUzI1NiJ9...",
    "user": {
      "id": 1,
      "email": "admin@vardiyapro.com",
      "name": "System Administrator",
      "role": "admin",
      "department_id": null,
      "active": true
    }
  }
}
```

**Test Departments API:**
```bash
# Get all departments
curl http://localhost:3000/api/v1/departments
```

**Test Shifts API:**
```bash
# Get all shifts
curl http://localhost:3000/api/v1/shifts

# Get shifts for specific department
curl http://localhost:3000/api/v1/shifts?department_id=1

# Get morning shifts only
curl http://localhost:3000/api/v1/shifts?shift_type=morning

# Get upcoming shifts
curl http://localhost:3000/api/v1/shifts?upcoming=true
```

**Test Assignments API:**
```bash
# Get all assignments
curl http://localhost:3000/api/v1/assignments

# Get assignments for specific employee
curl http://localhost:3000/api/v1/assignments?employee_id=5

# Get confirmed assignments only
curl http://localhost:3000/api/v1/assignments?status=confirmed
```

**Test Credentials (from seeds):**
- **Admin:** admin@vardiyapro.com / password123
- **HR:** hr@vardiyapro.com / password123
- **Manager (Sales):** manager1@vardiyapro.com / password123
- **Manager (Operations):** manager2@vardiyapro.com / password123
- **Manager (Support):** manager3@vardiyapro.com / password123
- **Employee:** employee1@vardiyapro.com / password123

---

## Database Schema (Current State)

After running migrations, your database will have:

### Solid Cache (1 table)
- `solid_cache_entries` - Cache storage

### Solid Queue (9 tables)
- `solid_queue_jobs` - Main jobs table
- `solid_queue_scheduled_executions` - Scheduled jobs
- `solid_queue_ready_executions` - Ready to execute
- `solid_queue_claimed_executions` - Currently executing
- `solid_queue_blocked_executions` - Blocked by concurrency
- `solid_queue_failed_executions` - Failed jobs with errors
- `solid_queue_pauses` - Queue pause management
- `solid_queue_processes` - Worker processes
- `solid_queue_semaphores` - Concurrency control

### Solid Cable (1 table)
- `solid_cable_messages` - WebSocket messages

### VardiyaPro Tables (4 tables)

**1. departments** - Organizational departments
- Columns: id, name (unique), description, active, timestamps
- Indexes: name (unique), active

**2. users** - User authentication and profiles
- Columns: id, email (unique), name, role, password_digest, phone, active, department_id, timestamps
- Indexes: email (unique), role, active, department_id
- Roles: admin, manager, employee, hr
- Foreign Keys: department_id → departments.id

**3. shifts** - Work shift scheduling
- Columns: id, department_id, shift_type, start_time, end_time, required_staff, description, active, timestamps
- Shift Types: morning, afternoon, evening, night, flexible, on_call
- Validations: Duration 4-12 hours
- Indexes: department_id, shift_type, start_time, end_time, active
- Foreign Keys: department_id → departments.id

**4. assignments** - Employee shift assignments
- Columns: id, shift_id, employee_id, status, notes, timestamps
- Statuses: pending, confirmed, completed, cancelled
- **🔥 CRITICAL: Overlap validation** prevents double-booking
- Indexes: shift_id, employee_id, status, unique(shift_id, employee_id)
- Foreign Keys: shift_id → shifts.id, employee_id → users.id

**Total: 15 tables** (11 Solid Stack + 4 VardiyaPro)

---

## Troubleshooting

### PostgreSQL Connection Error

**Error:**
```
FATAL: password authentication failed for user "postgres"
```

**Solution:**
1. Check PostgreSQL is running: `pg_isready`
2. Verify credentials in `.env` file
3. Test connection: `psql -U postgres -h localhost`

---

### pg Gem Installation Fails

**Error:**
```
ERROR: Failed to build gem native extension (pg)
```

**Solution (macOS):**
```bash
brew install postgresql@15
bundle install
```

**Solution (Ubuntu/Debian):**
```bash
sudo apt-get install libpq-dev
bundle install
```

---

### Rails Command Not Found

**Error:**
```
bundler: command not found: rails
```

**Solution:**
```bash
# Regenerate binstubs
bundle install --binstubs
chmod +x bin/*

# Or use full path
bundle exec rails <command>
```

---

### Migration Already Exists Error

**Error:**
```
rails aborted! Migrations already exist
```

**Solution:**
This is normal if `db/schema.rb` exists. Rails uses schema file instead of running migrations again. To force re-migration:

```bash
bundle exec rails db:drop db:create db:migrate
```

---

## What's Next?

After successful setup, Phase 1 and Phase 2 are complete!

**Phase 1 - Foundation (COMPLETE ✅):**
- ✅ **Task 1.1:** Rails 8.1 API project initialized
- ✅ **Task 1.2:** Database configured with ENV variables
- ✅ **Task 1.3:** Solid Gems installed and migrated
- ✅ **Task 1.4:** JWT Authentication (User model, AuthController)
- ✅ **Task 1.5:** CORS configured
- ✅ **Task 1.6:** Seed data (3 departments, 10 users)

**Phase 2 - Core MVP (COMPLETE ✅):**
- ✅ **Task 2.1:** Department API Controller (CRUD operations)
- ✅ **Task 2.2:** Shift Model with validations (duration 4-12h)
- ✅ **Task 2.3:** Shifts API Controller with pagination & filtering
- ✅ **Task 2.4:** Assignment Model with **CRITICAL overlap validation** 🔥
- ✅ **Task 2.5:** Assignments API Controller with status management
- ✅ **Task 2.6:** Comprehensive seed data (100+ shifts, 200+ assignments)

**Current Status:** ✅ **Phase 2 Complete - Ready for Testing!** (YOU ARE HERE)

**Next Phase:**
- **Phase 3 - Advanced Features:** Users API, Reports, Notifications, Search
- **Phase 4 - Testing & Production:** RSpec tests, Postman collection, Docker, CI/CD

---

## Development Workflow

### Running Tests

```bash
# Install RSpec (will be done in Phase 4)
bundle exec rails generate rspec:install

# Run all tests
bundle exec rspec

# Run with coverage
COVERAGE=true bundle exec rspec
```

### Code Quality

```bash
# Run RuboCop (style checks)
bundle exec rubocop

# Run Brakeman (security audit)
bundle exec brakeman

# Check for N+1 queries (Bullet gem)
# Automatically enabled in development mode
# Check log/bullet.log after making requests
```

### Database Commands

```bash
# Reset database (drop, create, migrate, seed)
bundle exec rails db:reset

# Rollback last migration
bundle exec rails db:rollback

# Check migration status
bundle exec rails db:migrate:status

# Open database console
bundle exec rails dbconsole
```

---

## Project Status

**Current Phase:** Phase 2 - Core MVP ✅ COMPLETE
**Completed Tasks:** 1.1-1.6 (Phase 1), 2.1-2.6 (Phase 2)
**Next Phase:** Phase 3 - Advanced Features

**Total Progress:** ~55% (Task 12/22)
- **Phase 1 Progress:** 100% (6/6 tasks) ✅
- **Phase 2 Progress:** 100% (6/6 tasks) ✅

---

## Support

If you encounter any issues not covered in this guide:

1. Check `README.md` for project overview
2. Review `technical-plan.poml` for architecture details
3. Check `tasks.poml` for implementation roadmap
4. Open an issue on GitHub

---

**Happy Coding! 🚀**
