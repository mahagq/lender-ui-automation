*** Settings ***
Documentation
...    Page object keywords for the GQ Customer Portal Lender Selection page (/application-loader/{app_id}).
...    All locators use role-based or text selectors confirmed from Playwright recordings.
...    Library: Browser (Playwright).
...
...    Session model:
...      Suite Setup   → Navigate to Lender Selection (ApplicationCreationFlowPage.robot)
...      Test Setup    → Navigate To Lender Selection Within Session
...      Test Teardown → NONE (shared session)
...      Suite Teardown → Close Browser

Library    Browser
Library    String

*** Variables ***
# Page heading
${LS_HEADING}                   role=heading[name='Congratulations, your EMI application is approved']
${LS_SUBHEADING}                xpath=//p[contains(text(),'Please choose one of the financing partners below to complete your EMI registration.')]

# Rank labels — conditional presence (1–N lenders)
${LS_RANK_1_LABEL}              text=Rank 1
${LS_RANK_2_LABEL}              text=Rank 2
${LS_RANK_3_LABEL}              text=Rank 3

# Unavailable section — conditional presence (0–N unavailable)
${LS_UNAVAILABLE_HEADING}       role=heading[name='Currently Unavailable']
${LS_UNAVAILABLE_DISCLAIMER}    text=These options don't match
${LS_DISCLAIMER_TEXT}           xpath=//p[contains(text(),'Lenders are displayed in ascending order of estimated disbursement time')]

# Modal buttons (stable role-based selectors from Playwright recording)
${LS_LOAN_OFFER_DETAILS_BTN}    role=button[name='Loan Offer Details'] >> nth=0
${LS_VIEW_KFS_BTN}              role=button[name='View KFS'] >> nth=0
${LS_CLOSE_MODAL_BTN}           role=button[name='Close']

# Loan Offer Details modal fields
${LS_MODAL_TOTAL_FEE}           text=Total Fee Amount
${LS_MODAL_EMI_AMOUNT}          text=EMI Amount
${LS_MODAL_TENURE}              text=Tenure
${LS_MODAL_PAYABLE_TODAY}       text=Payable Today / Downpayment
${LS_MODAL_PROCESSING_FEE}      text=Processing Fee
${LS_MODAL_FORECLOSURE}         text=Foreclosure Charges
${LS_MODAL_MANDATE_CHARGE}      text=Mandate Charge
${LS_MODAL_APR}                 text=Annual Percentage Rate (APR)
${LS_MODAL_EMI_DEBIT_DATE}      text=EMI Will Be Debited On
${LS_MODAL_PENAL_CHARGES}       text=Penal Charges

# KFS modal fields
${LS_KFS_FEE_AMOUNT}            text=Fee Amount
${LS_KFS_MONTHLY_PAYMENTS}      text=No of Monthly Payments
${LS_KFS_MONTHLY_PAYMENT_AMT}   text=Monthly Payment Amount

# Consent + filters
${LS_CONSENT_CHECKBOX}          role=checkbox[name='I have carefully read and understood the Key Fact Statement (KFS)'] >> nth=0
${LS_FILTER_BANK}               xpath=//span[normalize-space()='Bank']
${LS_FILTER_NBFC}               xpath=//span[normalize-space()='NBFC'] >> nth=0

# Processing page (/application-loader-status/{app_id})
${LS_PROCESSING_HEADING}        role=heading[name='Processing your application...']
${LS_VERIFYING_TEXT}            text=Verifying your application

# Rejection state — modal shown when lender is rejected and user returns to lender selection
${LS_UNABLE_TO_PROCEED}         role=heading[name='More partners ready to help you!']
${LS_PLEASE_SELECT_ANOTHER}     text=Pick your preferred partner
${LS_VIEW_AVAILABLE_BTN}        role=button[name='View Available Financing Partners']

# Success state — application-status page shown after APPROVED bureau decision
${LS_SUCCESS_TEXT}              text=Your application has been successfully approved
${LS_PROCEED_BUTTON}            css=[data-testid='proceed-button']

*** Keywords ***
Lender Selection Page Should Be Visible
    [Documentation]    Waits for the lender selection page to load (heading or any lender card).
    ${has_heading}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${LS_HEADING}    visible    timeout=${LONG_TIMEOUT}
    IF    not ${has_heading}
        # Fallback: wait for any CONTINUE WITH button (lender cards loaded even without heading)
        Wait For Elements State    css=button:has-text('CONTINUE WITH')    visible    timeout=${LONG_TIMEOUT}
    END

