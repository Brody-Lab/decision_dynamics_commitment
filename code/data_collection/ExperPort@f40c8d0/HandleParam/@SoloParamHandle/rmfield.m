function [sph] = rmfield(sph, fieldname)

  if isstruct(value(sph)),
    global private_soloparam_list;
    private_soloparam_list{sph.lpos} = ...
      rmfield(private_soloparam_list{sph.lpos}, fieldname);
  else
    error('This SoloParamHandle does not contain a struct, rmfield undefined');
  end;
  