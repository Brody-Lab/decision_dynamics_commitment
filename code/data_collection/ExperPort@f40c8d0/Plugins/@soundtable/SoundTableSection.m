% [x, y] = SoundTableSection(obj, action, [arg1], [arg2])

% This plugin makes a Sound Table window that manages any number of f1/f2
% stimulus sounds.  The sounds specified in this table are sent to
% SoundManagerSection as 'Soundx', where 'x' is the row where this sound
% appears in the table.
%
% PARAMETERS:
% -----------
%
% obj      Default object argument.
%
% action   One of:
%
%   'init'     Initializes the plugin. Sets up internal variables
%               and the GUI window.
%
%   'n_stimulus_cycle'      if a value <1 is entered for n_stimulus_cycle,
%               reset it to 1.
%
%   'StimTimeStart'         disables/enables FromAnswerPoke and
%               n_stimulus_cycles as appropriate
%
%   'display_table'         formats the sounds stored in stims to be
%               displayed in the table
%
%   'sttable'               when a row is clicked in the table, copy the
%               values in that row into the NumeditParams for the
%               corresonding fields.  This makes it easier to modify the
%               sounds and then update them.
%
%   'side'                  enforces the value entered in side to be either
%               'r' or 'l'.
%
%   'pprob'                 enforces the value entered in pprob to be [0 1].
%
%   'set'                   a useful action that takes 3 extra arguments:
%               the sound pair to be modified, the field to be modified,
%               and the new value.  For example, if we want to set the
%               f1_dur of sound pair 4 to 0.7:
%                 SoundTableSection(obj, 'set', 4, 'f1_dur', 0.7);
%
%   'get'                   a complementary action to set that takes 1-2
%               extra arguments.  To get the number of sounds currently
%               defined or a matrix of all sides, use 'nstims' and
%               'all_sides'.  To get a field from a specific sound pair,
%               for example, the pprob of sound 2:
%                 SoundTableSection(obj, 'get', 2, 'pprob');
%
%   'add_pair'              adds a new row to the table using the values 
%               currently in the editparams.  Makes the appropriate row in
%               stims and constructs the sound.
%
%   'delete_pair'           deletes the row currently selected in the table.
%
%   'update_pair'           replaces the row currently selected in the
%               table with the values entered in the editparams.
%
%   'next_trial_sound'      returns the row of one pair chosen randomly
%               according to the pprobs.  Passing an extra variable 'l' or
%               'r' forces a sound for that side to be picked.
%
%   'make_sounds'           constructs all sounds specified in stims and
%               sends them to SoundManagerSection.  Sounds are named
%               'Soundx', where x is the row this sound pair appears in the
%               table.  If passed an additional optional parameter, then
%               only this particular row is rebuilt and set in SoundManagerSection.
%
%   'check_norm'            checks that a valid set of sounds have been
%               specified, and if not, print a error message at the field
%               at the right bottom corner of the window.  Criterion for
%               all systems go: 1) pprobs sum to 1, and 2) at least one
%               left and one right sound are defined.  If these are both
%               met, go_flg is set to 1 and the message box turns green;
%               otherwise, go_flg is 0 and the message box turns red.
%
%   'get_go_flg'            returns the value of go_flg.
%
%   'normalize'             normalizes pprobs so they sum to 1.
%
%   'play_sound'            plays the currently selected sound in the table.
%
%   'stop_sound'            stops the currently selected sound in the table.
%
%   'get_n_sound_pairs'     returns the number of rows in stims.  This can
%               also be accomplished with the 'get' action.




% BWB, Jan. 2008




function [x, y] = SoundTableSection(obj, action, varargin)

message=[];
GetSoloFunctionArgs(obj);