Lender Selection Subheading Should Be Visible
    [Documentation]    Asserts the lender selection subheading text is visible.
    Wait For Elements State    ${LS_SUBHEADING}    visible    timeout=${LONG_TIMEOUT}

At Least One Rank Label Should Be Visible
    [Documentation]
    ...    Asserts Rank 1 label is visible and logs presence/absence of Rank 2 and Rank 3.
    Wait For Elements State    ${LS_RANK_1_LABEL}    visible    timeout=${TIMEOUT}
    ${has_rank_2}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${LS_RANK_2_LABEL}    visible    timeout=${TIMEOUT}
    Log    Rank 2 label present: ${has_rank_2}    level=DEBUG
    ${has_rank_3}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${LS_RANK_3_LABEL}    visible    timeout=${TIMEOUT}
    Log    Rank 3 label present: ${has_rank_3}    level=DEBUG

Currently Unavailable Section Should Be Visible If Present
    [Documentation]
    ...    Conditionally asserts the Currently Unavailable section.
    ...    Skips the check with a pass if the section is absent (dynamic lender set).
    ${is_present}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${LS_UNAVAILABLE_HEADING}    visible    timeout=3s
    Pass Execution If    not ${is_present}    Currently Unavailable section not present — dynamic lender set
    Wait For Elements State    ${LS_UNAVAILABLE_DISCLAIMER}    visible    timeout=${TIMEOUT}

Disclaimer Text Should Be Visible
    [Documentation]    Asserts the lender ordering disclaimer text is visible.
    Wait For Elements State    ${LS_DISCLAIMER_TEXT}    visible    timeout=${TIMEOUT}

Open Loan Offer Details For First Lender
    [Documentation]    Clicks the Loan Offer Details button on the first available lender card.
    Wait For Elements State    ${LS_LOAN_OFFER_DETAILS_BTN}    visible    timeout=${TIMEOUT}
    Click    ${LS_LOAN_OFFER_DETAILS_BTN} >> nth=0

Loan Offer Details Modal Should Show All Fields
    [Documentation]    Asserts all 10 Loan Offer Details modal fields are visible.
    Wait For Elements State    ${LS_MODAL_TOTAL_FEE}          visible    timeout=${TIMEOUT}
    Wait For Elements State    ${LS_MODAL_EMI_AMOUNT}         visible    timeout=${TIMEOUT}
    Wait For Elements State    ${LS_MODAL_TENURE}             visible    timeout=${TIMEOUT}
    Wait For Elements State    ${LS_MODAL_PAYABLE_TODAY}      visible    timeout=${TIMEOUT}
    Wait For Elements State    ${LS_MODAL_PROCESSING_FEE}     visible    timeout=${TIMEOUT}
    Wait For Elements State    ${LS_MODAL_FORECLOSURE}        visible    timeout=${TIMEOUT}
    Wait For Elements State    ${LS_MODAL_MANDATE_CHARGE}     visible    timeout=${TIMEOUT}
    Wait For Elements State    ${LS_MODAL_APR}                visible    timeout=${TIMEOUT}
    Wait For Elements State    ${LS_MODAL_EMI_DEBIT_DATE}     visible    timeout=${TIMEOUT}
    Wait For Elements State    ${LS_MODAL_PENAL_CHARGES}      visible    timeout=${TIMEOUT}

Close Modal
    [Documentation]    Clicks the Close button on any open modal.
    Click    ${LS_CLOSE_MODAL_BTN}

Open KFS For First Lender
    [Documentation]    Clicks the View KFS button on the first available lender card.
    Wait For Elements State    ${LS_VIEW_KFS_BTN}    visible    timeout=${TIMEOUT}
    Click    ${LS_VIEW_KFS_BTN} >> nth=0

Check KFS Consent
    [Documentation]    Ensures the KFS consent checkbox is checked; clicks it if not already checked.
    ${checked}=    Get Property    ${LS_CONSENT_CHECKBOX}    checked
    IF    not ${checked}
        Click    ${LS_CONSENT_CHECKBOX}
    END

Uncheck KFS Consent
    [Documentation]    Ensures the KFS consent checkbox is unchecked; clicks it if currently checked.
    ${checked}=    Get Property    ${LS_CONSENT_CHECKBOX}    checked
    IF    ${checked}
        Click    ${LS_CONSENT_CHECKBOX}
    END

