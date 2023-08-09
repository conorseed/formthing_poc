import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';

export interface FormReturn {
  'id' : string,
  'created' : bigint,
  'name' : string,
  'updated' : bigint,
  'users' : Array<Principal>,
  'organisation_id' : string,
}
export interface FormThingActor {
  'create_form' : ActorMethod<[string, string], string>,
  'create_organisation' : ActorMethod<[string], string>,
  'get_form_by_id' : ActorMethod<[string], Result>,
  'vetkd_get_public_key' : ActorMethod<[], string>,
  'vetkd_get_symmetric_key' : ActorMethod<
    [Uint8Array | number[], Uint8Array | number[]],
    string
  >,
}
export type Result = { 'ok' : FormReturn } |
  { 'err' : string };
export interface _SERVICE extends FormThingActor {}
