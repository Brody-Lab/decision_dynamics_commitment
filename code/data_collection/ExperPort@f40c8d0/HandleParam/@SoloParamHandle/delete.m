% [] = delete(sph, [also_unregister=1])    Permanently deletes the passed SoloParamHandle. 
%
% Also deletes any graphics objects associated with it; removes it from
% the AutoSet register; and removes it from the register of functions
% that have been granted access to it. 
%
% The second argument is optional and its default value is 1. If it is
% passed as 0, then all of the above will happen except the SoloParamHandle
% will *not* be removed from the register of functions
% that have been granted access to it: make sure to remove it yourself!!
% (This possibility is added because that removal is slow; if removing
% whole owners, then removal from that register is faster done in a single
% chunk, not individually per SoloParamHandle, as is done here.)
%



% CDB wrote me Sep 05

function [] = delete(sph, also_unregister_flag)

   if nargin<2, also_unregister_flag = 1; end;

   RegisterAutoSetParam(sph, 'delete');
   if also_unregister_flag
     SoloFunctionAddVars(sph, 'add_or_delete', 'delete');
   end;
   
   if ~isempty(get_type(sph)),
      lh = get_lhandle(sph);
      gh = get_ghandle(sph);
      if ishandle(lh), delete(lh); end;
      if ishandle(gh), delete(gh); end;
      drawnow;
   end;
   
   global private_soloparam_list;
   
   private_soloparam_list{sph.lpos} = [];
