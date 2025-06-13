

function [obj] = ProAnti3Marino(varargin)

obj = class(struct, mfilename, saveload, water, wateradaptor, antibias, pokesplot2, ...
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
    disp('Setting rand seed to sum(1e3*clock)');  
    rand('twister',sum(1e3*clock));
    
    dispatcher('set_trialnum_indicator_flag');  
    
    hackvar = 10; SoloFunctionAddVars('SessionModel', 'ro_args', 'hackvar'); %#ok<NASGU>
    
    SoloParamHandle(obj, 'myfig', 'saveable', 0); myfig.value = double(figure);

    % Make the title of the figure be the protocol name, and if someone tries
    % to close this figure, call dispatcher's close_protocol function, so it'll know
    % to take it off the list of open protocols.
    name = mfilename;
    set(value(myfig), 'Name', name, 'Tag', name, ...
      'closerequestfcn', 'dispatcher(''close_protocol'')', 'MenuBar', 'none');

    % At this point we have one SoloParamHandle, myfig
    % Let's put the figure where we want it and give it a reasonable size:
    set(value(myfig), 'Position', [303 60 850 900]);

    % ----------
    
    SoloParamHandle(obj, 'hit_history',   'value', []);
    SoloParamHandle(obj, 'sides_history', 'value', '');
    SoloParamHandle(obj, 'psych_history', 'value', []);
    SoloParamHandle(obj, 'loc_history',   'value', '');
    SoloParamHandle(obj, 'mem_history',   'value', []);
    SoloParamHandle(obj, 'free_history',  'value', []);
    SoloParamHandle(obj, 'cpoketry',      'value', []);
    DeclareGlobals(obj, 'ro_args', {'hit_history', 'sides_history', 'psych_history', 'loc_history', 'cpoketry'});
    

    % We use the following to generate a call that will occur after
    % any loading of data. We can use that to do any updates we may want.
    SoloParamHandle(obj, 'after_load_callbacks', 'value', []);
    set_callback(after_load_callbacks, {mfilename, 'after_load_callbacks'});
    set_callback_on_load(after_load_callbacks, 1);

    
    SoundManagerSection(obj, 'init');
    
    x = 5; y = 5;             % Initial position on main GUI window

    [x, y] = SavingSection(obj,       'init', x, y); 
    [x, y] = WaterValvesSection(obj,  'init', x, y, 'show_calib_info',1);
    
    [x, y] = WaterAdaptorSection(obj, 'init', x, y);
    next_row(y);

    [x, y] = PokesPlotSection(obj,    'init', x, y, ...
      struct('states',  state_colors(obj)));
    next_row(y);
    
    [x, y] = CommentsSection(obj, 'init', x, y);

    SessionDefinition(obj,   'init', x, y, value(myfig)); next_row(y, 2); 
    next_row(y, 1.5);
    
    NumeditParam(obj, 'Total_Good_Count',  0, x, y,  'labelfraction', 0.6); next_row(y);
    NumeditParam(obj, 'Total_Trial_Count', 0, x, y,  'labelfraction', 0.6); next_row(y);
    NumeditParam(obj, 'Pro_L_Cnt',   0, x, y, 'position',[x     y  100 20], 'labelfraction', 0.6);   
    NumeditParam(obj, 'Pro_L_Perf',  0, x, y, 'position',[x+100 y  100 20], 'labelfraction', 0.6); next_row(y);   
    NumeditParam(obj, 'Anti_L_Cnt',  0, x, y, 'position',[x     y  100 20], 'labelfraction', 0.6); 
    NumeditParam(obj, 'Anti_L_Perf', 0, x, y, 'position',[x+100 y  100 20], 'labelfraction', 0.6); next_row(y);
    NumeditParam(obj, 'Pro_R_Cnt',   0, x, y, 'position',[x     y  100 20], 'labelfraction', 0.6); 
    NumeditParam(obj, 'Pro_R_Perf',  0, x, y, 'position',[x+100 y  100 20], 'labelfraction', 0.6); next_row(y);
    NumeditParam(obj, 'Anti_R_Cnt',  0, x, y, 'position',[x     y  100 20], 'labelfraction', 0.6); 
    NumeditParam(obj, 'Anti_R_Perf', 0, x, y, 'position',[x+100 y  100 20], 'labelfraction', 0.6); next_row(y,1.3);
    
    NumeditParam(obj, 'Average_Cpoke_Trys',   0, x, y, 'labelfraction', 0.6); next_row(y);
    NumeditParam(obj, 'Percent_Single_Cpoke', 0, x, y, 'labelfraction', 0.6); next_row(y,1.3);

    
    figpos = get(gcf, 'Position');
    [expmtr, rname]=SavingSection(obj, 'get_info');
    HeaderParam(obj, 'prot_title', [mfilename ': ' expmtr ', ' rname], ...
      x, y, 'position', [10 figpos(4)-25, 800 20]);

  
    SoloParamHandle(obj, 'SoundPanel', 'value', figure('Position', [ 50 50 210 575], ...
        'closerequestfcn', [mfilename '(' class(obj) ', ''hide'');'], 'MenuBar', 'none', ...
        'Name', mfilename), 'saveable', 0);
    set(gcf, 'Visible', 'off');
        
    nx=10; ny=10;
    [nx, ny] = SoundInterface(obj, 'add', 'Reinit',         nx, ny);
    [nx, ny] = SoundInterface(obj, 'add', 'TemperrorSound', nx, ny);    
    [nx, ny] = SoundInterface(obj, 'add', 'ProSound',       nx, ny);
    [nx, ny] = SoundInterface(obj, 'add', 'AntiSound',      nx, ny); 
        
    figure(value(myfig));
    
    next_column(x); y=5; pause(0.1);
    
    MenuParam(  obj, 'n_center_pokes', {'0', '1'}, 1, x, y);                                                                                    next_row(y);
    ToggleParam(obj, 'CenterCue',    0,x,y,                            'OnString','CueCenter_ON',       'OffString','CueCenter_Off');           next_row(y);
    ToggleParam(obj, 'CenterSustain',0,x,y,'position',[x     y 100 20],'OnString','Cue_Sustain',        'OffString','Cue_PreOnly');
    ToggleParam(obj, 'CueInOut',     0,x,y,'position',[x+100 y 100 20],'OnString','Cue_InOut',          'OffString','Cue_Constant');            next_row(y);
    ToggleParam(obj, 'TypeCenterCue',0,x,y,                            'OnString','CenterOn_SideOff',   'OffString','CenterOff_SideOn');        next_row(y);
    ToggleParam(obj, 'LockContextNIC',0,x,y,                           'OnString','Lock_Context_to_NIC','OffString','Context_NIC_Independent'); next_row(y,1.3);
    
    ToggleParam(obj,'KeepNoseCenter',  0,x,y,'position',[x     y  60 20],'OnString','NIC_ON',      'OffString','NIC_OFF'); 
    ToggleParam(obj,'ExitNICTime',     0,x,y,'position',[x+60  y  80 20],'OnString','Exit_at_Time','OffString','Exit_with_NIC');
    ToggleParam(obj,'AllowLR',         0,x,y,'position',[x+140 y  60 20],'OnString','AllowLR',     'OffString','NO_LR'); next_row(y);
    ToggleParam(obj,'NICViolation',    0,x,y,'OnString','NIC Violation Start New Trial', 'OffString', 'NIC Violation Reinit'); next_row(y);
    
    NumeditParam(obj, 'MinNICDur',     0,x,y,'position',[x     y 100 20],'labelfraction', 0.6);
    NumeditParam(obj, 'MaxNICDur',     0,x,y,'position',[x+100 y 100 20],'labelfraction', 0.6); next_row(y); 
    NumeditParam(obj, 'endNIC',        0,x,y,'position',[x     y 100 20],'labelfraction', 0.6);
    NumeditParam(obj, 'miniLCB',       0,x,y,'position',[x+100 y 100 20],'labelfraction', 0.6); next_row(y); 
    NumeditParam(obj, 'NICDur',        0,x,y,'position',[x     y 100 20],'labelfraction', 0.6);
    NumeditParam(obj, 'LegalCBrk',     0,x,y,'position',[x+100 y 100 20],'labelfraction', 0.6); next_row(y); 
    NumeditParam(obj, 'GoodNICRewMult',1,x,y,                            'labelfraction', 0.5); next_row(y, 1.3);
    
    NumeditParam(obj, 'ContextDur',    1,x,y,                            'labelfraction',0.5); next_row(y); 
    NumeditParam(obj, 'CtoSgap',       0,x,y,'position',[x     y 100 20],'labelfraction',0.5); 
    ToggleParam( obj, 'CtoStype',      0,x,y,'position',[x+100 y 100 20],'OnString','CtoS_on_Cout','OffString','CtoS_on_Tup'); next_row(y);
    
    NumeditParam(obj, 'StimDur',       1,x,y,'position',[x     y 100 20],'labelfraction',0.5); 
    NumeditParam(obj, 'StimAfNIC',   0.2,x,y,'position',[x+100 y 100 20],'labelfraction',0.5); next_row(y);
    
    NumeditParam(obj, 'StimRewardOverlap', 1,x,y,'labelfraction',0.5); next_row(y);
    set_callback(StimDur, {mfilename, 'StimDur'});
    
    NumeditParam(obj, 'StimDelay',   0,x,y,'labelfraction',0.6,                        'position',[x     y 100 20]);
    ToggleParam(obj,  'StimTime',    1,x,y,'OnString','PostStim','OffString','NICStim','position',[x+100 y 100 20]);  next_row(y);
    NumeditParam(obj, 'MinDelay',    0,x,y,'labelfraction',0.6,                        'position',[x     y 100 20]);
    NumeditParam(obj, 'MemoryZap',   0,x,y,'labelfraction',0.6,                        'position',[x+100 y 100 20]); next_row(y,1.3);
    
    ToggleParam(obj, 'Temperror',    0,x,y,'OnString', 'Temperror ON', 'OffString', 'Temperror OFF'); next_row(y, 1.3);
    
    [x, y] = StimulatorSection(obj, 'init', x, y); next_row(y, 1.3);
    
    next_column(x); y = 5; pause(0.1);
    
    ToggleParam(obj,'showsounds',0,x,y,'OnString','Show Sound Panel','OffString','Hide Sound Panel'); next_row(y);
    set_callback(showsounds, {mfilename, 'show_hide'});
    
    [x, y] = SoftPokeStayInterface2(obj, 'add', 'soft_drink_time', x, y);
    SoftPokeStayInterface2(obj, 'set', 'soft_drink_time', 'Duration', 10, 'Grace', 2);
    
    [x, y] = SoundInterface(obj, 'add', 'StimSound', x, y); next_row(y, 0.3);
    [x, y] = PsychSection(  obj, 'init',             x, y); next_row(y, 1);
    [x, y] = MaskSection(obj,    'init',             x, y); next_row(y, 1.3);
      
    next_column(x); y = 5; pause(0.1);
    
    [x, y] = WarnDangerInterface(obj, 'add', 'warndanger', x, y); 
    WarnDangerInterface(obj, 'set', 'warndanger', 'WarnDur',   3);
    WarnDangerInterface(obj, 'set', 'warndanger', 'DangerDur', 0);
    
    [x, y] = PunishInterface(obj, 'add', 'error_state', x, y);    next_row(y, 0.3);
    PunishInterface(obj, 'set', 'error_state', 'SoundsPanel', 0);
    
    [x, y] = AntibiasSection(  obj, 'init', x, y); next_row(y, 1.3);
    [x, y] = SidesSection(     obj, 'init', x, y); next_row(y, 1.3);
    [x, y] = RewardsSection(   obj, 'init', x, y); 
    
    ToggleParam(obj, 'StimOnFree',0,x,y,'OnString', 'Stim On Free', 'OffString', 'Stim on ALL'); next_row(y, 1.3);
    
    SoloFunctionAddVars('StimulatorSection' ,'rw_args',{'LegalCBrk'});
    SoloFunctionAddVars('StimulatorSection' ,'ro_args',{'StimOnFree'});
    SoloFunctionAddVars('SidesSection',   'rw_args',   {'sides_history', 'loc_history', 'mem_history', 'free_history','NICDur','StimAfNIC','StimDur','StimDelay','MinDelay','LegalCBrk'});
    SoloFunctionAddVars('RewardsSection', 'rw_args',   {'hit_history', 'cpoketry','Average_Cpoke_Trys', 'Percent_Single_Cpoke', 'NICViolation'});
    SoloFunctionAddVars('PsychSection', 'rw_args',     {'psych_history'});
    SoloFunctionAddVars('SMASection', 'ro_args', {'ContextDur',...
                                                  'StimDur',...
                                                  'StimAfNIC',...
                                                  'CtoSgap',...
                                                  'CtoStype',...
                                                  'TypeCenterCue',...
                                                  'CenterCue',...
                                                  'CueInOut',...
                                                  'KeepNoseCenter',...
                                                  'ExitNICTime',...
                                                  'AllowLR',...
                                                  'NICViolation',...
                                                  'MinNICDur',...
                                                  'MaxNICDur',...
                                                  'miniLCB',...
                                                  'endNIC',...
                                                  'NICDur',...
                                                  'LegalCBrk',...
                                                  'GoodNICRewMult',...
                                                  'n_center_pokes',...
                                                  'Temperror',...
                                                  'StimRewardOverlap',...
                                                  'CenterSustain',...
                                                  'StimDelay',...
                                                  'StimTime',...
                                                  'MemoryZap'});
      
    feval(mfilename, obj, 'prepare_next_trial');
    
    
%% StimDur    
  %---------------------------------------------------------------
  %          CASE STIMDUR
  %---------------------------------------------------------------

  case 'StimDur',
      if value(StimDur) == Inf
          SoundInterface(obj, 'set', 'StimSound', 'Loop', 1);
      else
          SoundInterface(obj, 'set', 'StimSound', 'Loop', 0);
          SoundInterface(obj, 'set', 'StimSound', 'Dur1',value(StimDur));
      end

%% GetStateColors      
  case 'get_state_colors',
    obj=state_colors(obj);
    
    
%% ShowHide    
  case 'show_hide'
    if value(showsounds) == 1; set(value(SoundPanel),'Visible','On');
    else                       set(value(SoundPanel),'Visible','Off');
    end
    
  case 'hide'
    set(value(SoundPanel),'Visible','Off');
    
    
%% prepare_next_trial    
  %---------------------------------------------------------------
  %          CASE PREPARE_NEXT_TRIAL
  %---------------------------------------------------------------
  case 'prepare_next_trial'
    % feval(mfilename, 'update');
    
    SessionDefinition(obj, 'next_trial');
    RewardsSection( obj, 'prepare_next_trial');

    hh = value(hit_history); %#ok<NODEF>
    sh = value(sides_history); sh = sh(1:length(hh)); %#ok<NODEF>
    lh = value(loc_history);   lh = lh(1:length(hh)); %#ok<NODEF>
    cpt = value(cpoketry);    cpt = cpt(1:length(hh)); %#ok<NODEF>
    
    if n_done_trials >= 1
        Total_Trial_Count.value = value(Total_Trial_Count) + 1; %#ok<NODEF>
        if ~isempty(sh) && ~isempty(lh) && ~isnan(hh(end))
            if     sh(end) == 'l' && lh(end) == 'p' ;  Pro_L_Cnt.value = value( Pro_L_Cnt) + 1;  %#ok<NODEF>
            elseif sh(end) == 'l' && lh(end) == 'a' ; Anti_L_Cnt.value = value(Anti_L_Cnt) + 1;  %#ok<NODEF>
            elseif sh(end) == 'r' && lh(end) == 'a' ; Anti_R_Cnt.value = value(Anti_R_Cnt) + 1;  %#ok<NODEF>
            else                                       Pro_R_Cnt.value = value( Pro_R_Cnt) + 1;  %#ok<NODEF>
            end
            
             Pro_L_Perf.value = nanmean(hh(sh == 'l' & lh == 'p'));
            Anti_L_Perf.value = nanmean(hh(sh == 'l' & lh == 'a'));
             Pro_R_Perf.value = nanmean(hh(sh == 'r' & lh == 'p'));
            Anti_R_Perf.value = nanmean(hh(sh == 'r' & lh == 'a'));
            
        end
        if ~isempty(hh) && ~isempty(cpt)
            if hh(end) == 1 && cpt(end) == 0
                Total_Good_Count.value = value(Total_Good_Count) + 1; %#ok<NODEF>
            end
        end
    else
        Pro_L_Cnt.value = 0;
        Pro_R_Cnt.value = 0;
        Anti_L_Cnt.value = 0;
        Anti_R_Cnt.value = 0;
    end

    AntibiasSection(obj, 'update',...
        SidesSection(obj, 'get_left_prob'),...
        SidesSection(obj, 'get_pro_prob'),...
        hit_history, sides_history, loc_history);
    
    NICDur.value = (rand(1) * (value(MaxNICDur) - value(MinNICDur))) + value(MinNICDur);
    if value(LockContextNIC) == 1; ContextDur.value = value(NICDur); end
    
    StimulatorSection(obj, 'update_values');
    MaskSection(      obj, 'update_values');
    
    SidesSection(     obj, 'prepare_next_trial');
    
    PsychSection(     obj, 'prepare_next_trial');
    
    SoundManagerSection(obj, 'send_not_yet_uploaded_sounds');
     
    [sma, prepare_next_trial_states] = SMASection(obj, 'prepare_next_trial');
    sma = StimulatorSection(obj,'prepare_next_trial',sma);
    sma = MaskSection(      obj,'prepare_next_trial',sma);
    
    dispatcher('send_assembler', sma, prepare_next_trial_states);

    SidesSection(obj, 'update_plot');
    
    % Default behavior of following call is that every 20 trials, the data
    % gets saved, not interactive, no commit to CVS. 
    SavingSection(obj, 'autosave_data');
    
    CommentsSection(obj, 'clear_history'); % Make sure we're not storing unnecessary history
    if n_done_trials==1,  % Auto-append date for convenience.
      WaterAdaptorSection(obj, 'set_first_trial_time_stamp');
      CommentsSection(obj, 'append_date'); CommentsSection(obj, 'append_line', '');
    end;

    if n_done_trials==1
      [expmtr, rname]=SavingSection(obj, 'get_info');
      prot_title.value=[mfilename ' on rig ' get_hostname ' : ' expmtr ', ' rname  '.  Started at ' datestr(now, 'HH:MM')];
    end
    
    try send_n_done_trials(obj); end

    
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
     WaterAdaptorSection(obj, 'end_session_report');
     getSessID(obj);
    
%% pre_saving_settings
  %---------------------------------------------------------------
  %          CASE PRE_SAVING_SETTINGS
  %---------------------------------------------------------------
  case 'pre_saving_settings'

      try %#ok<TRYNC>
 		pd.sides = sides_history(:);
        pd.hit   = hit_history(:);
        pd.loc   = loc_history(:);
        pd.cpt   = cpoketry(:);
        if isempty(pd.cpt); pd.cpt = zeros(size(pd.hit)); pd.cpt(:) = nan; end

        fds=fieldnames(pd);
		for fi=1:numel(fds)
			pd.(fds{fi})=pd.(fds{fi})(1:n_completed_trials);
		end

        
        pd.ProL_cnt = value(Pro_L_Cnt); %#ok<NODEF>
        pd.ProR_cnt = value(Pro_R_Cnt); %#ok<NODEF>
        pd.AntL_cnt = value(Anti_L_Cnt); %#ok<NODEF>
        pd.AntR_cnt = value(Anti_R_Cnt); %#ok<NODEF>
        
        pd.ProL_perf = value(Pro_L_Perf); %#ok<NODEF>
        pd.ProR_perf = value(Pro_R_Perf); %#ok<NODEF>
        pd.AntL_perf = value(Anti_L_Perf); %#ok<NODEF>
        pd.AntR_perf = value(Anti_R_Perf);
		
        pd.MinNIC    = value(MinNICDur);
        pd.MaxNIC    = value(MaxNICDur);
        

		sendsummary(obj,'sides',sides_history,'protocol_data',pd);
        sendtrial(obj);
      catch
          showerror
      end
        
        SessionDefinition(obj, 'run_eod_logic_without_saving'); 
        
    
%% after_load_callbacks
  %---------------------------------------------------------------
  %          CASE AFTER_LOAD_CALLBACKS
  %---------------------------------------------------------------
  case 'after_load_callbacks'
    AntibiasSection(obj, 'update',...
        SidesSection(obj, 'get_left_prob'),...
        SidesSection(obj, 'get_pro_prob'),...
        hit_history, sides_history, loc_history);

    
    
%% close    
  %---------------------------------------------------------------
  %          CASE CLOSE
  %---------------------------------------------------------------
  case 'close'
    PokesPlotSection(obj, 'close');
    WaterAdaptorSection(obj, 'close');

    if exist('myfig', 'var') && isa(myfig, 'SoloParamHandle') && ishandle(value(myfig)), %#ok<NODEF>
      delete(value(myfig));
    end;
    delete_sphandle('owner', ['^@' class(obj) '$']);

  otherwise,
    warning('Unknown action! "%s"\n', action); %#ok<WNTAG>
end;

return;

