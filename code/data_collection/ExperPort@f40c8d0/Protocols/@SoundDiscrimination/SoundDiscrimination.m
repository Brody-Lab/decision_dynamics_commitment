

function [obj] = SoundDiscrimination(varargin)

obj = class(struct, mfilename, saveload, water, antibias, pokesplot, ...
  soundmanager, soundui ,sessionmodel, distribui, punishui, warnDanger, ...
  comments, softpokestay2, sqlsummary);

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
if ~ischar(action), error('The action parameter must be a string'); end;

GetSoloFunctionArgs(obj);

%---------------------------------------------------------------
%   END OF SECTION COMMON TO ALL PROTOCOLS, MODIFY AFTER THIS LINE
%---------------------------------------------------------------


% ---- From here on is where you can put the code you like.
%
% Your protocol will be called, at the appropriate times, with the
% following possible actions:
%
%   'init'     To initialize -- make figure windows, variables, etc.
%
%   'update'   Called periodically within a trial
%
%   'prepare_next_trial'  Called when a trial has ended and your protocol
%              is expected to produce the StateMachine diagram for the next
%              trial; i.e., somewhere in your protocol's response to this
%              call, it should call "dispatcher('send_assembler', sma,
%              prepare_next_trial_set);" where sma is the
%              StateMachineAssembler object that you have prepared and
%              prepare_next_trial_set is either a single string or a cell
%              with elements that are all strings. These strings should
%              correspond to names of states in sma.
%                 Note that after the 'prepare_next_trial' call, further
%              events may still occur in the RTLSM while your protocol is thinking,
%              before the new StateMachine diagram gets sent. These events
%              will be available to you when 'trial_completed' is called on your
%              protocol (see below).
%
%   'trial_completed'   Called when 'state_0' is reached in the RTLSM,
%              marking final completion of a trial (and the start of 
%              the next).
%
%   'close'    Called when the protocol is to be closed.
%
%
% VARIABLES THAT DISPATCHER WILL ALWAYS INSTANTIATE FOR YOU IN YOUR 
% PROTOCOL:
%
% (These variables will be instantiated as regular Matlab variables, 
% not SoloParamHandles. For any method in your protocol (i.e., an m-file
% within the @your_protocol directory) that takes "obj" as its first argument,
% calling "GetSoloFunctionArgs(obj)" will instantiate all the variables below.)
%
%
% n_done_trials     How many trials have been finished; when a trial reaches
%                   one of the prepare_next_trial states for the first
%                   time, this variable is incremented by 1.
%
% n_started trials  How many trials have been started. This variable gets
%                   incremented by 1 every time the state machine goes
%                   through state 0.
%
% parsed_events     The result of running disassemble.m, with the
%                   parsed_structure flag set to 1, on all events from the
%                   start of the current trial to now.
%
% latest_events     The result of running disassemble.m, with the
%                   parsed_structure flag set to 1, on all new events from
%                   the last time 'update' was called to now.
%
% raw_events        All the events obtained in the current trial, not parsed
%                   or disassembled, but raw as gotten from the State
%                   Machine object.
%
% current_assembler The StateMachineAssembler object that was used to
%                   generate the State Machine diagram in effect in the
%                   current trial.
%
% Trial-by-trial history of parsed_events, raw_events, and
% current_assembler, are automatically stored for you in your protocol by
% dispatcher.m. See the wiki documentation for information on how to access
% those histories from within your protocol and for information.
%
% 


switch action,

  %---------------------------------------------------------------
  %          CASE INIT
  %---------------------------------------------------------------
