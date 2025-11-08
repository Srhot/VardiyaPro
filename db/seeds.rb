# frozen_string_literal: true

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts '🌱 Seeding VardiyaPro database...'
puts ''

# Clear existing data (development only)
if Rails.env.development?
  puts '🧹 Cleaning existing data...'
  Assignment.destroy_all
  Shift.destroy_all
  User.destroy_all
  Department.destroy_all
  puts '   ✓ Existing data cleared'
  puts ''
end

# Create Departments
puts '🏢 Creating departments...'
departments = [
  { name: 'Sales', description: 'Sales and customer acquisition team' },
  { name: 'Operations', description: 'Day-to-day operations and logistics' },
  { name: 'Support', description: 'Customer support and success team' }
]

created_departments = departments.map do |dept_attrs|
  dept = Department.create!(dept_attrs)
  puts "   ✓ #{dept.name} department created"
  dept
end

puts ''

# Create Users
puts '👥 Creating users...'

# 1. Admin User
admin = User.create!(
  email: 'admin@vardiyapro.com',
  name: 'System Administrator',
  role: 'admin',
  password: 'password123',
  password_confirmation: 'password123',
  phone: '+90 555 000 0001',
  active: true
)
puts "   ✓ Admin: #{admin.email} (password: password123)"

# 2. HR User
hr = User.create!(
  email: 'hr@vardiyapro.com',
  name: 'HR Manager',
  role: 'hr',
  password: 'password123',
  password_confirmation: 'password123',
  phone: '+90 555 000 0002',
  active: true
)
puts "   ✓ HR: #{hr.email} (password: password123)"

# 3. Managers (one per department)
managers = []
created_departments.each_with_index do |dept, index|
  manager = User.create!(
    email: "manager#{index + 1}@vardiyapro.com",
    name: "#{dept.name} Manager",
    role: 'manager',
    password: 'password123',
    password_confirmation: 'password123',
    phone: "+90 555 000 00#{10 + index}",
    department: dept,
    active: true
  )
  managers << manager
  puts "   ✓ Manager: #{manager.email} (#{dept.name} department)"
end

# 4. Employees (distributed across departments)
employees = []
5.times do |i|
  dept = created_departments.sample
  employee = User.create!(
    email: "employee#{i + 1}@vardiyapro.com",
    name: Faker::Name.name,
    role: 'employee',
    password: 'password123',
    password_confirmation: 'password123',
    phone: Faker::PhoneNumber.cell_phone,
    department: dept,
    active: true
  )
  employees << employee
  puts "   ✓ Employee: #{employee.email} (#{dept.name} department) - #{employee.name}"
end

puts ''

# Create Shifts
puts '⏰ Creating shifts...'

# Get date range: next 14 days
base_date = Date.today
shifts_created = []

# Shift type definitions with time ranges
shift_definitions = {
  morning: { start_hour: 8, end_hour: 16 },    # 08:00 - 16:00
  afternoon: { start_hour: 12, end_hour: 20 }, # 12:00 - 20:00
  evening: { start_hour: 16, end_hour: 24 },   # 16:00 - 24:00
  night: { start_hour: 0, end_hour: 8 }        # 00:00 - 08:00
}

# Create shifts for next 14 days
14.times do |day_offset|
  date = base_date + day_offset.days

  # Each department gets 2-3 shifts per day
  created_departments.each do |dept|
    # Morning shift (every day)
    morning_start = date.to_time + shift_definitions[:morning][:start_hour].hours
    morning_end = date.to_time + shift_definitions[:morning][:end_hour].hours

    morning_shift = Shift.create!(
      department: dept,
      shift_type: 'morning',
      start_time: morning_start,
      end_time: morning_end,
      required_staff: rand(2..3),
      description: "Morning shift for #{dept.name}",
      active: true
    )
    shifts_created << morning_shift

    # Evening shift (every day)
    evening_start = date.to_time + shift_definitions[:evening][:start_hour].hours
    evening_end = date.to_time + shift_definitions[:evening][:end_hour].hours

    evening_shift = Shift.create!(
      department: dept,
      shift_type: 'evening',
      start_time: evening_start,
      end_time: evening_end,
      required_staff: rand(1..2),
      description: "Evening shift for #{dept.name}",
      active: true
    )
    shifts_created << evening_shift

    # Night shift (only on weekdays)
    next unless date.wday.between?(1, 5)

    night_start = date.to_time + 1.day # Night shift starts at midnight
    night_end = night_start + shift_definitions[:night][:end_hour].hours

    night_shift = Shift.create!(
      department: dept,
      shift_type: 'night',
      start_time: night_start,
      end_time: night_end,
      required_staff: 1,
      description: "Night shift for #{dept.name}",
      active: true
    )
    shifts_created << night_shift
  end
