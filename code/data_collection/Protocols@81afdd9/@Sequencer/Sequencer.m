%
%Written by Carlos 2025


function [obj, x] = Sequencer(varargin)

% Default object is of our own class (mfilename); in this simplest of
% protocols, we inherit only from Plugins/@pokesplot

obj = class(struct, mfilename, saveload, water, AdLibGUI, antibias, pokesplot2, ...
  soundmanager, soundui ,sessionmodel, distribui, punishui, warnDanger, ...
  comments, softpokestay2, sqlsummary);

%---------------------------------------------------------------
%   BEGIN SECTION COMMON TO ALL PROTOCOLS, DO NOT MODIFY
%---------------------------------------------------------------

% If creating an empty object, return without further ado:
if nargin==0 || (nargin==1 && ischar(varargin{1}) && strcmp(varargin{1}, 'empty')) 
   return; 
end

if isa(varargin{1}, mfilename)  % If first arg is an object of this class itself, we are 
                                % Most likely responding to a callback from  
                                % a SoloParamHandle defined in this mfile.
  if length(varargin) < 2 || ~ischar(varargin{2})  
    error(['If called with a "%s" object as first arg, a second arg, a ' ...
      'string specifying the action, is required\n']);
  else
      action = varargin{2}; varargin = varargin(3:end);
  end
else % Ok, regular call with first param being the action string.
       action = varargin{1}; varargin = varargin(2:end); 
end
if ~ischar(action), error('The action parameter must be a string'); end

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


