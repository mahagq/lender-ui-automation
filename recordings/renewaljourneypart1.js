const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch({
    headless: false
  });
  const context = await browser.newContext();
  const page = await context.newPage();
  await page.goto('https://customer.uat.graydev.in/');
  await page.getByTestId('mobile-number-input').click();
  await page.getByTestId('mobile-number-input').fill('8108556701');
  await page.getByTestId('consent-checkbox').check();
  await page.getByTestId('send-otp-button').click();
  await page.getByTestId('otp-input').click();
  await page.getByTestId('otp-input').fill('9999');
  await page.getByTestId('verify-otp-button').click();
  await page.getByTestId('create-new-application-button').click();
  await page.getByRole('button', { name: 'Create new application' }).click();
  await page.locator('.css-19bb58m').click();
  await page.locator('#react-select-2-input').fill('masi');
  await page.getByRole('option', { name: 'Masira Darvesh', exact: true }).click();
  await page.locator('.css-19bb58m').click();
  await page.getByRole('option', { name: 'Bangalore (Whitefield)' }).click();
  await page.locator('.css-19bb58m').click();
  await page.getByRole('option', { name: 'BA Photography' }).click();
  await page.locator('.css-19bb58m').click();
  await page.getByRole('option', { name: '-2023' }).click();
  await page.locator('._InputWrapper_4a5np_4').first().click();
  await page.getByTestId('first-name-input').fill('masira');
  await page.getByTestId('last-name-input').click();
  await page.getByTestId('last-name-input').fill('darvesh');
  await page.getByText('New Admission').click();
  await page.locator('div').filter({ hasText: /^Class$/ }).nth(3).click();
  await page.getByRole('option', { name: 'Jr. K.G (UKG)' }).click();
  await page.getByTestId('loan-amount-input').click();
  await page.getByTestId('loan-amount-input').fill('76000');
  await page.getByRole('button', { name: 'Show Plans' }).click();
  await page.getByTestId('0-133147').getByText('159').click();
  await page.locator('._Radio_Circle_3vblw_29').first().click();
  await page.getByTestId('submit-plan-details-button').click();
  await page.locator('div').filter({ hasText: 'Welcome back, Sanjay! We\'ve' }).nth(2).click();
  await page.getByTestId('back-button').click();
  await page.getByTestId('submit-plan-details-button').click();
  await page.getByTestId('close-button').click();
  await page.getByTestId('emi-card-900974').getByTestId('emi-card-action-button').click();

  // ---------------------
  await context.close();
  await browser.close();
})();