end

puts "   ✓ Created #{shifts_created.count} shifts across #{created_departments.count} departments"

puts ''

# Create Assignments
puts '📋 Creating assignments...'

assignments_created = []
all_employees = employees # Only assign to employee role users

# Distribute assignments
shifts_created.each do |shift|
  # Get department employees
  dept_employees = all_employees.select { |emp| emp.department_id == shift.department_id }
  next if dept_employees.empty?

  # Assign required_staff employees to this shift
  assigned_count = 0
  attempts = 0
  max_attempts = dept_employees.size * 2

  while assigned_count < shift.required_staff && attempts < max_attempts
    employee = dept_employees.sample
    attempts += 1

    # Try to create assignment (will fail if overlap detected)
    begin
      assignment = Assignment.create!(
        shift: shift,
        employee: employee,
        status: %w[pending confirmed].sample,
        notes: 'Auto-assigned'
      )
      assignments_created << assignment
      assigned_count += 1
    rescue ActiveRecord::RecordInvalid
      # Skip if employee has overlapping shift or shift is full
      next
    end
  end
end

puts "   ✓ Created #{assignments_created.count} assignments"
puts '   ✓ Assignments by status:'
puts "     • Pending: #{Assignment.pending.count}"
puts "     • Confirmed: #{Assignment.confirmed.count}"

puts ''
puts '✅ Seeding completed successfully!'
puts ''
puts '📊 Summary:'
puts "   - Departments: #{Department.count}"
puts "   - Users: #{User.count}"
puts "     • Admins: #{User.where(role: 'admin').count}"
puts "     • HR: #{User.where(role: 'hr').count}"
puts "     • Managers: #{User.where(role: 'manager').count}"
puts "     • Employees: #{User.where(role: 'employee').count}"
puts "   - Shifts: #{Shift.count}"
puts "     • By type: Morning (#{Shift.by_type('morning').count}), Evening (#{Shift.by_type('evening').count}), Night (#{Shift.by_type('night').count})"
puts "   - Assignments: #{Assignment.count}"
puts "     • Confirmed: #{Assignment.confirmed.count}"
puts "     • Pending: #{Assignment.pending.count}"
puts ''
puts '🔐 Test Credentials:'
puts '   Admin:    admin@vardiyapro.com / password123'
puts '   HR:       hr@vardiyapro.com / password123'
puts '   Manager:  manager1@vardiyapro.com / password123'
puts '   Employee: employee1@vardiyapro.com / password123'
puts ''
puts '🚀 Ready to test the API!'
puts ''
puts 'Authentication:'
puts '   POST /api/v1/auth/login'
puts '   Body: { "email": "admin@vardiyapro.com", "password": "password123" }'
puts ''
puts 'Departments:'
puts '   GET /api/v1/departments'
puts ''
puts 'Shifts:'
puts '   GET /api/v1/shifts'
puts '   GET /api/v1/shifts?department_id=1'
puts '   GET /api/v1/shifts?shift_type=morning'
puts '   GET /api/v1/shifts?upcoming=true'
puts ''
puts 'Assignments:'
puts '   GET /api/v1/assignments'
puts '   GET /api/v1/assignments?employee_id=5'
puts '   GET /api/v1/assignments?status=confirmed'
puts '   PATCH /api/v1/assignments/:id/confirm (requires admin/hr/manager auth)'
puts ''
puts '🔥 CRITICAL FEATURE ENABLED:'
puts '   ✅ Overlap validation - prevents double-booking employees!'
puts ''
