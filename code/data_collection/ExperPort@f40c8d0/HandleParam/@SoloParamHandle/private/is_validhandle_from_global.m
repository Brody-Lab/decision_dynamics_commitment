% [t] = is_validhandle_from_global(sph)   Check whether an SPH is a valid pointer
%                      to an actual SoloParam. No second optional argument
%                      is allowed; list of valid SoloParamHandles is always
%                      taken fromthe global private_soloparam_list.
%
% PARAMETERS:
% -----------
%
% sph    A SoloParamHandle object
%
%
% RETURNS:
% --------
%
% t      0 if the sph isn't a handle to a SoloParam; 1 if it is.
%


function [t] = is_validhandle_from_global(sph)

   global private_soloparam_list;
   x = private_soloparam_list{sph.lpos};
   t = isa(x, 'SoloParam');

   
   