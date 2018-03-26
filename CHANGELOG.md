## 9.0.0

### Enhancements
- **Gem Changes**
  - Updated to rails 5.2.0.rc2

## 8.0.0 (March 1, 2018)

### Enhancements
- **General Changes**
  - Added a page to track consent revisions
- **Consent Changes**
  - The consent form language has been updated to reflect that the lottery is
    now drawn twice each quarter

### Bug Fix
- Fixed a bug that could occasionally prevent a user account from being created

## 7.0.0 (February 11, 2018)

### Enhancements
- **Consent Changes**
  - The consent form language has been updated to reflect the new lottery prize
    amount and the change in principal investigators
- **Email Changes**
  - Reminder email text updated to include eligiblity for quarterly lottery
    drawing

## 6.0.1 (February 6, 2018)

### Bug Fix
- Fixed a bug importing nightly Test My Brain data

## 6.0.0 (February 6, 2018)

### Enhancements
- **Email Changes**
  - Email links now link directly to the login page
  - The login page now highlights the "Forgot your password?" link after failure
    to login
- **Survey Changes**
  - Added a survey review page to review responses before submitting and
    completing a survey
  - Survey reminder emails and the dashboard now take into account completed
    surveys with skipped questions
  - Added unique indices for tracking completion of brain tests and slice
    surveys
- **Test My Brain Changes**
  - Added progress bar text to indicate that updates only occur once a day
- **Gem Changes**
  - Updated to rails 5.2.0.rc1
  - Updated to pg 1.0.0
  - Updated to bootstrap 4.0.0
  - Updated to carrierwave 1.2.2
  - Updated to devise 4.4.1

## 5.0.1 (January 16, 2018)

### Bug Fix
- Removed bootsnap due to asset compilation issues

## 5.0.0 (January 16, 2018)

### Enhancements
- **Admin Changes**
  - Subject codes for withdrawn subjects are now displayed
  - Survey activation and reminder email times are now included in admin export
- **Email Changes**
  - Updated survey available email
  - Updated survey reminder email
  - Baseline surveys now have reminder email
  - Reminder emails now take into account Test My Brain survey completion
- **Dashboard Changes**
  - Added study timeline to dashboard
  - Disabled survey start buttons in order to reduce the likelihood of launching
    the survey twice
  - The dashboard now highlights an active panel for users
- **Survey Changes**
  - Imperial height is now displayed as two dropdowns for feet and inches
  - Time of day is now displayed as dropdowns for hours, minutes, and seconds
- **Test My Brain Changes**
  - Total number of brain surveys now matches number of surveys instead of
    number of batteries
- **Gem Changes**
  - Updated to ruby 2.5.0
  - Updated to rails 5.2.0.beta2
  - Updated to bootsnap 1.1.8
  - Updated to bootstrap 4.0.0.beta3
  - Updated to devise 4.4.0

### Bug Fixes
- Deleted users can now no longer login
- Admins no longer receive an error when attempting to view a deleted user
- Users who have revoked consent no longer receive survey followup reminder
  emails

## 4.1.0 (December 12, 2017)

### Enhancements
- **General Changes**
  - Removed parking voucher text from landing page

## 4.0.0 (November 15, 2017)

### Enhancements
- **General Changes**
  - Autocomplete removed from registration and sign in pages
  - About page button now links to dashboard for logged in users
  - Fixed position of footer icons in Firefox
- **Admin Changes**
  - Fixed color of header on users index
  - Reports and exports no longer include users flagged as testers
  - Admins receive an overview email of activation and reminder emails sent
  - Improved display of Test My Brain results
- **Consent Changes**
  - Improved language for alert when clicking Consent without checking box
- **Email Changes**
  - Added brain quizzes and surveys available and reminder emails
- **Event Changes**
  - Followup events activation emails and reminders are now sent out
- **Landing Changes**
  - Landing page now includes text about longitudinal followup by email
- **Settings Changes**
  - Autocomplete now turned off on the "WITHDRAW" leave study prompt
- **Survey Changes**
  - Numeric input questions should now default to numeric keyboard
  - Dropdowns now include text for blank default options
  - Survey completion bar now display percent of overall surveys completed
    instead of overall questions completed
- **Test My Brain Changes**
  - Test My Brain CSV files are now archived by year and month
- **Gem Changes**
  - Updated to kaminari 1.1.1

## 3.0.0 (October 30, 2017)

### Enhancements
- **General Changes**
  - Removed extraneous session expired notification
  - The Enrollment Exit and Registration pages now redirect back to the
    dashboard after three minutes of inactivity
- **Dashboard Changes**
  - Parking voucher links now only show up if the clinic has been set
- **Settings Changes**
  - Users are now prompted to type "WITHDRAW" to leave the SleepINNOVATE study
- **Survey Changes**
  - Removed survey skip question button
  - Removed auto-advance for single response questions
  - Improved spacing of separators in date and time questions
  - Clicking "Continue" now disables and animates the button
- **Test My Brain Changes**
  - Brain quizzes import now archives processed CSV files