%% INIT 
  case 'init'
    
    hackvar = 10; SoloFunctionAddVars('SessionModel', 'ro_args', 'hackvar'); %#ok<NASGU>
    
    SoloParamHandle(obj, 'myfig', 'saveable', 0); myfig.value = figure;

    % Make the title of the figure be the protocol name, and if someone tries
    % to close this figure, call dispatcher's close_protocol function, so it'll know
    % to take it off the list of open protocols.
    name = mfilename;
    set(value(myfig), 'Name', name, 'Tag', name, ...
      'closerequestfcn', 'dispatcher(''close_protocol'')', 'MenuBar', 'none');

    % At this point we have one SoloParamHandle, myfig
    % Let's put the figure where we want it and give it a reasonable size:
    set(value(myfig), 'Position', [485   144   850   900]);

    % ----------
    
    SoloParamHandle(obj, 'hit_history',   'value', []);
    SoloParamHandle(obj, 'sides_history', 'value', '');
    %SoloParamHandle(obj, 'psych_history', 'value', []);
    %SoloParamHandle(obj, 'ckhit_history', 'value', []);
    DeclareGlobals(obj, 'ro_args', {'hit_history', 'sides_history'});
    SoloFunctionAddVars('RewardsSection', 'rw_args', 'hit_history');
    SoloFunctionAddVars('SidesSection',   'rw_args', 'sides_history');

    % We use the following to generate a call that will occur after
    % any loading of data. We can use that to do any updates we may want.
    SoloParamHandle(obj, 'after_load_callbacks', 'value', []);
    set_callback(after_load_callbacks, {mfilename, 'after_load_callbacks'});
    set_callback_on_load(after_load_callbacks, 1);

    
    SoundManagerSection(obj, 'init');
    
    x = 5; y = 5;             % Initial position on main GUI window

    [x, y] = SavingSection(obj,       'init', x, y); 
    [x, y] = WaterValvesSection(obj,  'init', x, y);
    
    
    [x, y] = PokesPlotSection(obj,    'init', x, y, ...
      struct('states',  SMASection(obj, 'get_state_colors')));
    next_row(y);
    
    [x, y] = CommentsSection(obj, 'init', x, y);

    SessionDefinition(obj,   'init', x, y, value(myfig)); next_row(y, 2); %#ok<NASGU>
    next_row(y, 1.5);
        
    
    figpos = get(gcf, 'Position');
    [expmtr, rname]=SavingSection(obj, 'get_info');
    HeaderParam(obj, 'prot_title', [mfilename ': ' expmtr ', ' rname], ...
      x, y, 'position', [10 figpos(4)-25, 800 20]);


    next_column(x); y=5;
    MenuParam(obj, 'n_center_pokes', {'1', '2'}, 1, x, y); next_row(y, 1.5);
    SoloFunctionAddVars('SMASection', 'ro_args', 'n_center_pokes');
    
    [x, y] = DistribInterface(obj, 'add', 'var_gap1', x, y);
    next_row(y, 0.5);

    [x, y] = SoundInterface(obj, 'add', 'left_stimulus', x, y);
    next_row(y, 0.5);

    [x, y] = SoundInterface(obj, 'add', 'right_stimulus', x, y);
    next_row(y, 0.5);
    
    [x, y] = DistribInterface(obj, 'add', 'var_gap2', x, y);
    next_row(y, 0.5);
    
    ToggleParam(obj, 'Lock_Gap_Sound', 0, x,y, 'OnString','Lock_gap_sound',...
        'OffString','Unlock_gap_sound');
    
    
    next_column(x); y = 5;
    
    ToggleParam(obj, 'Temperror', 0, x, y, 'TooltipString', ...
      sprintf(['\nIf ON, incorrect poke causes temperror sound then back to' ...
      '\nwait_for_spoke. If OFF, incorrect poke causes error_state then new trial']), ...
      'OnString', 'Temperror ON', 'OffString', 'Temperror OFF'); next_row(y);
    set_callback(Temperror, {mfilename, 'Temperror'});
    SoloFunctionAddVars('SMASection', 'ro_args', 'Temperror');
    next_row(y, 0.5);
    
    [x, y] = SoundInterface(obj, 'add', 'TemperrorSound', x, y); 
    next_row(y, 0.5);
    
    [x, y] = SoftPokeStayInterface2(obj, 'add', 'soft_drink_time', x, y);
    SoftPokeStayInterface2(obj, 'set', 'soft_drink_time', 'Duration', 20, 'Grace', 2.5);
    next_row(y, 0.5);
    
    NumeditParam(obj, 'SoundRewardOverlap', 2, x, y, ...
      'TooltipString', sprintf(['\nAfter this many seconds, the stimulus sound will be' ...
      '\nturned off (if it wasn''t off already by then)']));
    SoloFunctionAddVars('SMASection', 'ro_args', 'SoundRewardOverlap');
    next_row(y, 1.5);
    
    
    [x, y] = WarnDangerInterface(obj, 'add', 'warndanger', x, y);
    WarnDangerInterface(obj, 'set', 'warndanger', 'WarnDur',   6);
    WarnDangerInterface(obj, 'set', 'warndanger', 'DangerDur', 0);
    next_row(y, 0.5);
    
    [x, y] = PunishInterface(obj, 'add', 'error_state', x, y);
    PunishInterface(obj, 'set', 'error_state', 'SoundsPanel', 0);
    next_row(y, 0.5);
    
    NumeditParam(obj, 'Psych10_Count',     0, x, y, 'labelfraction', 0.6); next_row(y);
    NumeditParam(obj, 'Total_Trial_Count', 0, x, y, 'labelfraction', 0.6); next_row(y,2);
    [x, y] = PhantomSection(obj, 'init', x, y);

    next_column(x); y = 5;
    [x, y] = AntibiasSection(obj, 'init', x, y);
    next_row(y, 0.5);
    
    [x, y] = SidesSection(obj, 'init', x, y);
    next_row(y);
    
    [x, y] = PsychSection(obj, 'init', x, y);
    next_row(y);
    
    RewardsSection(obj,'init',x,y);
    
    feval(mfilename, obj, 'Temperror');    
    feval(mfilename, obj, 'prepare_next_trial');
    

