% flickr protocol that included headfixation
% BBS Feb 2013

function [obj] = flickerfixed(varargin)

% Default object is of our own class (mfilename);
% we inherit only from Plugins

obj = class(struct, mfilename, saveload, water, ...
   pokesplot2, soundmanager, soundui, ...
   distribui, comments, sqlsummary, AdLibGUI);

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
      

      %   Let RewardsSection, the part that parses what happened at the end of
      %   a trial, write to hit_history:
      %    SoloFunctionAddVars('RewardsSection', 'rw_args', {'hit_history'; 'violation_history'});
      
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
      
      [x, y] = AdLibGUISection(obj,'init',x,y);
      [x, y] = SidesSection(obj, 'init', x, y);
      [x, y] = SoundWindow(obj,'init',x,y);
      
      % [x, y] = HeadfixSection(obj, 'init', x, y);
      
           
      
      SC = state_colors(obj);
      [x, y] = PokesPlotSection(obj, 'init', x, y, ...
         struct('states',  SC));
      PokesPlotSection(obj, 'set_alignon', 'cpoke1(1,1)');
      
      next_row(y);
      
      [x, y] = CommentsSection(obj, 'init', x, y);
      
      figpos = get(gcf, 'Position');
      [expmtr, rname]=SavingSection(obj, 'get_info');
      HeaderParam(obj, 'prot_title', ['flickerfixed: ' expmtr ', ' rname], ...
         x, y, 'position', [10 figpos(4)-25, 800 20]);
      
      flickerfixed(obj, 'prepare_next_trial');
      
      
      %% prepare next trial
   case 'prepare_next_trial'
      nTrials.value = n_done_trials;
      
      if n_done_trials==1,
          AdLibGUISection(obj, 'set_first_trial_time_stamp');
      end
      % do sample duration accounting on the just finished trial
      SidesSection(obj, 'next_trial');
      SoundManagerSection(obj, 'send_not_yet_uploaded_sounds');
      %  TrainingSection(obj, 'next_trial');

      % invoke autosave
      SavingSection(obj, 'autosave_data');
      if n_done_trials==1
      [expmtr, rname]=SavingSection(obj, 'get_info');
      prot_title.value=['PBups - on rig ' get_hostname ' : ' expmtr ', ' rname  '.  Started at ' datestr(now, 'HH:MM')];
      end
      SMA1(obj,'next_trial');
      
      %% trial_completed
   case 'trial_completed'
      feval(mfilename, 'update');
      
      % And PokesPlot needs completing the trial:
      PokesPlotSection(obj, 'trial_completed');
          
      if n_done_trials==1,
         CommentsSection(obj, 'append_date');
         CommentsSection(obj, 'append_line', '');
        % HFWaterAdaptorSection(obj, 'set_first_trial_time_stamp');
      end;
      CommentsSection(obj, 'clear_history'); % Make sure we're not storing unnecessary history
      [x, y] = SidesSection(obj, 'get_current_side');
      x = char(x);
      if x == 's'; 
          x = 'r';
      end
      if x == 'm';
          x = 'l';
      end
      
      if n_done_trials > 0
          AdLibGUISection(obj, 'update_water_volume', x, y);
      end
      %HFWaterAdaptorSection(obj, 'update_water_volume', x);
      %AdLibGUISection(obj, 'update_water_volume', x, y);
      
      %% update
   case 'update'
      PokesPlotSection(obj, 'update');
      
      
      %% close
   case 'close'
      AdLibGUISection(obj, 'close');
      PokesPlotSection(obj, 'close');
      CommentsSection(obj, 'close');
      %HFWaterAdaptorSection(obj, 'close');
      
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
     % HFWaterAdaptorSection(obj, 'evaluate_outcome');
      
      
      %% pre_saving_settings
   case 'pre_saving_settings'
   %   SessionDefinition(obj, 'run_eod_logic_without_saving');
      AdLibGUISection(obj, 'evaluate_outcome');
      SidesSection(obj, 'make_and_send_summary');
      
      
      %% otherwise
      
   otherwise,
      warning('Unknown action! "%s"\n', action);
end;

return;

