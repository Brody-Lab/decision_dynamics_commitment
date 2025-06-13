%extension  [r] = extension(fname)  keep only filename extension
%
% Takes a single string argument, and discards anything before
% (and including) the last '.' 
%
% Does not take string matrices, but does take cell string vectors.
%
% see also NOPATH, NOEXTENSION, PATHONLY

function [r] = extension(fname)

   if isempty(fname), r = fname; return; end;
   if ~isvector(fname),
      error('Need a string or cell vector, please');
   end;	
   
   if iscell(fname),
      for i=1:length(fname), fname{i} = extension(fname{i}); end;
      r = fname;
      return;
   end;

   fname = nopath(fname);
   p = max(find(fname == '.'));
   if isempty(p),
      r = [];
   else	
      r = fname((p+1):length(fname));
   end;
