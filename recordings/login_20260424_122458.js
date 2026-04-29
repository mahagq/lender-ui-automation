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
  await page.getByTestId('verify-otp-button').click();
  await page.getByTestId('dashboard-title').click();
  await page.getByTestId('dashboard-subtitle').click();
  await page.getByTestId('emi-tab-navigation-button').click();
  await page.getByTestId('emi-card-900775').getByText('Application ID:').click();
  await page.getByTestId('900775').click();
  await page.getByTestId('emi-card-900775').getByTestId('app-id-copy-button').click();
  await page.getByRole('img').nth(4).click();
  await page.locator('._Option_Item_1pt7z_24 > span > svg > path').click();
  await page.getByTestId('back-button').click();
  await page.locator('div:nth-child(2) > ._EMIPlanCardWrap_1a4s5_4 > ._EMIPlanCard_apg6r_1 > ._Body_apg6r_44 > ._CardActions_apg6r_111 > ._BoxShadow_apg6r_132 > svg').click();
  await page.getByText('Upload documents').click();
  await page.getByTestId('back-button').click();
  await page.getByTestId('load-more-button').click();
  await page.getByTestId('create-new-application-button').click();
  await page.locator('._ModalImage_l4hfu_33').click();
  await page.getByText('Still want to create a new').click();
  await page.getByRole('button', { name: 'Create new application' }).click();
  await page.getByTestId('close-button').click();

  // ---------------------
  await context.close();
  await browser.close();
})();