switch action,
    
  % ------------------------------------------------------------------
  %              INIT
  % ------------------------------------------------------------------    

  case 'init'
    if length(varargin) < 2,
      error('Need at least two arguments, x and y position, to initialize %s', mfilename);
    end;
    x = varargin{1}; y = varargin{2};
    
    % SoloParamHandle(obj, 'soundtablefig', 'value', [x y gcf]);
    
    
    ToggleParam(obj, 'soundtable_show', 0, x, y, ...
       'OnString', 'Sound Table Showing', ...
       'OffString', 'Sound Table Hidden', ...
       'TooltipString', 'Show/Hide Sound Table window'); next_row(y);
    set_callback(soundtable_show, {mfilename, 'show_hide'}); 
    
    screen_size = get(0, 'ScreenSize'); fig = double(gcf);
    SoloParamHandle(obj, 'soundtablefig', ...
        'value', double(figure('Position', [200 screen_size(4)-740, 630 400], ...
        'closerequestfcn', [mfilename '(' class(obj) ', ''hide'');'], 'MenuBar', 'none', ...
        'NumberTitle', 'off', 'Name', 'Sound Table')), 'saveable', 0);
    origfig_xy = [x y]; 
    
    x = 10; y = 75;
    
    NumeditParam(obj, 'f1f2Gap', 0.2, x, y, ...
        'position', [x y 150 20], ...
        'TooltipString', 'Duration (in sec) of silent gap between f1 and f2');
    NumeditParam(obj, 'InterCycleGap', 0.2, x, y, ...
        'position', [x+150 y 150 20], ...
        'TooltipString', 'Duration (in sec) of silent gap between end of f2 and reinitiation of f1');
    set_callback({f1f2Gap; InterCycleGap}, {mfilename, 'make_sounds'});
    

    
    x = 10; y = 55;
    
    ToggleParam(obj, 'StimTimeStart', 0, x, y, 'position', [x y 150 20], ...
        'OffString', 'FromStimStart', 'OnString', 'FromAnswerPoke', ...
        'TooltipString', sprintf(['\nFromStimStart means stimulus is timed by n_stimulus_cycles', ...
        '\nwhich start counting when the stimulus start. FromAnswerPoke means stimulus playes until' ...
        '\nthe number of seconds indicated at left after the correct response have elapsed.' ...
        '\nStimulus always ends when the error state is entered.']));
    NumeditParam(obj, 'FromAnswerPoke', 2, x, y, 'position', [x+150 y 150 20], ...
        'labelfraction', 0.7, ...
        'TooltipString', sprintf(['\nNumber of seconds after correct response after which stimulus' ...
        '\nsound stops. Only valid if StimTimeStart (at left) is set to FromAnswerPoke']));
    NumeditParam(obj, 'n_stimulus_cycles', 2, x, y, ...
        'labelfraction', 0.7, ...
        'position', [x+300 y 150 20], ...
        'TooltipString', sprintf(['Number of cycles the stimuli are repeated before they' ...
                                    '\nare turned off.']));        
    set_callback(StimTimeStart, {mfilename, 'StimTimeStart'});
    
    SubheaderParam(obj, 'message', 'no sounds defined', x, y, ...
        'position', [x+450 y 150 20]);
    
    x = 10; y = 100;

    PushbuttonParam(obj, 'add', x, y, 'position', [x y 100 20], ...
      'label', 'Add Pair');
    PushbuttonParam(obj, 'del', x, y, 'position', [x+100 y 100 20], ...
      'label', 'Delete Pair');
    PushbuttonParam(obj, 'up', x, y, 'position', [x+200 y 100 20], ...
      'label', 'Update Pair', ...
      'TooltipString', 'replaces the currently selected row with values in the gui elements above');
    PushbuttonParam(obj, 'play_snd', x, y, 'position', [x+310 y 80 20], ...
      'label', 'Play Sound');
    PushbuttonParam(obj, 'stop_snd', x, y, 'position', [x+390 y 80 20], ...
      'label', 'Stop Sound');
    NumeditParam(obj, 'snd_amp', 0.03, x, y, 'position', [x+510 y 100 20], ...
      'TooltipString', 'all sounds multiplied by this amplifying factor');
    set_callback(add, {mfilename, 'add_pair'});
    set_callback(del, {mfilename, 'delete_pair'});
    set_callback(up,  {mfilename, 'update_pair'});
    set_callback(play_snd, {mfilename, 'play_sound'});
    set_callback(stop_snd, {mfilename, 'stop_sound'});
    next_row(y);

    x = 10;
    col_wid = 90;
    NumeditParam(obj, 'pprob', 0.5, x, y, 'position', [x y col_wid 20], ...
      'labelfraction', 0.6, ...
      'TooltipString', 'Prior probability of choosing this stimulus pair; must be [0,1]');
    set_callback(pprob, {mfilename, 'pprob'});
    EditParam(obj, 'side', 'l', x, y, 'position', [x+col_wid y col_wid 20], ...
      'labelfraction', 0.6, ...
      'TooltipString', 'Correct side choice for this stimulus pair');
    set_callback(side, {mfilename, 'side'});
    NumeditParam(obj, 'f1_frq', 25, x, y, 'position', [x+2*col_wid y col_wid 20], ...
      'labelfraction', 0.6);
    NumeditParam(obj, 'f1_dur', 0.2, x, y, 'position', [x+3*col_wid y col_wid 20], ...
      'labelfraction', 0.6);
    NumeditParam(obj, 'f2_frq', 25, x, y, 'position', [x+4*col_wid y col_wid 20], ...
      'labelfraction', 0.6);
    NumeditParam(obj, 'f2_dur', 0.2, x, y, 'position', [x+5*col_wid y col_wid 20], ...
      'labelfraction', 0.6);
    NumeditParam(obj, 'wtr_ml', 1, x, y, 'position', [x+6*col_wid y col_wid 20], ...
      'labelfraction', 0.6, ...
      'TooltipString', 'The amount of reward water will be multiplied by this number for this stimulus pair');
    next_row(y,1.5);

    % the sph 'table' holds the rows of the stable as a character
    % array
    % 'sttable' is the gui that displays what's held in table
    % 'stims' is a cell array that stores all the stimulus pairs in
    % use in a reasonable format
    SoloParamHandle(obj, 'table_', 'value', ...
      {'PProb   R/L   f1_frq     f1_dur     f2_frq     f2_dur    wtr_mul'}, ...
      'saveable', 0);
    ListboxParam(obj, 'sttable', value(table_), ...
      rows(value(table_)), ...
      x, y, 'position', [x y 620 200], ...
      'FontName', 'Courier', 'FontSize', 14, ...
      'saveable', 0);
    set(get_ghandle(sttable), 'BackgroundColor', [255 240 255]/255);
    SoloParamHandle(obj, 'stims', 'value', {}, 'save_with_settings', 1);
    set_callback(stims, {mfilename, 'display_table'; ...
        mfilename, 'check_norm'});
    set_callback_on_load(stims, 1);
    set_callback(sttable, {mfilename, 'sttable'});


    y = y+210;
    HeaderParam(obj, 'panel_title', 'Sound Stimulus Pairs', x, y, ...
    'position', [x y 140 20]);
    set(get_ghandle(panel_title), 'BackgroundColor', [215 190 200]/255);

    MenuParam(obj, 'sounds_type', {'Bups (Hz)', 'Pure Tones (KHz)', 'S Bups (Hz)'}, 1, x, y, ...
    'position', [x+145 y 200 20], ...
    'TooltipString', sprintf(['\nselects whether stimuli in the sounds panel' ...
    '\nare Bups or Pure Tones']), 'labelfraction', 0.4, 'labelpos', 'left');
    set_callback(sounds_type, {mfilename, 'make_sounds'});      
    PushbuttonParam(obj, 'normal', x, y, 'position', [x+360 y 100 20], ...
      'label', 'Normalize PProb', ...
      'TooltipString', 'Normalizes the PProb (prior probabilities) column so that it sums to unity \nWhen RED, the sum is incorrect and this button needs to be pressed!'); 
    PushbuttonParam(obj, 'fsave', x, y, 'position', [x+460 y 80 20], ...
      'label', 'Save to File', ...
      'TooltipString', 'not yet implemented');
    PushbuttonParam(obj, 'fload', x, y, 'position', [x+540 y 80 20], ...
      'label', 'Load from File',...
      'TooltipString', 'not yet implemented');
    set_callback(normal, {mfilename, 'normalize'});
    

    
    SoloParamHandle(obj, 'go_flg', 'value', 0);
    set(get_ghandle(message), 'BackgroundColor', 'r');
    

    feval(mfilename, obj, 'show_hide');                     
                         
    figure(fig);
    x = origfig_xy(1); y = origfig_xy(2);

