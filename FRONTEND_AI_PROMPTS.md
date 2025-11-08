# Frontend AI Prompts - VardiyaPro

Bu dosya, VardiyaPro API'sini kullanarak **Google Stitch**, **Lovable**, **v0.dev** veya benzeri AI tabanlı frontend oluşturma platformlarında kullanılmak üzere hazırlanmış **comprehensive prompt**'ları içerir.

---

## Table of Contents

1. [Genel Uygulama Prompt](#1-genel-uygulama-prompt)
2. [Dashboard Prompt](#2-dashboard-prompt)
3. [Shift Management Prompt](#3-shift-management-prompt)
4. [User Management Prompt](#4-user-management-prompt)
5. [Reports & Analytics Prompt](#5-reports--analytics-prompt)
6. [Notification System Prompt](#6-notification-system-prompt)
7. [Tüm Modüller için Kapsamlı Prompt](#7-comprehensive-full-application-prompt)

---

## 1. Genel Uygulama Prompt

```
VardiyaPro - Shift Management System için modern bir web uygulaması tasarla.

# Teknik Gereksinimler:
- Frontend: React 18+ veya Next.js 14+
- Styling: Tailwind CSS veya Material-UI
- State Management: React Context veya Zustand
- HTTP Client: Axios veya Fetch API
- Authentication: JWT token-based

# API Detayları:
- Base URL: http://127.0.0.1:3000/api/v1
- Authentication: Bearer token in Authorization header
- Response Format: JSON

# Ana Özellikler:
1. Login/Authentication sistemi
2. Dashboard (overview statistics)
3. Shift yönetimi (vardiya oluşturma, düzenleme, silme)
4. Çalışan atama (overlap validation ile)
5. Bildirimler (real-time)
6. Raporlar (employee, department, overtime)
7. Kullanıcı yönetimi (admin/manager)

# API Endpoints:
## Authentication
POST /api/v1/auth/login
Body: { email, password }
Response: { token, user: { id, email, name, role } }

## Departments
GET /api/v1/departments
POST /api/v1/departments (admin only)

## Shifts
GET /api/v1/shifts?department_id=1&shift_type=morning
POST /api/v1/shifts
PATCH /api/v1/shifts/:id
DELETE /api/v1/shifts/:id

## Assignments
GET /api/v1/assignments?employee_id=1
POST /api/v1/assignments
PATCH /api/v1/assignments/:id/confirm

## Users
GET /api/v1/users?q=search&role=employee
POST /api/v1/users (admin only)
PATCH /api/v1/users/:id

## Notifications
GET /api/v1/notifications?unread=true
PATCH /api/v1/notifications/mark_all_as_read

## Reports
GET /api/v1/reports/employee/:id?start_date=2025-01-01&end_date=2025-01-31
GET /api/v1/reports/overtime

# Kullanıcı Rolleri:
- admin: Tüm yetkilere sahip
- manager: Departmanı yönetir, shift oluşturur
- employee: Sadece kendi vardiyalarını görür
- hr: Kullanıcı ve rapor yönetimi

# Tasarım Tercihleri:
- Modern ve minimal UI
- Dark mode desteği
- Responsive (mobile-first)
- Accessibility (WCAG 2.1 AA)
- Loading states ve error handling
- Toast notifications
- Confirmation dialogs for destructive actions

# Renk Paleti:
- Primary: Blue (#4A90E2)
- Success: Green (#52C41A)
- Warning: Orange (#FA8C16)
- Danger: Red (#F5222D)
- Background: Light gray (#F5F5F5)
- Text: Dark gray (#333333)

Bu detaylara göre eksiksiz bir web uygulaması oluştur.
```

---

## 2. Dashboard Prompt

```
VardiyaPro için bir Dashboard sayfası tasarla.

# Gereksinimler:
- Üst navbar: Logo, Kullanıcı profili, Notifications icon
- Sol sidebar: Navigation menu (Dashboard, Shifts, Assignments, Users, Reports)
- Ana alan: Statistics ve overview widgets

# Dashboard Widgets:
1. **Statistics Cards (4 adet):**
   - Total Shifts (bu ay)
   - Active Employees
   - Pending Assignments
   - Coverage Rate (%)

2. **Upcoming Shifts List:**
   - Bugünden itibaren sonraki 7 gün
   - Shift type, department, time, assigned count/required count
   - Color-coded by status (filled: green, partial: orange, empty: red)

3. **Recent Activity Feed:**
   - Son 10 aktivite (assignment created, shift confirmed, etc.)
   - Timestamp ve user bilgisi

4. **Department Pie Chart:**
   - Her departmanın shift dağılımı

# API Calls:
GET /api/v1/shifts?upcoming=true&per_page=7
GET /api/v1/assignments?status=pending
GET /api/v1/departments
GET /api/v1/reports/summary?start_date=2025-01-01&end_date=2025-01-31

# Responsive:
- Desktop: 4 column layout
- Tablet: 2 column layout
- Mobile: 1 column stacked

# Interactivity:
- Cards tıklanabilir (ilgili sayfaya yönlendirme)
- Real-time update (30 saniyede bir refresh)
- Loading skeletons

Eksiksiz olarak implement et.
```

---

## 3. Shift Management Prompt

```
VardiyaPro için Shift Management sayfası oluştur.

# Özellikler:
1. **Shift Listesi:**
   - Filtreleme: Department, Shift Type, Date Range, Available Only
   - Arama: Shift description
   - Pagination: 25 per page
   - Sıralama: Start time (ascending/descending)

2. **Shift Card:**
   Her shift card şunları göstermeli:
   - Shift type badge (color-coded: morning=blue, evening=orange, night=purple)
   - Department name
   - Date ve time range
   - Required staff vs Assigned staff (3/5 format)
   - Progress bar (fill rate)
   - Action buttons: View, Edit (manager+), Delete (admin)

3. **Create Shift Modal:**
   Form fields:
   - Department (dropdown)
   - Shift Type (morning, afternoon, evening, night, flexible, on_call)
   - Start Time (datetime picker)
   - End Time (datetime picker)
   - Required Staff (number input, min: 1)
   - Description (textarea, optional)

   Validation:
   - End time > Start time
   - Duration >= 4 hours ve <= 12 hours
   - Required staff >= 1

4. **Assign Employees:**
   - Shift tıklanınca modal açılır
   - Available employees listesi (overlap validation ile)
   - Search by name
   - Assign button ile atama
   - **CRITICAL:** Overlapping shift varsa warning göster

# API Endpoints:
GET /api/v1/shifts?department_id=1&shift_type=morning&upcoming=true
POST /api/v1/shifts
Body: { shift: { department_id, shift_type, start_time, end_time, required_staff, description } }

PATCH /api/v1/shifts/:id
DELETE /api/v1/shifts/:id

GET /api/v1/users?role=employee&department_id=1
POST /api/v1/assignments
Body: { assignment: { shift_id, employee_id, status: "pending" } }

# Hata Handling:
- 422: Validation error (duration too short, etc.)
- 401: Unauthorized
- 403: Forbidden (yetkisiz işlem)

# Success Messages:
- "Shift created successfully!"
- "Employee assigned to shift"
- "CRITICAL: Employee already has an overlapping shift!"

Tam fonksiyonel olarak implement et.
```

---

## 4. User Management Prompt

```
VardiyaPro için User Management sayfası oluştur (Admin/HR only).

# Özellikler:
1. **User Table:**
   Kolonlar:
   - Avatar (initials)
   - Name
   - Email
   - Role (badge: admin=red, manager=blue, hr=green, employee=gray)
   - Department
   - Status (active/inactive toggle)
   - Actions (Edit, Deactivate, View Profile)

2. **Filters & Search:**
   - Search: Name veya email
   - Filter by Role: All, Admin, Manager, Employee, HR
   - Filter by Department: Dropdown
   - Filter by Status: Active, Inactive, All

3. **Create User Form:**
   Fields:
   - Name (required)
   - Email (required, email validation)
   - Password (required, min 6 chars)
   - Password Confirmation (required, match validation)
   - Role (dropdown: admin, manager, employee, hr)
   - Department (dropdown, required for non-admin)
   - Phone (optional)

4. **Edit User:**
   - Same form but password optional
   - Can't change own role
   - Admin can change any user's role

5. **User Profile Modal:**
   Görüntüle:
   - User info
   - Statistics (total shifts, completed, hours this month)
   - Recent assignments (last 10)

# API Endpoints:
GET /api/v1/users?q=search&role=employee&department_id=1&page=1
POST /api/v1/users
Body: { user: { name, email, password, password_confirmation, role, department_id, phone } }

PATCH /api/v1/users/:id
Body: { user: { name, email, role, department_id } }

POST /api/v1/users/:id/activate
POST /api/v1/users/:id/deactivate

GET /api/v1/reports/employee/:id?start_date=2025-01-01&end_date=2025-01-31

# Authorization:
- Admin: Tüm işlemler
- HR: User create/edit/view, reports
- Manager: Sadece kendi departmanındaki users'ı view
- Employee: Unauthorized (403)

# Responsive:
- Desktop: Table view
- Mobile: Card view

Eksiksiz implement et.
```

---

## 5. Reports & Analytics Prompt

```
VardiyaPro için Reports & Analytics sayfası oluştur.

# Report Türleri:
1. **Employee Report:**
   Inputs:
   - Employee (autocomplete dropdown)
   - Start Date
   - End Date

   Display:
   - Total assignments, confirmed, completed, cancelled
   - Total hours
   - Shift type breakdown (bar chart)
   - Recent assignments table

2. **Department Report:**
   Inputs:
   - Department (dropdown)
   - Date range

   Display:
   - Employee statistics table
   - Coverage rate gauge
   - Shift distribution pie chart
   - Top performers list

3. **Overtime Report:**
   Inputs:
   - Date range
   - Standard hours per week (default: 40)

   Display:
   - Employees with overtime
   - Overtime hours table (sorted descending)
   - Total overtime hours
   - Export to CSV button

4. **Summary Dashboard:**
   - Overall statistics
   - Department comparison chart
   - Trends over time (line chart)

# API Endpoints:
GET /api/v1/reports/employee/:id?start_date=2025-01-01&end_date=2025-01-31
Response: { employee, statistics, shift_type_breakdown, recent_assignments }

GET /api/v1/reports/department/:id?start_date=2025-01-01&end_date=2025-01-31
Response: { department, statistics, employee_statistics, shift_type_distribution }

GET /api/v1/reports/overtime?start_date=2025-01-01&end_date=2025-01-31&standard_hours=40
Response: { overtime_employees, total_overtime_hours }

GET /api/v1/reports/summary?start_date=2025-01-01&end_date=2025-01-31

# Charts:
- Library: Chart.js veya Recharts
- Types: Bar, Pie, Line, Gauge

# Export:
- CSV export için client-side generation
- Excel export (bonus)

# Authorization:
- Admin, HR: Tüm raporlar
- Manager: Sadece kendi departmanı
- Employee: Unauthorized

Eksiksiz charts ve export ile implement et.
```

---

## 6. Notification System Prompt

```
VardiyaPro için Notification sistemi oluştur.

# Özellikler:
1. **Notification Bell Icon (Navbar):**
   - Unread count badge
   - Dropdown on click
   - "Mark all as read" button

2. **Notification Dropdown:**
   - Son 10 bildirim
   - Her notification:
     * Title
     * Message
     * Timestamp (relative: "2 hours ago")
     * Type icon (shift, assignment, etc.)
     * Read/Unread indicator
   - "View All" link

3. **Notifications Page:**
   - Tüm bildirimler (paginated)
   - Filter: Unread, All, By Type
   - Mark as read on click
   - Delete button

4. **Notification Types:**
   - shift_assigned: "📅 New shift assigned"
   - shift_confirmed: "✅ Shift confirmed"
   - shift_cancelled: "❌ Shift cancelled"
   - shift_reminder: "⏰ Shift reminder"
   - assignment_confirmed: "✅ Assignment confirmed"

# API Endpoints:
GET /api/v1/notifications?unread=true&per_page=10
Response: { data: [notifications], unread_count }

PATCH /api/v1/notifications/:id/mark_as_read
PATCH /api/v1/notifications/mark_all_as_read
DELETE /api/v1/notifications/:id

# Real-time (Optional):
- Poll every 30 seconds for new notifications
- Or use WebSocket for instant updates

# Toast Notifications:
- Yeni bildirim geldiğinde toast göster
- Auto-dismiss after 5 seconds
- Click to view detail

Eksiksiz implement et.
```

---

## 7. Comprehensive Full Application Prompt

**Tam Kapsamlı Uygulama için AI Prompt (Tüm Modüller):**

```
VardiyaPro - Complete Shift Management System Web Application

# Project Overview:
Modern, full-featured shift management system for organizations to manage employee schedules, assignments, and reporting.

# Tech Stack:
- Frontend: Next.js 14 with App Router
- Styling: Tailwind CSS + shadcn/ui components
- State: Zustand for global state
- Forms: React Hook Form + Zod validation
- HTTP: Axios with interceptors
- Charts: Recharts
- Notifications: React Hot Toast
- Icons: Lucide React
- Date Handling: date-fns

# API Configuration:
Base URL: http://127.0.0.1:3000/api/v1
Authentication: JWT Bearer Token
Token Storage: localStorage
Token Refresh: Automatic on 401

# Complete Feature List:

## 1. Authentication Module
Pages:
- /login - Login form with email/password
- /forgot-password - Password reset (bonus)

Features:
- JWT token management
- Auto-redirect if logged in
- Remember me functionality
- Error handling (invalid credentials, server error)

API:
POST /api/v1/auth/login
Body: { email, password }
Response: { token, user: { id, email, name, role } }

## 2. Dashboard Module
Page: /dashboard

Widgets:
- 4 statistic cards (total shifts, employees, pending, coverage)
- Upcoming shifts calendar view
- Recent activity feed
- Department distribution pie chart
- Quick actions (Create Shift, Assign Employee)

API:
GET /api/v1/shifts?upcoming=true
GET /api/v1/departments
GET /api/v1/assignments?status=pending

## 3. Shift Management Module
Pages:
- /shifts - List all shifts with filters
- /shifts/new - Create new shift
- /shifts/:id - Shift detail with assignments
- /shifts/:id/edit - Edit shift

Features:
- Advanced filters (department, type, date, available)
- Search by description
- Create/Edit/Delete shifts
- Assign employees to shifts
- **CRITICAL: Overlap validation** when assigning
- Bulk actions (bulk assign, bulk delete)
- Export to CSV

Validations:
- Duration: 4-12 hours
- End time > Start time
- Required staff >= 1
- Overlap prevention

API:
GET /api/v1/shifts?department_id=1&shift_type=morning&available=true
POST /api/v1/shifts
PATCH /api/v1/shifts/:id
DELETE /api/v1/shifts/:id
POST /api/v1/assignments { shift_id, employee_id }

## 4. Assignment Management Module
Pages:
- /assignments - All assignments
- /assignments/:id - Assignment detail

Features:
- List assignments with filters (employee, shift, status)
- Confirm/Cancel assignments
- Completion tracking
- Status updates (pending → confirmed → completed)

API:
GET /api/v1/assignments?employee_id=1&status=confirmed
PATCH /api/v1/assignments/:id/confirm
PATCH /api/v1/assignments/:id/cancel
PATCH /api/v1/assignments/:id/complete

## 5. User Management Module (Admin/HR)
Pages:
- /users - User list with table/card view
- /users/new - Create user
- /users/:id - User profile
- /users/:id/edit - Edit user

Features:
- Search by name/email
- Filter by role, department, status
- Create/Edit/Delete users
- Activate/Deactivate users
- Change password
- View user statistics
- Pagination

API:
GET /api/v1/users?q=search&role=employee
POST /api/v1/users
PATCH /api/v1/users/:id
POST /api/v1/users/:id/activate
PATCH /api/v1/users/:id/update_password

## 6. Department Management Module (Admin)
Pages:
- /departments - Department list
- /departments/new - Create department
- /departments/:id - Department detail
- /departments/:id/edit - Edit department

API:
GET /api/v1/departments
POST /api/v1/departments
PATCH /api/v1/departments/:id

## 7. Reports & Analytics Module
Pages:
- /reports - Report selector
- /reports/employee - Employee report
- /reports/department - Department report
- /reports/overtime - Overtime report
- /reports/summary - Overall summary

Features:
- Date range picker
- Export to CSV/PDF
- Interactive charts
- Print view

API:
GET /api/v1/reports/employee/:id?start_date=X&end_date=Y
GET /api/v1/reports/department/:id?start_date=X&end_date=Y
GET /api/v1/reports/overtime?start_date=X&end_date=Y&standard_hours=40
GET /api/v1/reports/summary?start_date=X&end_date=Y

## 8. Notifications Module
Components:
- Notification bell in navbar (with badge)
- Notification dropdown (last 10)
- Notification center page (/notifications)

Features:
- Real-time polling (30s interval)
- Mark as read/unread
- Mark all as read
- Filter by type
- Delete notifications
- Toast for new notifications

API:
GET /api/v1/notifications?unread=true
PATCH /api/v1/notifications/:id/mark_as_read
PATCH /api/v1/notifications/mark_all_as_read
DELETE /api/v1/notifications/:id

## 9. Profile Module
Pages:
- /profile - Current user profile
- /profile/edit - Edit profile
- /profile/password - Change password

Features:
- View/edit own info
- Change password
- View own shifts
- View own statistics

API:
GET /api/v1/users/:id (own ID)
PATCH /api/v1/users/:id
PATCH /api/v1/users/:id/update_password

# Layout Components:
1. **Navbar:**
   - Logo (left)
   - Search bar (center)
   - Notifications bell (right)
   - User menu (right)

2. **Sidebar:**
   - Dashboard
   - Shifts
   - Assignments
   - Users (admin/hr only)
   - Departments (admin only)
   - Reports (admin/hr/manager)
   - Notifications
   - Profile
   - Logout

3. **Footer:**
   - © 2025 VardiyaPro
   - Version 1.0.0
   - Support link

# Authorization Guards:
Implement route protection based on user role:
- /users/* → Admin, HR only
- /departments/* → Admin only
- /reports/* → Admin, HR, Manager (own dept)
- /shifts/new → Admin, Manager
- /shifts/:id/edit → Admin, Manager
- /shifts/:id/delete → Admin only

# UI/UX Requirements:
1. **Responsive:** Mobile, Tablet, Desktop
2. **Dark Mode:** Toggle in user menu
3. **Loading States:** Skeleton loaders, spinners
4. **Empty States:** "No data" illustrations
5. **Error Handling:** Toast for errors, retry buttons
6. **Confirmations:** Modal for destructive actions
7. **Accessibility:** WCAG 2.1 AA, keyboard navigation
8. **Performance:** Code splitting, lazy loading
9. **SEO:** Meta tags, Open Graph

# Color Scheme:
Primary: Blue (#4A90E2)
Secondary: Indigo (#6366F1)
Success: Green (#10B981)
Warning: Orange (#F59E0B)
Error: Red (#EF4444)
Background (light): #F9FAFB
Background (dark): #111827
Text (light): #1F2937
Text (dark): #F9FAFB

# Typography:
Font: Inter
Headings: Font-semibold, sizes: 3xl, 2xl, xl, lg
Body: Font-normal, size: base
Small: Font-normal, size: sm

# Component Library:
Use shadcn/ui components:
- Button
- Input, Textarea
- Select, Combobox
- Dialog (Modal)
- Toast
- Table
- Card
- Badge
- Avatar
- Dropdown Menu
- Calendar
- Date Picker
- Tabs
- Pagination

# Error Handling Strategy:
1. Network errors → Toast with retry
2. 401 Unauthorized → Redirect to login
3. 403 Forbidden → Toast "You don't have permission"
4. 404 Not Found → 404 page
5. 422 Validation → Show validation errors in form
6. 500 Server Error → Toast "Something went wrong"

# Testing Credentials:
Admin: admin@vardiyapro.com / password123
Manager: manager@vardiyapro.com / password123
Employee: employee1@vardiyapro.com / password123

# File Structure:
```
/app
  /(auth)
    /login
  /(dashboard)
    /dashboard
    /shifts
    /assignments
    /users
    /departments
    /reports
    /notifications
    /profile
/components
  /ui (shadcn)
  /layout (Navbar, Sidebar, Footer)
  /features (ShiftCard, UserTable, etc.)
/lib
  /api (axios instance, endpoints)
  /utils (helpers, formatters)
  /hooks (useAuth, useNotifications)
  /store (zustand stores)
/types (TypeScript interfaces)
```

Yukarıdaki tüm detaylara göre eksiksiz, production-ready bir web uygulaması oluştur. Her sayfa tamamen fonksiyonel olmalı, tüm API endpoint'leri kullanılmalı, ve modern UI/UX standartlarına uymalı.
```

---

## Kullanım Talimatları

### Google Stitch / v0.dev / Lovable için:

1. **Platform'a gir**
2. **Yukarıdaki comprehensive prompt'u kopyala**
3. **"New Project" veya "Generate" butonuna tıkla**
4. **Prompt'u yapıştır ve Generate**
5. **Oluşan kodu incele ve gerekirse düzelt**
6. **Export et ve projeye entegre et**

### Figma ile Entegrasyon:

1. **AI tool'dan çıkan tasarımı Figma'ya aktar**
2. **Figma'da düzenle (renk, spacing, typography)**
3. **Figma2Code plugin kullan**
4. **React/Next.js component'leri oluştur**
5. **VardiyaPro projesine ekle**

---

**Son Güncelleme:** 2025-01-08
**Version:** 1.0.0
