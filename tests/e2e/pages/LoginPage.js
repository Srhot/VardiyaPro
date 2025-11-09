/**
 * LoginPage - Page Object Model
 * Handles all interactions with the login page
 */
class LoginPage {
  constructor(page) {
    this.page = page;

    // Selectors
    this.emailInput = 'input[name="email"]';
    this.passwordInput = 'input[name="password"]';
    this.loginButton = 'button[type="submit"]';
    this.pageTitle = 'text=VardiyaPro';
    this.welcomeMessage = 'text=Shift Management System';
  }

  /**
   * Navigate to login page
   */
  async goto() {
    await this.page.goto('/');
    await this.page.waitForLoadState('networkidle');
  }

  /**
   * Fill login credentials
   * @param {string} email - User email
   * @param {string} password - User password
   */
  async fillCredentials(email, password) {
    await this.page.fill(this.emailInput, email);
    await this.page.fill(this.passwordInput, password);
  }

  /**
   * Click login button
   */
  async clickLogin() {
    await this.page.click(this.loginButton);
    await this.page.waitForLoadState('networkidle');
  }

  /**
   * Complete login flow
   * @param {string} email - User email
   * @param {string} password - User password
   */
  async login(email, password) {
    await this.fillCredentials(email, password);
    await this.clickLogin();
  }

  /**
   * Verify login page is visible
   */
  async verifyLoginPageVisible() {
    await this.page.waitForSelector(this.pageTitle, { state: 'visible' });
    await this.page.waitForSelector(this.welcomeMessage, { state: 'visible' });
  }

  /**
   * Verify successful login by checking dashboard
   */
  async verifyLoginSuccess() {
    // Wait for redirect to dashboard
    await this.page.waitForURL('**/#dashboard', { timeout: 10000 });
    // Verify dashboard elements
    await this.page.waitForSelector('text=Dashboard', { state: 'visible', timeout: 5000 });
  }

  /**
   * Verify toast notification appears
   * @param {string} message - Expected toast message
   */
  async verifyToast(message) {
    const toast = this.page.locator(`text=${message}`);
    await toast.waitFor({ state: 'visible', timeout: 5000 });
  }
}

module.exports = { LoginPage };