% ---------------------------------------------------------------------
%
%          N_STIMULUS_CYCLES
%
% ---------------------------------------------------------------------
  case 'n_stimulus_cycles',
      if n_stimulus_cycles < 1, n_stimulus_cycles.value = 1; end; 
      
      
% ---------------------------------------------------------------------
%
%          STIMTIMESTART
%
% ---------------------------------------------------------------------
  case 'StimTimeStart',
      if StimTimeStart == 0,
          disable(FromAnswerPoke);
          enable(n_stimulus_cycles);
      else
          enable(FromAnswerPoke);
          disable(n_stimulus_cycles);
      end;
      
      feval(mfilename, obj, 'make_sounds'); 

   
% ---------------------------------------------------------------------
%
%          DISPLAY_TABLE
%
% ---------------------------------------------------------------------
  case 'display_table',
      if isempty(stims), return; end;
      
      temp = value(table_);
      temp = temp(1);
      for k = 1:rows(stims),
          frq = stims{k,2};
          dur = stims{k,3};
          newrow = format_newrow(obj, stims{k,5}, stims{k,1}, frq(1), dur(1), ...
              frq(2), dur(2), stims{ k,4});
          temp = [temp; cell(1,1)];
          temp{end} = newrow;
      end;     
      table_.value = temp;
      
      set(get_ghandle(sttable), 'string', value(table_));
      sttable.value = length(value(table_));

