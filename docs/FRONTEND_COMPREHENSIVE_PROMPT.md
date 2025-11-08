# VardiyaPro Frontend - Comprehensive AI Design Prompt

## 🎯 Purpose
This document contains a comprehensive prompt for AI-powered frontend design tools (Google Stitch, Lovable, v0.dev, Bolt.new, etc.) to generate a complete frontend application for VardiyaPro shift management system.

---

## 📋 COMPREHENSIVE PROMPT FOR AI DESIGN TOOLS

```
Create a modern, responsive frontend application for "VardiyaPro" - a comprehensive shift management system for businesses. The application should be built with React/Next.js and Tailwind CSS.

## PROJECT OVERVIEW

**Name:** VardiyaPro (Turkish: Vardiya = Shift, Pro = Professional)
**Purpose:** Employee shift scheduling, time tracking, and workforce management system
**Target Users:** Admins, HR, Managers, and Employees
**Design Style:** Modern, clean, professional, mobile-first
**Color Scheme:**
- Primary: Blue (#2563EB)
- Secondary: Indigo (#4F46E5)
- Success: Green (#10B981)
- Warning: Yellow (#F59E0B)
- Error: Red (#EF4444)
- Neutral: Gray shades

## USER ROLES & PERMISSIONS

1. **Admin** - Full system access
2. **HR** - User management, reports, all shifts view
3. **Manager** - Department-specific management
4. **Employee** - View own shifts, clock in/out, notifications

## API ENDPOINTS (Backend Ready)

Base URL: http://localhost:3000/api/v1

### Authentication
- POST /auth/login - { email, password } → { token, user }
- POST /auth/refresh - Refresh JWT token
- DELETE /auth/logout - Logout

### Departments
- GET /departments - List all departments
- GET /departments/:id - Get department details
- POST /departments - Create department (admin)
- PATCH /departments/:id - Update department (admin)

### Shifts
- GET /shifts?page=1&per_page=25&shift_type=morning&upcoming=true
- GET /shifts/:id - Get shift details with assignments
- POST /shifts - Create shift (admin/manager)
- PATCH /shifts/:id - Update shift
- DELETE /shifts/:id - Delete shift

### Assignments
- GET /assignments?employee_id=X&status=confirmed
- POST /assignments - Assign employee to shift
- PATCH /assignments/:id/confirm - Confirm assignment
- PATCH /assignments/:id/complete - Mark completed
- PATCH /assignments/:id/cancel - Cancel assignment

### Time Entries (Clock In/Out)
- POST /assignments/:id/clock_in - Clock in to shift
- PATCH /time_entries/:id/clock_out - Clock out from shift
- GET /time_entries?status=clocked_in - List time entries

### Holidays
- GET /holidays?upcoming=true - List holidays
- GET /holidays/check?date=2025-01-01 - Check if date is holiday
- POST /holidays - Create holiday (admin)

### Reports
- GET /reports/employee/:id?start_date=X&end_date=Y - Employee hours report
- GET /reports/department/:id - Department coverage report
- GET /reports/overtime - Overtime report

### Notifications
- GET /notifications?unread=true - List notifications
- PATCH /notifications/:id/mark_as_read - Mark as read

### Users
- GET /users?role=employee - List users
- GET /users/:id - Get user profile
- POST /users - Create user (admin)
- PATCH /users/:id - Update user
- POST /users/:id/activate - Activate user
- POST /users/:id/deactivate - Deactivate user

**Authorization:** All endpoints (except /auth/login) require:
```
Authorization: Bearer <JWT_TOKEN>
```

## REQUIRED PAGES & COMPONENTS

### 1. Login Page
- Email and password fields
- "Remember me" checkbox
- JWT token storage in localStorage
- Redirect to dashboard after successful login
- Error messages for invalid credentials

### 2. Dashboard (Role-based)
- **Admin/HR Dashboard:**
  - Total employees count
  - Active shifts today
  - Pending assignments
  - Upcoming holidays
  - Quick actions: Create shift, Assign employee
  - Recent activity feed

- **Manager Dashboard:**
  - Department stats
  - Today's shifts for department
  - Employee availability
  - Pending approvals

- **Employee Dashboard:**
  - My upcoming shifts (calendar view)
  - Clock in/out button (if shift active)
  - Worked hours this week/month
  - Unread notifications
  - My assignments with status badges

### 3. Shifts Page
- **List View:**
  - Table with columns: Date, Shift Type, Time, Department, Required Staff, Assigned Staff, Status
  - Filters: Date range, Department, Shift type, Status
  - Pagination (25 per page)
  - "Create Shift" button (admin/manager)

- **Calendar View:**
  - Weekly/Monthly calendar
  - Color-coded shifts by type:
    - Morning: Light blue
    - Afternoon: Orange
    - Evening: Purple
    - Night: Dark blue
  - Click shift to see details modal

- **Shift Details Modal:**
  - Shift info: Title, Date, Time, Type, Location, Notes
  - Department and required staff
  - Assigned employees list with avatars
  - "Edit Shift" button (admin/manager)
  - "Delete Shift" button (admin only)
  - "Assign Employee" button

### 4. Assignments Page
- **My Assignments (Employee):**
  - List of assigned shifts
  - Status badges: Pending, Confirmed, Completed, Cancelled
  - Confirm/Decline buttons
  - Clock in/out buttons (if confirmed)

- **All Assignments (Admin/Manager):**
  - Table with filters: Employee, Shift, Status, Date range
  - Bulk actions: Confirm selected, Cancel selected
  - "Create Assignment" button

### 5. Time Tracking Page
- **Employee View:**
  - Clock in/out interface with large button
  - Current shift info if clocked in
  - Timer showing elapsed time
  - Today's worked hours
  - Weekly timesheet table

- **Admin/HR View:**
  - All employees' time entries
  - Filters: Employee, Date range, Status
  - Export to CSV button
  - Edit time entry button (corrections)

### 6. Employees Page (Admin/HR)
- **List View:**
  - Table: Name, Email, Role, Department, Status (Active/Inactive)
  - Filters: Role, Department, Status
  - Search by name/email
  - "Add Employee" button

- **Employee Details:**
  - Profile info: Name, Email, Phone, Role, Department
  - Active/Inactive toggle
  - Edit profile button
  - Assigned shifts history
  - Worked hours statistics

- **Add/Edit Employee Modal:**
  - Form fields: Name, Email, Password, Role, Department, Phone
  - Role dropdown: Admin, HR, Manager, Employee
  - Department dropdown
  - Save/Cancel buttons

### 7. Departments Page
- Grid/List of departments
- Department card: Name, Description, Employee count, Manager
- "Create Department" button (admin)
- Click to see department details and shifts

### 8. Holidays Page
- Calendar showing holidays with names
- List view with filters: Upcoming, Past, By year
- "Check Holiday" feature: Enter date, see if it's a holiday
- "Add Holiday" button (admin only)

### 9. Reports Page (Admin/HR)
- **Employee Report:**
  - Select employee and date range
  - Display: Total hours, Regular hours, Overtime, Shifts count
  - Visual chart (bar/line graph)

- **Department Report:**
  - Select department and date range
  - Coverage statistics
  - Employee distribution

- **Overtime Report:**
  - All employees with overtime
  - Sortable table
  - Export to CSV

### 10. Notifications Page
- List of notifications with:
  - Icon based on type (info, warning, success)
  - Title and message
  - Timestamp (relative: "2 hours ago")
  - Read/Unread indicator
- "Mark all as read" button
- Filter: All, Unread only

### 11. Profile Page
- User info: Name, Email, Role, Department
- Change password form
- Profile picture upload
- Preferences: Language, Timezone, Email notifications

## UI/UX REQUIREMENTS

### Layout
- **Sidebar Navigation (Desktop):**
  - Logo at top
  - Navigation items with icons:
    - Dashboard
    - Shifts
    - Assignments (badge for pending count)
    - Time Tracking
    - Employees (admin/hr only)
    - Departments
    - Holidays
    - Reports (admin/hr only)
    - Notifications (badge for unread count)
  - User profile at bottom with logout

- **Mobile Navigation:**
  - Bottom tab bar with main items
  - Hamburger menu for additional items
  - Responsive layout for all screen sizes

### Components to Create

1. **Reusable Components:**
   - Button (primary, secondary, danger, ghost variants)
   - Input (text, email, password, date, select)
   - Card with header, body, footer
   - Modal dialog
   - Toast notifications
   - Loading spinner
   - Empty state (no data)
   - Error state
   - Pagination
   - Badge (status indicators)
   - Avatar with fallback initials
   - Dropdown menu
   - Date picker
   - Time picker
   - Data table with sorting

2. **Shift-Specific Components:**
   - ShiftCard (shows shift info in card format)
   - ShiftTypebadge (color-coded)
   - StatusBadge (assignment/shift status)
   - EmployeeAvatar (with name and role)
   - CalendarView (weekly/monthly)
   - TimelinView (today's shifts)

3. **Forms:**
   - LoginForm
   - CreateShiftForm
   - CreateAssignmentForm
   - CreateEmployeeForm
   - CreateDepartmentForm
   - CreateHolidayForm
   - ClockInOutForm
   - ChangePasswordForm

### Design Patterns

1. **Colors:**
   - Use semantic colors: success, warning, error, info
   - Shift types: morning (blue), afternoon (orange), evening (purple), night (dark blue)
   - Status: pending (yellow), confirmed (green), cancelled (red), completed (gray)

2. **Typography:**
   - Headings: Bold, clear hierarchy (H1, H2, H3)
   - Body text: Readable, 16px base size
   - Labels: Uppercase, small, gray color
   - Use Inter or similar modern sans-serif font

3. **Spacing:**
   - Consistent padding: 4px, 8px, 16px, 24px, 32px
   - Card spacing: 16px padding
   - Section spacing: 32px margin

4. **Animations:**
   - Smooth transitions (200ms ease)
   - Hover effects on buttons and cards
   - Loading states with skeleton screens
   - Toast notifications slide in from top-right

### Accessibility (WCAG)

- Keyboard navigation support
- ARIA labels for screen readers
- Focus indicators
- Sufficient color contrast (4.5:1 minimum)
- Alt text for images
- Form labels and error messages
- Skip to main content link

### Mobile Responsiveness

- Breakpoints:
  - Mobile: < 768px
  - Tablet: 768px - 1024px
  - Desktop: > 1024px

- Mobile-specific features:
  - Touch-friendly buttons (44px minimum)
  - Swipe gestures for calendar
  - Bottom sheet modals instead of center modals
  - Collapsible sections

## STATE MANAGEMENT

Use React Context or Zustand for:
- User authentication state (token, user info)
- Current user role
- Notifications count
- Theme preferences

## API INTEGRATION

```javascript
// Example API calls with axios

