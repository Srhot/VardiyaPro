# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "🌱 Seeding VardiyaPro database..."
puts ""

# Clear existing data (development only)
if Rails.env.development?
  puts "🧹 Cleaning existing data..."
  User.destroy_all
  Department.destroy_all
  puts "   ✓ Existing data cleared"
  puts ""
end

# Create Departments
puts "🏢 Creating departments..."
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

puts ""

# Create Users
puts "👥 Creating users..."

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

puts ""
puts "✅ Seeding completed successfully!"
puts ""
puts "📊 Summary:"
puts "   - Departments: #{Department.count}"
puts "   - Users: #{User.count}"
puts "     • Admins: #{User.where(role: 'admin').count}"
puts "     • HR: #{User.where(role: 'hr').count}"
puts "     • Managers: #{User.where(role: 'manager').count}"
puts "     • Employees: #{User.where(role: 'employee').count}"
puts ""
puts "🔐 Test Credentials:"
puts "   Admin:    admin@vardiyapro.com / password123"
puts "   HR:       hr@vardiyapro.com / password123"
puts "   Manager:  manager1@vardiyapro.com / password123"
puts "   Employee: employee1@vardiyapro.com / password123"
puts ""
puts "🚀 Ready to test JWT authentication!"
puts "   POST /api/v1/auth/login"
puts "   Body: { email: 'admin@vardiyapro.com', password: 'password123' }"
puts ""