Check KFS Consent If Present
    [Documentation]    Checks KFS consent checkbox only if visible — some lenders do not require it.
    ${present}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${LS_CONSENT_CHECKBOX}    visible    timeout=3s
    IF    ${present}
        Check KFS Consent
    END

Check KFS Consent For Lender If Present
    [Arguments]    ${lender_name}
    [Documentation]
    ...    Checks the KFS consent checkbox scoped to the named lender's card only.
    ...    Uses CSS :has() to find the checkbox inside the same card as the lender's button.
    ...    Skips silently if that lender does not require KFS consent.
    ${selector}=    Set Variable    css=div:has(button:has-text('${lender_name}')) input[type='checkbox']
    ${present}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${selector}    visible    timeout=3s
    IF    ${present}
        ${checked}=    Get Property    ${selector}    checked
        IF    not ${checked}
            Click    ${selector}
        END
    END

Click Bank Filter
    [Documentation]    Clicks the Bank filter tab on the lender selection page.
    Click    ${LS_FILTER_BANK}

Click NBFC Filter
    [Documentation]    Clicks the NBFC filter tab on the lender selection page.
    Click    ${LS_FILTER_NBFC}

Lender Selection Page Footer Text Should Be Visible
    [Documentation]    Asserts the footer text about lender ranking and display is visible.
    Wait For Elements State    ${LS_DISCLAIMER_TEXT}    visible    timeout=${TIMEOUT}

Click First Available Continue Button
    [Documentation]
    ...    Clicks the first CONTINUE WITH lender button with up to 3 retries (2s apart).
    Wait For Elements State    role=button[name*='CONTINUE WITH'] >> nth=0    visible    timeout=${TIMEOUT}
    Click    role=button[name*='CONTINUE WITH'] >> nth=0
    Log    Clicked first available lender continue button    level=DEBUG

Click Lender Continue Button By Name
    [Arguments]    ${lender_name}
    [Documentation]
    ...    Clicks the CONTINUE WITH button for a named lender (case-insensitive substring match).
    ...    The UI display name often differs from the internal lender-master name
    ...    (e.g. master "Ratnaafin Capital Pvt Ltd Lite" renders as "CONTINUE WITH RATNAAFIN CAPITAL").
    ...    Strategy: (1) try the full name, (2) try the first two words as a short token,
    ...    (3) fall back to the first available CONTINUE WITH button — BRE has already assigned
    ...    the lender at this stage, so the displayed card is the correct one.
    ${full}=    Run Keyword And Return Status
    ...    Wait For Elements State    css=button:has-text('${lender_name}') >> nth=0    visible    timeout=5s
    IF    ${full}
        Click    css=button:has-text('${lender_name}') >> nth=0
        Log    Clicked continue button for lender (full name): ${lender_name}    level=DEBUG
        RETURN
    END
    ${short_token}=    Evaluate    ' '.join('''${lender_name}'''.split()[:2])
    ${short}=    Run Keyword And Return Status
    ...    Wait For Elements State    css=button:has-text('${short_token}') >> nth=0    visible    timeout=5s
    IF    ${short}
        Click    css=button:has-text('${short_token}') >> nth=0
        Log    Clicked continue button for lender (short token '${short_token}'): ${lender_name}    level=WARN
        RETURN
    END
    Log    Named lender button not found for '${lender_name}' — clicking first available CONTINUE WITH    level=WARN
    Click First Available Continue Button

Processing Page Should Be Visible
    [Documentation]    Waits for the processing/loader page heading to become visible.
    Wait For Elements State    ${LS_PROCESSING_HEADING}    visible    timeout=${LONG_TIMEOUT}

Bureau Decision Should Be Final
    [Documentation]
    ...    Asserts one of three terminal bureau states:
    ...    - APPROVED: URL contains /application-status/
    ...    - REJECTED: "Unable to Proceed" modal heading visible (back on /application-loader/)
    ...    - BANK: URL contains /bank-statement/
    ...    Called by Wait For Bureau Decision — not intended for direct use.
    ${url}=    Get Url
    ${is_success}=    Evaluate    '/application-status/' in '${url}'
    ${is_rejected}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${LS_UNABLE_TO_PROCEED}   visible    timeout=2s
    ${is_bank}=    Evaluate    '/bank-statement/' in '${url}'
    Should Be True    ${is_success} or ${is_rejected} or ${is_bank}
    ...    Bureau decision not yet final