%% Temperror    
  %---------------------------------------------------------------
  %          CASE Temperror
  %---------------------------------------------------------------

  case 'Temperror', 
    if Temperror==0, SoundInterface(obj, 'disable_all', 'TemperrorSound');
    else             SoundInterface(obj, 'enable_all',  'TemperrorSound');
    end;
    
  case 'get_state_colors',
    obj=SMASection(obj, 'get_state_colors');
    
    
%% prepare_next_trial    
  %---------------------------------------------------------------
  %          CASE PREPARE_NEXT_TRIAL
  %---------------------------------------------------------------
  case 'prepare_next_trial'
    % feval(mfilename, 'update');
    
    PsychSection(obj, 'update_psych_values');
    SessionDefinition(obj, 'next_trial');
    RewardsSection( obj, 'prepare_next_trial');
    PsychSection(obj, 'update_psych_values');
    
    tt = PsychSection(obj, 'get_trialtype');
    hh = value(hit_history);
    
    if n_done_trials >= 1 && tt == 10 && hh(end) == 1
        Psych10_Count.value = value(Psych10_Count) + 1; %#ok<NODEF>
    end
    if n_done_trials >= 1
        Total_Trial_Count.value = value(Total_Trial_Count) + 1;
    end
    
    AntibiasSection(obj, 'update', SidesSection(obj, 'get_left_prob'), hit_history, sides_history);
    SidesSection(   obj, 'prepare_next_trial');
    PsychSection(   obj, 'prepare_next_trial');
    
    SoundManagerSection(obj, 'send_not_yet_uploaded_sounds');
    
    DistribInterface(obj, 'get_new_sample', 'var_gap1');
    DistribInterface(obj, 'get_new_sample', 'var_gap2');
    
    if value(Lock_Gap_Sound) == 1
        s = SidesSection(obj,'get_current_side');
        if strcmp(s,'l')
            DistribInterface(obj,'set','var_gap2','Max',SoundInterface(obj,'get','left_stimulus','Dur1'));
            DistribInterface(obj,'set','var_gap2','Min',SoundInterface(obj,'get','left_stimulus','Dur1')); 
            DistribInterface(obj,'set','var_gap2','Max',SoundInterface(obj,'get','left_stimulus','Dur1'));
            DistribInterface(obj, 'get_new_sample', 'var_gap2');
        else
            DistribInterface(obj,'set','var_gap2','Max',SoundInterface(obj,'get','right_stimulus','Dur1'));
            DistribInterface(obj,'set','var_gap2','Min',SoundInterface(obj,'get','right_stimulus','Dur1'));
            DistribInterface(obj,'set','var_gap2','Max',SoundInterface(obj,'get','right_stimulus','Dur1'));
            DistribInterface(obj, 'get_new_sample', 'var_gap2');
        end
    end
    
    [sma, prepare_next_trial_states] = SMASection(obj, 'prepare_next_trial');
    
    dispatcher('send_assembler', sma, prepare_next_trial_states);

    SidesSection(obj, 'update_plot');
    
    % Default behavior of following call is that every 20 trials, the data
    % gets saved, not interactive, no commit to CVS. 
    SavingSection(obj, 'autosave_data');
    
    CommentsSection(obj, 'clear_history'); % Make sure we're not storing unnecessary history
    if n_done_trials==1,  % Auto-append date for convenience.
      CommentsSection(obj, 'append_date'); CommentsSection(obj, 'append_line', '');
    end;

    if n_done_trials==1
      [expmtr, rname]=SavingSection(obj, 'get_info');
      prot_title.value=[mfilename ' on rig ' get_hostname ' : ' expmtr ', ' rname  '.  Started at ' datestr(now, 'HH:MM')];
    end

    
