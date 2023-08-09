export const idlFactory = ({ IDL }) => {
  const FormReturn = IDL.Record({
    'id' : IDL.Text,
    'created' : IDL.Int,
    'name' : IDL.Text,
    'updated' : IDL.Int,
    'users' : IDL.Vec(IDL.Principal),
    'organisation_id' : IDL.Text,
  });
  const Result = IDL.Variant({ 'ok' : FormReturn, 'err' : IDL.Text });
  const FormThingActor = IDL.Service({
    'create_form' : IDL.Func([IDL.Text, IDL.Text], [IDL.Text], []),
    'create_organisation' : IDL.Func([IDL.Text], [IDL.Text], []),
    'get_form_by_id' : IDL.Func([IDL.Text], [Result], []),
    'vetkd_get_public_key' : IDL.Func([], [IDL.Text], []),
    'vetkd_get_symmetric_key' : IDL.Func(
        [IDL.Vec(IDL.Nat8), IDL.Vec(IDL.Nat8)],
        [IDL.Text],
        [],
      ),
  });
  return FormThingActor;
};
export const init = ({ IDL }) => { return []; };