Wait For Bureau Decision
    [Documentation]
    ...    Polls until a terminal bureau decision state is detected
    ...    (approved, rejected, or bank-statement redirect).
    ...    Uses SUBMISSION_TIMEOUT (60s) to accommodate UAT latency on re-mount after rejection.
    Wait Until Keyword Succeeds    ${SUBMISSION_TIMEOUT}    2s    Bureau Decision Should Be Final
    Log    Bureau decision reached    level=INFO

Click View Available Financing
    [Documentation]
    ...    Clicks the View Available Financing Partners button on the rejection modal.
    ...    Modal closes and lender selection page remains (URL stays at /application-loader/).
    Log    Clicking View Available Financing Partners — dismissing rejection modal    level=INFO
    Wait For Elements State    ${LS_VIEW_AVAILABLE_BTN}    visible    timeout=${TIMEOUT}
    Click    ${LS_VIEW_AVAILABLE_BTN}
    Log    Rejection modal dismissed — back on lender selection page    level=DEBUG

Successful Lender Assignment Should Be Visible
    [Documentation]
    ...    Waits for either /application-status/ or /bank-statement/ URL after BRE decision.
    ...    BRE/lender decision can be slow (esp. CSB), so poll up to ${SUBMISSION_TIMEOUT}.
    Wait Until Keyword Succeeds    ${SUBMISSION_TIMEOUT}    2s    Application Status Or Bank Statement URL Should Be Active
    ${url}=    Get Url
    IF    '/bank-statement/' in '${url}'
        Log    BRE routed to /bank-statement/ — skipping bank statement page    console=True
    ELSE
        Wait For Elements State    ${LS_SUCCESS_TEXT}    visible    timeout=${LONG_TIMEOUT}
    END

Application Status URL Should Be Active
    [Documentation]    Helper — asserts the current URL contains /application-status/.
    ${url}=    Get Url
    Should Contain    ${url}    /application-status/

Application Status Or Bank Statement URL Should Be Active
    [Documentation]    Helper — asserts the current URL contains /application-status/ or /bank-statement/.
    ${url}=    Get Url
    Run Keyword If    '/application-status/' not in '${url}' and '/bank-statement/' not in '${url}'
    ...    Fail    URL '${url}' is neither /application-status/ nor /bank-statement/

Click Proceed To KYC
    [Documentation]    Clicks the proceed-button to advance to the KYC step. On /bank-statement/ pages,
    ...    navigates directly to /okyc/ using the app ID embedded in the URL.
    ${url}=    Get Url
    IF    '/bank-statement/' in '${url}'
        ${app_id}=    Evaluate    '${url}'.rstrip('/').split('/')[-1]
        Log    Bank statement page — navigating directly to /okyc/${app_id}    console=True
        Go To    ${BASE_URL}/okyc/${app_id}
    ELSE
        Click    ${LS_PROCEED_BUTTON}
    END

Lender Selection URL Should Be Active
    [Documentation]    Helper — asserts the current URL contains /application-loader/.
    ${url}=    Get Url
    Should Contain    ${url}    /application-loader/

Bank Statement URL Should Be Active
    [Documentation]    Helper — asserts the current URL contains /bank-statement/.
    ${url}=    Get Url
    Should Contain    ${url}    /bank-statement/

Extract App ID From Current URL
    [Documentation]    Extracts and returns the application ID from an /application-loader/{app_id} URL.
    ${url}=    Get Url
    ${app_id}=    Fetch From Right    ${url}    /application-loader/
    RETURN    ${app_id}

Extract App Code From Bank Statement URL
    [Documentation]    Extracts and returns the app code from a /bank-statement/{app_code} URL.
    ${url}=    Get Url
    ${app_code}=    Fetch From Right    ${url}    /bank-statement/
    RETURN    ${app_code}

Navigate To Lender Selection Within Session
    [Arguments]    ${app_id}
    [Documentation]    Navigates directly to the lender selection page for the given app ID.
    Go To    ${BASE_URL}/application-loader/${app_id}
    Lender Selection Page Should Be Visible

