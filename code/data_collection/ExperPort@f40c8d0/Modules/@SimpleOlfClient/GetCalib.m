% function [cell_array_out] = GetCalib(olf, comp)
%
% Retreives the entire contents of the in-memory calibration table for a
% PIDFlow controller.  See SetCalib and List.
function [out] = GetCalib(olf, comp)
    lines = DoQueryCmd(olf, sprintf('GET CALIB %s', comp));
    out = [];
    for i=1:size(lines,1)
      l = lines(i, :);
      row = [];
      while true,
        [str, l] = strtok(l);
        if (isempty(str)), break; end;
        num = str2num(str);
        if (isempty(num)), 
            error('Parse error in GetCalib, expected number!');
        end;
        row = horzcat(row, num);
      end;
      out = vertcat(out,row);
    end;
    
