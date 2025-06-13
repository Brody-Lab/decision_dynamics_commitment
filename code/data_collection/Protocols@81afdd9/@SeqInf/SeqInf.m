

function [obj] = SeqInf(varargin)

% Default object is of our own class (mfilename);
% we inherit only from Plugins

obj = class(struct, mfilename, saveload, water, ...
   pokesplot2, soundmanager, soundui, AdLibGUI, ...
   distribui, comments, sqlsummary, sessionmodel);

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
   
   % init
   case 'init'
      getSessID(obj);
      dispatcher('set_trialnum_indicator_flag');
      %   Make default figure. We remember to make it non-saveable; on next run
      %   the handle to this figure might be different, and we don't want to
      %   overwrite it when someone does load_data and some old value of the
      %   fig handle was stored as SoloParamHandle "myfig"
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
      SoloParamHandle(obj, 'hit_history', 'value', []);

      DeclareGlobals(obj, 'ro_args', {'hit_history'});

      % From Plugins/@soundmanager:
      SoundManagerSection(obj, 'init');

      %   ----------------------
      %   Set up the main GUI window
      %   ----------------------
      x = 5; y = 5; maxy=5;     % Initial position on main GUI window
      
      % COLUMN 1
      %   From Plugins/@saveload:
      [x, y] = SavingSection(obj, 'init', x, y);
      
      %   From Plugins/@water:
      [x, y] = WaterValvesSection(obj, 'init', x, y, 'streak_gui', 1);
     % [x, y] = HFWaterAdaptorSection(obj, 'init', x, y); 
    
      maxy = max(y, maxy); next_column(x); y=5;
      
     
      [x, y] = SidesSection(obj, 'init', x, y);
      [x, y] = SoundWindow(obj,'init',x,y);      
      
      SC = state_colors(obj);
      [x, y] = PokesPlotSection(obj, 'init', x, y, ...
         struct('states',  SC));
      PokesPlotSection(obj, 'set_alignon', 'cpoke1(1,1)');
      
      next_row(y);
      
      [x, y] = CommentsSection(obj, 'init', x, y);
      %SessionDefinition(obj, 'init', x, y, value(myfig)); next_row(y, 2); 
      %SessionDefinition(obj, 'set_old_style_parsing_flag',0);
      
      figpos = get(gcf, 'Position');
      [expmtr, rname]=SavingSection(obj, 'get_info');
      HeaderParam(obj, 'prot_title', ['SeqInf: ' expmtr ', ' rname], ...
         x, y, 'position', [10 figpos(4)-25, 800 20]);
      
      SeqInf(obj, 'prepare_next_trial');
      
      
      % prepare next trial
   case 'prepare_next_trial'
      nTrials.value = n_done_trials;
      % do sample duration accounting on the just finished trial
      SidesSection(obj, 'next_trial');
      SoundManagerSection(obj, 'send_not_yet_uploaded_sounds');

      % invoke autosave
      SavingSection(obj, 'autosave_data');
      if n_done_trials==1
      [expmtr, rname]=SavingSection(obj, 'get_info');
      prot_title.value=['PBups - on rig ' get_hostname ' : ' expmtr ', ' rname  '.  Started at ' datestr(now, 'HH:MM')];
      end
      SMA1(obj,'next_trial');
      
      % trial_completed
   case 'trial_completed'
      feval(mfilename, 'update');
      
      % And PokesPlot needs completing the trial:
      PokesPlotSection(obj, 'trial_completed');
          
      if n_done_trials==1,
         CommentsSection(obj, 'append_date');
         CommentsSection(obj, 'append_line', '');    

      end;
      CommentsSection(obj, 'clear_history'); % Make sure we're not storing unnecessary history
      
      SidesSection(obj, 'trial_completed');
    
      
      
      % update
   case 'update'
      PokesPlotSection(obj, 'update');
      
      
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
      SidesSection(obj, 'end_sess');
  %    AdLibGUISection(obj, 'evaluate_outcome');
      
      %% pre_saving_settings
   case 'pre_saving_settings'
   %   SessionDefinition(obj, 'run_eod_logic_without_saving');
      SidesSection(obj, 'make_and_send_summary');
      
      
   otherwise,
      warning('Unknown action! "%s"\n', action);
end;

return;

