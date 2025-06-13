function [h] = get_glhandle(sph)
% When passed a vector of SoloParamHandles, this function deals with
% calling get_glhandle for each of them, and returns them in a column 
% vector.
   
   h = zeros(2*prod(size(sph)), 1);
   for i=1:length(sph(:)),
      h(2*i-1) = get_ghandle(sph{i});
      h(2*i)   = get_lhandle(sph{i});
   end;
   