// Login
const login = async (email, password) => {
  const response = await axios.post('/api/v1/auth/login', { email, password });
  localStorage.setItem('token', response.data.token);
  return response.data;
};

// Get Shifts (with auth)
const getShifts = async (params) => {
  const token = localStorage.getItem('token');
  const response = await axios.get('/api/v1/shifts', {
    headers: { Authorization: `Bearer ${token}` },
    params
  });
  return response.data;
};

// Clock In
const clockIn = async (assignmentId, notes) => {
  const token = localStorage.getItem('token');
  const response = await axios.post(
    `/api/v1/assignments/${assignmentId}/clock_in`,
    { notes },
    { headers: { Authorization: `Bearer ${token}` } }
  );
  return response.data;
};
```

## EXAMPLE USER FLOWS

### Flow 1: Admin Creates Shift and Assigns Employee
1. Admin logs in
2. Navigates to Shifts page
3. Clicks "Create Shift" button
4. Fills form: Title, Date/Time, Type, Department, Required staff
5. Submits form → Shift created
6. Clicks "Assign Employee" on new shift
7. Selects employee from dropdown
8. Submits → Assignment created
9. Employee receives notification

### Flow 2: Employee Clocks In and Out
1. Employee logs in
2. Dashboard shows "Clock In" button (shift starting soon)
3. Clicks "Clock In" → Time entry created
4. Dashboard shows timer with elapsed time and "Clock Out" button
5. After shift, clicks "Clock Out" → Time entry completed
6. Assignment status changes to "Completed"

### Flow 3: Manager Views Department Report
1. Manager logs in
2. Navigates to Reports page
3. Selects "Department Report"
4. Chooses date range
5. Views coverage statistics and charts
6. Exports to CSV

## ERROR HANDLING

- Show toast notification for API errors
- Display inline error messages for form validation
- Network error: "Unable to connect. Please check your internet."
- 401 Unauthorized: Redirect to login page
- 403 Forbidden: "You don't have permission for this action"
- 404 Not Found: "Resource not found"
- 500 Server Error: "Something went wrong. Please try again."

## TESTING CREDENTIALS

```
Admin:
  Email: admin@vardiyapro.com
  Password: password123

