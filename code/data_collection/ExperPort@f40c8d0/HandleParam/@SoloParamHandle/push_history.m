% [sph] = push_history(sph)    Add current value to the history of this SoloParamHandle
%
% Every time you call "push_history(sph)", the current value of that sph
% gets appended to a history record of it. To get the history back, use get_history(sph).
%
% PARAMETERS:
% -----------
%
% sph     The SoloParamHandle whose history is being added to. The current
%         value of the sph is what will be added to the history record.
%
% RETURNS:
% --------
%
% sph     The same SoloParamHandle. The return is actually pointless, since
%         SoloParamHandles operate as variables by reference.
%
%
% EXAMPLE:
% ---------
%
% Suppose you did:
%  >> SoloParamHandle('base', 'gu', 'value', 10);
%  >> push_history(gu);
%  >> gu.value = 20;
%  >> push_history(gu); push_history(gu);
%
% Then 
%  >> get_history(gu)
%      ans = {10 ; 20 ; 20}
%
%  >> get_history(gu, 2)
%      ans = 20

% Written by Carlos Brody in late 2005

function [sph] = push_history(sph)
   
   global private_soloparam_list;
   private_soloparam_list{sph.lpos} = ...
       push_history(private_soloparam_list{sph.lpos});
   
