% [sph] = add_callback(sph, callback)      Add a callback for a SoloParamHandle.
%
% If the SoloParamHandle had no callbacks in its list, creates a list and
% adds the new callback. If a list exists already, all callbacks in it,
% including the new one being added, must have the same number of args.
%
% EXAMPLE:
% --------
%
%  >> add_callback(my_sph, {'this_func', 10});
%
% After this call, if my_sph requests a callback, then after all other
% callbacks for my_sph are done, the function @owner/this_func.m will be
% called with arguments (obj, 10), where owner is the owner of my_sph
% (typically the class of the object that owns it), and obj is an object of
% class owner.
%

function [sph] = add_callback(sph, callback)

   global private_soloparam_list;
   private_soloparam_list{sph.lpos} = ...
       add_callback(private_soloparam_list{sph.lpos}, callback);

   