% [vh] = get_history(sph, [record_n])    Return a history of values of this SoloParamHandle
%
% Every time you call "push_history(sph)", the current value of that sph
% gets appended to a history record of it. To get the history back, use the
% current function, get_history.
%
% PARAMETERS:
% -----------
%
% sph     The SoloParamHandle whose history is being retrieved
%
% OPTIONAL PARAMETERS:
% --------------------
%
% record_n    If present, this parameter should be a number, indicating the
%          record number to be returned. If absent, an n-by-1 cell is
%          returned, with each element corresponding to one record.
%
% RETURNS:
% --------
%
% vh       A cell with the history record; each time push_history is called,
%          a new record is made. Thus vh will be an n-by-1 cell with n
%          being the number of times push_history(sph) was called. If
%          parameter record_n was present, vh will not be a cell but will
%          be the record_n element of the history.
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


function [vh] = get_history(sph, u)
   
   global private_soloparam_list
   if nargin==1,
      vh = get_history(private_soloparam_list{sph.lpos});
   else
      vh = get_history(private_soloparam_list{sph.lpos}, u);
   end;
      