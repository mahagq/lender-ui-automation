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
  await page.getByTestId('otp-input').click();
  await page.getByTestId('otp-input').fill('9999');
  await page.getByTestId('otp-input').press('Enter');
  await page.getByTestId('verify-otp-button').click();
  await page.getByTestId('emi-card-900849').getByTestId('emi-card-action-button').click();
  await page.getByTestId('proceed-button').click();
  await page.getByTestId('proceed-button').click();
  await page.getByText('Ahmed, Your General Details Enter your PAN Enter PANPlease enter panWhat is').click();
  await page.getByTestId('pan-number-input').click();
  await page.getByTestId('pan-number-input').fill('AABBSSSSSs');
  await page.getByTestId('pan-number-input-error').click();
  await page.getByTestId('close-button').click();
  await page.getByTestId('emi-card-900849').getByTestId('emi-card-action-button').click();
  await page.getByTestId('proceed-button').click();
  await page.getByTestId('pan-number-input').click();
  await page.getByTestId('pan-number-input').press('CapsLock');
  await page.getByTestId('pan-number-input').fill('AAAPA0000A');
  await page.getByText('Female').click();
  await page.getByTestId('year-react-select').locator('svg').click();
  await page.locator('.css-19bb58m').first().click();
  await page.getByRole('option', { name: 'Aug' }).click();
  await page.locator('div').filter({ hasText: /^Year$/ }).nth(4).click();
  await page.getByRole('option', { name: '1999' }).click();
  await page.locator('.css-19bb58m').click();
  await page.getByRole('option', { name: '9', exact: true }).click();
  await page.getByTestId('marital-status-radio-container-0').getByTestId('marital-status-radio').click();
  await page.getByTestId('email-input').click();
  await page.getByTestId('email-input').fill('masira.darvesh@grayquest.com');
  await page.getByTestId('proceed-button').click();
  await page.getByTestId('consent-checkbox-error').click();
  await page.getByTestId('back-button').click();
  await page.getByTestId('proceed-button').click();
  await page.getByTestId('pan-number-input').click();
  await page.getByTestId('pan-number-input').fill('AAAPA0000a');
  await page.getByText('Female').click();
  await page.locator('div:nth-child(2) > ._CustomReactSelect_uhnzr_1 > .css-b62m3t-container > .css-1l2ljem-control > .css-1nzdoek > .css-19bb58m').click();
  await page.getByRole('option', { name: 'Aug' }).click();
  await page.locator('.css-1p25tiz-indicatorContainer').first().click();
  await page.getByRole('option', { name: '2001' }).click();
  await page.locator('.css-19bb58m').click();
  await page.getByRole('option', { name: '13' }).click();
  await page.getByTestId('marital-status-radio-container-1').getByTestId('marital-status-radio').click();
  await page.getByTestId('consent-checkbox').check();
  await page.getByTestId('proceed-button').click();
  await page.getByTestId('email-input-error').click();

  // ---------------------
  await context.close();
  await browser.close();
})();