%% trial_completed    
  %---------------------------------------------------------------
  %          CASE TRIAL_COMPLETED
  %---------------------------------------------------------------
  case 'trial_completed'
    % Do any updates in the protocol that need doing:
    feval(mfilename, 'update');
    % And PokesPlot needs completing the trial:
    PokesPlotSection(obj, 'trial_completed');
  
%% update    
  %---------------------------------------------------------------
  %          CASE UPDATE
  %---------------------------------------------------------------
  case 'update'
    PokesPlotSection(obj, 'update');
    

%% end_session    
  %---------------------------------------------------------------
  %          CASE END_SESSION
  %---------------------------------------------------------------
  case 'end_session'
     prot_title.value = [value(prot_title) ', Ended at ' datestr(now, 'HH:MM')]; %#ok<NODEF>
     getSessID(obj);
    
%% pre_saving_settings
  %---------------------------------------------------------------
  %          CASE PRE_SAVING_SETTINGS
  %---------------------------------------------------------------
  case 'pre_saving_settings'
% 	  	pd.context=value(previous_cntxt);
% 		pd.blocks=value(block_history);
 		pd.sides=value(sides_history);
		leftHz=get_sphandle('name','left_stimulusFreq1');
		rightHz=get_sphandle('name','right_stimulusFreq1');
		leftDur=get_sphandle('name','left_stimulusDur1');
		rightDur=get_sphandle('name','right_stimulusDur1');
		
		pd.leftHz=cell2mat(get_history(leftHz{1}));
		pd.leftDur=cell2mat(get_history(leftDur{1}));
		pd.rightHz=cell2mat(get_history(rightHz{1}));
		pd.rightDur=cell2mat(get_history(rightDur{1}));
		fds=fieldnames(pd);
		for fi=1:numel(fds)
			pd.(fds{fi})=pd.(fds{fi})(1:n_done_trials);
		end
% 		pd.gotit=value(gotit_history);
 		pd.hit=value(hit_history);
% 		pd.nPokes=[NLeftPokes+0 NCenterPokes+0 NRightPokes+0];
%         pd.comment=CommentsSection(obj,'get_latest');
% 		pd.RT=value(RT);
%		lets={'l' 'c' 'r'};
%		sides=cell2mat(lets(previous_sides+2));
		% This is the general summary for x-protocol comparison
        
		sendsummary(obj,'sides',sides_history(1:n_done_trials),'protocol_data',pd)
        sendtrial(obj)
        SessionDefinition(obj, 'run_eod_logic_without_saving'); %     added on March.31.2008 because EOD doesn't seem to be running on Chuck's protocol... anymore
        
    
%% after_load_callbacks
  %---------------------------------------------------------------
  %          CASE AFTER_LOAD_CALLBACKS
  %---------------------------------------------------------------
  case 'after_load_callbacks'
    AntibiasSection(obj, 'update', SidesSection(obj, 'get_left_prob'), hit_history, sides_history);
    PsychSection(obj, 'update_psych_values');

    

%% close    
  %---------------------------------------------------------------
  %          CASE CLOSE
  %---------------------------------------------------------------
  case 'close'
    PokesPlotSection(obj, 'close');

    if exist('myfig', 'var') && isa(myfig, 'SoloParamHandle') && ishandle(value(myfig)), %#ok<NODEF>
      delete(value(myfig));
    end;
    delete_sphandle('owner', ['^@' class(obj) '$']);

  otherwise,
    warning('Unknown action! "%s"\n', action); %#ok<WNTAG>
end;

return;

