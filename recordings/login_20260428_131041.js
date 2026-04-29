const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch({
    headless: false
  });
  const context = await browser.newContext();
  const page = await context.newPage();
  await page.goto('https://customer.uat.graydev.in/');
  await page.getByText('Assisted by our Campus').click();
  await page.getByText('If you were assisted by GQ').click();
  await page.getByPlaceholder('Enter Referral Code').click();
  await page.getByRole('button', { name: 'PROCEED' }).click();
  await page.getByTestId('undefined-error').click();
  await page.getByTestId('skip-button').click();
  await page.getByTestId('referral-code-heading').click();
  await page.getByText('Code', { exact: true }).click();
  await page.getByTestId('code-value').click();
  await page.getByTestId('referral-code-edit-button').click();
  await page.getByPlaceholder('Enter Referral Code').click();
  await page.getByPlaceholder('Enter Referral Code').fill('841');
  await page.getByRole('button', { name: 'PROCEED' }).click();
  await page.getByText('Referral code updated').click();

  // ---------------------
  await context.close();
  await browser.close();
})();