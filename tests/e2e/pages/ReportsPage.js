/**
 * ReportsPage - Page Object Model
 * Handles all interactions with reports page
 */
class ReportsPage {
  constructor(page) {
    this.page = page;

    // Page elements
    this.pageHeading = 'h2:has-text("Reports")';
    this.employeeReportCard = 'text=Employee Report';
    this.departmentReportCard = 'text=Department Report';
    this.overtimeReportCard = 'text=Overtime Report';
    this.summaryReportCard = 'text=Summary Report';

    // Buttons
    this.viewSummaryButton = 'button:has-text("View Summary")';
    this.generateEmployeeReportButton = 'button:has-text("Generate Report")';

    // Modal elements
    this.modalHeading = 'h3';
    this.totalUsersMetric = 'text=Total Users';
    this.totalShiftsMetric = 'text=Total Shifts';
    this.assignmentsMetric = 'text=Assignments';
    this.departmentsMetric = 'text=Departments';
    this.closeModalButton = 'button:has-text("Close")';
  }

  /**
   * Navigate to reports page
   */
  async goto() {
    await this.page.goto('/#reports');
    await this.page.waitForLoadState('networkidle');
  }

  /**
   * Verify reports page is loaded
   */
  async verifyPageLoaded() {
    await this.page.waitForSelector(this.pageHeading, { state: 'visible', timeout: 10000 });
  }

  /**
   * Verify all report cards are visible
   */
  async verifyAllReportCardsVisible() {
    await this.page.waitForSelector(this.employeeReportCard, { state: 'visible' });
    await this.page.waitForSelector(this.departmentReportCard, { state: 'visible' });
    await this.page.waitForSelector(this.overtimeReportCard, { state: 'visible' });
    await this.page.waitForSelector(this.summaryReportCard, { state: 'visible' });
  }

  /**
   * Click View Summary button
   */
  async clickViewSummary() {
    await this.page.click(this.viewSummaryButton);
    await this.page.waitForSelector(this.modalHeading, { state: 'visible', timeout: 5000 });
  }

  /**
   * Verify summary report modal is displayed
   */
  async verifySummaryReportModal() {
    await this.page.waitForSelector('h3:has-text("Summary Report")', { state: 'visible' });
    await this.page.waitForSelector(this.totalUsersMetric, { state: 'visible' });
    await this.page.waitForSelector(this.totalShiftsMetric, { state: 'visible' });
    await this.page.waitForSelector(this.assignmentsMetric, { state: 'visible' });
    await this.page.waitForSelector(this.departmentsMetric, { state: 'visible' });
  }

  /**
   * Get metric value from summary report
   * @param {string} metricName - Name of the metric (e.g., "Total Users")
   */
  async getMetricValue(metricName) {
    const metricElement = this.page.locator(`text=${metricName}`).locator('..').locator('p').last();
    const value = await metricElement.textContent();
    return parseInt(value);
  }

  /**
   * Close modal
   */
  async closeModal() {
    await this.page.click(this.closeModalButton);
    await this.page.waitForSelector(this.modalHeading, { state: 'hidden', timeout: 5000 });
  }

  /**
   * Complete summary report flow
   */
  async viewSummaryReport() {
    await this.clickViewSummary();
    await this.verifySummaryReportModal();
    await this.page.waitForTimeout(2000); // Wait 2 seconds to see the report
    await this.closeModal();
  }
}

module.exports = { ReportsPage };
