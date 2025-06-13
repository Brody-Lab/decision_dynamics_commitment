%setdiff_sph.m    [hlist] = setdiff_sph(s1, s2)
%
% Given two cells containing SoloParamHandles, returns a cell
% containing all those SPHs that are in s1 but not in s2.
% ASSUMES that the SPHs in s1 are all unique and that the SPHs in s2 are
% all unique.
%

function [hlist] = setdiff_sph(s1, s2)
   
   if isempty(s1) || isempty(s2), hlist = s1; return; end;

   s1 = s1(:); s2 = s2(:);
   
   guys = true(size(s1));
   for i=1:length(s1),
      j=1; while j<=length(s2), %#ok<ALIGN>
         if is_same_soloparamhandle(s1{i}, s2{j}),
            guys(i) = false;
            s2 = s2([1:j-1 j+1:end]); % this guy in s2 was already matched;
                                      % remove him (we're assuming all SPHs
                                      % in s1 and s2 are unique)
            j = length(s2);
         end;
      j=j+1; end;
   end;
   
   hlist = s1(guys);
   
