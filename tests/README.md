# VardiyaPro - Playwright E2E Test Suite

## 📋 Overview

This directory contains comprehensive end-to-end (E2E) tests for VardiyaPro Shift Management System, written using **Playwright** with **BDD (Behavior Driven Development)** approach.

### Test Coverage

- ✅ **Authentication**: Login, Logout, Role-based access
- ✅ **Navigation**: SPA routing, Browser back/forward, Role-based menus
- ✅ **CRUD Operations**: Departments (Create, Read, Update)
- ✅ **Reports**: Summary reports, API integration
- ✅ **Video Recording**: All tests recorded automatically

### Test Statistics

| Category | Test Count | Status |
|----------|------------|--------|
| Authentication | 6 tests | ✅ |
| Navigation | 8 tests | ✅ |
| Departments CRUD | 7 tests | ✅ |
| Reports | 8 tests | ✅ |
| **Total** | **29 tests** | ✅ |

---

## 🚀 Quick Start

### Prerequisites

1. **Node.js** installed (v16 or higher)
2. **Playwright** installed globally or locally
3. **VardiyaPro backend** running on `http://127.0.0.1:3000`

### Installation

```bash
cd tests
npm install
```

This will install:
- `@playwright/test` - Playwright testing framework
- `@axe-core/playwright` - Accessibility testing (for future WCAG tests)

### Install Playwright Browsers

```bash
npx playwright install chromium
```

---

## 🎬 Running Tests

### Run All Tests (with video recording)

```bash
npm test
```

### Run Tests in Headed Mode (See browser)

```bash
npm run test:headed
```

### Run Tests with UI Mode (Interactive debugging)

```bash
npm run test:ui
```

### Run Specific Test File

```bash
npx playwright test e2e/specs/auth.spec.js
```

### Run Tests by Tag

```bash
# Run only negative tests
npx playwright test --grep @negative
```

### Debug Mode

```bash
npm run test:debug
```

### Generate and View HTML Report

```bash
npm run test:report
```

---

## 📁 Project Structure

```
tests/
├── e2e/
│   ├── pages/                  # Page Object Model (POM)
│   │   ├── LoginPage.js        # Login page interactions
│   │   ├── DashboardPage.js    # Dashboard and navigation
│   │   ├── DepartmentsPage.js  # Departments CRUD operations
│   │   └── ReportsPage.js      # Reports and analytics
│   └── specs/                  # Test specifications (BDD style)
│       ├── auth.spec.js        # Authentication tests
│       ├── navigation.spec.js  # Navigation and routing tests
│       ├── departments.spec.js # Departments CRUD tests
│       └── reports.spec.js     # Reports tests
├── test-results/               # Generated test results
│   ├── videos/                 # Video recordings
│   ├── screenshots/            # Failure screenshots
│   └── html-report/            # HTML test report
├── package.json                # Dependencies
├── playwright.config.js        # Playwright configuration
└── README.md                   # This file
```

---

## 📝 BDD Test Format

All tests follow **BDD (Behavior Driven Development)** approach with **Given-When-Then** structure:

```javascript
test('Scenario: Successful login with admin credentials', async ({ page }) => {
  // GIVEN I am on the login page
  await loginPage.verifyLoginPageVisible();

  // WHEN I enter valid admin credentials
  await test.step('I fill in the email field', async () => {
    await loginPage.fillCredentials(email, password);
  });

  // AND I click the login button
  await test.step('I click the login button', async () => {
    await loginPage.clickLogin();
  });

  // THEN I should be redirected to the dashboard
  await test.step('I should see the dashboard', async () => {
    await loginPage.verifyLoginSuccess();
    await dashboardPage.verifyDashboardLoaded();
  });
});
```

---

## 🎥 Video Recording

### Automatic Video Recording

All tests are automatically recorded with video. Configuration in `playwright.config.js`:

```javascript
use: {
  video: 'on',
  viewport: { width: 1280, height: 720 },
  launchOptions: {
    slowMo: 500 // Slow down for better video visibility
  }
}
```

### Video Output Location

Videos are saved to:
```
tests/test-results/[test-name]-[browser]/video.webm
```

### Viewing Videos

After test run:
```bash
cd test-results
ls -la */video.webm
```

Play videos with VLC, Chrome, or any WebM-compatible player.

### Merging Videos (Optional)

To merge all test videos into one:

```bash
# Install FFmpeg (if not already installed)
# Windows: choco install ffmpeg
# macOS: brew install ffmpeg
# Linux: sudo apt install ffmpeg

# Create file list
ls test-results/*/video.webm | sed 's/^/file /' > videos.txt

# Merge videos
ffmpeg -f concat -safe 0 -i videos.txt -c copy merged-tests.webm
```

---

## 📊 Test Reports

### HTML Report

After running tests:
```bash
npm run test:report
```

This opens an interactive HTML report showing:
- ✅ Passed tests
- ❌ Failed tests
- ⏱️ Test duration
- 📸 Screenshots
- 🎥 Video recordings
- 📋 Test steps

### JSON Report

Results are also saved as JSON:
```
tests/test-results/results.json
```

---

## 🧪 Test Scenarios

### Authentication Tests (`auth.spec.js`)

1. ✅ Successful login with admin credentials
2. ✅ Successful login with manager credentials
3. ✅ Successful login with employee credentials
4. ✅ Logout successfully
5. ❌ Failed login with invalid credentials
6. ✅ JWT token persistence across page refresh

