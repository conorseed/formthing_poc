// Vendor Imports
import Blob "mo:base/Blob";
import Buffer "mo:base/Buffer";
import Char "mo:base/Char";
import Int "mo:base/Int";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Text "mo:base/Text";

import Map "vendor/map/Map";
// import Source "vendor/uuid/async/SourceV4";
// import UUID "vendor/uuid/UUID";

module FormThingHelpers {

  /*
   * TYPES
   */
  public type Organisation = {
    id : Text; // id of the organisation
    created : Int; // timestamp from Time.now() of when created
    updated : Int; // timestamp from Time.now() of when updated
    name : Text; // name of the organisation
    users : Buffer.Buffer<Principal>; // buffer of users with access to the organisation
  };

  public type FormStatus = { #active; #inactive };

  public type FormBase = {
    id : Text; // id of the form
    created : Int; // timestamp from Time.now() of when created
    updated : Int; // timestamp from Time.now() of when updated
    name : Text; // name of the form
    organisation_id : Text; // id of organisation the form belongs to
    owner : Principal; // owner of the form
    status : FormStatus; // status of the form
  };

  public type Form = FormBase and {
    users : [Principal]; // array of users with access to the form
    next_entry_id : Nat; // next entry id
  };

  public type FormReturn = FormBase and {
    users : [Principal]; // array of users with access to the form
    entries_total : Nat; // total number of entries
  };

  public type Nonce = {
    nonce : Text; // nonce
  };

  public type NonceCheck = {
    form_id : Text; // id of the form the nonce belongs to
    lock : Bool; // lock
  };

  public type FormReturnPublicWithNonce = Nonce and {
    id : Text; // id of the form
    name : Text; // name of the form
    status : FormStatus; // status of the form
  };

  public type Entry = {
    created : Int; // timestamp from Time.now() of when created
    form_id : Text; // id of the form the entry belongs to
    data : Text; // encrypted entry data
  };

  public type Entries = Map.Map<Nat, Entry>; // buffer of entries

  public type EntriesReturn = [(Nat, Entry)]; // array of entries

  public type ResultText = Result.Result<Text, Text>;
  public type ResultFormReturn = Result.Result<FormReturn, Text>;
  public type ResultFormReturnArray = Result.Result<[FormReturn], Text>;
  public type ResultFormReturnPublicWithNonce = Result.Result<FormReturnPublicWithNonce, Text>;
  public type ResultEntriesReturn = Result.Result<EntriesReturn, Text>;

  /*
   * HELPER FUNCTIONS
   */

  // Returns a substring of the given text from the given start index to the given end index
  public func sub_text(value : Text, indexStart : Nat, indexEnd : Nat) : Text {
    if (indexStart == 0 and indexEnd >= value.size()) {
      return value;
    };
    if (indexStart >= value.size()) {
      return "";
    };

    var result : Text = "";
    var i : Nat = 0;
    label l for (c in value.chars()) {
      if (i >= indexStart and i < indexEnd) {
        result := result # Char.toText(c);
      };
      if (i == indexEnd) {
        break l;
      };
      i += 1;
    };

    result;
  };

  // creates a unique nonce
  public func create_nonce() : Text {
    // let g = Source.Source();
    // return UUID.toText(await g.new());
    return "Hello123";
  };

  /*
   * VETKD
   */
  type VETKD_SYSTEM_API = actor {
    vetkd_public_key : ({
      canister_id : ?Principal;
      derivation_path : [Blob];
      key_id : { curve : { #bls12_381 }; name : Text };
    }) -> async ({ public_key : Blob });
    vetkd_encrypted_key : ({
      public_key_derivation_path : [Blob];
      derivation_id : Blob;
      key_id : { curve : { #bls12_381 }; name : Text };
      encryption_public_key : Blob;
    }) -> async ({ encrypted_key : Blob });
  };

  public let vetkd_api : VETKD_SYSTEM_API = actor ("s55qq-oqaaa-aaaaa-aaakq-cai");
};
