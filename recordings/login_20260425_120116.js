const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch({
    headless: false
  });
  const context = await browser.newContext();
  const page = await context.newPage();
  await page.goto('https://customer.uat.graydev.in/');
  await page.getByTestId('mobile-number-input').click();
  await page.getByTestId('mobile-number-input').fill('9838832882');
  await page.locator('._Checkbox_Container_t4qvy_1').click();

  // ---------------------
  await context.close();
  await browser.close();
})();