### Navigation Tests (`navigation.spec.js`)

1. ✅ Navigate to all pages via sidebar menu
2. ✅ Browser back/forward buttons work correctly
3. ✅ Admin sees all menu items
4. ✅ Manager sees limited menu items
5. ✅ Employee sees minimal menu items
6. ✅ Sidebar active state updates on navigation
7. ✅ Direct URL navigation works
8. ✅ No full page reload on navigation (SPA behavior)

### Departments CRUD Tests (`departments.spec.js`)

1. ✅ Create a new department successfully
2. ✅ View list of all departments
3. ✅ Edit an existing department
4. ✅ Department displays active status
5. ✅ Cancel department creation
6. ❌ Form validation - Empty name field
7. ✅ Multiple departments can be created in succession

### Reports Tests (`reports.spec.js`)

1. ✅ View all available report types
2. ✅ View Summary Report with live statistics
3. ✅ Summary Report shows real-time data from API
4. ✅ Employee Report form opens when clicking Generate Report
5. ✅ Summary Report displays correct metric labels
6. ✅ Complete summary report viewing flow
7. ✅ Report page is accessible to Manager role
8. ❌ Reports page not accessible to Employee role

---

## 🎯 Page Object Model (POM)

All tests use **Page Object Model** pattern for maintainability:

### LoginPage

```javascript
- goto()                    # Navigate to login page
- fillCredentials(email, password)
- clickLogin()
- login(email, password)    # Complete login flow
- verifyLoginPageVisible()
- verifyLoginSuccess()
- verifyToast(message)
```

### DashboardPage

```javascript
- goto()
- verifyDashboardLoaded()
- verifyAdminDashboard()
- navigateToPage(pageName)
- verifySidebarMenuItem(menuItem)
- countSidebarMenuItems()
- logout()
- verifyCurrentPage(pageName)
```

### DepartmentsPage

```javascript
- goto()
- verifyPageLoaded()
- clickCreateButton()
- fillDepartmentForm(name, description)
- submitForm()
- createDepartment(name, description)
- verifySuccessToast(message)
- verifyDepartmentInTable(departmentName)
- getTableRowCount()
- clickEditForDepartment(departmentName)
- updateDepartment(oldName, newName, newDescription)
- cancelForm()
```

### ReportsPage

```javascript
- goto()
- verifyPageLoaded()
- verifyAllReportCardsVisible()
- clickViewSummary()
- verifySummaryReportModal()
- getMetricValue(metricName)
- closeModal()
- viewSummaryReport()
```

---

## 🐛 Debugging Tests

### Debug Single Test

```bash
npx playwright test e2e/specs/auth.spec.js --debug
```

### Debug with Trace Viewer

```bash
# Run with trace
npm run test:trace

# Open trace viewer
npx playwright show-trace test-results/[test-name]/trace.zip
```

### Console Logging in Tests

```javascript
test('My test', async ({ page }) => {
  page.on('console', msg => console.log('Browser log:', msg.text()));
  // Your test code
});
```

---

## ✅ CI/CD Integration

### GitHub Actions Example

```yaml
name: Playwright Tests

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: 18
      - name: Install dependencies
        run: |
          cd tests
          npm ci
      - name: Install Playwright Browsers
        run: npx playwright install --with-deps chromium
      - name: Run tests
        run: |
          cd tests
          npm test
      - name: Upload test results
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: playwright-report
          path: tests/test-results/
```

---

## 📖 Best Practices

1. **Always use Page Object Model** - Don't put selectors in test files
2. **Use test.step()** for better reporting - Each step appears in reports
3. **Use meaningful test names** - "Scenario: Create a new department successfully"
4. **Tag negative tests** - Use `@negative` for error scenarios
5. **Wait for network idle** - `await page.waitForLoadState('networkidle')`
6. **Use explicit waits** - Don't use fixed `setTimeout()`, use `waitForSelector()`
7. **Test one thing per test** - Each test should verify one scenario
8. **Keep tests independent** - Tests should not depend on each other

---

## 🔧 Configuration

### Playwright Config (`playwright.config.js`)

```javascript
{
  timeout: 30000,              // 30 seconds per test
  retries: 0,                  // No retries in dev
  workers: 1,                  // Sequential execution
  video: 'on',                 // Always record video
  screenshot: 'only-on-failure',
  trace: 'on-first-retry',
  slowMo: 500                  // 500ms delay for visibility
}
```

---

## 🎓 Homework Requirements Met

✅ **BDD Approach**: All tests written in Given-When-Then format
✅ **Playwright Framework**: Modern E2E testing tool
✅ **Video Recording**: All tests recorded automatically
✅ **AI-Generated Tests**: Tests created by Claude AI
✅ **Comprehensive Coverage**: 29 tests covering all major features
✅ **Page Object Model**: Maintainable test architecture
✅ **HTML Reports**: Beautiful test reports with videos

---

## 📞 Support

For issues or questions:
1. Check the HTML report: `npm run test:report`
2. Review video recordings in `test-results/`
3. Run in debug mode: `npm run test:debug`

---

## 📚 Resources

- [Playwright Documentation](https://playwright.dev/)
- [BDD Testing Guide](https://cucumber.io/docs/bdd/)
- [Page Object Model Pattern](https://playwright.dev/docs/pom)
- [Test Automation Best Practices](https://playwright.dev/docs/best-practices)

---

**Last Updated:** November 9, 2025
**Test Suite Version:** 1.0.0
**Playwright Version:** 1.40.0
