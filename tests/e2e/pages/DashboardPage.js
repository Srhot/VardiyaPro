/**
 * DashboardPage - Page Object Model
 * Handles all interactions with the dashboard and sidebar navigation
 */
class DashboardPage {
  constructor(page) {
    this.page = page;

    // Sidebar menu selectors
    this.sidebarLogo = 'text=VardiyaPro';
    this.dashboardLink = 'a[href="#dashboard"]';
    this.timeTrackingLink = 'a[href="#time-tracking"]';
    this.departmentsLink = 'a[href="#departments"]';
    this.usersLink = 'a[href="#users"]';
    this.shiftsLink = 'a[href="#shifts"]';
    this.assignmentsLink = 'a[href="#assignments"]';
    this.holidaysLink = 'a[href="#holidays"]';
    this.notificationsLink = 'a[href="#notifications"]';
    this.reportsLink = 'a[href="#reports"]';
    this.auditLogsLink = 'a[href="#audit-logs"]';

    // Dashboard elements
    this.pageHeading = 'h2:has-text("Welcome")';
    this.logoutButton = 'button[title="Logout"]';

    // Admin dashboard stat cards
    this.totalUsersCard = 'text=Total Users';
    this.activeShiftsCard = 'text=Active Shifts';
    this.assignmentsCard = 'text=Assignments';
    this.departmentsCard = 'text=Departments';
  }

  /**
   * Navigate to dashboard
   */
  async goto() {
    await this.page.goto('/#dashboard');
    await this.page.waitForLoadState('networkidle');
  }

  /**
   * Verify dashboard is loaded
   */
  async verifyDashboardLoaded() {
    await this.page.waitForSelector(this.pageHeading, { state: 'visible', timeout: 10000 });
    await this.page.waitForSelector(this.sidebarLogo, { state: 'visible' });
  }

  /**
   * Verify admin dashboard elements
   */
  async verifyAdminDashboard() {
    await this.page.waitForSelector(this.totalUsersCard, { state: 'visible' });
    await this.page.waitForSelector(this.activeShiftsCard, { state: 'visible' });
    await this.page.waitForSelector(this.assignmentsCard, { state: 'visible' });
    await this.page.waitForSelector(this.departmentsCard, { state: 'visible' });
  }

  /**
   * Navigate to a specific page via sidebar
   * @param {string} pageName - Name of the page (departments, users, shifts, etc.)
   */
  async navigateToPage(pageName) {
    const linkSelector = this[`${pageName}Link`];
    if (!linkSelector) {
      throw new Error(`Unknown page: ${pageName}`);
    }
    await this.page.click(linkSelector);
    await this.page.waitForLoadState('networkidle');
  }

  /**
   * Verify sidebar menu item is visible
   * @param {string} menuItem - Menu item name
   */
  async verifySidebarMenuItem(menuItem) {
    const linkSelector = this[`${menuItem}Link`];
    await this.page.waitForSelector(linkSelector, { state: 'visible' });
  }

  /**
   * Count visible sidebar menu items
   */
  async countSidebarMenuItems() {
    const menuItems = await this.page.locator('nav a').count();
    return menuItems;
  }

  /**
   * Logout from application
   */
  async logout() {
    await this.page.click(this.logoutButton);
    await this.page.waitForURL('**/#login', { timeout: 5000 });
  }

  /**
   * Verify user is on specific page
   * @param {string} pageName - Expected page name
   */
  async verifyCurrentPage(pageName) {
    const expectedURL = `#${pageName}`;
    await this.page.waitForURL(`**/${expectedURL}`, { timeout: 5000 });
  }
}

module.exports = { DashboardPage };
