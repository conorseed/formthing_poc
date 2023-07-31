// Vendor Imports
import Map "vendor/map/Map"; // https://github.com/ZhenyaUsenko/motoko-hash-map

// Base Imports
import Nat "mo:base/Nat";
import Blob "mo:base/Blob";


shared ({ caller = creator }) actor class FormThingActor() {

  /*
   * Stable Vars
   */
  let { bhash; } = Map;
  
  // FORMS INFORMATION
  // - Hashed by "Organisation ID + Form ID"
  var forms = Map.new<Blob, Nat>(bhash);

  // FORM ENTRIES
  // - Hashed by "Organisation ID + Form ID"
  var entries = Map.new<Blob, Nat>(bhash);

  // ORGANISATIONS
  // - Hashed by "Organisation ID"
  var organisations = Map.new<Blob, Nat>(bhash);
  
}