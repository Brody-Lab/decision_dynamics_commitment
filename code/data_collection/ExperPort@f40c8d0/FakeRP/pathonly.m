%pathonly 	[r] = pathonly(fname)	keep only path header
%
% Takes a single string argument, and discards anything after (not
% including) the last '\' or ':' (that is, keeps trailing
% slash). If there was no '\' or ':', returns the empty string.  
%
% Does not take string matrices, but does take cell string vectors.
%
% See also NOEXTENSION, NOPATH

function [r] = pathonly(fname)

   if isempty(fname), r = fname; return; end;
   if ~isvector(fname),
      error('Need a string vector, please');
   end;	
   
   if iscell(fname),
      for i=1:length(fname), fname{i} = pathonly(fname{i}); end;
      r = fname;
      return;
   end;

   if ~isunix, 
      p = max(find(fname == '\'  |  fname == ':'));
   else
      p = max(find(fname == '/'));
   end;
   
   if isempty(p),
      r = [];
   else	
      r = fname(1:p);
   end;
   
   return;
	
