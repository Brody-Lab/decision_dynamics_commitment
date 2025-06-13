function [h] = get_ghandle(sph)
%
% Returns the graphics handle that corresponds to a
% SoloParamHandle. Returns an error if the SPH is not a UI SPH. 
%
% If passed a cell array of SPH's, returns a matrix the same size as
% the cell, with corresponding entries being the graphics handle.
%
   
   if iscell(sph),
      h = zeros(size(sph));
      for i=1:rows(sph), for j=1:cols(sph),
            h(i,j) = get_ghandle(sph{i,j});
      end; end;
      return;
   end;
   
   
   global private_soloparam_list
   
   if ~isempty(get_type(private_soloparam_list{sph.lpos}))
      h = get_ghandle(private_soloparam_list{sph.lpos});
   else
      error('This is not a UI param handle');
   end;
   
