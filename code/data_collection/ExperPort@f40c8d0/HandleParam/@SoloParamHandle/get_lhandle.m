function [h] = get_lhandle(sph)
   
   global private_soloparam_list
   
   if ~isempty(get_type(private_soloparam_list{sph.lpos}))
      h = get_lhandle(private_soloparam_list{sph.lpos});
   else
      error('This is not a UI param handle');
   end;
   