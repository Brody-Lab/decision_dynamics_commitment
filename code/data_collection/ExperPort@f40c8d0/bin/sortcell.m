%sortcell [C,I] = sortcell(C)  Sorts cell arrays, by rows
%
% Assumes that C is a square array of elements. Each column must
% composed of either strings or single numbers. Elements may also be empty;
% in a string column empty counts as the earliest string for sorting
% purposes; in a number column empty counts as -Inf for sorting purposes.
%
% Sorts alphabetically.  
%
% Remember: each column must be either only numbers (and empties) or only
% strings (and empties). Mixed columns will result in undefined errors.
%


function [N, I] = sortcell(C)

   orig_C = C;  % might replace some empties with -Inf or empty strings

   N = zeros(size(C));
   for i=1:cols(C), % Get unique entries column-by-column
      j=1; while isempty(C{j,i}), j=j+1; end;
      if j>size(C,1) || ~ischar(C{j,i}), char_or_num = 'num';
      else                               char_or_num = 'char';
      end;
      switch char_or_num,
         case 'char'
            try
               [trash1, trash2, J] = unique(C(:,i));
            catch ME %#ok<NASGU>
               % If the error was because an empty entry should have been an
               % empty string, let's try to fix it:
               for j=1:numel(C(:,i)), if isempty(C{j,i}), C{j,i} = ''; end; end;
               [trash1, trash2, J] = unique(C(:,i));
            end;
         case 'num'               % for numerical columns
            M = cell2mat(C(:,i));
            % number of elements matches, there were no empties
            if numel(M) == numel(C(:,i)),
               [trash1, trash2, J] = unique(M);
            else % will need to find the empties and assign -Inf to them.
               for j=1:numel(C(:,i)), if isempty(C{j,i}), C{j,i} = -Inf; end; end;
               M = cell2mat(C(:,i));
               [trash1, trash2, J] = unique(M);
            end;
      end;
      N(:,i) = J;
   end;
   
   [N, I] = sortrows(N);
   N = orig_C(I,:);
   return;
   
         
   