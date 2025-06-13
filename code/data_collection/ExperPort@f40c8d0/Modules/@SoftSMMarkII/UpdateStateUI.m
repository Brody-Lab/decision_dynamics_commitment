function [sm] = UpdateStateUI(sm)
    
    set(sm.CurrentStateLabel, 'String', sprintf('State%d', ...
                                                sm.CurrentState));

    if (sm.NeedSMListBoxUpdate), 
      stateStrings = {};
      timeCol = size(sm.StateMatrix, 2) - 2;
      if sm.HasSchedWaves,
        timeCol = timeCol - 1;
      end;
      
      if ~sm.CookedSMView | ~sm.LongestLabel,
        % raw view, no state names present
        for i=1:size(sm.StateMatrix, 1),
          s = sprintf('State%3d ', i-1);
          beforetimeCol = 1:timeCol-1;
          aftertimeCol  = timeCol+1:size(sm.StateMatrix,2);
          beforestr  = sprintf('%7d', sm.StateMatrix(i, beforetimeCol));
          timeColstr = sprintf('    %3.3f', sm.StateMatrix(i,timeCol));
          afterstr   = sprintf('%7d', sm.StateMatrix(i, aftertimeCol));
          s = sprintf('%s%s%s%s', s, beforestr, timeColstr, afterstr);
          stateStrings(i) = {s};
        end;
      else
        % cooked view, append state names
        for i=1:size(sm.StateMatrix, 1),
          
          s = sprintf(sprintf('State%%3d/%%-0%ds', sm.LongestLabel), ...
                      i-1, StateName(sm,i-1));
          
          for j=1:size(sm.StateMatrix, 2),        
            if (j < timeCol),
              s = sprintf(sprintf('%%s%%7d/%%-0%ds', sm.LongestLabel), ...
                          s, sm.StateMatrix(i, j), StateName(sm, sm.StateMatrix(i, j)));
            elseif (j == timeCol),          
              s = sprintf('%s    %3.3f', s, sm.StateMatrix(i, j));
            else
              s = sprintf('%s%7d', s, sm.StateMatrix(i, j));
            end;
          end;
          stateStrings(i) = {s};
        end;
      end;
      
      set(sm.SMListBox, 'String', stateStrings);
      sm.NeedSMListBoxUpdate = 0;
    end;
    
    set(sm.SMListBox, 'Min', 0);
    set(sm.SMListBox, 'Max', 1);
    set(sm.SMListBox, 'Value', [sm.CurrentState+1]);
    
    
    return;
    
function [str] = StateName(sm,stateNum)
    str = '?';
    if (stateNum+1 < size(sm.StateStrings, 2) & ~isempty(sm.StateStrings{stateNum+1})),
      str = sm.StateStrings{stateNum+1};
    end;    
    return;
