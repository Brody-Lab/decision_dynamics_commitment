% determine_fullfuncname.m    [owner] = determine_fullfuncname()
%
% RETURNS:  funcname, a string
%
% determine_fullfuncname asks who called the function that in turn called
% determine_fullfuncname. If it was an object's method, then "owner" is the
% relative pathname of the method, relative to @object/, starting with
% the method's m-file and ending with the subfunction name. fileseps
% are replaced by underscores. Thus, if called from
%         @this/private/mymethod.m,  subfunction boo()
% determine_fullfuncname would return:
%         'private_mymethod_boo'
% However, if the subfunction is the principal function of the m-file,
% then that part is not returned. That is, if called from
%         @this/private/mymethod.m,  subfunction mymethod()
% determine_fullfuncname would return:
%         'private_mymethod' 
%
% If called from a regular m-file, returns the name of that m-file and
% the subfunction. 
%
% If called from the base workspace, returns, simply, 'base'.
%
% Carlos Brody wrote me in Sep 05

function [owner] = determine_fullfuncname()
   
   st = dbstack('-completenames');
   if length(st)<3, owner = 'base'; return; end;

   caller = st(3).file; [trash, callername] = fileparts(caller);
   objdpt = strfind(caller, [filesep '@']);
   if ~isempty(objdpt)                      % It does belong to an object
      caller = caller(objdpt(end)+1:end);   % Only use lowest level object
      v = find(caller == filesep);
      caller(v(2:end)) = '_';
      caller = caller(v+1:end);
      if strcmp(caller(end-1:end), '.m'), caller = caller(1:end-2); end;
   else % Not an object, a regular m-file
      [pathstr, caller] = fileparts(caller);
   end;
   
   if ~strcmp(callername, st(3).name),
      owner = [caller '_' st(3).name];
   else
      owner = caller;
   end;
   
   