% ---------------------------------------------------------------------
%
%          STTABLE
%
% ---------------------------------------------------------------------
  case 'sttable',
      n = get(get_ghandle(sttable), 'value');
      n = n(1);
      if n==1, return; end;  %if the label row was selected, do nothing
      k = n-1;
      
      frq = stims{k,2};
      dur = stims{k,3};
      pprob.value  = stims{k,5};
      side.value   = stims{k,1};
      f1_frq.value = frq(1);
      f1_dur.value = dur(1);
      f2_frq.value = frq(2);
      f2_dur.value = dur(2);
      wtr_ml.value = stims{k,4};
     
% ---------------------------------------------------------------------
%
%          SIDE
%
% ---------------------------------------------------------------------
  case 'side',
      side.value = lower(value(side)); %convert to upper case
      if length(value(side)) > 1 || ~(strcmp(value(side),'l') || strcmp(value(side),'r')),
          msgbox('Enter ''r'' or ''l'' for the side parameter!', 'Warning');
          return;
      end;
      
      
% ---------------------------------------------------------------------
%
%          PPROB
%
% ---------------------------------------------------------------------
  case 'pprob',
      if pprob > 1, pprob.value = 1; 
      elseif pprob < 0, pprob.value = 0;
      end;
      
% ---------------------------------------------------------------------
%
%          SET
%
% ---------------------------------------------------------------------
  case 'set',
      if nargin < 5,
          warning('STIMULUSSECTION:Invalid', 'not enough arguments for ''set'' action');
          return;
      end;
      modified_snd_ids = [];

      while ~isempty(varargin),
        snd_id = varargin{1};
        param = varargin{2};
        newvalue = varargin{3};
        varargin = varargin(4:end);
        if rem(length(varargin),3) ~= 0,
          warning('STIMULUSSECTION:Invalid', 'wrong # of args for action ''set''');
          varargin = {};
        end;
      
        if snd_id > rows(stims),
          warning('STIMULUSSECTION:Invalid', 'Sound %d does not exist!', snd_id);
          return;
        end;
      
        switch param,
          case 'side',
            stims{snd_id,1} = newvalue;

          case 'f1_frq',
            frq = stims{snd_id,2};
            stims{snd_id, 2} = [newvalue frq(2)];

          case 'f1_dur',
            dur = stims{snd_id, 3};
            stims{snd_id, 3} = [newvalue dur(2)];

          case 'f2_frq',
            frq = stims{snd_id,2};
            stims{snd_id, 2} = [frq(1) newvalue];

          case 'f2_dur',
            dur = stims{snd_id, 3};
            stims{snd_id, 3} = [dur(1) newvalue];

          case 'wtr_ml',
            stims{snd_id, 4} = newvalue;

          case 'pprob',
            stims{snd_id, 5} = newvalue;

          otherwise,
            error([param 'does not exist!']);
        end;
        modified_snd_ids = [modified_snd_ids ; snd_id];
      end;
      
      feval(mfilename, obj, 'display_table');
      feval(mfilename, obj, 'check_norm');
      modified_snd_ids = unique(modified_snd_ids);
      for i=1:length(modified_snd_ids),
        feval(mfilename, obj, 'make_sounds', modified_snd_ids(i));
      end;
   
