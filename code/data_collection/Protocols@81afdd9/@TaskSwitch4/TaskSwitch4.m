% TaskSwitch4 protocol
% Marino Pagan, October 2015

function [obj] = TaskSwitch4(varargin)

% Default object is of our own class (mfilename);
% we inherit only from Plugins

obj = class(struct, mfilename, saveload, water, ...
    pokesplot2, soundmanager, soundui, ...
    distribui, comments, sqlsummary);

%---------------------------------------------------------------
%   BEGIN SECTION COMMON TO ALL PROTOCOLS, DO NOT MODIFY
%---------------------------------------------------------------

% If creating an empty object, return without further ado:
if nargin==0 || (nargin==1 && ischar(varargin{1}) && strcmp(varargin{1}, 'empty')),
    return;
end;

if isa(varargin{1}, mfilename), % If first arg is an object of this class itself, we are
    % Most likely responding to a callback from
    % a SoloParamHandle defined in this mfile.
    if length(varargin) < 2 || ~ischar(varargin{2}),
        error(['If called with a "%s" object as first arg, a second arg, a ' ...
            'string specifying the action, is required\n']);
    else action = varargin{2}; varargin = varargin(3:end); %#ok<NASGU>
    end;
else % Ok, regular call with first param being the action string.
    action = varargin{1}; varargin = varargin(2:end); %#ok<NASGU>
end;

GetSoloFunctionArgs(obj);

switch action,

    case 'init'

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%% INIT %%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        getSessID(obj);
        dispatcher('set_trialnum_indicator_flag');
        %   Make default figure
        SoloParamHandle(obj, 'myfig', 'saveable', 0); myfig.value = double(figure);
        %   Make the title of the figure be the protocol name
        name = mfilename;set(value(myfig), 'Name', name, 'Tag', name, ...
            'closerequestfcn', 'dispatcher(''close_protocol'')', 'MenuBar', 'none');
        % Hack Variable
        hackvar = 10; SoloFunctionAddVars('SessionModel', 'ro_args', 'hackvar'); %#ok<NASGU>
        %   Put the figure where we want it and resize (x,y,width,height)
        set(value(myfig), 'Position', [400 100 850 570]);       
        % From Plugins/@soundmanager:
        SoundManagerSection(obj, 'init');


        %   ----------------------
        %   Set up the main GUI window
        %   ----------------------
        x = 5; y = 5;   % Initial position on main GUI window

        
        %   From Plugins/@saveload:
        [x, y] = SavingSection(obj, 'init', x, y);

        next_row(y,-0.4);
        
        %   Comments
        [x, y] = CommentsSection(obj, 'init', x, y);
        
        %   From Plugins/@water:
        [x, y] = WaterValvesSection(obj, 'init', x, y, 'streak_gui', 1);
                
        next_row(y,-0.4);                
        
        %   PokesPlot
        SC = state_colors(obj);
        [x, y] = PokesPlotSection(obj,'init',x,y,struct('states',SC));
        PokesPlotSection(obj, 'set_alignon', 'cpoke(1,1)');
        PokesPlotSection(obj, 'hide'); 
        next_row(y);
        
        
        %   History
        [x, y] = HistorySection(obj, 'init', x, y);
        
        
        %   Training
        [x, y] = TrainingSection(obj, 'init', x, y);

        
        %%%%%%%%%%%%%%%%%%%%% NEXT COLUMN %%%%%%%%%%%%%%%%%%%%%
        y=5; next_column(x); 

        
        %   Stimulus
        [x, y] = StimulusSection(obj, 'init', x, y);

        
        
        figpos = get(gcf, 'Position');
        [expmtr, rname]=SavingSection(obj, 'get_info');
        HeaderParam(obj, 'prot_title', ['TaskSwitch4: ' expmtr ', ' rname], ...
        x, y, 'position', [10 figpos(4)-20, 807 20]);

    
        %   OK, start preparing the first trial
        TaskSwitch4(obj, 'prepare_next_trial');


        
        
    case 'prepare_next_trial'
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%% PREPARE NEXT TRIAL %%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        %%% update history
        HistorySection(obj, 'next_trial');
        
        %%% update training stage
        TrainingSection(obj, 'next_trial');
        
        %%% set up stimulus for next trial
        StimulusSection(obj, 'next_trial');
        
        
        SoundManagerSection(obj, 'send_not_yet_uploaded_sounds');
        
        % invoke autosave
        SavingSection(obj, 'autosave_data');
        if n_done_trials==1
            [expmtr, rname]=SavingSection(obj, 'get_info');
            prot_title.value=['TaskSwitch4 - on rig ' get_hostname ' : ' expmtr ', ' rname  '.  Started at ' datestr(now, 'HH:MM')];
            
            
            
        end
        
        %%% prepare the actual state matrix
        SMA1(obj,'next_trial');

        
        %%% this line updates the "training room" webpage on Zut
        try send_n_done_trials(obj); end

        
        
    case 'trial_completed'
        feval(mfilename, 'update');
        
        StimulusSection(obj, 'update_plot');

        % And PokesPlot needs completing the trial:
        PokesPlotSection(obj, 'trial_completed');

        if n_done_trials==1,
            CommentsSection(obj, 'append_date');
            CommentsSection(obj, 'append_line', '');
        end;
        CommentsSection(obj, 'clear_history'); % Make sure we're not storing unnecessary history


        
    case 'update'
        PokesPlotSection(obj, 'update');


        
    case 'close'
        PokesPlotSection(obj, 'close');
        CommentsSection(obj, 'close');

        if exist('myfig', 'var') && isa(myfig, 'SoloParamHandle') && ishandle(value(myfig)),
            delete(value(myfig));
        end;

        if exist('myfig2', 'var') && isa(myfig2, 'SoloParamHandle') && ishandle(value(myfig2)),
            delete(value(myfig2));
        end;

        if exist('myfig3', 'var') && isa(myfig3, 'SoloParamHandle') && ishandle(value(myfig3)),
            delete(value(myfig3));
        end;

        try
            delete_sphandle('owner', ['^@' class(obj) '$']);
        catch
            warning('Some SoloParams were not properly cleaned up');
        end

        
    case 'end_session'
        HistorySection(obj, 'end_session');
        TrainingSection(obj, 'end_session');
        prot_title.value = [value(prot_title) ', Ended at ' datestr(now, 'HH:MM')];

        
    case 'pre_saving_settings'
        HistorySection(obj, 'make_and_send_summary');


    case 'get'
        val=varargin{1};
        
        eval(['x=value(' val ');']);
        
       
    otherwise,
        warning('Unknown action! "%s"\n', action);
end;

return;

