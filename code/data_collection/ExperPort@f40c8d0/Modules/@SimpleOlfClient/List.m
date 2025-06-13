% function [cell_array_out] = List(olf)
%
% List all components of the olfactometer
%
%
% function [cell_array_out] = List(olf, objtype)
%
% List all components of the olfactometer that match a certain
% object type.  Known object types are:
%   'saveables'  for all objects that support the save method
%   'readables'  for all objects that support the read method
%   'writeables' for all objects that support the write method
%   'startstop'  for all objects that support the start/stop methods
%   'log'        for all objects that support the log method
%   'cont'       for all objects that take control parameter set/get
%                methods
function [out] = List(varargin)
    if (nargin < 1), error('Please pass in a SimpleOlfClient object'); end;
    if (nargin > 2), 
      error('Only two arguments are accepted to this function'); 
    end;
    olf = varargin{1};
    type = '';    
    if (nargin > 1), type = varargin{2}; end;
    out = DoQueryCellCmd(olf, sprintf('LIST %s', type), sprintf('\t'));
%     out = {};
%     for i=1:size(lines,1)
%       l = lines(i, :);
%       row = {};
%       while true,
%         [str, l] = strtok(l, sprintf('\t'));
        
%         str = regexprep(str, '(^\s*)|(\s*$)', ''); % strip
%                                                    % leading/tailing
%                                                    % whitespace
%         if (regexp(str, '^[+-]?[0-9]+([.][0-9]*)?$')),
%           str = str2num(str); % make numeric if it's a numeric string
%         end;
%         if (isempty(str)), break; end;
%         row = { row{:}, str };
%       end;
%       out = vertcat(out,row);
%     end;
    