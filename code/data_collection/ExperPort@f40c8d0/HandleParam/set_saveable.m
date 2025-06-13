%set_saveable   [] = set_saveable(handlelist, saveval)  
%
% Sets the saveable parameter for each handle in a cell containing a
% list of handles 
%
% PARAMS:
%
% -handlelist   a cell containing SoloParamHandles
%
% -saveable     a scalar or a matrix with same number of elems as
%               handlelist. If scalar, all members of handlelist get
%               the same saveable value set.
%

function [] = set_saveable(handlelist, saveval)
   
   handlelist = handlelist(:);
   saveval    = saveval(:);
   
   if length(saveval) == 1, saveval = saveval*ones(size(handlelist)); end;
      
   if length(saveval) ~= length(handlelist),
      error(['saveval must either be a scalar or have same total number ' ...
             'of elements as handlelist']);
   end;
   
   for i=1:length(handlelist),
      set_saveable(handlelist{i}, saveval(i));
   end;
   
   
