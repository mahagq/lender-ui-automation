const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch({
    headless: false
  });
  const context = await browser.newContext();
  const page = await context.newPage();
  await page.goto('https://customer.uat.graydev.in/');
  await page.getByTestId('mobile-number-input').click();
  await page.getByTestId('mobile-number-input').click();
  await page.getByTestId('mobile-number-input').fill('8763694182');
  await page.getByTestId('consent-checkbox').check();
  await page.getByTestId('send-otp-button').click();
  await page.getByTestId('otp-input').fill('9999');
  await page.getByTestId('verify-otp-button').click();
  await page.getByTestId('ad-tab-navigation-button').click();
  await page.getByText('App. Code:').first().click();
  await page.getByText('GQAD-KFR8I7SYN12').click();
  await page.getByTestId('copy-button').first().click();
  await page.locator('.col-sm-12').first().click();
  await page.getByText('Your repayment is active').nth(1).click();
  await page.getByText('Your repayment is pending').click();
  await page.getByTestId('auto-debit-action-button').nth(2).click();
  await page.getByRole('heading', { name: 'App. Code: GQAD-0MO90CYHU4D' }).click();
  await page.getByRole('heading', { name: 'App. Code: GQAD-0MO90CYHU4D' }).getByRole('img').click();
  await page.getByText('See your active auto payment').click();
  await page.getByText('Summary').click();
  await page.getByText('₹3,08,720 /₹1,07,000Repayment').click();
  await page.locator('img').click();
  await page.getByText('₹3,08,720 /').click();
  await page.getByText('₹1,07,000').click();
  await page.getByText('Repayment Complete').click();
  await page.getByText('Sudhansu Sekhar').click();
  await page.getByText('Student Details').click();
  await page.getByText('Anand International School,').click();
  await page.getByText('Student nameSudhansu SekharAcademic year-Student IDstu_testClass-').click();
  await page.getByRole('button', { name: 'Close' }).click();
  await page.getByText('Auto payments schedule').click();
  await page.locator('._RepaymentScheduleCard_130ps_62').first().click();
  await page.getByText('Debit Details').first().click();
  await page.getByText('FEES DEBIT BREAKDOWN').first().click();
  await page.getByText('FEES DEBIT BREAKDOWN A . ₹22,').click();
  await page.getByText('Total Amount :₹22,000Paid').click();
  await page.locator('._RepaymentScheduleCard_130ps_62').first().click();
  await page.locator('._ADRepaymentSchedule_130ps_1 > div:nth-child(2) > div:nth-child(2)').click();
  await page.locator('._ADRepaymentSchedule_130ps_1 > div:nth-child(2) > div:nth-child(3)').click();
  await page.getByTestId('close-button').click();

  // ---------------------
  await context.close();
  await browser.close();
})();