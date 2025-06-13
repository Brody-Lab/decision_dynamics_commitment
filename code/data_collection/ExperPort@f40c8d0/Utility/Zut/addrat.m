% <~> function: addrat.m
%     adds a rat to the Brody Lab rat table
%
%     Optional arguments must come in argument name--argument value pairs.
%       The first argument in each pair should be the field name (column
%       name), and the second should be the value to assign to that field.
%
%     Example calls:
%
%       addrat();                                               adds an unnamed rat with default vals
%
%       addrat('ratname','C029','experimenter','Carlos');       adds a rat named C029 w/ experimenter set to Carlos
%
%       addrath('deliverydate','2008-01-27','experimenter','Tedd','lastProtocol','Classical','comments','Using this rat for recordings','waterperday',30,'ephys',1,','recovering',1,'alert',1);
%
function answer = addrat(varargin)

%     Constants
nameRatTable      = getZutConstant('nameRatTable');

%     We need an even number of arguments. (0 is fine.)
if mod(nargin,2),
    error('Arguments are optional but must be in argumentname-argumentvalue pairs, e.g. "addrat(''ratname'',''unnamed'',''ephys'',1)".');
end;

if nargin==0,
    %     GUI query
    nl = sprintf('\n');
    properties{1} = 'ratname';
    prompts{1} = ['Please enter the rat''s properties.' nl nl 'ratname:'];
    
    properties{2} = 'experimenter';
    prompts{2} = [nl 'experimenter:'];
    
    properties{3} = 'comments';
    prompts{3} = [nl 'comments:'];
    
    properties{4} = 'free';
    prompts{4} = [nl 'free: Is the rat FREE for any experimenter''s use? (0 or 1)'];
    
    properties{5} = 'lastProtocol';
    prompts{5} = [nl 'lastProtocol: Last protocol the rat ran:'];

    properties{6} = 'alert';
    prompts{6} = [nl 'alert: Does the rat require special attention? (e.g. sick)'];

    properties{7} = '';
    prompts{7} = [nl ':'];
    
    properties{8} = '';
    prompts{8} = [nl ':'];
    
    properties{9} = '';
    prompts{9} = [nl ':'];

    properties{10} = '';
    prompts{10} = [nl ':'];

    answer = inputdlg(prompts,'Rat Entry',1,{'unnamed','','',''});
    display(answer);
    
    
    return;
end;




command_part1 = ['insert into ' nameRatTable ' ('];
command_part2 = ') VALUES(';
command_part3 = ')';

for i = 1:nargin,
    if mod(i,2), %     if this arg is an odd-numbered arg (1st, 3rd, ...)
        if ~ischar(varargin{i}), error('Arguments are optional but must be in argumentname-argumentvalue pairs of the form argumentname,argumentvalue, e.g. "addrat(''n'', 2, ''ratname'', ''unnamed'',''experimenter'',''john'')".'); end;
        if i~=1, command_part1 = [command_part1 ',']; end; %#ok<AGROW> %     add a comma if this isn't the first column name
        command_part1 = [command_part1 varargin{i}];         %#ok<AGROW>
    else
        if i~=2, command_part2 = [command_part2 ',']; end; %#ok<AGROW> %     add a comma if this isn't the first value
        if ~ischar(varargin{i}), varargin{i} = num2str(varargin{i}); %     if not a string, assume it's numeric
        else varargin{i} = ['"' varargin{i} '"']; end; %     if it is a string, we add "" for mym/mysql
        command_part2 = [command_part2 varargin{i}]; %#ok<AGROW>
    end;
end;

command_full = [command_part1 command_part2 command_part3];

bdata(command_full);









%     Discarded code fragments:


% pairs = { ...
% %    'n'             1; ... %     number of rats to add; information for all rats is identical
%     'unnamed'       []; ...
%     'free'          []; ...
%     'alert'         []; ...
%     'training'      []; ...
%     'recovering'    []; ...
%     'ephys'         []; ...
%     'deliverydate'  []; ...
%     'massArrival'   []; ...
%     'lastProtocol'  []; ...
%     'comments'      []; ...
%     'vendor'        []; ...
%     'waterperday'   []; ...
%     'experimenter'  []; ...
%     'ratname'       []; ...
%     }; parseargs(varargin, pairs);

% for i=1:n,
%     bdata('insert into rats (experimenter,ratname) VALUES("{S}","{S}")',experimenter,ratname);
% end;

% for i = {unnamed free alert training recovering ephys deliverydate massArrival lastProtocol comments vendor waterperday},
%     if i ~= [],
%         if ischar(i), i=['"' i '"']; end;
%         if 
%             command_part1 = [command_part1 '"'
% 
% end
