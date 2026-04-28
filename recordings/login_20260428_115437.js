const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch({
    headless: false
  });
  const context = await browser.newContext();
  const page = await context.newPage();
  await page.goto('https://customer.uat.graydev.in/');
  await page.getByTestId('proceed-button').click();
  await page.getByText('Self Owned').click();
  await page.getByTestId('type-radio-container-1').getByTestId('type-radio').click();
  await page.getByRole('button', { name: 'Proceed' }).click();
  await page.getByTestId('salaried').click();
  await page.getByTestId('back-button').click();
  await page.getByTestId('self-employed').click();
  await page.getByTestId('back-button').click();
  await page.getByTestId('salaried').locator('svg').click();
  await page.getByTestId('back-button').click();
  await page.getByTestId('self-employed').locator('svg').click();
  await page.getByTestId('back-button').click();
  await page.getByTestId('salaried').click();
  await page.getByTestId('employer-name-input').click();
  await page.getByTestId('employer-name-input').press('CapsLock');
  await page.getByTestId('employer-name-input').fill('GQ');
  await page.getByTestId('net-monthly-salary-input').click();
  await page.getByTestId('net-monthly-salary-input').fill('23000');
  await page.getByText('Click if your Family Monthly').click();
  await page.getByTestId('consent-checkbox').uncheck();
  await page.getByTestId('consent-checkbox').check();
  await page.getByTestId('consent-checkbox').uncheck();
  await page.getByRole('button', { name: 'Proceed' }).click();
  await page.getByTestId('consent-checkbox-error').click();
  await page.getByText('In words:').click();
  await page.getByTestId('consent-checkbox').check();
  await page.getByTestId('back-button').click();
  await page.getByTestId('self-employed').locator('svg').click();
  await page.getByTestId('business-name-input').click();
  await page.getByTestId('business-name-input').press('CapsLock');
  await page.getByTestId('business-name-input').fill('GQ');
  await page.getByTestId('business-annual-income-input').click();
  await page.getByTestId('business-annual-income-input').fill('23000');
  await page.locator('[data-test-id="consent-checkbox"]').check();
  await page.getByText('Click if your Family Monthly').click();
  await page.locator('[data-test-id="consent-checkbox-error"]').click();
  await page.getByTestId('years-of-current-business-input').click();
  await page.getByTestId('years-of-current-business-input').fill('6');
  await page.getByTestId('business-description-input').click();
  await page.getByTestId('business-description-input').fill('test');
  await page.getByTestId('info').click();
  await page.getByRole('button', { name: 'Proceed' }).click();
  await page.locator('[data-test-id="consent-checkbox"]').check();
  await page.getByRole('button', { name: 'Proceed' }).click();
  await page.getByTestId('skip-button').click();

  // ---------------------
  await context.close();
  await browser.close();
})();