% flickr protocol
% JCE,BBS July 2012

function [obj] = SpeakerTest(varargin)

% Default object is of our own class (mfilename);
% we inherit only from Plugins

obj = class(struct, mfilename, saveload, water, pokesplot)
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
   
   %% init
   case 'init'
  
      
      SoloParamHandle(obj, 'myfig', 'saveable', 0); myfig.value = double(figure);
      
      %   Make the title of the figure be the protocol name, and if someone tries
      %   to close this figure, call dispatcher's close_protocol function, so
      %   it'll know to take it off the list of open protocols.
      name = mfilename;
      set(value(myfig), 'Name', name, 'Tag', name, ...
         'closerequestfcn', 'dispatcher(''close_protocol'')', 'MenuBar', 'none');
      
      
      % Ok, gotta figure out what this hack variable is doing here, why we need
      % it, and how to do without it. For now, though, if you want to use
      % SessionModel...
      hackvar = 10; SoloFunctionAddVars('SessionModel', 'ro_args', 'hackvar'); %#ok<NASGU>
      
      %   Put the figure where we want it and give it a reasonable size
      set(value(myfig), 'Position', [400 100 850 680]);
      
      %   ----------------------
      %   Let's declare some globals that everybody is likely to want to know about.
      %   ----------------------
      
      

      %   Let RewardsSection, the part that parses what happened at the end of
      %   a trial, write to hit_history:
      %    SoloFunctionAddVars('RewardsSection', 'rw_args', {'hit_history'; 'violation_history'});
      
      % From Plugins/@soundmanager:
      
      
      %   ----------------------
      %   Set up the main GUI window
      %   ----------------------
      x = 5; y = 5; maxy=5;     % Initial position on main GUI window
      
      % COLUMN 1
      %   From Plugins/@saveload:
      [x, y] = SavingSection(obj, 'init', x, y);
      
      %   From Plugins/@water:
      %[x, y] = WaterValvesSection(obj, 'init', x, y, 'streak_gui', 1);
    
      
      state_colors = struct( ...
          'start',                [220 115 215]/255, ...  % orchid
          'googlie',              [0.52 0.76 1], ...
          'buzzle',               [1    1    1], ...      % white
          'cpoke1',               [0.52 0.76 1], ...
          'cpoke2',               [0.52 0.72 1], ...
          'cpoke3',               [0.52 0.68 1]);

      [x, y] = PokesPlotSection(obj, 'init', x, y, ...
         struct('states',  state_colors));
      SpeakerTest(obj, 'prepare_next_trial');
      
      
      %% prepare next trial
   case 'prepare_next_trial'
%WaterValvesSection(obj, 'set_water_amounts', 100, 200);
       
       sma = StateMachineAssembler('full_trial_structure');
       
       left1led           = bSettings('get', 'DIOLINES', 'left1led');
       center1led         = bSettings('get', 'DIOLINES', 'center1led');
       right1led          = bSettings('get', 'DIOLINES', 'right1led');
       left1water         = bSettings('get', 'DIOLINES', 'left1water');
       right1water        = bSettings('get', 'DIOLINES', 'right1water');

       
       sma = add_state(sma, 'name', 'start', 'self_timer', 1, ...
           'output_actions', {'DOut', left1led}, ...
           'input_to_statechange', {'Tup', 'testtest'});
       
       sma = add_state(sma, 'name', 'testtest', 'self_timer', 1, ...
           'output_actions', {'DOut', center1led}, ...
           'input_to_statechange', {'Cin', 'speaker'});
       
       sma = add_state(sma, 'name', 'speaker', 'self_timer', 0.5, ...
           'output_actions', {'DOut', right1led+center1led}, ...  %%% Replace right1led with DIO line for the speaker
           'input_to_statechange', {'Tup', 'current_state+1'});
       
       sma = add_state(sma, 'self_timer', 0.5, ...
           'output_actions', {}, ...
           'input_to_statechange', {'Tup', 'current_state+1'});
       
       sma = add_state(sma, 'self_timer', 0.5, ...
           'output_actions', {'DOut', right1led+center1led}, ...   %%% Replace right1led with DIO line for the speaker
           'input_to_statechange', {'Tup', 'current_state+1'});
       
       sma = add_state(sma, 'self_timer', 0.5, ...
           'output_actions', {}, ...
           'input_to_statechange', {'Tup', 'current_state+1'});
 
       sma = add_state(sma, 'self_timer', 0.5, ...
           'output_actions', {'DOut', right1led+center1led}, ...   %%% Replace right1led with DIO line for the speaker
           'input_to_statechange', {'Tup', 'current_state+1'});
       
       sma = add_state(sma, 'self_timer', 0.5, ...
           'input_to_statechange', {'Tup', 'check_next_trial_ready'});
       

       dispatcher('send_assembler', sma);


      
      %% trial_completed
   case 'trial_completed'
      feval(mfilename, 'update');
      
      % And PokesPlot needs completing the trial:
      PokesPlotSection(obj, 'trial_completed');
      
      
      if n_done_trials==1,
         CommentsSection(obj, 'append_date');
         CommentsSection(obj, 'append_line', '');
      end;
      CommentsSection(obj, 'clear_history'); % Make sure we're not storing unnecessary history
      
      %% update
   case 'update'
      PokesPlotSection(obj, 'update');
      
      
      %% close
   case 'close'
      PokesPlotSection(obj, 'close');
      CommentsSection(obj, 'close');
      
      if exist('myfig', 'var') && isa(myfig, 'SoloParamHandle') && ishandle(value(myfig)),
         delete(value(myfig));
      end;
      
      try
         delete_sphandle('owner', ['^@' class(obj) '$']);
      catch
         warning('Some SoloParams were not properly cleaned up');
      end
      
      %% end_session
   case 'end_session'
      prot_title.value = [value(prot_title) ', Ended at ' datestr(now, 'HH:MM')];
      
      
      
      %% pre_saving_settings
   case 'pre_saving_settings'
   %   SessionDefinition(obj, 'run_eod_logic_without_saving');
      SidesSection(obj, 'make_and_send_summary');
      
      
      %% otherwise
      
   otherwise,
      warning('Unknown action! "%s"\n', action);
end;

return;

