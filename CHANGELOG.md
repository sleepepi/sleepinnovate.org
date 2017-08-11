## 1.0.0

### Enhancements
- **General Changes**
  - Setup initial flow through website
  - New users can now create accounts, and reset their passwords
  - Account registration requires full name, email, date of birth, and recaptcha
  - New users are sent a welcome email that contains a link to create their
    password
  - Users can sign and accept consent form
  - The full consent can now be viewed online
  - Users are emailed a PDF copy of the consent after consenting to the study
  - An about page describes the study
  - A contact page was added to allow users to contact research study staff
  - Consent forms can now be downloaded as PDFs
  - Users can reset their password on the settings page
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
