const { test, expect } = require('@playwright/test');
const { LoginPage } = require('../pages/LoginPage');
const { DashboardPage } = require('../pages/DashboardPage');
const { DepartmentsPage } = require('../pages/DepartmentsPage');

/**
 * BDD-Style Test Suite: Departments CRUD Operations
 *
 * Features:
 * - Admin can create a new department
 * - Admin can view departments list
 * - Admin can edit a department
 * - Admin can see department status (Active/Inactive)
 */

test.describe('Feature: Departments Management (CRUD)', () => {
  let loginPage;
  let dashboardPage;
  let departmentsPage;

  test.beforeEach(async ({ page }) => {
    loginPage = new LoginPage(page);
    dashboardPage = new DashboardPage(page);
    departmentsPage = new DepartmentsPage(page);

    // GIVEN I am logged in as admin
    await loginPage.goto();
    await loginPage.login('admin@vardiyapro.com', 'password123');
    await loginPage.verifyLoginSuccess();

    // AND I am on the departments page
    await dashboardPage.navigateToPage('departments');
    await departmentsPage.verifyPageLoaded();
  });

  test('Scenario: Create a new department successfully', async ({ page }) => {
    // GIVEN I am on the departments page
    const timestamp = Date.now();
    const departmentName = `Test Department ${timestamp}`;
    const departmentDescription = `Created by Playwright automation test at ${new Date().toLocaleString()}`;

    // WHEN I click the "Create Department" button
    await test.step('I click Create Department button', async () => {
      await departmentsPage.clickCreateButton();
    });

    // AND I fill in the department form
    await test.step('I fill in department details', async () => {
      await departmentsPage.fillDepartmentForm(departmentName, departmentDescription);
    });

    // AND I submit the form
    await test.step('I submit the form', async () => {
      await departmentsPage.submitForm();
    });

    // THEN I should see a success message
    await test.step('I should see success notification', async () => {
      await departmentsPage.verifySuccessToast('Department created successfully');
    });

    // AND the modal should close
    await test.step('The modal should close', async () => {
      await departmentsPage.verifyModalClosed();
    });

    // AND the new department should appear in the table
    await test.step('The new department should be visible in table', async () => {
      await departmentsPage.verifyDepartmentInTable(departmentName);
    });
  });

  test('Scenario: View list of all departments', async ({ page }) => {
    // GIVEN I am on the departments page
    // WHEN I view the departments table
    await test.step('I should see the departments table', async () => {
      const rowCount = await departmentsPage.getTableRowCount();

      // THEN I should see at least one department
      expect(rowCount).toBeGreaterThan(0);
    });

    // AND I should see department details
    await test.step('I should see department columns', async () => {
      // Verify table headers
      await page.waitForSelector('th:has-text("Name")', { state: 'visible' });
      await page.waitForSelector('th:has-text("Description")', { state: 'visible' });
      await page.waitForSelector('th:has-text("Status")', { state: 'visible' });
      await page.waitForSelector('th:has-text("Actions")', { state: 'visible' });
    });
  });

  test('Scenario: Edit an existing department', async ({ page }) => {
    // GIVEN a department exists
    const timestamp = Date.now();
    const originalName = `Original Department ${timestamp}`;
    const originalDescription = 'Original description';

    await test.step('I create a department to edit', async () => {
      await departmentsPage.createDepartment(originalName, originalDescription);
      await departmentsPage.verifyDepartmentInTable(originalName);
    });

    // WHEN I click edit on the department
    const updatedName = `Updated Department ${timestamp}`;
    const updatedDescription = 'Updated description with new information';

    await test.step('I click Edit button', async () => {
      await departmentsPage.clickEditForDepartment(originalName);
    });

    // AND I update the department details
    await test.step('I update department details', async () => {
      await departmentsPage.fillDepartmentForm(updatedName, updatedDescription);
    });

    // AND I submit the form
    await test.step('I submit the updated form', async () => {
      await page.click('button[type="submit"]:has-text("Update")');
      await page.waitForLoadState('networkidle');
    });

    // THEN I should see a success message
    await test.step('I should see update success notification', async () => {
      await departmentsPage.verifySuccessToast('Department updated successfully');
    });

    // AND the updated department should appear in the table
    await test.step('The updated department should be visible', async () => {
      await departmentsPage.verifyDepartmentInTable(updatedName);
    });

    // AND the old name should not be present
    await test.step('The old department name should be gone', async () => {
      const oldRow = page.locator(`tr:has-text("${originalName}")`);
      await expect(oldRow).toHaveCount(0, { timeout: 5000 });
    });
  });

  test('Scenario: Department displays active status', async ({ page }) => {
    // GIVEN a new department is created
    const timestamp = Date.now();
    const departmentName = `Active Department ${timestamp}`;

    await test.step('I create a new department', async () => {
      await departmentsPage.createDepartment(departmentName, 'Test active status');
    });

    // WHEN I view the department in the table
    await test.step('I view the department row', async () => {
      await departmentsPage.verifyDepartmentInTable(departmentName);
    });

    // THEN I should see "Active" status badge
    await test.step('I should see Active status badge', async () => {
      const row = page.locator(`tr:has-text("${departmentName}")`);
      const statusBadge = row.locator('span:has-text("Active")');
      await statusBadge.waitFor({ state: 'visible' });

      // Verify it has green styling
      const badgeClass = await statusBadge.getAttribute('class');
      expect(badgeClass).toContain('bg-green');
    });
  });

  test('Scenario: Cancel department creation', async ({ page }) => {
    // GIVEN I am on the departments page
    const initialRowCount = await departmentsPage.getTableRowCount();

    // WHEN I click "Create Department"
    await test.step('I click Create Department button', async () => {
      await departmentsPage.clickCreateButton();
    });

    // AND I fill in some information
    await test.step('I partially fill the form', async () => {
      await departmentsPage.fillDepartmentForm('Cancelled Department', 'This will be cancelled');
    });

    // AND I click Cancel
    await test.step('I click Cancel button', async () => {
      await departmentsPage.cancelForm();
    });

    // THEN the modal should close
    await test.step('The modal should close', async () => {
      await departmentsPage.verifyModalClosed();
    });

    // AND no new department should be created
    await test.step('No new department should be added', async () => {
      const finalRowCount = await departmentsPage.getTableRowCount();
      expect(finalRowCount).toBe(initialRowCount);
    });
  });

  test('Scenario: Form validation - Empty name field @negative', async ({ page }) => {
    // GIVEN I am creating a new department
    await test.step('I click Create Department button', async () => {
      await departmentsPage.clickCreateButton();
    });

    // WHEN I submit the form without filling the name
    await test.step('I try to submit with empty name', async () => {
      // Fill only description
      await page.fill('textarea[name="description"]', 'Description without name');

      // Try to submit
      await page.click('button[type="submit"]:has-text("Create")');
    });

    // THEN the browser should show validation error
    await test.step('Form should not submit', async () => {
      // Modal should still be visible (form not submitted)
      await page.waitForSelector('h3:has-text("Create Department")', { state: 'visible' });

      // Check for HTML5 validation
      const nameInput = page.locator('input[name="name"]');
      const isInvalid = await nameInput.evaluate((el) => !el.validity.valid);
      expect(isInvalid).toBe(true);
    });
  });

  test('Scenario: Multiple departments can be created in succession', async ({ page }) => {
    // GIVEN I am on the departments page
    const timestamp = Date.now();
    const departments = [
      { name: `Sales ${timestamp}`, description: 'Sales team department' },
      { name: `Engineering ${timestamp}`, description: 'Engineering team department' },
      { name: `HR ${timestamp}`, description: 'Human resources department' }
    ];

    // WHEN I create multiple departments
    for (const dept of departments) {
      await test.step(`I create department: ${dept.name}`, async () => {
        await departmentsPage.createDepartment(dept.name, dept.description);
        await departmentsPage.verifySuccessToast('Department created successfully');
      });
    }

    // THEN all departments should be visible in the table
    for (const dept of departments) {
      await test.step(`Department ${dept.name} should be visible`, async () => {
        await departmentsPage.verifyDepartmentInTable(dept.name);
      });
    }
  });
});
