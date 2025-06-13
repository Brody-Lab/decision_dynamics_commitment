% [] = close(obj)    Method that gets called when the protocol is closed
%
% This method deletes any and all SoloParamHandles that are owned by
% obj. It assumes that it has been given read-only access to a
% SoloParamHandle named myfig which holds a handle to the main protocol
% figure; this method deletes that figure.
%
% Add any other necessary figure closures or deletions to this code.
%

% CDB Feb 06

function [] = close(obj)

   GetSoloFunctionArgs;
   % SoloFunctionAddVars('close', 'ro_args', 'myfig');
   
   delete(value(myfig));
   
   delete_sphandle('owner', ['^@' class(obj) '$']);



