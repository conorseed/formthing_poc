# FormThing: End to End Encypted Form Builder on the Blockchain

Create beautiful, fully accesible forms and control your own data using FormThing.

![FormThing Screenshot](/src/form_thing_frontend/public/images/screenshot.jpg 'FormThing Screenshot')

## ⛔️ Before you get too excited...

This currently uses an [**insecure** implementation](../../rust/vetkd/src/system_api) of [the proposed vetKD system API on the IC](https://github.com/dfinity/interface-spec/pull/158) in a pre-compiled form. **Do not use this in production or for sensitive data**! This is solely provided **for demonstration purposes only**.

## 👋 Introduction

FormThing was created for Web3 companies to "do forms" the Web3 way:

- Login via Web3 wallet ([Internet Identity](https://identity.ic0.app/))
- Create and manage forms as needed
  - Manage user access to forms and submissions
  - Turn submissions on or off (active / inactive form)
- Share public URL to created forms for submissions
- Store your data on the blockchain instead of trusting it to the big boys (Google Forms, Typeform etc). Form submissions:
  - Are End-to-end encrypted
  - Only readable by who you choose to give access
  - Cannot be read by the blockchain nor the smart contract
  - Protected from spam by a simple nonce system
  - Exportable to CSV to do with as you please

## 🚀 Roadmap

- [x] Proof of Concept: Backend Canister API
  - [x] Create Forms
  - [x] Get Form by ID
  - [x] Get Form by ID with Nonce (for public use)
  - [x] Get Forms by User
  - [x] Update Form Settings
  - [x] Delete Form
- [x] Proof of Concept: Basic Frontend
  - [x] Login with Internet Identity
  - [x] Create & Manage Forms
  - [x] View Forms & Submissions
  - [x] Add other users to view Forms & Submissions
  - [x] Share public link for users to fill out form
  - [x] Public form is two fields: Name & Email address
  - [x] Export submissions to CSV
- [ ] Form Builder
  - [ ] Easily create beautiful, fully accessible forms
  - [ ] Basic Input Fields
    - Text, Text Area, Number, Email, Phone, Select, Radio, Checkbox
  - [ ] Information Fields (for display purposes)
    - Title, Text Area, Section Divider
  - [ ] Advanced Fields
    - Date, Time, File Upload(?)
  - [ ] Field Validation
  - [ ] Conditional fields
  - [ ] Custom Submission Confirmations
  - [ ] Submission Notifications (via email?)
- [ ] Refined Form Permissions
- [ ] Organisations
- [ ] Login without needing Web3 knowhow
- [ ] Embeddable Forms
- [ ] Form Analytics
- [ ] Paid Services

## 👀 How does it work?

In a nutshell, it's the magic of [the proposed vetKD system API on the IC](https://github.com/dfinity/interface-spec/pull/158). Specifically, FormThing utilises the `ibe_encryption` derivation path for encrypting data. This means, for example:

- Sharalanda creates a new form. The form is given a unique ID.
- Barnicus goes to the public URL and fills out the form. Their submission is encrypted using the derived public IBE key (based on the unique form ID), and then sent to the blockchain for storage.
- Sharalanda can then login, decrypt and view entries by deriving the secret IBE key (based on the unique form ID). They can also add other users to the form, giving them access to derive the secret IBE key.

![Account Holder Diagrams](/readme/formthing-notesv2-account.jpg 'Account Holder Diagrams')

![Form Submitter Diagrams](/readme/formthing-notesv2-submitter.jpg 'Form Submitter Diagrams')

## 📝 Build Your Own Form

Right now, the demo only outputs a single form:

![Form Example](/readme/formthing-form-example.png 'Form Example')

You could, however, build your own form using whatever tech stack you desire. To do so, all you need to do is:

1. Create a Form and note the Form ID
2. Make a call to the backend canister function `get_form_by_id_with_nonce` to get current form settings, and a security nonce used to verify the submission
3. Make a call to the backend canister function `vetkd_get_public_key` to get the Derived IBE Public Key
4. On form submission, encrypt the form data and send it to the backend canister function `create_entry`, along with the Form ID and nonce

An example form can be [found here](https://github.com/conorseed/formthing_poc/blob/main/src/form_thing_frontend/src/components/PublicFormPage.vue).

## 👩‍💻 Deploy Locally

To deploy locally, please ensure you have installed:

- [dfx](https://internetcomputer.org/docs/current/developer-docs/setup/install/) ^0.14.3
- [mops](https://mops.one/docs/install)
- node ^16.X

1. Clone the repo to your device
2. Open a new terminal to run a local IC replica:

```
dfx start --clean
```

3. Open a new terminal at the root of the project and run:

```
npm install
mops install
dfx canister create vetkd_system_api --specified-id s55qq-oqaaa-aaaaa-aaakq-cai
dfx generate
dfx deploy
```

4. Open a new terminal at the root of the project and run the below to start the frontend dev server:

```
npm run frontend
```

You should then be able to access the frontend, login and create forms at a url like `http://127.0.0.1:5173/`
