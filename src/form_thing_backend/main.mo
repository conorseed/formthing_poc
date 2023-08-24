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
  stable var stable_forms = Map.new<Text, FormThing.Form>(thash);
  // - Hashed by "User Principal", value is array of "Form ID"s
  stable var stable_forms_by_user = Map.new<Principal, [Text]>(phash);

  // FORM ENTRIES
  // - Hashed by "Form ID"
  stable var stable_entries = Map.new<Text, FormThing.Entries>(thash);

  // NONCES
  // - Hashed by "Nonce"
  stable var stable_nonces = Map.new<Text, FormThing.NonceCheck>(thash);

  // ORGANISATIONS
  // - Hashed by "Organisation ID"
  // var stable_organisations = Map.new<Text, FormThing.Organisation>(thash);

  /**
   * Forms Functionality
   */

  stable var current_form_id : Nat = 0;

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

    // Create users array
    let users : [Principal] = [];

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
      next_entry_id = 1;
    };

    // add form to forms
    ignore Map.put(stable_forms, thash, form_id, new_form);

    // add form_id to forms_by_user
    let found_form_ids = Map.find<Principal, [Text]>(stable_forms_by_user, func(k, v) { k == caller });

    switch (found_form_ids) {

      // create form_ids if not found
      // add new form_id to form_ids
      case null {
        let form_ids : [Text] = Array.make(form_id);

        ignore Map.put(stable_forms_by_user, phash, caller, form_ids);
      };

      // add form_id to form_ids if found
      case (?(key, found_form_ids)) {
        let found_form_ids_buffer = Buffer.fromArray<Text>(found_form_ids);
        found_form_ids_buffer.add(form_id);
        ignore Map.put(stable_forms_by_user, phash, caller, Buffer.toArray<Text>(found_form_ids_buffer));
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

        // get entries total
        let entries_check = Map.find<Text, FormThing.Entries>(stable_entries, func(k, v) { k == form_id });

        let entries_total : Nat = switch (entries_check) {
          case null { 0 };
          case (?(key, found_entries)) { Map.size(found_entries) };
        };

        // create return form
        let form_return : FormThing.FormReturn = {
          id = found_form.id;
          name = found_form.name;
          organisation_id = found_form.organisation_id;
          created = found_form.created;
          updated = found_form.updated;
          users = found_form.users;
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
    let form_ids_check = Map.find<Principal, [Text]>(stable_forms_by_user, func(k, v) { k == caller });

    let form_ids : [Text] = switch (form_ids_check) {
      // if no form_ids, return empty array
      case null {
        return #ok([]);
      };
      // otherwise set form_ids
      case (?(key, found_form_ids)) {
        found_form_ids;
      };
    };

    // grab all the forms
    let forms = Buffer.Buffer<FormThing.FormReturn>(0);

    // iterate over form_ids
    for (form_id in form_ids.vals()) {
      // find form
      let form = Map.find<Text, FormThing.Form>(stable_forms, func(k, v) { k == form_id });

      switch (form) {
        // do nothing if no form found
        case null {};

        case (?(key, found_form)) {

          // get entries total
          let entries_check = Map.find<Text, FormThing.Entries>(stable_entries, func(k, v) { k == form_id });

          let entries_total : Nat = switch (entries_check) {
            case null { 0 };
            case (?(key, found_entries)) { Map.size(found_entries) };
          };

          // create return form
          let form_return : FormThing.FormReturn = {
            id = found_form.id;
            name = found_form.name;
            organisation_id = found_form.organisation_id;
            created = found_form.created;
            updated = found_form.updated;
            users = found_form.users;
            entries_total;
            owner = found_form.owner;
            status = found_form.status;
          };

          forms.add(form_return);
        };
      };
    };

    // covert forms buffer to array
    let forms_return = Buffer.toArray<FormThing.FormReturn>(forms);

    return #ok(forms_return);
  };

  // - Update Form Settings
  let update_form_settings_lock = Map.new<Text, Bool>(thash);
  public shared ({ caller }) func update_form_settings(form_id : Text, name : Text, status : FormThing.FormStatus, users : [Principal]) : async FormThing.ResultText {

    // Auth - No anonymous calls
    if (Principal.isAnonymous(caller) == true) {
      return #err("You must be logged in to use this function");
    };

    // find form
    let form_check = Map.find<Text, FormThing.Form>(stable_forms, func(k, v) { k == form_id });

    let form : FormThing.Form = switch (form_check) {
      // return null if no form found
      case null {
        return #err("Form not found");
      };
      // return form if found
      case (?(key, found_form)) {
        found_form;
      };
    };

    // form exists, check if it's locked
    let form_lock_check = Map.find<Text, Bool>(update_form_settings_lock, func(k, v) { k == form_id });

    switch (form_lock_check) {
      // return early if form is locked
      case (?(key, found_form_lock)) {
        if (found_form_lock == true) {
          return #err("Form is locked for updates");
        };
      };
      // otherwise lock form
      case null {
        ignore Map.put(update_form_settings_lock, thash, form_id, true);
      };
    };

    // check if caller is owner
    if (form.owner != caller) {
      return #err("You do not have permission to update this form");
    };

    // if users different, update stable_forms_by_user
    if (form.users != users) {

      // get the values which are different
      // create new empty buffer
      let difference = Buffer.Buffer<(Principal, Text)>(0);

      // find users to delete
      for (user in form.users.vals()) {
        let found_user = Array.find<Principal>(users, func(u) { u == user });

        switch (found_user) {
          // add user to difference if not found
          case null {
            difference.add((user, "delete"));
          };
          // do nothing if found
          case (?user) {};
        };
      };

      // find users to add
      for (user in users.vals()) {
        let found_user = Array.find<Principal>(form.users, func(u) { u == user });

        switch (found_user) {
          // add user to difference if not found
          case null {
            difference.add((user, "add"));
          };
          // do nothing if found
          case (?user) {};
        };
      };

      // iterate over difference
      for (user in difference.vals()) {
        let user_principal : Principal = user.0;
        let action : Text = user.1;

        // find form_ids
        let form_ids_check = Map.find<Principal, [Text]>(stable_forms_by_user, func(k, v) { k == user_principal });

        if (action == "add") {
          switch (form_ids_check) {
            // create form_ids if not found
            case null {
              let form_ids : [Text] = Array.make(form_id);

              ignore Map.put(stable_forms_by_user, phash, user_principal, form_ids);
            };
            // add form_id to form_ids if found
            case (?(key, found_form_ids)) {
              let found_form_ids_buffer = Buffer.fromArray<Text>(found_form_ids);
              found_form_ids_buffer.add(form_id);
              ignore Map.put(stable_forms_by_user, phash, user_principal, Buffer.toArray<Text>(found_form_ids_buffer));
            };
          };
        };

        if (action == "delete") {
          switch (form_ids_check) {
            // do nothing if not found
            case null {};
            // remove form_id from form_ids if found
            case (?(key, found_form_ids)) {
              let found_form_ids_buffer = Buffer.fromArray<Text>(found_form_ids);

              // get index of form_id
              let index = Buffer.indexOf<Text>(form_id, found_form_ids_buffer, Text.equal);

              // remove form_id from buffer
              switch (index) {
                case null {};
                case (?index) {
                  ignore found_form_ids_buffer.remove(index);
                };
              };
              // update stable_forms_by_user
              ignore Map.put(stable_forms_by_user, phash, user_principal, Buffer.toArray<Text>(found_form_ids_buffer));
            };
          };
        };

      };

    };

    // update form
    let updated_form : FormThing.Form = {
      created = form.created;
      updated = Time.now();
      id = form.id;
      name;
      organisation_id = form.organisation_id;
      users;
      owner = form.owner;
      status;
      next_entry_id = form.next_entry_id;
    };

    // save form
    ignore Map.put(stable_forms, thash, form_id, updated_form);

    // unlock form
    Map.delete(update_form_settings_lock, thash, form_id);

    #ok("Form updated");

  };

  // TO DO:
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
    let form_check = Map.find<Text, FormThing.Form>(stable_forms, func(k, v) { k == form_id });

    // return early if form not found
    let form = switch (form_check) {
      case null {
        return #err("Form not found");
      };
      case (?(key, found_form)) { found_form };
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

      case null {
        // create entries if not found
        let new_entries : FormThing.Entries = Map.new<Nat, FormThing.Entry>(nhash);
        ignore Map.put(new_entries, nhash, form.next_entry_id, new_entry);
        // add new entry to entries
        ignore Map.put(stable_entries, thash, form_id, new_entries);

        // increment next_entry_id
        let next_entry_id = form.next_entry_id + 1;
        let updated_form : FormThing.Form = {
          created = form.created;
          updated = form.updated;
          id = form.id;
          name = form.name;
          organisation_id = form.organisation_id;
          users = form.users;
          owner = form.owner;
          status = form.status;
          next_entry_id;
        };
        ignore Map.put(stable_forms, thash, form_id, updated_form);
      };

      // add entry to entries if found
      case (?(key, found_entries)) {
        ignore Map.put(found_entries, nhash, form.next_entry_id, new_entry);
        // save to stable
        ignore Map.put(stable_entries, thash, form_id, found_entries);
        // increment next_entry_id
        let next_entry_id = form.next_entry_id + 1;
        let updated_form : FormThing.Form = {
          created = form.created;
          updated = form.updated;
          id = form.id;
          name = form.name;
          organisation_id = form.organisation_id;
          users = form.users;
          owner = form.owner;
          status = form.status;
          next_entry_id;
        };
        ignore Map.put(stable_forms, thash, form_id, updated_form);
      };
    };

    // delete nonce
    switch (nonce_check) {
      case null {};
      case (?(key, nonce_check)) {
        Map.delete(stable_nonces, thash, nonce);
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
        return #ok(Map.toArray<Nat, FormThing.Entry>(found_entries));
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
          let found_user = Array.find<Principal>(found_form.users, func(user) { user == caller }); //Buffer.indexOf<Principal>(caller, found_form.users, func(user) { user.0 == caller });

          switch (found_user) {
            // cannot access key if not found
            case null {
              return #err("You do not have permission to access this key");
            };
            // can access key if found
            case (?user) { true };
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