switch action

  %---------------------------------------------------------------
  %          CASE INIT
  %---------------------------------------------------------------
  
  case 'init'

    % --- initial figure setup ---
    dispatcher('set_trialnum_indicator_flag'); 
    
    hackvar = 10; SoloFunctionAddVars('SessionModel', 'ro_args', 'hackvar'); 
      
    % Make default figure. We remember to make it non-saveable; on next run
    % the handle to this figure might be different, and we don't want to
    % overwrite it when someone does load_data and some old value of the
    % fig handle was stored as SoloParamHandle "myfig"
    SoloParamHandle(obj, 'myfig', 'saveable', 0); myfig.value = double(figure);

    % Make the title of the figure be the protocol name, and if someone tries
    % to close this figure, call dispatcher's close_protocol function, so it'll know
    % to take it off the list of open protocols.
    name = mfilename;
    set(value(myfig), 'Name', name, 'Tag', name, ...
      'closerequestfcn', [mfilename,'(''close'');'], 'MenuBar', 'none');

    % --- Basic vars ---
    
    SoloParamHandle(obj, 'hit_history',   'value', []);
    SoloParamHandle(obj, 'sides_history', 'value', '');
    SoloParamHandle(obj, 'seq_history',   'value', {})
    SoloParamHandle(obj, 'loc_history',   'value', '');
    DeclareGlobals(obj, 'ro_args', {'hit_history', 'sides_history', 'loc_history', 'seq_history'});
    
  
    % --- set up sections ---

    SoundManagerSection(obj, 'init');

    x = 5; y = 5;             % Initial position on main GUI window

    [x, y] = SavingSection(obj,       'init', x, y); 
    [x, y] = WaterValvesSection(obj,  'init', x, y, 'show_calib_info',1);
    [x, y] = AdLibGUISection(obj,'init',x,y);
    
    [x, y] = PokesPlotSection(obj,    'init', x, y, ...
      struct('states',  state_colors(obj)));
    next_row(y);
    
    [x, y] = CommentsSection(obj, 'init', x, y);
    SessionDefinition(obj,   'init', x, y, value(myfig)); %next_row(y, 2); 

    figpos = get(gcf, 'Position');
    [expmtr, rname]=SavingSection(obj, 'get_info');
    HeaderParam(obj, 'prot_title', [mfilename ': ' expmtr ', ' rname], ...
      x, y, 'position', [10 figpos(4)-25, 800 20]);

    next_column(x);y = 5;
    
    [x, y] = SoftPokeStayInterface2(obj, 'add', 'soft_drink_time', x, y);
    SoftPokeStayInterface2(obj, 'set', 'soft_drink_time', 'Duration', 10, 'Grace', 2);
    
    [x, y] = WarnDangerInterface(obj, 'add', 'warndanger', x, y); 
    WarnDangerInterface(obj, 'set', 'warndanger', 'WarnDur',   3);
    WarnDangerInterface(obj, 'set', 'warndanger', 'DangerDur', 0);
    SoundInterface(Sequencer, 'set', ['warndanger' '_WarningSound'], 'Vol', 0)
    SoundInterface(Sequencer, 'set', ['warndanger' '_DangerSound'],  'Vol', 0)   
    
    [x, y] = PunishInterface(obj, 'add', 'error_state', x, y);    
    PunishInterface(obj, 'set', 'error_state', 'SoundsPanel', 0);
    PunishInterface(Sequencer, 'set', 'error_state', 'Reinit', 0)
    SoundInterface(Sequencer,  'set', 'error_state_InitSnd',     'Vol', 0)
    SoundInterface(Sequencer,  'set', 'error_state_OngoingSnd',  'Vol', 0)

    ToggleParam(obj, 'forgiveLastPokeError', 0, x, y, 'TooltipString', ...
      sprintf(['If true (black), wrong side pokes on the last poke of the sequence are ignored\n' ...
      'otherise (brown), wrong side pokes go to error state']));
    next_row(y);
    SubheaderParam(obj, 'forgivingHeader', 'Forgiving', x, y);
    next_row(y);

    NumeditParam(obj, 'spokeDelay', 0.3, x, y, 'TooltipString', ...
        'delay in seconds between completing one side poke, and going into softPokeOut');
    next_row(y);
    NumeditParam(obj, 'softPokeOutTime', 0.2, x, y, 'TooltipString', ...
        sprintf(['time for which the animal must be out and not poke back in\n' ...
          'before the spokeDelay is considered finished.\n' ...
          'set to 0 if you don''t want any softPoke']));
    next_row(y);

    NumeditParam(obj, 'nSides', 1, x, y, 'TooltipString', ...
        'number of side pokes after the center poke for a reward to be given')
    set_callback(nSides, {'ProbabilitiesSection', 'reinit_if_nSides_changed'})
    SoloFunctionAddVars('ProbabilitiesSection', 'ro_args', {'nSides'});
    next_row(y);
   
    
    [x, y] = ProbabilitiesSection(obj, 'init', x, y); %#ok<*ASGLU>
    
    feval(mfilename, obj, 'prepare_next_trial');

  %---------------------------------------------------------------
  %          CASE GET_STATE_COLORS
  %---------------------------------------------------------------

  case 'get_state_colors'
    obj=state_colors(obj);

  %---------------------------------------------------------------
  %          CASE UPDATE
  %---------------------------------------------------------------
    
  case 'update'
    PokesPlotSection(obj, 'update');
  

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  %          CASE PREPARE_NEXT_TRIAL
  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
  case 'prepare_next_trial'
      if n_done_trials >= 1
          if size(parsed_events.states.error_state,1) >= 1
              hit_history.value   = [hit_history(:) ; 0];
          else
              hit_history.value   = [hit_history(:) ; 1];
          end
      end
      
      seqs = ProbabilitiesSection(Sequencer, 'get_probabilities');
      
      s = find(rand(1) < cumsum([seqs{:,2}]), 1, 'first');
      s = seqs{s,1};
      % Sides history only acquires the side of the last required poke: 
      sides_history.value = [value(sides_history) lower(s(end))]; %#ok<*NODEF>
      % seq_history gets the full sequence history
      seq_history.value = [value(seq_history) ; {lower(s)}];
      
      Lled    = bSettings('get', 'DIOLINES', 'left1led'); %#ok<*NASGU>
      Cled    = bSettings('get', 'DIOLINES', 'center1led');
      Rled    = bSettings('get', 'DIOLINES', 'right1led');
      Lwater  = bSettings('get', 'DIOLINES', 'left1water');
      Rwater  = bSettings('get', 'DIOLINES', 'right1water');
      [LtValve, RtValve] = WaterValvesSection(obj, 'get_water_times');

      sma = StateMachineAssembler('full_trial_structure','use_happenings', 1);
      
      sma = add_state(sma, 'name', 'wait_for_cin',...
          'output_actions',{'DOut', Cled},...
          'input_to_statechange', {'Cin', ['wait_for_' s(1) 'poke1']; 'Chi', ['wait_for_' s(1) 'poke1']});

      for i = 1:(value(nSides)-1)
          if s(i) == 'R' sOther = 'L';  %#ok<*SEPEX>
          else           sOther = 'R';
          end
          
          sma = add_state(sma, 'name', ['wait_for_' s(i) 'poke' num2str(i)], ...
              'output_actions', {'DOut', eval([s(i) 'led'])}, ...
              'input_to_statechange', {[s(i) 'in'], ['pre_wait_for_' s(i+1) 'poke' num2str(i+1)]; 
                                       [s(i) 'hi'], ['pre_wait_for_' s(i+1) 'poke' num2str(i+1)];
                                       [sOther 'in'], 'error_state'; 
                                       [sOther 'hi'], 'error_state';
                                       });

          % spokeDelay before turning on light and waiting for next side poke:                         
          sma = add_state(sma, 'name', ['pre_wait_for_' s(i+1) 'poke' num2str(i+1)], ...
              'self_timer', value(spokeDelay), ...
              'input_to_statechange', {'Tup', 'soft_poke_out'});

          sma = add_state(sma, 'name', 'soft_poke_out', 'self_timer', value(softPokeOutTime), ...
              'input_to_statechange', {
                  'Tup', ['wait_for_' s(i+1) 'poke' num2str(i+1)] ;
                  [s(i) 'in'], 'soft_poke_in', ;
                  [s(i) 'hi'], 'soft_poke_in', ;
              });
          sma = add_state(sma, 'name', 'soft_poke_in', ...
            'input_to_statechange', {
                [s(i) 'out'], 'soft_poke_out', ;
                [s(i) 'lo'],  'soft_poke_out', ;
            });
      % next dummy states, just to have entries for them, but
          % in parsed_events they'll have zero rows, since no other state jumps to
          % them, so they are never reached.    
          sma = add_state(sma, 'name', ['wait_for_' sOther 'poke' num2str(i)]);                                       
          if s(i+1) == 'R' sNextOther = 'L';  %#ok<*SEPEX>
          else             sNextOther = 'R';
          end
          sma = add_state(sma, 'name', ['pre_wait_for_' sNextOther 'poke' num2str(i)]);                                       
                                                                  
      end
      
      if s(end) == 'R' sHit = 'R'; sError = 'L';  %#ok<*SEPEX>
      else             sHit = 'L'; sError = 'R';
      end
      if forgiveLastPokeError
        sma = add_state(sma, 'name', ['wait_for_' sHit 'poke' num2str(length(s))], ...
          'output_actions', {'DOut', eval([sHit 'led'])}, ...
          'input_to_statechange', {[sHit 'in'],  'soft_drink_time'; 
                                   [sHit 'hi'],  'soft_drink_time';
                                   });
      else
        sma = add_state(sma, 'name', ['wait_for_' sHit 'poke' num2str(length(s))], ...
          'output_actions', {'DOut', eval([sHit 'led'])}, ...
          'input_to_statechange', {[sHit 'in'],  'soft_drink_time'; 
                                   [sHit 'hi'],  'soft_drink_time';
                                   [sError 'in'], 'error_state'; 
                                   [sError 'hi'], 'error_state';                                   
                                   });
      end
      % dummy state that never gets jumped to:
      sma = add_state(sma, 'name', ['wait_for_' sError 'poke' num2str(length(s))]);
                               
      sma = SoftPokeStayInterface2(obj, 'add_sma_states', 'soft_drink_time', sma, ...
          'DOut', eval([sHit 'water']), 'DOutStartTime', 0, 'DOutOnTime', eval([sHit 'tValve']), ...
          'pokeid', sHit, 'success_exitstate_name', 'warndanger', 'abort_exitstate_name', 'warndanger');
        
      sma = WarnDangerInterface(obj, 'add_sma_states', 'warndanger', sma, ...
        'exitstate', 'final_state', 'on_poke_when_danger_state', 'warndanger');
        
      sma = PunishInterface(obj, 'add_sma_states', 'error_state', sma, ...
        'exitstate', 'final_state');
      
      sma = add_state(sma, 'name','final_state','self_timer', 0.01,...
        'input_to_statechange', {'Tup', 'check_next_trial_ready'});

      prepare_next_trial_states = {
          'soft_drink_time', ...
          'error_state', ...
          'warndanger_warning'};    
      
      SoundManagerSection(obj, 'send_not_yet_uploaded_sounds');

      dispatcher('send_assembler', sma, prepare_next_trial_states);        

      
      SavingSection(obj, 'autosave_data');
    
      CommentsSection(obj, 'clear_history'); % Make sure we're not storing unnecessary history
      if n_done_trials==1  % Auto-append date for convenience.
          CommentsSection(obj, 'append_date'); CommentsSection(obj, 'append_line', '');
          [expmtr, rname]=SavingSection(obj, 'get_info');
          prot_title.value=[mfilename ' on rig ' get_hostname ' : ' expmtr ', ' rname  '.  Started at ' datestr(now, 'HH:MM')]; %#ok<*STRNU>
      end

      try 
          send_n_done_trials(obj); 
      catch
      end

      SessionDefinition(obj, 'next_trial');

      x = sma;

      
  %---------------------------------------------------------------
  %          CASE TRIAL_COMPLETED
  %---------------------------------------------------------------

  case 'trial_completed'
    % Do any updates in the protocol that need doing:
    feval(mfilename, 'update');
    % And PokesPlot needs completing the trial:
    PokesPlotSection(obj, 'trial_completed');


  %---------------------------------------------------------------
  %          CASE PRE_SAVING_SETTINGS
  %---------------------------------------------------------------
  case 'pre_saving_settings'

      try 
 		    pd.sides = sides_history(:);
        pd.hit   = hit_history(:);

        fds=fieldnames(pd);
		for fi=1:numel(fds)
			pd.(fds{fi})=pd.(fds{fi})(1:n_completed_trials);
		end
      
		sendsummary(obj,'sides',sides_history,'protocol_data',pd);
        sendtrial(obj);
      catch
          showerror
      end
      
      SessionDefinition(obj, 'run_eod_logic_without_saving'); 
        
    
       
    
  %---------------------------------------------------------------
  %          CASE END_SESSION
  %---------------------------------------------------------------
  case 'end_session'
     prot_title.value = [value(prot_title) ', Ended at ' datestr(now, 'HH:MM')];
     getSessID(obj);
    

  %---------------------------------------------------------------
  %          CASE CLOSE
  %---------------------------------------------------------------
  case 'close'
        ProbabilitiesSection(obj, 'close')
        if exist('myfig', 'var') && isa(myfig, 'SoloParamHandle') && ishandle(value(myfig)) 
          delete(value(myfig));
        end
        if isempty(get_sphandle('owner', ['^@' class(obj) '$']))
            % We're done
            return
        else
            delete_sphandle('owner', ['^@' class(obj) '$']);
        end
        dispatcher('set_protocol','');
      
        
  %---------------------------------------------------------------
  %          OTHERWISE
  %---------------------------------------------------------------
  otherwise
      warning('Unknown action! "%s"\n', action); %#ok<WNTAG>

end

return;

