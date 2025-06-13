% function [cell_array_out] = GetLog(olf)
%
% Retreives the entire contents of the in-memory data log from the
% olfactometer olf
function [out] = GetLog(olf)
    out = {};

    if (~LogCount(olf)), return; end;
    
    out = DoQueryCellCmd(olf, sprintf('GET DATA LOG 0 1000000 1'), ...
                         sprintf('\t '));
%     for i=1:size(lines,1)
%       l = lines(i, :);
%       row = {};
%       while true,
%         [str, l] = strtok(l);
%         str = regexprep(str, '(^\s*)|(\s*$)', ''); % strip leading/tailing whitespace
%         num = str2num(str);
%         if (~isempty(num)), str = num; end;
%         if (isempty(str)), break; end;
%         row = { row{:}, str };
%       end;
%       out = vertcat(out,row);
%     end;