- **Gem Changes**
  - Updated to bootstrap 4.0.0.beta2
  - Updated to haml 5.0.4
  - Added bootsnap 1.1.5

### Tests
- Added tests to assure user passwords can be reset

## 2.1.1 (October 16, 2017)

### Enhancements
- **Settings Changes**
  - The "Leave Study" button can now be disabled in the application settings

## 2.1.0 (October 16, 2017)

### Enhancements
- **Admin Changes**
  - Users index is now paginated
  - Admin dashboard now provides relevant reports and links
  - Added a consent report by site and by month
- **Dashboard Changes**
  - Improved arrangement of dashboard cards on smaller devices
- **Consent Changes**
  - Added consent administrative header
  - Removed links from emails and telephone numbers on consent
  - Added meta tag to prevent automatic telephone links on iPads on consent form
  - Date of birth input now displays better on mobile
  - Signatures are no longer cleared when device window is resized
- **Landing Changes**
  - The pledge is now displayed on the landing page
  - Updated text for the pledge
- **Footer Changes**
  - Simplified footer on smaller devices
- **Survey Changes**
  - Completed surveys are now tracked to allow users to skip questions and
    continue to next surveys
  - Checkboxes with mutually exclusive options now update choices based on the
    selection of mutually exclusive or non-exclusive options
- **Test My Brain Changes**
  - Brain quizzes can now be disabled in the application settings
- **Gem Changes**
  - Updated to carrierwave 1.2.1
  - Updated to sitemap_generator 6.0.0

### Bug Fix
- Fixed a bug that prevented consenting when navigating directly to the consent
  page

## 2.0.0 (October 2, 2017)

### Enhancements
- **Admin Changes**
  - Added admin export task
- **Consent Changes**
  - Updated text for "Withdrawn from study" and "Refused to join study" pages
  - Added consent administrative footer
- **Dashboard Changes**
  - Test My Brain quizzes and Biobank registration are now accessible
    immediately after registration
  - Made the link to redeeming parking voucher more visible
- **Email Changes**
  - Added text from consent email to the welcome email
  - Added footer text on unencrypted emails to email layout
- **Password Changes**
  - Helper text added to describe the minimum password requirements
- **Registration Changes**
  - Added email confirmation to registration form
  - Signature is now required to complete user profile
  - Clinics can now specify a clinic code to allow users to be assigned the
    correct clinic on registration
- **Survey Changes**
  - Starting survey now jumps directly to the first page of the survey
- **Test My Brain Changes**
  - Improved the import of data from Test My Brain
- **Gem Changes**
  - Updated to ruby 2.4.2
  - Updated to rails 5.1.4
  - Updated to haml 5.0.3
  - Updated to mini_magick 4.8.0
  - Updated to simplecov 0.15.1
  - Updated to signature_pad 2.3.1

## 1.1.0 (September 12, 2017)

### Enhancements
- **Consent Changes**
  - Consent moved ahead of registration and consent signature removed
- **Profile Changes**
  - Improved routes to prevent users from reloading paths that do not exist
- **Settings Changes**
  - Removed ability to update Date of Birth and Address from settings
  - Users can now update their email from settings page
- **Survey Changes**
  - Time of day variables now correctly set PM variables that have PM set as
    default value
  - Time of day variables now correctly show and hide seconds based on time of
    day format
- **Test My Brain Changes**
  - Subject codes are now configurable to provide a way to differentiate between
    staging and production servers
  - Subject code now includes event slug when forwarding to Test My Brain

## 1.0.0 (August 28, 2017)

### Enhancements
- **General Changes**
  - Setup initial flow through website
  - New users can now create accounts, and reset their passwords
  - Account registration requires full name, email, date of birth, and recaptcha
  - New users are sent a welcome email that contains a link to create their
    password
  - Users can sign and accept consent form
  - The full consent can now be viewed online
  - Users are emailed that they have consented to the study and provided a link
    to download a copy of the consent
  - An about page describes the study
  - A contact page was added to allow users to contact research study staff
  - Consent forms can now be downloaded as PDFs
  - Users can reset their password on the settings page
  - Users who have consented and completed their profile can receive a parking
    voucher
  - Using Ruby on Rails 5.1.3 framework
  - Using Bootstrap 4.0.0.beta
- **Encryption Changes**
  - Sensitive data attributes are stored using AES-256-CBC encryption
  - A KEK/DEK rotation infrastructure is in place to allow quick and slow key
    rotations
    - `rails encryption:rotate_master_kek`
      - Run monthly and whenever master key during staff, who had access to key,
        leaves the institution
      - This task re-encrypts any stored data encryption keys
    - `rails encryption:rotate_dek`
      - Run yearly, this method re-encrypts every data element individually
- **Participant Changes**
  - Participants can be in the following states:
    - Registered
    - Refused
    - Consented
    - Withdrawn
- **Test My Brain Changes**
  - Added task to import data from Test My Brain export to track user brain
    surveys completion
- **Admin Changes**
  - Admins can now manage user accounts