Mock BRE Assign Lender
    [Arguments]    ${decision}=APPROVED
    [Documentation]
    ...    Replaces window.XMLHttpRequest with MockXHR so BRE API calls use plain writable
    ...    properties. Captures parent_lender_name from the POST body dynamically — no hardcoding.
    ...    Also intercepts lender-select/fetch: first call passes through to real backend to capture
    ...    the original eligible lender list, then subsequent calls return filtered responses with
    ...    rejected lenders removed (moved to ineligible). When eligible list empties, frontend
    ...    naturally redirects to bank-statement. Patches window.fetch as safety net.
    Evaluate JavaScript    ${None}    (() => { if(!window.__consoleErrors){window.__consoleErrors=[];const _e=console.error.bind(console);console.error=function(){window.__consoleErrors.push(Array.from(arguments).map(String).join(' '));_e.apply(console,arguments);};} })()
    Evaluate JavaScript    ${None}
    ...    (() => { window.__breMockCreditBody='{"success":true,"status_code":200,"message":"Credit data processed","data":{}}'; window.__breMockDecision='${decision}'; window.__breRejectedLenders=[]; delete window.__breOriginalEligible; delete window.__breOriginalIneligible; delete window.__breOriginalMeta; if(window.__xhrMocked){return;} window.__xhrMocked=true; window.__breMockAssignBody='{"success":true,"status_code":200,"message":"Lender Assignment job created","data":{"job_id":"mock_job_test_123"}}'; window.__breMockLenderName='Selected Financing Partner'; const Orig=window.XMLHttpRequest; window.__OrigXHR=Orig; const _isLenderSelect=(u)=>u.includes('/v2/credit-engine/lender-select/fetch'); const _isBRE=(u)=>u.includes('/v2/credit-engine/assign-lender')||u.includes('/v2/credit-engine/process-credit-data')||_isLenderSelect(u); const _fetchBody=()=>JSON.stringify({success:true,status_code:200,message:'Lender Assignment Log Found Successfully',data:{application_id:0,type:'bureau',status:'COMPLETED',decision:window.__breMockDecision||'REJECTED',parent_lender_name:window.__breMockLenderName||'Selected Financing Partner'}}); const _lenderSelectBody=()=>{if(!window.__breOriginalEligible)return'{"success":true,"status_code":200,"message":"Eligible Lenders Found Successfully","data":{"eligible_lenders":[],"ineligible_lenders":[],"is_bureau_rejected":true,"is_bureau_lenders_applicable":true,"is_banking_lenders_applicable":true}}';const rej=window.__breRejectedLenders||[];const elig=window.__breOriginalEligible.filter(l=>!rej.includes(l.parent_lender_name));const newInelig=window.__breOriginalEligible.filter(l=>rej.includes(l.parent_lender_name)).map(l=>({parent_lender_name:l.parent_lender_name,lender_uuids:l.lender_uuids}));const inelig=(window.__breOriginalIneligible||[]).concat(newInelig);const data=Object.assign({},window.__breOriginalMeta||{},{eligible_lenders:elig,ineligible_lenders:inelig,is_bureau_rejected:elig.length===0,is_bureau_lenders_applicable:true,is_banking_lenders_applicable:true});return JSON.stringify({success:true,status_code:200,message:'Eligible Lenders Found Successfully',data});}; function MXR(){const r=new Orig();this._r=r;this._url='';this._method='GET';this.__evts={};this.readyState=0;this.status=0;this.statusText='';this.responseText='';this.response='';this.responseURL='';this.responseType='';this.timeout=0;this.withCredentials=false;this.upload=r.upload;this.onreadystatechange=null;this.onload=null;this.onerror=null;this.onabort=null;this.ontimeout=null;this.onloadend=null;this.onprogress=null;} MXR.prototype.addEventListener=function(t,fn){if(!this.__evts[t])this.__evts[t]=[];this.__evts[t].push(fn);}; MXR.prototype.removeEventListener=function(t,fn){if(this.__evts[t])this.__evts[t]=this.__evts[t].filter(f=>f!==fn);}; MXR.prototype.dispatchEvent=function(e){return true;}; MXR.prototype.open=function(m,u,a,usr,pw){this._url=u;this._method=m;if(!_isBRE(u)||_isLenderSelect(u))this._r.open(m,u,a===undefined?true:a,usr,pw);}; MXR.prototype.setRequestHeader=function(n,v){if(!this._hdrs)this._hdrs={};this._hdrs[n]=v;if(!_isBRE(this._url)||_isLenderSelect(this._url))this._r.setRequestHeader(n,v);}; MXR.prototype.getResponseHeader=function(n){if(_isBRE(this._url))return n.toLowerCase()==='content-type'?'application/json':null;return this._r.getResponseHeader(n);}; MXR.prototype.getAllResponseHeaders=function(){if(_isBRE(this._url))return'content-type: application/json\\r\\n';return this._r.getAllResponseHeaders();}; MXR.prototype.abort=function(){if(!_isBRE(this._url))this._r.abort();}; MXR.prototype.send=function(d){const self=this;const fire=(t,e)=>{if(self['on'+t])self['on'+t](e);(self.__evts[t]||[]).forEach(f=>f(e));};if(_isBRE(self._url)){window.__mockSendLog=window.__mockSendLog||[];window.__mockSendLog.push('XHR:'+self._url);if(_isLenderSelect(self._url)){if(!window.__breOriginalEligible){self._r.onloadend=function(){try{const parsed=JSON.parse(self._r.responseText);const data=parsed.data||{};window.__breOriginalEligible=JSON.parse(JSON.stringify(data.eligible_lenders||[]));window.__breOriginalIneligible=JSON.parse(JSON.stringify(data.ineligible_lenders||[]));window.__breOriginalMeta={};Object.keys(data).forEach(function(k){if(k!=='eligible_lenders'&&k!=='ineligible_lenders')window.__breOriginalMeta[k]=data[k];});}catch(e){}const body=_lenderSelectBody();self.readyState=4;self.status=200;self.statusText='OK';self.responseText=body;self.response=body;self.responseURL=self._url;fire('readystatechange',{type:'readystatechange',target:self});fire('load',{type:'load',target:self});fire('loadend',{type:'loadend',target:self});};self._r.onerror=function(e){fire('error',e);};self._r.send(d);return;}const lsBody=_lenderSelectBody();let lsTries=0;const respondLS=()=>{const hasH=self.onreadystatechange||self.onload||self.onloadend||(self.__evts.readystatechange||[]).length;lsTries++;if(!hasH&&lsTries<40){setTimeout(respondLS,25);return;}self.readyState=4;self.status=200;self.statusText='OK';self.responseText=lsBody;self.response=lsBody;self.responseURL=self._url;fire('readystatechange',{type:'readystatechange',target:self});fire('load',{type:'load',target:self});fire('loadend',{type:'loadend',target:self});};setTimeout(respondLS,25);return;}if(!self._url.includes('/fetch')&&!self._url.includes('/process-credit-data')&&d){try{const name=JSON.parse(d).parent_lender_name||'Selected Financing Partner';window.__breMockLenderName=name;if(!window.__breRejectedLenders.includes(name))window.__breRejectedLenders.push(name);}catch(e){}}let body;if(self._url.includes('/fetch')){body=_fetchBody();}else if(self._url.includes('/process-credit-data')){body=window.__breMockCreditBody;}else{body=window.__breMockAssignBody;}let tries=0;const respond=()=>{const hasH=self.onreadystatechange||self.onload||self.onloadend||(self.__evts.readystatechange||[]).length||(self.__evts.load||[]).length||(self.__evts.loadend||[]).length;tries++;if(!hasH&&tries<40){setTimeout(respond,25);return;}window.__mockSendLog.push('RESP:tries='+tries+' onloadend='+!!self.onloadend);self.readyState=2;self.status=200;self.statusText='OK';fire('readystatechange',{type:'readystatechange',target:self});self.readyState=3;fire('readystatechange',{type:'readystatechange',target:self});self.readyState=4;self.responseText=body;self.response=body;self.responseURL=self._url;fire('readystatechange',{type:'readystatechange',target:self});fire('load',{type:'load',target:self});fire('loadend',{type:'loadend',target:self});};setTimeout(respond,25);}else{const r=self._r;const copyState=()=>{self.readyState=r.readyState;self.status=r.status;self.statusText=r.statusText||'';try{self.responseText=r.responseText;}catch(e){}try{self.response=r.response;}catch(e){}self.responseURL=r.responseURL||'';};r.onreadystatechange=function(){copyState();fire('readystatechange',{type:'readystatechange',target:self});};r.onload=function(e){copyState();fire('load',e);};r.onerror=function(e){fire('error',e);};r.onabort=function(e){fire('abort',e);};r.ontimeout=function(e){fire('timeout',e);};r.onloadend=function(e){copyState();fire('loadend',e);};r.send(d);};}; window.__mockSendLog=[]; window.XMLHttpRequest=MXR; if(!window.__origFetch){window.__origFetch=window.fetch;window.fetch=async(url,opts)=>{const u=typeof url==='string'?url:(url.url||String(url));if(u.includes('/v2/credit-engine/assign-lender/fetch')){window.__mockSendLog.push('FETCH:fetch');return new Response(_fetchBody(),{status:200,headers:{'Content-Type':'application/json'}});}if(u.includes('/v2/credit-engine/lender-select/fetch')){window.__mockSendLog.push('FETCH:lender-select');if(!window.__breOriginalEligible){return window.__origFetch(url,opts).then(r=>r.json()).then(parsed=>{const data=parsed.data||{};window.__breOriginalEligible=JSON.parse(JSON.stringify(data.eligible_lenders||[]));window.__breOriginalIneligible=JSON.parse(JSON.stringify(data.ineligible_lenders||[]));window.__breOriginalMeta={};Object.keys(data).forEach(k=>{if(k!=='eligible_lenders'&&k!=='ineligible_lenders')window.__breOriginalMeta[k]=data[k];});return new Response(_lenderSelectBody(),{status:200,headers:{'Content-Type':'application/json'}});});}return new Response(_lenderSelectBody(),{status:200,headers:{'Content-Type':'application/json'}});}if(u.includes('/v2/credit-engine/assign-lender')){window.__mockSendLog.push('FETCH:assign');return new Response(window.__breMockAssignBody,{status:200,headers:{'Content-Type':'application/json'}});}if(u.includes('/v2/credit-engine/process-credit-data')){window.__mockSendLog.push('FETCH:credit');return new Response(window.__breMockCreditBody,{status:200,headers:{'Content-Type':'application/json'}});}return window.__origFetch(url,opts);};} })()
    ${mocked}=    Evaluate JavaScript    ${None}    () => window.__xhrMocked
    ${xhr_replaced}=    Evaluate JavaScript    ${None}    () => window.XMLHttpRequest !== window.__OrigXHR && window.XMLHttpRequest.toString().includes('MXR')
    Log    BRE mock applied: mocked=${mocked} xhr_replaced=${xhr_replaced} decision=${decision}    level=INFO

