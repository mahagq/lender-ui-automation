const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch({
    headless: false
  });
  const context = await browser.newContext();
  const page = await context.newPage();
  await page.goto('https://customer.uat.graydev.in/');
  await page.getByTestId('mobile-number-input').click();
  await page.getByTestId('mobile-number-input').fill('8108556708');
  await page.getByTestId('consent-checkbox').check();
  await page.getByTestId('send-otp-button').click();
  await page.getByTestId('otp-input').fill('9999');
  await page.getByTestId('verify-otp-button').click();

  // ---------------------
  await context.close();
  await browser.close();
})();