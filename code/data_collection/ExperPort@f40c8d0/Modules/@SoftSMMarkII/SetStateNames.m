% function [sm] = SetStateNames(sm, M_by_2_cell_array)
%
% Sets the mapping of state numbers to state names
% Pass in an M by 2 cell array where:
% the number of rows corresponds to the mapped states
% and each row consists of a state name -> state number(s) array.
%
% The first column is a cell containing a string which is the name
% of the state.
%
% The second column contains an array (1xn vector) of scalars
% indicating the state numbers that belong to this state name. 
%
% So for instance if you wanted states 1, 35, 3, and 7 to belong to
% and share the label 'extra_iti_states' and state 40 to have the
% state name 'wait_for_cpoke' you would call this method as such:
%
% sm = SetStateNames(sm, { 'wait_for_cpoke' [ 40 ]; ...
%                          'extra_iti_states' [ 1 35 3 7 ]; } );
%
% Then, in the state matrix window you will see, rather than the
% raw state number, the text name of the state.
%
% State41 42 41 41 41 41 41 41 100.0 0 0
%
% becomes:
%
% State41/wait_for_cpoke       42 41/wait_for_cpoke 41/wait_for_cpoke 41/wait_for_cpoke 41/wait_for_cpoke 41/wait_for_cpoke 41/wait_for_cpoke 100.0 0 0
function [sm] = SetStateNames(sm, nvp)
    sm = get(sm.Fig, 'UserData');

    oldStateStrings = sm.StateStrings;
    oldLongestLabel = sm.LongestLabel;
    
    sm.LongestLabel = 0;
    sm.StateStrings = cell(0,1);

    [m, n] = size(nvp);
    if ~isa(nvp, 'cell') | n ~= 2 | m < 1,
      error(['Please pass an m x 2 cell array as the association of' ...
             ' state strings to state numbers.']);      
    end;
    for i=1:m
      str = nvp{i, 1};
      vec = nvp{i, 2};
      if ~isa(str, 'char'),
        error(sprintf(['Row %d, col 1 is not a string!'], i));
      end;
      if ~isvector(vec),
        error(sprintf(['Row %d, col 2 is not a vector!'], i));
      end;
      if (size(vec, 1) > 1), vec = vec'; end;
      if (length(str) > sm.LongestLabel),
        sm.LongestLabel = length(str);
      end;
      for pos=1:size(vec, 2)
        state = vec(1, pos);
        if state < 0,
          error('Cannot have negative state ids!');
        end;
        if state > 1000000,
          error('Cannot have state ids greater than 1 million!');
        end;
        sm.StateStrings{state+1} = str; % map state number to state name
      end;
    end;


%     % check for equality to determine if we need to call the
%     % expensive UpdateStateUI
%     isEq = all(size(oldStateStrings) == size(sm.StateStrings)) ...
%            & oldLongestLabel == sm.LongestLabel;
%     if (isEq), 
%       for i=1:size(oldStateStrings,1)
%         if (oldStateStrings{i, 1} ~= sm.StateStrings{i, 1} ...
%             | size(oldStateStrings{i, 2},2) ~= size(sm.StateStrings{i,2},2) ...
%             | any(oldStateStrings{i, 2}~=sm.StateStrings{i,2})),
%           isEq = 0;
%           break;
%         end;
%       end;
%     end;    
%     if ~isEq,      
    % redraw the matrix.. this is *SLOW*.
      sm.NeedSMListBoxUpdate = 1;
      sm = UpdateStateUI(sm);
%    end;
    
    set(sm.Fig, 'UserData', sm);

    return;

