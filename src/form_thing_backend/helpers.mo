// Vendor Imports
import Map "vendor/map/Map"; // https://github.com/ZhenyaUsenko/motoko-hash-map

// Base Imports
import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Int "mo:base/Int";
import Blob "mo:base/Blob";
import Char "mo:base/Char";
import Buffer "mo:base/Buffer";


module FormThingHelpers{

  /*
   * TYPES
   */
  public type Organisation = {
    id: Text; // id of the organisation
    created: Int; // timestamp from Time.now() of when created
    updated: Int; // timestamp from Time.now() of when updated
    name: Text; // name of the organisation
    users: Buffer.Buffer<Principal>; // buffer of users with access to the organisation
  };

  public type Form = {
    id: Text; // id of the form
    created: Int; // timestamp from Time.now() of when created
    updated: Int; // timestamp from Time.now() of when updated
    name: Text; // name of the form
    organisation_id: Text; // id of organisation the form belongs to
    users: Buffer.Buffer<Principal>; // buffer of users with access to the form
  };

  public type FormReturn = {
    id: Text; // id of the form
    created: Int; // timestamp from Time.now() of when created
    updated: Int; // timestamp from Time.now() of when updated
    name: Text; // name of the form
    organisation_id: Text; // id of organisation the form belongs to
    users: [Principal]; // array of users with access to the form
  };

  public type Entry = {
    created: Int; // timestamp from Time.now() of when created
    form_id: Text; // id of the form the entry belongs to
    data: Text; // encrypted entry data
  };

  /*
   * FUNCTIONS
   */
  
  // Returns a substring of the given text from the given start index to the given end index
  public func sub_text(value : Text, indexStart: Nat, indexEnd : Nat) : Text {
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

}