function obj = Analyzer(varargin)

% Analyzer class: Constructor
% SSP, 092005
% SSP, 092605   Being modified to suit newer protocol


% SSP TO DO:
% 1. Create the UIMenu that has all registered variables
% 2. As and when protocol registers a new tool, add a new menu child


%Default object
obj = struct('empty', []);
obj = class(obj, mfilename);
if nargin==1 && strcmp(varargin{1}, 'empty'), return; end;

SoloParamHandle(obj, 'tool_list', 'value', {});   % Tool list (t-by-2 name)

switch nargin
    case 1
        if (isa(varargin{1}, 'Analyzer'))
            ana = varargin{1};
        else
            error('Object passed is not member of the Analyzer class');
        end;
    otherwise
        2;
        %error('Invalid number of arguments');
end;

% initialise mother menu
%fig = findobj('Tag', me);
h = uimenu(gcf, 'Tag', 'sherlock', 'Label', 'Analyzer', 'Accelerator', 'A');


SoloFunction('register_tool', 'rw_args', 'tool_list');
SoloFunction('use_tool', 'ro_args', 'tool_list');
%register_tool(obj, 'analyze_hit_history');

%register_tool(obj, 'analyze_cp_history');

% 
% % Member variables
% pairs = {
%     'var_list', cell(0,0)   ; ... % variables to initialise in wspace
%     'use_tool', ''          ; ... % tool to open in new window
%     };
% parse_knownargs(varargin, pairs);
% 
% % Begin definition of various analysis tools
% if strcmpi(use_tool, 'analyze_hit_history')
%     % Hit_history: View the % successful trials
%     pairs = {
%         'MaxTrials', 10000          ; ...
%         'Trials', zeros(1,10000)    ; ...
%         'RewardHistory', []         ; ...
%         }
% elseif strcmpi(use_tool, 'analyze_cp_history')
%     % Poke history
%     pairs = {
%         'PreSoundMeanTime', 0   ; ...
%         'SoundDur', 0   ; ...
%         'Delay',  0;   ...
%         'Del2Cd_Mean', 0    ; ...
%         'nCenterPokes', 0 ; ...
%         'CenterPokeTimes', [] ;...
%         'CenterPokeDurations', []; ...
%         'CenterPokeStateHist', []; ...
%         'LastCpokeMins', 0 ; ...
%         'BaseState', 0 ;  ...
%         };
% end;
% 
% parse_knownargs(var_list, pairs);
% for s = 1:size(pairs,1)
%     SoloParamHandle(pairs{s,1}, 'value', eval(pairs{s,1}));
% end;
% 
% SoloFunction(use_tool, 'ro_args', pairs(:,1) );
% 
% feval(use_tool, ana);