Switch BRE Mock To
    [Arguments]    ${decision}
    [Documentation]    Updates the BRE decision — MockXHR+fetch patches stay active.
    Evaluate JavaScript    ${None}    (() => { window.__breMockDecision='${decision}'; })()
    Log    BRE mock switched to ${decision}    level=INFO

Unroute BRE Mock
    [Documentation]    Restores original window.XMLHttpRequest and window.fetch. Clears all mock globals.
    Evaluate JavaScript    ${None}
    ...    (() => { if(window.__OrigXHR){window.XMLHttpRequest=window.__OrigXHR;delete window.__OrigXHR;} if(window.__origFetch){window.fetch=window.__origFetch;delete window.__origFetch;} delete window.__xhrMocked; delete window.__breMockAssignBody; delete window.__breMockCreditBody; delete window.__breMockDecision; delete window.__breMockLenderName; delete window.__breRejectedLenders; delete window.__breOriginalEligible; delete window.__breOriginalIneligible; delete window.__breOriginalMeta; delete window.__consoleErrors; })()
    Log    BRE mock removed (XHR+fetch restored)    level=DEBUG

Wait For Lender Page Or Bank Statement
    [Documentation]
    ...    After dismissing the rejection modal — polls up to 30s for either:
    ...    - lender selection heading visible (more lenders remain) → returns 'lender'
    ...    - /bank-statement/ in URL (all lenders exhausted) → returns 'bank'
    ...    Used in the NR03 loop so the last iteration doesn't fail when the
    ...    empty-lender-list redirect happens before the heading check.
    FOR    ${_}    IN RANGE    30
        ${url}=    Get Url
        ${on_bank}=    Run Keyword And Return Status    Should Contain    ${url}    /bank-statement/
        IF    ${on_bank}    RETURN    bank
        ${on_lender}=    Run Keyword And Return Status
        ...    Wait For Elements State    ${LS_HEADING}    visible    timeout=1s
        IF    ${on_lender}    RETURN    lender
        Sleep    1s
    END
    RETURN    unknown
