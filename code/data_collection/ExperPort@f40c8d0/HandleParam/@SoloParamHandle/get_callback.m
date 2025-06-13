function [cbck] = get_callback(sph)
%
% Return the callback associated with the sph
%   
   
   global private_soloparam_list
   cbck = get_callback(private_soloparam_list{sph.lpos});
