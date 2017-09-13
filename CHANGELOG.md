## 2.0.0

### Enhancements
- **Consent Changes**
  - Updated text for "Withdrawn from study" and "Refused to join study" pages
- **Dashboard Changes**
  - Test My Brain quizzes and Biobank registration are now accessible
    immediately after registration
- **Password Changes**
  - Helper text added to describe the minimum password requirements
- **Registration Changes**
  - Added email confirmation to registration form
  - Signature is now required to complete user profile
- **Survey Changes**
  - Starting survey now jumps directly to the first page of the survey
- **Gem Changes**
  - Updated to rails 5.1.4
  - Updated to haml 5.0.3
  - Updated to simplecov 0.15.1

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
