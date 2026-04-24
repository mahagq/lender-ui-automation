const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch({
    headless: false
  });
  const context = await browser.newContext();
  const page = await context.newPage();
  await page.goto('https://customer.uat.graydev.in/');
  await page.locator('section').filter({ hasText: 'Register forEMI PlansShare a' }).locator('svg').click();
  await page.getByTestId('register-for-title').click();
  await page.getByTestId('emi-plans-title').click();
  await page.getByTestId('info-paragraph').click();
  await page.getByRole('img', { name: 'Trusted by Image desktop' }).click();
  await page.getByRole('paragraph').filter({ hasText: '© 2026 GrayQuest Education' }).click();
  await page.getByRole('heading', { name: 'What is your Mobile Number?' }).click();
  await page.getByTestId('mobile-number-input').click();
  await page.getByText('Please enter the mobile').click();
  await page.getByText('By signing in, I agree to the Terms of Services & Privacy Policy . I hereby give consent to the financers of GrayQuest and/or GrayQuest to sent communication to me over WhatsApp.').click();
  await page.getByTestId('consent-checkbox-label').click();
  await page.getByTestId('mobile-number-input').click();
  await page.getByTestId('mobile-number-input').fill('7383929838');
  await page.getByTestId('send-otp-button').click();
  await page.getByTestId('consent-checkbox-error').click();
  await page.getByTestId('consent-checkbox').check();
  await page.getByTestId('send-otp-button').click();
  await page.getByTestId('back-button').click();
  await page.getByTestId('mobile-number-input').click();
  await page.getByTestId('mobile-number-input').fill('7383929838');
  await page.getByTestId('consent-checkbox').check();
  await page.getByTestId('send-otp-button').click();
  await page.getByTestId('desktop-view-form-title').getByText('Enter').click();
  await page.getByRole('heading', { name: 'Enter 4 Digit OTP' }).click();
  await page.getByTestId('otp-input').click();
  await page.locator('._LeftIcon_4a5np_105 > svg > path:nth-child(2)').click();
  await page.getByTestId('mobile-number-info').click();
  await page.getByTestId('send-otp-timer-container').click();
  await page.getByTestId('verify-otp-button').click();
  await page.getByTestId('otp-input-error').click();
  await page.getByTestId('otp-input').click();
  await page.getByTestId('otp-input').fill('9999');
  await page.getByTestId('verify-otp-button').click();

  // ---------------------
  await context.close();
  await browser.close();
})();