Manager:
  Email: manager1@vardiyapro.com
  Password: password123

Employee:
  Email: employee1@vardiyapro.com
  Password: password123
```

## ADDITIONAL FEATURES

1. **Dark Mode Toggle** (optional)
2. **Language Switcher** (TR/EN) - optional
3. **Real-time Notifications** (WebSocket) - future enhancement
4. **Offline Mode** (PWA) - future enhancement
5. **Export to PDF** for reports
6. **Email Notifications** (backend handles this)

## DELIVERABLES

Please generate:
1. Complete React/Next.js application with all pages
2. Reusable component library
3. API integration with axios
4. Responsive design (mobile, tablet, desktop)
5. Authentication flow with JWT
6. Role-based access control
7. Loading states and error handling
8. README with setup instructions

## TECH STACK PREFERENCE

- **Framework:** React 18+ or Next.js 14+
- **Styling:** Tailwind CSS
- **Icons:** Lucide React or Heroicons
- **HTTP Client:** Axios
- **Date Handling:** date-fns or Day.js
- **Forms:** React Hook Form + Zod validation
- **State:** React Context or Zustand
- **Routing:** React Router or Next.js App Router
- **Build Tool:** Vite or Next.js

Start with the login page and dashboard, then build out the other pages systematically.
```

---

