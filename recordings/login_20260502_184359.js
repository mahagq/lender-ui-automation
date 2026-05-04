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
  await page.getByText('By signing in, I agree to the').click();
  await page.getByTestId('send-otp-button').click();
  await page.getByTestId('otp-input').click();
  await page.getByTestId('otp-input').fill('9999');
  await page.getByTestId('verify-otp-button').click();
  await page.getByTestId('emi-card-901154').getByTestId('emi-card-action-button').click();
  await page.getByRole('button', { name: 'EDIT DETAILS' }).first().click();
  await page.getByRole('button', { name: 'BACK', exact: true }).click();
  await page.getByRole('button', { name: 'EDIT DETAILS' }).first().click();
  await page.getByRole('button', { name: 'SUBMIT' }).click();
  await page.getByRole('button', { name: 'EDIT DETAILS' }).nth(1).click();
  await page.getByTestId('salaried').click();
  await page.getByRole('button', { name: 'SUBMIT' }).click();
  await page.getByRole('button', { name: 'EDIT DETAILS' }).nth(1).click();
  await page.getByTestId('salaried').click();
  await page.getByRole('button', { name: 'BACK', exact: true }).click();
  await page.getByRole('button', { name: 'EDIT DETAILS' }).nth(1).click();
  await page.getByTestId('self-employed').click();
  await page.getByRole('button', { name: 'SUBMIT' }).click();
  await page.getByRole('button', { name: 'BACK', exact: true }).click();
  await page.getByRole('button', { name: 'CONFIRM AND PROCEED' }).click();

  // ---------------------
  await context.close();
  await browser.close();
})();