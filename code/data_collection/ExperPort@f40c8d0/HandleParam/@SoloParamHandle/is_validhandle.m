% [t] = is_validhandle(sph)   Check whether an SPH is a valid pointer
%                             to an actual SoloParam. 
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
%
% SPECIAL CALL:
% -------------
%
% NOT INTENDED FOR USER SPACE:  If a second argument is passed, this is
% taken to be a cell vector of SoloParams, and taken to have the same value
% as private_soloparam_list. This enables slightly faster processing.
% Normal use, however, is with only one parameter as above.


function [t] = is_validhandle(sph, soloparam_list)
        
   if nargin < 2,
     t = is_validhandle_from_global(sph);
   else
     x = soloparam_list{sph.lpos};
     t = isa(x, 'SoloParam');
   end;
   
   