## 🎨 Visual Design References

### Color Palette

```css
:root {
  /* Primary */
  --blue-50: #EFF6FF;
  --blue-500: #3B82F6;
  --blue-600: #2563EB;
  --blue-700: #1D4ED8;

  /* Success */
  --green-50: #ECFDF5;
  --green-500: #10B981;
  --green-600: #059669;

  /* Warning */
  --yellow-50: #FEFCE8;
  --yellow-500: #F59E0B;
  --yellow-600: #D97706;

  /* Error */
  --red-50: #FEF2F2;
  --red-500: #EF4444;
  --red-600: #DC2626;

  /* Neutral */
  --gray-50: #F9FAFB;
  --gray-100: #F3F4F6;
  --gray-200: #E5E7EB;
  --gray-500: #6B7280;
  --gray-700: #374151;
  --gray-900: #111827;
}
```

### Component Examples

**Button:**
```jsx
<button className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition">
  Create Shift
</button>
```

**Card:**
```jsx
<div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
  <h3 className="text-lg font-semibold text-gray-900 mb-2">Shift Title</h3>
  <p className="text-gray-600">Shift details...</p>
</div>
```

**Badge:**
```jsx
<span className="px-2 py-1 text-xs font-medium bg-green-100 text-green-800 rounded-full">
  Confirmed
</span>
```

---

## 📱 Mobile Mockup Structure

```
┌─────────────────────┐
│  VardiyaPro  [🔔 3] │  <- Header with logo and notifications
├─────────────────────┤
│                     │
│  [Dashboard Cards]  │  <- Main content area
│  [Calendar View]    │
│  [Shift List]       │
│                     │
├─────────────────────┤
│ 🏠 📅 ⏰ 👤         │  <- Bottom navigation
└─────────────────────┘
```

---

## 🖥️ Desktop Mockup Structure

```
┌──────────┬─────────────────────────────────────┐
│          │  VardiyaPro     [Search] [🔔 3] [👤] │  <- Top bar
│  SIDEBAR ├─────────────────────────────────────┤
│          │                                     │
│ Dashboard│        MAIN CONTENT AREA            │
│ Shifts   │                                     │
│ Time     │  [Cards, Tables, Forms, etc.]       │
│ ...      │                                     │
│          │                                     │
│ [Profile]│                                     │
│ [Logout] │                                     │
└──────────┴─────────────────────────────────────┘
```

---

## 🚀 Usage Instructions

### For Google Stitch / Lovable / v0.dev / Bolt.new:

1. Copy the entire prompt from the "COMPREHENSIVE PROMPT" section
2. Paste it into the AI tool's input field
3. Wait for the initial generation
4. Review and iterate with specific requests:
   - "Make the calendar view more prominent"
   - "Add animation to the clock in/out button"
   - "Improve the mobile navigation"

### For Figma Design:

After AI generates the UI:
1. Export designs to Figma
2. Refine colors, spacing, typography
3. Add interactions and prototypes
4. Use Figma2Code plugin to generate React components

---

## ✅ Checklist

- [ ] Copy comprehensive prompt
- [ ] Generate frontend with AI tool (Lovable/Stitch/v0)
- [ ] Review generated components
- [ ] Test with backend API (localhost:3000)
- [ ] Adjust designs in Figma
- [ ] Convert Figma to code with Figma2Code
- [ ] Integrate with VardiyaPro backend
- [ ] Test all user flows
- [ ] Deploy frontend

---

**Hazırlayan:** Claude AI for VardiyaPro
**Tarih:** 2025-01-11
**Versiyon:** 1.0.0
