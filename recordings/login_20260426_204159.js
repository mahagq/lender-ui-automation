const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch({
    headless: false
  });
  const context = await browser.newContext();
  const page = await context.newPage();
  await page.goto('https://customer.uat.graydev.in/');
  await page.getByTestId('submit-button').click();
  await page.getByTestId('submit-button').click();
  await page.getByTestId('submit-button').click();
  await page.getByTestId('first-name-input').click();
  await page.getByTestId('first-name-input').fill('ahmed');
  await page.getByTestId('last-name-input').click();
  await page.getByTestId('last-name-input').fill('darvesh');
  await page.getByTestId('consent-checkbox').check();
  await page.getByTestId('submit-button').click();
  await page.goto('https://customer.uat.graydev.in/onboarding');

  // ---------------------
  await context.close();
  await browser.close();
})();