% ---------------------------------------------------------------------
%
%          GET
%
% ---------------------------------------------------------------------   
  case 'get',
      if nargin==3
        switch varargin{1},
          case 'nstims',
            x = size(value(stims),1); %#ok<NODEF>
          case 'all_sides',
            x = stims(:,1);
          otherwise,
            warning('EXTENDEDSTIMULUS:StimulusSection', 'Don''t know how to ''get'' %s', varargin{1});
            x = [];
        end;
        return;
      end;
      
      if nargin < 4,
          warning('EXTENDEDSTIMULUS:StimulusSection', 'not enough arguments for ''get'' action');
          return;
      end;
      
      snd_id = varargin{1};
      param = varargin{2};
      
      switch param,
          case 'side',
              x = stims{snd_id,1};
              
          case 'f1_frq',
              frq = stims{snd_id,2};
              x = frq(1);
              
          case 'f1_dur', 
              dur = stims{snd_id, 3};
              x = dur(1);
              
          case 'f2_frq',
              frq = stims{snd_id,2};
              x = frq(2);
              
          case 'f2_dur', 
              dur = stims{snd_id, 3};
              x = dur(2);
              
          case 'wtr_ml',
              x = stims{snd_id, 4};
              
          case 'pprob',
              x = stims{snd_id, 5};
              
          otherwise,
              error([param 'does not exist!']);
      end;
      
      
% ---------------------------------------------------------------------
%
%          ADD_PAIR
%
% ---------------------------------------------------------------------
  case 'add_pair',
      side.value = lower(value(side)); %convert to lower case
      if length(value(side)) > 1 || ~(strcmp(value(side),'l') || strcmp(value(side),'r')),
          msgbox('Enter ''r'' or ''l'' for the side parameter!', 'Warning');
          return;
      end;

      newrow = format_newrow(obj, value(pprob), value(side), value(f1_frq), value(f1_dur), ...
          value(f2_frq), value(f2_dur), value(wtr_ml));
      table_.value = [value(table_); cell(1,1)];  % make empty row where newrow will go
      table_{rows(table_)} = newrow;

      set(get_ghandle(sttable), 'string', value(table_));
      sttable.value = length(value(table_));
      
      if ~isempty(stims),
          new = rows(stims)+1;
      else
          new = 1;
      end;
      
      stims.value = [value(stims); cell(1, 5)];
      stims{new,1} = value(side);
      stims{new,2} = [value(f1_frq) value(f2_frq)];
      stims{new,3} = [value(f1_dur) value(f2_dur)];
      stims{new,4} = value(wtr_ml);
      stims{new,5} = value(pprob);
    
      feval(mfilename, obj, 'check_norm');
      feval(mfilename, obj, 'make_sounds');
       
% ---------------------------------------------------------------------
%
%          DELETE_PAIR
%
% --------------------------------------------------------------------- 
  case 'delete_pair',    
      n = get(get_ghandle(sttable), 'value');
      n = n(1);
      if n==1, return; end;  %if the label row was selected, do nothing
      temp = value(table_);
      table_.value = temp([1:n-1 n+1:end],:);
      
      celltable = cellstr(value(table_));
      set(get_ghandle(sttable), 'string', celltable);
      sttable.value = min(n, rows(table_));
      
      % the nth row in table corresponds to the (n-1)th row in stims
      k = n-1;
      stims.value = stims([1:k-1 k+1:rows(stims)],:);
      
      feval(mfilename, obj, 'check_norm');
      feval(mfilename, obj, 'make_sounds');
      
