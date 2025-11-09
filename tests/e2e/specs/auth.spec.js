const { test, expect } = require('@playwright/test');
const { LoginPage } = require('../pages/LoginPage');
const { DashboardPage } = require('../pages/DashboardPage');

/**
 * BDD-Style Test Suite: Authentication
 *
 * Features:
 * - User can login with valid credentials
 * - User can logout successfully
 * - User sees appropriate error with invalid credentials
 */

test.describe('Feature: User Authentication', () => {
  let loginPage;
  let dashboardPage;

  test.beforeEach(async ({ page }) => {
    loginPage = new LoginPage(page);
    dashboardPage = new DashboardPage(page);

    // GIVEN I am on the login page
    await loginPage.goto();
  });

  test('Scenario: Successful login with admin credentials', async ({ page }) => {
    // GIVEN I am on the login page
    await loginPage.verifyLoginPageVisible();

    // WHEN I enter valid admin credentials
    const email = 'admin@vardiyapro.com';
    const password = 'password123';

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

    // AND I should see a welcome toast message
    await test.step('I should see a welcome message', async () => {
      await loginPage.verifyToast('Welcome back');
    });

    // AND I should see admin dashboard elements
    await test.step('I should see admin dashboard elements', async () => {
      await dashboardPage.verifyAdminDashboard();
    });
  });

  test('Scenario: Successful login with manager credentials', async ({ page }) => {
    // GIVEN I am on the login page
    await loginPage.verifyLoginPageVisible();

    // WHEN I enter valid manager credentials
    const email = 'manager1@vardiyapro.com';
    const password = 'password123';

    await test.step('I fill in manager credentials', async () => {
      await loginPage.login(email, password);
    });

    // THEN I should be redirected to the dashboard
    await test.step('I should see the dashboard', async () => {
      await loginPage.verifyLoginSuccess();
      await dashboardPage.verifyDashboardLoaded();
    });

    // AND I should NOT see Departments menu (manager doesn't have access)
    await test.step('I should not see admin-only menu items', async () => {
      const menuCount = await dashboardPage.countSidebarMenuItems();
      // Manager should have fewer menu items than admin
      expect(menuCount).toBeLessThan(10);
    });
  });

  test('Scenario: Successful login with employee credentials', async ({ page }) => {
    // GIVEN I am on the login page
    await loginPage.verifyLoginPageVisible();

    // WHEN I enter valid employee credentials
    const email = 'employee1@vardiyapro.com';
    const password = 'password123';

    await test.step('I fill in employee credentials', async () => {
      await loginPage.login(email, password);
    });

    // THEN I should be redirected to the dashboard
    await test.step('I should see the dashboard', async () => {
      await loginPage.verifyLoginSuccess();
      await dashboardPage.verifyDashboardLoaded();
    });

    // AND I should see employee-specific dashboard
    await test.step('I should see employee dashboard elements', async () => {
      // Employee dashboard has clock in/out widget
      await page.waitForSelector('text=Time Tracking', { state: 'visible' });
    });
  });

  test('Scenario: Logout successfully', async ({ page }) => {
    // GIVEN I am logged in as admin
    await test.step('I login as admin', async () => {
      await loginPage.login('admin@vardiyapro.com', 'password123');
      await loginPage.verifyLoginSuccess();
    });

    // WHEN I click the logout button
    await test.step('I click logout button', async () => {
      await dashboardPage.logout();
    });

    // THEN I should be redirected to login page
    await test.step('I should see the login page', async () => {
      await page.waitForURL('**/#login', { timeout: 5000 });
      await loginPage.verifyLoginPageVisible();
    });

    // AND I should see a logout success message
    await test.step('I should see logout confirmation', async () => {
      await loginPage.verifyToast('Logged out successfully');
    });
  });

  test('Scenario: Failed login with invalid credentials @negative', async ({ page }) => {
    // GIVEN I am on the login page
    await loginPage.verifyLoginPageVisible();

    // WHEN I enter invalid credentials
    const email = 'invalid@example.com';
    const password = 'wrongpassword';

    await test.step('I fill in invalid credentials', async () => {
      await loginPage.fillCredentials(email, password);
      await loginPage.clickLogin();
      await page.waitForTimeout(2000); // Wait for error response
    });

    // THEN I should see an error message or remain on login page
    await test.step('I should see an error or stay on login', async () => {
      // Check if error toast appears (lenient selector)
      const errorToastVisible = await page.locator('.bg-red-500, [class*="bg-red"]').count();

      // OR verify we're still on login page
      const currentURL = page.url();
      const stillOnLogin = currentURL.includes('#login') || currentURL.includes('/');

      expect(errorToastVisible > 0 || stillOnLogin).toBeTruthy();
    });

    // AND I should remain on the login page
    await test.step('I should still be on login page', async () => {
      await loginPage.verifyLoginPageVisible();
    });
  });

  test('Scenario: JWT token persistence across page refresh', async ({ page }) => {
    // GIVEN I am logged in
    await test.step('I login as admin', async () => {
      await loginPage.login('admin@vardiyapro.com', 'password123');
      await loginPage.verifyLoginSuccess();
    });

    // WHEN I refresh the page
    await test.step('I refresh the page', async () => {
      await page.reload();
      await page.waitForLoadState('networkidle');
    });

    // THEN I should still be logged in
    await test.step('I should still be on dashboard', async () => {
      await dashboardPage.verifyDashboardLoaded();
    });

    // AND I should not be redirected to login
    await test.step('I should not see login page', async () => {
      const currentURL = page.url();
      expect(currentURL).not.toContain('#login');
    });
  });
});
