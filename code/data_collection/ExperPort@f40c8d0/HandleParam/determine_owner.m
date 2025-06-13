% determine_owner.m    [owner] = determine_owner()
%
% RETURNS:  owner, a string
%
% determine_onwer asks who called the function that in turn called
% determine_owner. If it was an object's method, then "owner" is the
% object type, with an "@" at the beginning. If it was a regular
% m-file, then it is the name of that m-file. If it was the base
% workspace, then "owner" is 'base'.
%
% Carlos Brody wrote me in Sep 05

function [owner] = determine_owner()
   
   st = dbstack('-completenames');
   if length(st)<3, owner = 'base'; 
   else
      caller = st(3).file;
      objdpt = strfind(caller, [filesep '@']);
      if ~isempty(objdpt)           % It does belong to an object
         objdpt = objdpt(end);      % Only use lowest level object
         fseps  = strfind(caller, filesep);            
         v = find(objdpt < fseps);  % Find any fileseps after objdpt
         if isempty(v),
            owner = caller(objdpt+1:end);
         else
            owner = caller(objdpt+1:min(fseps(v))-1);
         end;
      else % Not an object, a regular m-file
         [pathstr, name] = fileparts(caller);
         owner = name;
      end;
   end;