% ---------------------------------------------------------------------
%
%          UPDATE_PAIR
%
% ---------------------------------------------------------------------
  case 'update_pair',
      n = get(get_ghandle(sttable), 'value');
      n = n(1);
      if n==1, return; end;  %if the label row was selected, do nothing
      
      side.value = lower(value(side)); %convert to lower case
      if length(value(side)) > 1 || ~(strcmp(value(side),'l') || strcmp(value(side),'r')),
          msgbox('Enter ''r'' or ''l'' for the side parameter!', 'Warning');
          return;
      end;
      
      temp = value(table_);
      newrow = format_newrow(obj, value(pprob), value(side), value(f1_frq), value(f1_dur), ...
          value(f2_frq), value(f2_dur), value(wtr_ml));
      table_.value = [temp([1:n-1]); cell(1,1); temp(n+1:end)];
      table_{n} = newrow;
      
      set(get_ghandle(sttable), 'string', value(table_));
      sttable.value = length(value(table_));
      
      % the nth row in table corresponds to the (n-1)th row in stims
      k = n-1;
      stims{k,1} = value(side);
      stims{k,2} = [value(f1_frq) value(f2_frq)];
      stims{k,3} = [value(f1_dur) value(f2_dur)];
      stims{k,4} = value(wtr_ml);
      stims{k,5} = value(pprob);
      
      feval(mfilename, obj, 'check_norm');
      feval(mfilename, obj, 'make_sounds', k);      
      
% ---------------------------------------------------------------------
%
%          	NEXT_TRIAL_SOUND
%
% ---------------------------------------------------------------------
  case 'next_trial_sound',
      if isempty(stims), x = 0; return; end;
      
      pprobs = cell2mat(stims(:,5));
      sides  = cell2mat(stims(:,1));
      
      if nargin > 2,
          set_side = varargin{1};  % the desired side to be picked for the next trial
      else
          set_side = '';
      end;
      
      if strcmp(set_side, 'l') || strcmp(set_side, 'r'),
          sc = (sides == set_side);
          pprobs = pprobs .* sc;  % consider pprobs of the other side to be 0s.
      end;
      
      pprobs = pprobs ./ sum(pprobs);
      pprobs = cumsum(pprobs);
      
      x = find(pprobs > rand(1), 1);
      
      
% ---------------------------------------------------------------------
%
%          MAKE_SOUNDS
%
% ---------------------------------------------------------------------
  case 'make_sounds',
      if isempty(stims), return; end; %#ok<NODEF>
      
      % make silent gaps to go in between stimuli
      srate = SoundManagerSection(obj, 'get_sample_rate');
