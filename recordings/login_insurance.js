const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch({
    headless: false
  });
  const context = await browser.newContext();
  const page = await context.newPage();
  await page.goto('https://customer.uat.graydev.in/');
  await page.getByTestId('mobile-number-input').click();
  await page.getByTestId('mobile-number-input').fill('8668768645');
  await page.getByTestId('consent-checkbox').check();
  await page.getByTestId('send-otp-button').click();
  await page.getByTestId('otp-input').click();
  await page.getByTestId('otp-input').fill('9999');
  await page.getByTestId('verify-otp-button').click();
  await page.getByTestId('ins-tab-navigation-button').click();
  await page.getByRole('img', { name: 'Education costs illustration' }).click();
  await page.getByRole('heading', { name: 'Education costs are rising' }).click();
  await page.getByText('Education inflation is real.').click();
  await page.getByRole('img', { name: 'Guardian One logo' }).click();
  await page.locator('._EducationBanner__Content_s3fr1_157').click();
  await page.getByRole('heading', { name: 'Your Policies' }).click();
  await page.getByTestId('app-id-copy-button').first().click();
  await page.getByText('Status: Issued').click();
  await page.getByText('Status: Applied').first().click();
  const downloadPromise = page.waitForEvent('download');
  await page.getByTestId('download-button').first().click();
  const download = await downloadPromise;
  const page1Promise = page.waitForEvent('popup');
  await page.getByRole('button', { name: 'CALCULATE NOW Graduation hat' }).click();
  const page1 = await page1Promise;
  await page1.close();

  // ---------------------
  await context.close();
  await browser.close();
})();