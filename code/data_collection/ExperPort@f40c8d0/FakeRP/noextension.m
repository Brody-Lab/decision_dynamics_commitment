%noextension  [r] = noextension(fname)  discard filename extension
%
% Takes a single string argument, and discards anything after (and
% including) the last '.'
%
% Does not take string matrices, but does take cell string vectors.
%
% see also NOPATH, EXTENSION, PATHONLY

function [r] = noextension(fname)

   if isempty(fname), r = fname; return; end;
   if ~isvector(fname),
      error('Need a string or cell vector, please');
   end;	
   
   if iscell(fname),
      for i=1:length(fname), fname{i} = noextension(fname{i}); end;
      r = fname;
      return;
   end;

   p = max(find(fname == '.'));
   if isempty(p),
      r = fname;
   else	
      r = fname(1:(p-1));
   end;
