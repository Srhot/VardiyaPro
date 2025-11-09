const { test, expect } = require('@playwright/test');
const { LoginPage } = require('../pages/LoginPage');
const { DashboardPage } = require('../pages/DashboardPage');

/**
 * BDD-Style Test Suite: Navigation & Routing
 *
 * Features:
 * - User can navigate between pages using sidebar
 * - Hash-based routing works correctly
 * - Role-based menu visibility
 */

test.describe('Feature: Application Navigation', () => {
  let loginPage;
  let dashboardPage;

  test.beforeEach(async ({ page }) => {
    loginPage = new LoginPage(page);
    dashboardPage = new DashboardPage(page);

    // GIVEN I am logged in as admin
    await loginPage.goto();
    await loginPage.login('admin@vardiyapro.com', 'password123');
    await loginPage.verifyLoginSuccess();
  });

  test('Scenario: Navigate to all pages via sidebar menu', async ({ page }) => {
    // GIVEN I am on the dashboard
    await dashboardPage.verifyDashboardLoaded();

    const pages = [
      { name: 'timeTracking', hash: '#time-tracking', heading: 'Time Tracking' },
      { name: 'departments', hash: '#departments', heading: 'Departments' },
      { name: 'users', hash: '#users', heading: 'Users' },
      { name: 'shifts', hash: '#shifts', heading: 'Shifts' },
      { name: 'assignments', hash: '#assignments', heading: 'Assignments' },
      { name: 'holidays', hash: '#holidays', heading: 'Holidays' },
      { name: 'notifications', hash: '#notifications', heading: 'Notifications' },
      { name: 'reports', hash: '#reports', heading: 'Reports' },
      { name: 'auditLogs', hash: '#audit-logs', heading: 'Audit Logs' }
    ];

    // WHEN I navigate to each page
    for (const pageData of pages) {
      await test.step(`Navigate to ${pageData.heading}`, async () => {
        // Click sidebar menu item
        await dashboardPage.navigateToPage(pageData.name);

        // Verify URL changed
        await page.waitForURL(`**/${pageData.hash}`, { timeout: 5000 });

        // Verify page heading
        await page.waitForSelector(`h2:has-text("${pageData.heading}")`, {
          state: 'visible',
          timeout: 10000
        });
      });
    }

    // THEN I should be able to navigate back to dashboard
    await test.step('Navigate back to Dashboard', async () => {
      await dashboardPage.navigateToPage('dashboard');
      await dashboardPage.verifyDashboardLoaded();
    });
  });

  test('Scenario: Browser back/forward buttons work correctly', async ({ page }) => {
    // GIVEN I navigate through multiple pages
    await test.step('Navigate to Departments', async () => {
      await dashboardPage.navigateToPage('departments');
      await page.waitForURL('**/#departments');
    });

    await test.step('Navigate to Users', async () => {
      await dashboardPage.navigateToPage('users');
      await page.waitForURL('**/#users');
    });

    await test.step('Navigate to Reports', async () => {
      await dashboardPage.navigateToPage('reports');
      await page.waitForURL('**/#reports');
    });

    // WHEN I use browser back button
    await test.step('Click browser back button', async () => {
      await page.goBack();
      await page.waitForLoadState('networkidle');
    });

    // THEN I should be on Users page
    await test.step('I should be on Users page', async () => {
      await page.waitForURL('**/#users');
      await page.waitForSelector('h2:has-text("Users")', { state: 'visible' });
    });

    // WHEN I use browser back button again
    await test.step('Click browser back button again', async () => {
      await page.goBack();
      await page.waitForLoadState('networkidle');
    });

    // THEN I should be on Departments page
    await test.step('I should be on Departments page', async () => {
      await page.waitForURL('**/#departments');
      await page.waitForSelector('h2:has-text("Departments")', { state: 'visible' });
    });

    // WHEN I use browser forward button
    await test.step('Click browser forward button', async () => {
      await page.goForward();
      await page.waitForLoadState('networkidle');
    });

    // THEN I should be back on Users page
    await test.step('I should be back on Users page', async () => {
      await page.waitForURL('**/#users');
      await page.waitForSelector('h2:has-text("Users")', { state: 'visible' });
    });
  });

  test('Scenario: Admin sees all menu items', async ({ page }) => {
    // GIVEN I am logged in as admin
    await dashboardPage.verifyDashboardLoaded();

    // THEN I should see all 10 menu items
    await test.step('I should see all admin menu items', async () => {
      const menuCount = await dashboardPage.countSidebarMenuItems();
      expect(menuCount).toBe(10); // All pages accessible to admin
    });

    // AND I should see admin-only pages
    await test.step('I should see admin-only menu items', async () => {
      await dashboardPage.verifySidebarMenuItem('departments');
      await dashboardPage.verifySidebarMenuItem('users');
      await dashboardPage.verifySidebarMenuItem('holidays');
      await dashboardPage.verifySidebarMenuItem('auditLogs');
    });
  });

  test('Scenario: Manager sees limited menu items', async ({ page }) => {
    // GIVEN I logout and login as manager
    await test.step('Logout from admin', async () => {
      await dashboardPage.logout();
    });

    await test.step('Login as manager', async () => {
      await loginPage.login('manager1@vardiyapro.com', 'password123');
      await loginPage.verifyLoginSuccess();
    });

    // THEN I should see fewer menu items than admin
    await test.step('I should see limited menu items', async () => {
      const menuCount = await dashboardPage.countSidebarMenuItems();
      expect(menuCount).toBeLessThan(10);
    });

    // AND I should NOT see admin-only pages
    await test.step('I should not see Departments menu', async () => {
      const departmentsLink = page.locator('a[href="#departments"]');
      await expect(departmentsLink).toHaveCount(0);
    });

    await test.step('I should not see Users menu', async () => {
      const usersLink = page.locator('a[href="#users"]');
      await expect(usersLink).toHaveCount(0);
    });

    // BUT I should see manager-accessible pages
    await test.step('I should see Shifts menu', async () => {
      await dashboardPage.verifySidebarMenuItem('shifts');
    });

    await test.step('I should see Reports menu', async () => {
      await dashboardPage.verifySidebarMenuItem('reports');
    });
  });

  test('Scenario: Employee sees minimal menu items', async ({ page }) => {
    // GIVEN I logout and login as employee
    await test.step('Logout from admin', async () => {
      await dashboardPage.logout();
    });

    await test.step('Login as employee', async () => {
      await loginPage.login('employee1@vardiyapro.com', 'password123');
      await loginPage.verifyLoginSuccess();
    });

    // THEN I should see only employee-accessible menu items
    await test.step('I should see minimal menu items', async () => {
      const menuCount = await dashboardPage.countSidebarMenuItems();
      expect(menuCount).toBeLessThan(6); // Very limited access
    });

    // AND I should see employee pages
    await test.step('I should see Dashboard menu', async () => {
      await dashboardPage.verifySidebarMenuItem('dashboard');
    });

    await test.step('I should see Time Tracking menu', async () => {
      await dashboardPage.verifySidebarMenuItem('timeTracking');
    });

    await test.step('I should see Assignments menu', async () => {
      await dashboardPage.verifySidebarMenuItem('assignments');
    });

    // AND I should NOT see management pages
    await test.step('I should not see Shifts menu', async () => {
      const shiftsLink = page.locator('a[href="#shifts"]');
      await expect(shiftsLink).toHaveCount(0);
    });

    await test.step('I should not see Reports menu', async () => {
      const reportsLink = page.locator('a[href="#reports"]');
      await expect(reportsLink).toHaveCount(0);
    });
  });

  test('Scenario: Sidebar active state updates on navigation', async ({ page }) => {
    // GIVEN I am on the dashboard
    await dashboardPage.verifyDashboardLoaded();

    // WHEN I navigate to Departments
    await test.step('Navigate to Departments', async () => {
      await dashboardPage.navigateToPage('departments');
    });

    // THEN the Departments menu item should be highlighted
    await test.step('Departments menu should be active', async () => {
      const departmentsLink = page.locator('a[href="#departments"]');
      const classes = await departmentsLink.getAttribute('class');
      expect(classes).toContain('bg-blue'); // Active state has blue background
    });

    // WHEN I navigate to Reports
    await test.step('Navigate to Reports', async () => {
      await dashboardPage.navigateToPage('reports');
    });

    // THEN the Reports menu item should be highlighted
    await test.step('Reports menu should be active', async () => {
      const reportsLink = page.locator('a[href="#reports"]');
      const classes = await reportsLink.getAttribute('class');
      expect(classes).toContain('bg-blue');
    });

    // AND Departments should no longer be highlighted
    await test.step('Departments menu should not be active', async () => {
      const departmentsLink = page.locator('a[href="#departments"]');
      const classes = await departmentsLink.getAttribute('class');
      expect(classes).not.toContain('bg-blue');
    });
  });

  test('Scenario: Direct URL navigation works', async ({ page }) => {
    // GIVEN I am logged in
    await dashboardPage.verifyDashboardLoaded();

    // WHEN I navigate directly to a page via URL
    await test.step('Navigate to Reports via URL', async () => {
      await page.goto('http://127.0.0.1:3000/#reports');
      await page.waitForLoadState('networkidle');
    });

    // THEN I should see the Reports page
    await test.step('I should be on Reports page', async () => {
      await page.waitForSelector('h2:has-text("Reports")', { state: 'visible' });
    });

    // WHEN I navigate to another page via URL
    await test.step('Navigate to Departments via URL', async () => {
      await page.goto('http://127.0.0.1:3000/#departments');
      await page.waitForLoadState('networkidle');
    });

    // THEN I should see the Departments page
    await test.step('I should be on Departments page', async () => {
      await page.waitForSelector('h2:has-text("Departments")', { state: 'visible' });
    });
  });

  test('Scenario: No full page reload on navigation (SPA behavior)', async ({ page }) => {
    // GIVEN I am on the dashboard
    await dashboardPage.verifyDashboardLoaded();

    // WHEN I add a custom flag to window object
    await test.step('Add custom flag to window', async () => {
      await page.evaluate(() => {
        window.testFlag = 'persistent_value';
      });
    });

    // AND I navigate to different pages
    await test.step('Navigate to multiple pages', async () => {
      await dashboardPage.navigateToPage('departments');
      await dashboardPage.navigateToPage('reports');
      await dashboardPage.navigateToPage('users');
    });

    // THEN the custom flag should still exist (no page reload)
    await test.step('Custom flag should persist', async () => {
      const flagValue = await page.evaluate(() => window.testFlag);
      expect(flagValue).toBe('persistent_value');
    });
  });
});
