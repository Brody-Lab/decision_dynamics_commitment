%nopath 	[r] = nopath(fname)	discard path header
%
% Takes a single string argument, and discards anything before
% (and including) the last '\'. Also discards drive if there.
%
% Does not take string matrices, but does take cell vectors of
% strings. 
%
% See also NOEXTENSION, PATHONLY, EXTENSION

function [r] = nopath(fname)

   if isempty(fname), r = fname; return; end;

   if ~isvector(fname),
      error('Need a string vector or cell vector, please');
   end;	

   if iscell(fname),
      for i=1:length(fname), fname{i} = nopath(fname{i}); end;
      r = fname;
      return;
   end;
          
   if ~isunix,
      p = max(find(fname == '\'  |  fname == ':'));
   else
      p = max(find(fname == '/'));
   end;
   
   if isempty(p),
      r = fname;
   else	
      r = fname((p+1):length(fname));
   end;