%       gap1 = 0:1/srate:value(f1f2Gap);
%       gap1 = gap1(1:(end-1));
       gap2 = 0:1/srate:value(InterCycleGap);
       gap2 = gap2(1:(end-1));
      
      if value(n_stimulus_cycles) == 1,  %#ok<NODEF>
          loop_flg = 0;
      elseif value(n_stimulus_cycles) > 1,
          loop_flg = 1;
      else
          loop_flg = 0;
          warning('What''s n_stimulus_cycles???'); %#ok<WNTAG>
      end;
      
      if nargin > 3,
          k = varargin{1};
          frq = stims{k, 2};
          dur = stims{k, 3};
          switch value(sounds_type)
            case 'Bups (Hz)'   
                snd = MakeBupperSwoop(srate, 10, frq(1), frq(2), ...
                    dur(1)*1000, dur(2)*1000, value(f1f2Gap)*1000, 0.1, ...
                    'F1_volume_factor', snd_amp, 'F2_volume_factor', snd_amp);
            case 'S Bups (Hz)'
                snd = MakeBupperSwoop(srate, 10, frq(1), frq(2), ...
                    dur(1)*1000, dur(2)*1000, value(f1f2Gap)*1000, 0.1, ...
                    'F1_volume_factor', snd_amp, 'F2_volume_factor', snd_amp, ...
                    'bup_width', 3);
            case 'Pure Tones (KHz)'
                snd = MakeSigmoidSwoop3(srate, 10, frq(1)*1000, frq(2)*1000, ...
                dur(1)*1000, dur(2)*1000, value(f1f2Gap)*1000, 0.1, 3, ... 
                'F1_volume_factor', snd_amp, 'F2_volume_factor', snd_amp);
            otherwise
              error('StimulusSection:Invalid', 'Don''t know how to make sounds type %s', value(sounds_type));
          end;

          snd = [snd zeros(1, length(gap2))];
          snd = [snd; snd]; % make stereo
          
          if ~SoundManagerSection(obj, 'sound_exists', sprintf('Sound%d', k)),
              SoundManagerSection(obj, 'declare_new_sound', sprintf('Sound%d', k));
              SoundManagerSection(obj, 'set_sound', sprintf('Sound%d', k), snd, loop_flg);
          else
              snd_prev = SoundManagerSection(obj, 'get_sound', sprintf('Sound%d', k));
              if ~isequal(snd, snd_prev),
                  SoundManagerSection(obj, 'set_sound', sprintf('Sound%d', k), snd, loop_flg);
              end;
          end;
      else
          for k = 1:rows(stims),
              frq = stims{k, 2};
              dur = stims{k, 3};
              switch value(sounds_type)
                case 'Bups (Hz)'   
                    snd = MakeBupperSwoop(srate, 10, frq(1), frq(2), ...
                        dur(1)*1000, dur(2)*1000, value(f1f2Gap)*1000, 0.1, ...
                        'F1_volume_factor', snd_amp, 'F2_volume_factor', snd_amp);
                case 'S Bups (Hz)'
                    snd = MakeBupperSwoop(srate, 10, frq(1), frq(2), ...
                        dur(1)*1000, dur(2)*1000, value(f1f2Gap)*1000, 0.1, ...
                        'F1_volume_factor', snd_amp, 'F2_volume_factor', snd_amp, ...
                        'bup_width', 3);
                case 'Pure Tones (KHz)'
                    snd = MakeSigmoidSwoop3(srate, 10, frq(1)*1000, frq(2)*1000, ...
                    dur(1)*1000, dur(2)*1000, value(f1f2Gap)*1000, 0.1, 3, ... 
                    'F1_volume_factor', snd_amp, 'F2_volume_factor', snd_amp);
                otherwise
                  error('StimulusSection:Invalid', 'Don''t know how to make sounds type %s', value(sounds_type));
              end;

              snd = [snd zeros(1, length(gap2))];
              snd = [snd; snd]; % make stereo

              if ~SoundManagerSection(obj, 'sound_exists', sprintf('Sound%d', k)),
                  SoundManagerSection(obj, 'declare_new_sound', sprintf('Sound%d', k));
                  SoundManagerSection(obj, 'set_sound', sprintf('Sound%d', k), snd, loop_flg);
              else
                  snd_prev = SoundManagerSection(obj, 'get_sound', sprintf('Sound%d', k));
                  if ~isequal(snd, snd_prev),
                      SoundManagerSection(obj, 'set_sound', sprintf('Sound%d', k), snd, loop_flg);
                  end;
              end;
          end;

          % if there's an extra sound declared, delete it
          SoundManagerSection(obj, 'delete_sound', sprintf('Sound%d', rows(stims)+1));
      end;
% ---------------------------------------------------------------------
%
%          CHECK_NORM
%
% ---------------------------------------------------------------------
  case 'check_norm',
      go_flg.value = 1;  % assume all system go
      if isempty(stims),  % if no sounds defined
          message.value = 'No sounds defined!!';
          set(get_ghandle(message), 'BackgroundColor', 'r');
          go_flg.value = 0;
          return;
      end;
      
      prb = cell2mat(stims(:,5));
      if sum(prb) == 1, 
          set(get_ghandle(normal), 'BackgroundColor', [30 200 30]/255);
      else % if pprob's do not sum to unity
          set(get_ghandle(normal), 'BackgroundColor', 'r');
          message.value = 'PProb does not sum to 1';
          set(get_ghandle(message), 'BackgroundColor', 'r');
          go_flg.value = 0;
          return;
      end;
      
      s = cell2mat(stims(:,1));
      if all(s == 'l'),  % if all choices are left
          message.value = 'No right choices defined!!';
          set(get_ghandle(message), 'BackgroundColor', 'r');
          go_flg.value = 0;
      elseif all(s == 'r'), % if all choices are right
          message.value = 'No left choices defined!!';
          set(get_ghandle(message), 'BackgroundColor', 'r');
          go_flg.value = 0;
      end;
      
      if value(go_flg),
          message.value = 'All Sounds Valid';
          set(get_ghandle(message), 'BackgroundColor', 'g');
      end;
      
