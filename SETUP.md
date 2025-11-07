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
git clone <repository-url>
cd VardiyaPro
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
DATABASE_PASSWORD=your_password_here
DATABASE_HOST=localhost
DB_POOL=5

JWT_SECRET=your_development_secret_key
JWT_EXPIRY_HOURS=24

RAILS_ENV=development
RAILS_MAX_THREADS=5
```

**⚠️ IMPORTANT:** Never commit `.env` file to git. It's already in `.gitignore`.

### 4. Create and Setup Database

```bash
# Create databases (development and test)
bundle exec rails db:create

# Run migrations (Solid Gems + future models)
bundle exec rails db:migrate

# Load seed data (will be added in Task 1.6)
bundle exec rails db:seed
```

**Expected Output:**
- Creates `vardiyapro_development` and `vardiyapro_test` databases
- Runs 3 migrations:
  1. `CreateSolidCacheEntries` - PostgreSQL-backed caching
  2. `CreateSolidQueueTables` - Background jobs (9 tables)
  3. `CreateSolidCableTables` - WebSocket support

### 5. Verify Setup

```bash
# Check if Rails boots successfully
bundle exec rails console

# In the console, run:
ActiveRecord::Base.connection.active?
# Should return: true

# Check Solid Gems tables exist
ActiveRecord::Base.connection.tables
# Should include: solid_cache_entries, solid_queue_jobs, solid_cable_messages
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

**Total: 11 tables**

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

After successful setup, the following tasks will be implemented:

- ✅ **Task 1.1:** Rails 8.1 project initialized
- ✅ **Task 1.2:** Database configured with ENV variables
- ✅ **Task 1.3:** Solid Gems installed and migrated (YOU ARE HERE)
- ⏭️ **Task 1.4:** JWT Authentication (User model, AuthController)
- ⏭️ **Task 1.6:** Seed data (admin, managers, employees, departments)

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

**Current Phase:** Phase 1 - Foundation
**Completed Tasks:** 1.1, 1.2, 1.3
**Next Task:** 1.4 - JWT Authentication

**Total Progress:** ~20% (Task 3/22)

---

## Support

If you encounter any issues not covered in this guide:

1. Check `README.md` for project overview
2. Review `technical-plan.poml` for architecture details
3. Check `tasks.poml` for implementation roadmap
4. Open an issue on GitHub

---

**Happy Coding! 🚀**
