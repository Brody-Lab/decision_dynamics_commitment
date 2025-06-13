% determine_partfuncname.m    [funcname] = determine_partfuncname()
%
% RETURNS:  funcname, a string
%
% determine_partfuncname asks who called the function that in turn called
% determine_partfuncname. It just returns the main mfile's name, no
% subfunction or path to it. Thus, if called from
%         @this/private/mymethod.m,  subfunction boo()
% determine_partfuncname would return:
%         'mymethod'
%
% If called from a regular m-file, returns the name of that m-file  
%
% If called from the base workspace, returns, simply, 'base'.
%
% Carlos Brody wrote me in Sep 05

function [fname] = determine_partfuncname()
   
   st = dbstack('-completenames');
   if length(st)<3, fname = 'base'; return; end;

   caller = st(3).file; 
   [trash, fname] = fileparts(caller);
   
   
