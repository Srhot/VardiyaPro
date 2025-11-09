/**
 * DepartmentsPage - Page Object Model
 * Handles all CRUD operations for departments
 */
class DepartmentsPage {
  constructor(page) {
    this.page = page;

    // Page elements
    this.pageHeading = 'h2:has-text("Departments")';
    this.createButton = 'button:has-text("Create Department")';
    this.departmentsTable = 'table';

    // Modal elements
    this.modalHeading = 'h3:has-text("Department")';
    this.nameInput = 'input[name="name"]';
    this.descriptionInput = 'textarea[name="description"]';
    this.submitButton = 'button[type="submit"]:has-text("Create")';
    this.updateButton = 'button[type="submit"]:has-text("Update")';
    this.cancelButton = 'button:has-text("Cancel")';

    // Table elements
    this.editButtons = 'button:has-text("Edit")';
    this.tableRows = 'tbody tr';

    // Toast notification
    this.successToast = '.fixed.top-4.right-4';
  }

  /**
   * Navigate to departments page
   */
  async goto() {
    await this.page.goto('/#departments');
    await this.page.waitForLoadState('networkidle');
  }

  /**
   * Verify departments page is loaded
   */
  async verifyPageLoaded() {
    await this.page.waitForSelector(this.pageHeading, { state: 'visible', timeout: 10000 });
    await this.page.waitForSelector(this.createButton, { state: 'visible' });
  }

  /**
   * Click create department button
   */
  async clickCreateButton() {
    await this.page.click(this.createButton);
    await this.page.waitForSelector(this.modalHeading, { state: 'visible' });
  }

  /**
   * Fill department form
   * @param {string} name - Department name
   * @param {string} description - Department description
   */
  async fillDepartmentForm(name, description) {
    await this.page.fill(this.nameInput, name);
    await this.page.fill(this.descriptionInput, description);
  }

  /**
   * Submit department form
   */
  async submitForm() {
    await this.page.click(this.submitButton);
    await this.page.waitForLoadState('networkidle');
  }

  /**
   * Create a new department
   * @param {string} name - Department name
   * @param {string} description - Department description
   */
  async createDepartment(name, description) {
    await this.clickCreateButton();
    await this.fillDepartmentForm(name, description);
    await this.submitForm();
  }

  /**
   * Verify success toast appears
   * @param {string} message - Expected message
   */
  async verifySuccessToast(message) {
    const toast = this.page.locator(`text=${message}`);
    await toast.waitFor({ state: 'visible', timeout: 5000 });
  }

  /**
   * Verify department appears in table
   * @param {string} departmentName - Name to search for
   */
  async verifyDepartmentInTable(departmentName) {
    const row = this.page.locator(`tr:has-text("${departmentName}")`);
    await row.waitFor({ state: 'visible', timeout: 5000 });
  }

  /**
   * Get table row count
   */
  async getTableRowCount() {
    await this.page.waitForSelector(this.tableRows, { timeout: 5000 });
    return await this.page.locator(this.tableRows).count();
  }

  /**
   * Click edit button for specific department
   * @param {string} departmentName - Department name
   */
  async clickEditForDepartment(departmentName) {
    const row = this.page.locator(`tr:has-text("${departmentName}")`);
    await row.locator('button:has-text("Edit")').click();
    await this.page.waitForSelector(this.modalHeading, { state: 'visible' });
  }

  /**
   * Update department
   * @param {string} oldName - Current department name
   * @param {string} newName - New department name
   * @param {string} newDescription - New description
   */
  async updateDepartment(oldName, newName, newDescription) {
    await this.clickEditForDepartment(oldName);
    await this.page.fill(this.nameInput, newName);
    await this.page.fill(this.descriptionInput, newDescription);
    await this.page.click(this.updateButton);
    await this.page.waitForLoadState('networkidle');
  }

  /**
   * Verify modal is closed
   */
  async verifyModalClosed() {
    await this.page.waitForSelector(this.modalHeading, { state: 'hidden', timeout: 5000 });
  }

  /**
   * Cancel form
   */
  async cancelForm() {
    await this.page.click(this.cancelButton);
    await this.verifyModalClosed();
  }
}

module.exports = { DepartmentsPage };