% ---------------------------------------------------------------------
%
%          GET_GO_FLG
%
% ---------------------------------------------------------------------
  case 'get_go_flg',
      x = value(go_flg);  
      
% ---------------------------------------------------------------------
%
%          NORMALIZE
%
% ---------------------------------------------------------------------
  case 'normalize',
      if ~isempty(stims),
          normalize_pprob(obj, stims);
      else
          warning('No sounds defined');
      end;
      feval(mfilename, obj, 'display_table');
      feval(mfilename, obj, 'check_norm');
      
% ---------------------------------------------------------------------
%
%          PLAY_SOUND
%
% ---------------------------------------------------------------------
  case 'play_sound',
      n = get(get_ghandle(sttable), 'value'); % get selected row
      n = n(1);
      if n==1, return; end;  %if the label row was selected, do nothing
      k = n-1;
      
      SoundManagerSection(obj, 'play_sound', sprintf('Sound%d', k));
      
% ---------------------------------------------------------------------
%
%          STOP_SOUND
%
% ---------------------------------------------------------------------
  case 'stop_sound',
      n = get(get_ghandle(sttable), 'value'); % get selected row
      n = n(1);
      if n==1, return; end;  %if the label row was selected, do nothing
      k = n-1;
      
      SoundManagerSection(obj, 'stop_sound', sprintf('Sound%d', k));
      
% ---------------------------------------------------------------------
%
%          GET_N_SOUND_PAIRS
%
% ---------------------------------------------------------------------
  case 'get_n_sound_pairs',
      x = rows(stims);
      
% ---------------------------------------------------------------------
%
%          SHOW_HIDE
%
% ---------------------------------------------------------------------

  case 'hide',
    soundtable_show.value_callback = 0; 
    
  case 'show_hide',
    if soundtable_show == 1, set(value(soundtablefig), 'Visible', 'on'); 
    else                     set(value(soundtablefig), 'Visible', 'off');
    end;
    
    
% ---------------------------------------------------------------------
%
%          CLOSE
%
% ---------------------------------------------------------------------
  case 'close'   
    % delete all sounds this plugin set  
    if ~isempty(stims),  
        for k = 1:rows(stims),
            SoundManagerSection(obj, 'delete_sound', sprintf('Sound%d', k));
        end;
    end;
    % delete everything

    if ishandle(value(soundtablefig)) delete(value(soundtablefig)); end;
    delete_sphandle('owner', ['^@' class(obj) '$'], 'fullname', [mfilename '_']);

    
% ---------------------------------------------------------------------
%
%          REINIT
%
% ---------------------------------------------------------------------
  case 'reinit'
    currfig = double(gcf);
    
    feval(mfilename, obj, 'close');
    
    %SoundManagerSection(obj, 'delete_sound', 'sound_stimulus');

    figure(currfig);

        
  otherwise
    warning('%s : action "%s" is unknown!', mfilename, action); %#ok<WNTAG> (This line OK.)

end; %     end of switch action

function [stims] = normalize_pprob(obj, stims)
    prb = cell2mat(stims(:,5));
    prb = prb./sum(prb);
    
    for i = 1:rows(stims)
        stims{i,5} = prb(i);
    end;
	return;
    
function newrow = format_newrow(obj, pprob, side, f1_frq, f1_dur, f2_frq, f2_dur, water) 
    newrow = [sprintf('%5.3g   ', pprob) ' ' side ...
          sprintf('     %5.3g      %5.3g      %5.3g      %5.3g     %6.3g', ...
          f1_frq, f1_dur, f2_frq, f2_dur, water)];
    return;
