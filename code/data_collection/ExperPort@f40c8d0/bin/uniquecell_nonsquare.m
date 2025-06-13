%uniquecell [S] = uniquecell_nonsquare(C)   return unique rows of cell array C
%
% Every column of C must be either strings or numbers. S will have
% sorted, unique, rows of C. Crucially, S will have the same number of
% columns as C. 
% 
% This is a variant of uniquecell, but is used for cell arrays where not
% all columns may be populated
%

function [S] = uniquecell_nonsquare(C)

    % Strategy will be to to first get unique entries of 1-arg callbacks,
    % then two-arg callbacks.
    ind_1 = [0]; ind_2 = [0];
    for ctr = 1:rows(C)
        if C{ctr,1} == 1
            ind_1 = [ind_1 ctr];
        elseif C{ctr,1} == 2
            ind_2 = [ind_2 ctr];
        end;
    end;
    
    sorted_1 = sort_subcell(C(ind_1(2:end),1:3));
    sorted_2 = sort_subcell(C(ind_2(2:end),1:4));
    
    S = sorted_2;   % put bigger one in first
    S(end+1:end+rows(sorted_1),:) = cell(rows(sorted_1), cols(S));
    S(end+1:end+rows(sorted_1), 1:cols(sorted_1)) = sorted_1;  % put smaller one at bottom.

   return;
   
% ---------

function [sorted] = sort_subcell(D)
   T = sortcell(D);         % SP: Strategy seems to be to sort and then      
   if rows(T) <= 1,                   % go down cell row-by-row, discarding equal cell rows
      sorted = T; return;
   end;
   
   nuniques = 1; 
   lastguy = T(1,:);

   sorted = cell(size(T));
   sorted(1,:) = lastguy;
   
   for i=2:rows(T),
      if ~isequal(T(i,:), lastguy),
         lastguy = T(i,:);
         nuniques = nuniques + 1;
         sorted(nuniques,:) = lastguy;
      end;
   end;

   sorted = sorted(1:nuniques,:);
      
% ---------
function [t] = isequal(A, B)
% Given two column cell string vectors, return 1 if they are equal, 0
% if not. A and B must have same number of columns.
   
   t = 1;
   for i=1:cols(A),
      if isstr(A{i}),
         if ~strcmp(A{i}, B{i}), t=0; return; end;
      else
         if A{i} ~= B{i}, t=0; return; end;
      end;
   end;
   
   return;
   
   