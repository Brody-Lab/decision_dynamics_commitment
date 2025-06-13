% determine_fullowner.m    [owner] = determine_fullowner()
%
% RETURNS:  owner, a string
%
% determine_fullowner asks who called the function that in turn called
% determine_fullowner. If it was an object's method, then "owner" is the
% relative pathname of the method, relative to @object/, starting with
% the method's m-file and ending with the subfunction name. fileseps
% are replaced by underscores. Thus, if called from
%         @this/private/mymethod.m,  subfunction boo()
% determine_fullowner would return:
%         '@this_private_mymethod_boo'
%
% If called from a regular m-file, returns the name of that m-file and
% the subfunction. 
%
% If called from the base workspace, returns, simply, 'base'.
%
% Carlos Brody wrote me in Sep 05

function [owner] = determine_fullowner()
   
   st = dbstack('-completenames');
   if length(st)<3, owner = 'base'; return; end;

   caller = st(3).file;
   objdpt = strfind(caller, [filesep '@']);
   if ~isempty(objdpt)                      % It does belong to an object
      caller = caller(objdpt(end)+1:end);   % Only use lowest level object
      caller(find(caller==filesep)) = '_';
      if strcmp(caller(end-1:end), '.m'), caller = caller(1:end-2); end;
   else % Not an object, a regular m-file
      [pathstr, caller] = fileparts(caller);
   end;
   
   owner = [caller '_' st(3).name];
