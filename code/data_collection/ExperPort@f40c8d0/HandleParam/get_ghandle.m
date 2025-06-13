function [h] = get_ghandle(sph)
% When passed a vector of SoloParamHandles, this function deals with
% calling get_ghandle for each of them.
   
   h = zeros(size(sph));
   for i=1:length(sph(:)),
      h(i) = get_ghandle(sph{i});
   end;
   
