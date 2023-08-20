// FormThing Imports
import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Bool "mo:base/Bool";
import Buffer "mo:base/Buffer";
import Nat "mo:base/Nat";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Time "mo:base/Time";

import FormThing "helpers";
import Hex "vendor/Hex";
import Map "vendor/map/Map";

shared ({ caller = creator }) actor class FormThingActor() {

  /**
   * Global Vars
   */
  let { thash; nhash; phash } = Map;

  // FORMS INFORMATION
  // - Hashed by "Form ID"
  var stable_forms = Map.new<Text, FormThing.Form>(thash);
  // - Hashed by "User Principal", value is Buffer of "Form ID"s
  var stable_forms_by_user = Map.new<Principal, Buffer.Buffer<Text>>(phash);

  // FORM ENTRIES
  // - Hashed by "Form ID"
  var stable_entries = Map.new<Text, FormThing.Entries>(thash);

  // NONCES
  // - Hashed by "Nonce"
  var stable_nonces = Map.new<Text, FormThing.NonceCheck>(thash);

  // ORGANISATIONS
  // - Hashed by "Organisation ID"
  var stable_organisations = Map.new<Text, FormThing.Organisation>(thash);

  /**
   * Forms Functionality
   */

  var current_form_id : Nat = 0;

  // - Create Form
  public shared ({ caller }) func create_form(name : Text, organisation_id : Text) : async FormThing.ResultText {

    // Auth - No anonymous calls
    if (Principal.isAnonymous(caller) == true) {
      return #err("You must be logged in to use this function");
    };

    // Create Form ID
    let short_caller_id = FormThing.sub_text(Principal.toText(caller), 0, 8);
    let form_id = Text.concat(Nat.toText(current_form_id), short_caller_id);

    // Get time now
    let time_now = Time.now();

    // Create users buffer and add caller as user
    let users = Buffer.Buffer<Principal>(0);

    // Create Form
    let new_form : FormThing.Form = {
      created = time_now;
      updated = time_now;
      id = form_id;
      name;
      organisation_id;
      users;
      owner = caller;
      status = #inactive;
    };

    // add form to forms
    ignore Map.put(stable_forms, thash, form_id, new_form);

    // add form_id to forms_by_user
    let found_form_ids = Map.find<Principal, Buffer.Buffer<Text>>(stable_forms_by_user, func(k, v) { k == caller });

    switch (found_form_ids) {

      // create form_ids if not found
      // add new form_id to form_ids
      case null {
        let form_ids_buffer = Buffer.Buffer<Text>(0);
        form_ids_buffer.add(form_id);

        ignore Map.put(stable_forms_by_user, phash, caller, form_ids_buffer);
      };

      // add form_id to form_ids if found
      case (?(key, found_form_ids)) {
        found_form_ids.add(form_id);
        ignore Map.put(stable_forms_by_user, phash, caller, found_form_ids);
      };
    };

    // increment current_form_id
    current_form_id += 1;

    // return id
    return #ok(form_id);
  };

  // - Get Form by ID
  public shared ({ caller }) func get_form_by_id(form_id : Text) : async FormThing.ResultFormReturn {

    // Auth - No anonymous calls
    if (Principal.isAnonymous(caller) == true) {
      return #err("You must be logged in to use this function");
    };

    // find form
    let form = Map.find<Text, FormThing.Form>(stable_forms, func(k, v) { k == form_id });

    switch (form) {

      // return null if no form found
      case null {
        #err("Form not found");
      };

      // return form if found
      case (?(key, found_form)) {

        // convert users buffer to array
        let users = Buffer.toArray<Principal>(found_form.users);

        // get entries total
        let entries_check = Map.find<Text, FormThing.Entries>(stable_entries, func(k, v) { k == form_id });

        let entries_total : Nat = switch (entries_check) {
          case null { 0 };
          case (?(key, found_entries)) { found_entries.size() };
        };

        // create return form
        let form_return : FormThing.FormReturn = {
          id = found_form.id;
          name = found_form.name;
          organisation_id = found_form.organisation_id;
          created = found_form.created;
          updated = found_form.updated;
          users;
          entries_total;
          status = found_form.status;
          owner = found_form.owner;
        };

        #ok(form_return);
      };
    };

  };

  // - Get Form by ID with nonce
  public func get_form_by_id_with_nonce(form_id : Text) : async FormThing.ResultFormReturnPublicWithNonce {

    // find form
    let form = Map.find<Text, FormThing.Form>(stable_forms, func(k, v) { k == form_id });

    switch (form) {

      // return null if no form found
      case null {
        #err("Form not found");
      };

      // return form if found
      case (?(key, found_form)) {

        // convert users buffer to array
        let users = Buffer.toArray<Principal>(found_form.users);

        // create a nonce and save it
        let nonce = FormThing.create_nonce();

        let nonce_check : FormThing.NonceCheck = {
          form_id = found_form.id;
          lock = false;
        };

        // save nonce
        ignore Map.put(stable_nonces, thash, nonce, nonce_check);

        // create return form
        let form_return : FormThing.FormReturnPublicWithNonce = {
          id = found_form.id;
          name = found_form.name;
          status = found_form.status;
          nonce;
        };

        #ok(form_return);
      };
    };

  };

  // - Get Forms by User Principal
  public shared ({ caller }) func get_forms_by_user_principal() : async FormThing.ResultFormReturnArray {

    // Auth - No anonymous calls
    if (Principal.isAnonymous(caller) == true) {
      return #err("You must be logged in to use this function");
    };

    // find form_ids
    let form_ids = Map.find<Principal, Buffer.Buffer<Text>>(stable_forms_by_user, func(k, v) { k == caller });

    // grab all the forms
    let forms = Buffer.Buffer<FormThing.FormReturn>(0);

    switch (form_ids) {
      // if no forms, return empty array
      case null {
        return #ok([]);
      };
      case (?(key, found_form_ids)) {
        // iterate over form_ids
        Buffer.iterate<Text>(
          found_form_ids,
          func(form_id) {

            // find form
            let form = Map.find<Text, FormThing.Form>(stable_forms, func(k, v) { k == form_id });

            switch (form) {
              // do nothing if no form found
              case null {};

              case (?(key, found_form)) {
                // convert users buffer to array
                let users = Buffer.toArray<Principal>(found_form.users);

                // get entries total
                let entries_check = Map.find<Text, FormThing.Entries>(stable_entries, func(k, v) { k == form_id });

                let entries_total : Nat = switch (entries_check) {
                  case null { 0 };
                  case (?(key, found_entries)) { found_entries.size() };
                };

                // create return form
                let form_return : FormThing.FormReturn = {
                  id = found_form.id;
                  name = found_form.name;
                  organisation_id = found_form.organisation_id;
                  created = found_form.created;
                  updated = found_form.updated;
                  users;
                  entries_total;
                  owner = found_form.owner;
                  status = found_form.status;
                };

                forms.add(form_return);
              };
            };
          },
        )

      };
    };

    // covert forms buffer to array
    let forms_return = Buffer.toArray<FormThing.FormReturn>(forms);

    return #ok(forms_return);
  };

  // TO DO:
  // - Get Forms by Organisation ID
  // - Update Form Name
  // - Delete Form

  /**
   * Organisations Functionality
   */

  // var current_organisation_id : Nat = 0;

  // // - Create Organisation
  // public shared ({ caller }) func create_organisation(name : Text) : async Text {

  //   // Create Organisation ID
  //   let short_caller_id = FormThing.sub_text(Principal.toText(caller), 0, 8);
  //   let organisation_id = Text.concat(Nat.toText(current_organisation_id), short_caller_id);

  //   // Get time now
  //   let time_now = Time.now();

  //   // Create users buffer and add caller as user
  //   let users = Buffer.Buffer<Principal>(0);
  //   users.add(caller);

  //   // Create Organisation
  //   let new_organisation : FormThing.Organisation = {
  //     created = time_now;
  //     updated = time_now;
  //     id = organisation_id;
  //     name = name;
  //     users = users;
  //   };

  //   // add organisation to organisations
  //   ignore Map.put(organisations, thash, organisation_id, new_organisation);

  //   // increment current_organisation_id
  //   current_organisation_id += 1;

  //   // return id
  //   return organisation_id;
  // };

  // TO DO:
  // - Get Organisation by ID
  // - Get Organisation by Name
  // - Get Organisations by User Principal
  // - Add User Principal to Organisation
  // - Remove User Principal from Organisation
  // - Update Organisation Name
  // - Delete Organisation

  /**
   * Entries Functionality
   */

  // - Create Entry
  public func create_entry(form_id : Text, data : Text, nonce : Text) : async FormThing.ResultText {

    // find form
    let form = Map.find<Text, FormThing.Form>(stable_forms, func(k, v) { k == form_id });

    // return early if form not found
    switch (form) {
      case null {
        return #err("Form not found");
      };
      case (?(key, found_form)) {};
    };

    // check nonce
    let nonce_check = Map.find<Text, FormThing.NonceCheck>(stable_nonces, func(k, v) { k == nonce });

    switch (nonce_check) {
      // return early if nonce not found
      case null {
        return #err("Invalid nonce");
      };
      case (?(key, nonce_check)) {
        // return early if nonce does not match form id
        if (nonce_check.form_id != form_id) {
          return #err("Nonce does not match form id");
        };

        // return early if nonce is locked
        if (nonce_check.lock) {
          return #err("Nonce is already in use");
        };

        // lock nonce to ensure it can only be used once
        let new_nonce_check : FormThing.NonceCheck = {
          form_id = nonce_check.form_id;
          lock = true;
        };
        ignore Map.put(stable_nonces, thash, nonce, new_nonce_check);
      };
    };

    // Get time now
    let created = Time.now();

    // Create Entry
    let new_entry : FormThing.Entry = {
      created;
      form_id;
      data;
    };

    // get entries for form
    let found_entries = Map.find<Text, FormThing.Entries>(stable_entries, func(k, v) { k == form_id });

    switch (found_entries) {

      // create entries if not found
      // add new entry to entries
      case null {
        let entries_buffer = Buffer.Buffer<FormThing.Entry>(0);
        entries_buffer.add(new_entry);

        let new_entries : FormThing.Entries = entries_buffer;

        ignore Map.put(stable_entries, thash, form_id, new_entries);
      };

      // add entry to entries if found
      case (?(key, found_entries)) {
        found_entries.add(new_entry);
        ignore Map.put(stable_entries, thash, form_id, found_entries);
      };
    };

    // delete nonce
    switch (nonce_check) {
      case null {};
      case (?(key, nonce_check)) {
        ignore Map.remove(stable_nonces, thash, nonce);
      };
    };

    // return id
    return #ok("Entry created");
  };

  // - Get entries for form
  public shared ({ caller }) func get_entries(form_id : Text) : async FormThing.ResultEntriesReturn {

    // Auth - No anonymous calls
    if (Principal.isAnonymous(caller) == true) {
      return #err("You must be logged in to use this function");
    };

    // find form
    let form = Map.find<Text, FormThing.Form>(stable_forms, func(k, v) { k == form_id });

    // return early if form not found
    switch (form) {
      case null {
        return #err("Form does not exist");
      };
      case (?(key, found_form)) {};
    };

    // get entries for form
    let found_entries = Map.find<Text, FormThing.Entries>(stable_entries, func(k, v) { k == form_id });

    switch (found_entries) {

      // return early if entries not found
      case null {
        return #err("No entries found");
      };

      // return entries if found
      case (?(key, found_entries)) {
        return #ok(Buffer.toArray<FormThing.Entry>(found_entries));
      };
    };
  };

  /**
   * VETKD Functionality
   */
  public shared ({ caller }) func vetkd_get_public_key() : async Text {
    let { public_key } = await FormThing.vetkd_api.vetkd_public_key({
      canister_id = null;
      derivation_path = Array.make(Text.encodeUtf8("ibe_encryption"));
      key_id = { curve = #bls12_381; name = "test_key_1" };
    });
    return Hex.encode(Blob.toArray(public_key));
  };

  public shared ({ caller }) func vetkd_get_decryption_key(derivation_id : Blob, encryption_public_key : Blob) : async FormThing.ResultText {

    // Auth - No anonymous calls
    if (Principal.isAnonymous(caller) == true) {
      return #err("You must be logged in to use this function");
    };

    // convert derivation_id to text
    let form_id_check = Text.decodeUtf8(derivation_id);
    // make sure form_id is not null
    let form_id : Text = switch (form_id_check) {
      case null {
        return #err("Invalid derivation_id");
      };
      case (?form_id_text) {
        form_id_text;
      };
    };

    // Check if valid form_id
    let form_check = Map.find<Text, FormThing.Form>(stable_forms, func(k, v) { k == form_id });

    // check if caller has permissions to access this key
    let can_access_key : Bool = switch (form_check) {

      // return early if form not found
      case null {
        return #err("Form ID '" # form_id # "' not found");
      };

      case (?(key, found_form)) {

        // check if caller is owner
        if (found_form.owner == caller) {
          true;
        } else {
          // check if caller is user
          let found_user_index = Buffer.indexOf<Principal>(caller, found_form.users, func(user) { user.0 == caller });

          switch (found_user_index) {
            // cannot access key if not found
            case null {
              return #err("You do not have permission to access this key");
            };
            // can access key if found
            case (?index) { true };
          };
        };

      };
    };

    // get public key
    let { encrypted_key } = await FormThing.vetkd_api.vetkd_encrypted_key({
      derivation_id;
      public_key_derivation_path = Array.make(Text.encodeUtf8("ibe_encryption"));
      key_id = { curve = #bls12_381; name = "test_key_1" };
      encryption_public_key;
    });
    return #ok(Hex.encode(Blob.toArray(encrypted_key)));
  };

};

// https://github.com/dfinity/examples/blob/master/motoko/encrypted-notes-dapp-vetkd/src/encrypted_notes_motoko/
// https://github.com/dfinity/motoko-base/blob/1bee37dbe5dbab1017b18ba0490b78f148196c8b/src/Array.mo
