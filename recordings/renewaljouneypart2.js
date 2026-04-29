const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch({
    headless: false
  });
  const context = await browser.newContext();
  const page = await context.newPage();
  await page.goto('https://customer.uat.graydev.in/');
  await page.locator('._Radio_Circle_3vblw_29').first().click();
  await page.getByTestId('submit-plan-details-button').click();
  await page.locator('div').filter({ hasText: 'Welcome back, Sanjay! We\'ve' }).nth(2).click();
  await page.getByText('Welcome').click();
  await page.getByText('We\'ve found your previous').click();
  await page.getByText('Applicant Name', { exact: true }).click();
  await page.getByText('Date of Birth').click();
  await page.getByText('PAN Number').click();
  await page.getByText('Click to change applicant').click();
  await page.locator('div').filter({ hasText: /^CONTINUE WITH THESE DETAILS$/ }).click();
  await page.locator('div').filter({ hasText: 'Sanjay, Verify your Details' }).nth(2).click();
  await page.getByRole('heading', { name: 'Residential details' }).click();
  await page.getByText('Please ensure your current address is updated').click();
  await page.getByText('Current address', { exact: true }).click();
  await page.getByText('Residence type').click();
  await page.getByRole('heading', { name: 'Employment details' }).click();
  await page.getByText('Please ensure your current employment details are up to date to improve').click();
  await page.getByText('Employment type').click();
  await page.getByRole('button', { name: 'CONFIRM AND PROCEED' }).click();
  await page.getByTestId('skip-button').click();

  // ---------------------
  await context.close();
  await browser.close();
})();