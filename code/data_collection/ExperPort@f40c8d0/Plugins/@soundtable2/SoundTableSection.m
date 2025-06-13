% [x, y] = SoundTableSection(obj, action, tname, varargin)
%
% This plugin makes a Sound Table window that manages any number of 
% stimulus sounds of arbitray types.  Each may be a single or a pair of
% sounds.  It is version two of soundtable and manages more general sounds.
%
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
%
% 'set' tablename sound_id   'pprob' | 'side' | 'wtr_mul' | ...
%                  'S1_Vol'|'S1_Bal'|'S1_Freq1'|'S1_Freq2'|'S1_FMFreq'|'S1_FMAmp'| ...
%                  'S1_Style'|'S1_Dur1'|'S1_Dur2'|'S1_Tau'|'S1_Gap'|'S1_Loop'| ...
%                  'S2_Vol'|'S2_Bal'|'S2_Freq1'|'S2_Freq2'|'S2_FMFreq'|'S2_FMAmp'| ...
%                  'S2_Style'|'S2_Dur1'|'S2_Dur2'|'S2_Tau'|'S2_Gap'|'S2_Loop'| newvalue
%        
%               The 'set' action allows setting the parameters for any of
%               the sounds in the "tablename" sound table. The next argument
%               after 'set' must be a string, identifying the table to work on; 
%               the next must be a number, identifying the row of the
%               sound table  that will be affected; the next argument
%               should be one of the strings above; and the last argument should be
%               the value the corresponding setting will be changed to.
%               Example calls:
%                 To set in table "T1", the second row's S1 frequency:
%                     SoundTableSection(SameDifferent, 'set', 'T1', 2, 'S1_Freq1', 100);
%                 or, to set several parameters in a table with a single call,
%                     SoundTableSection(SameDifferent, 'set', 'T1', 2, 'S1_Freq1', 100, 1, 'S2_Freq1', 25, ...)
%               After the tablename argument, all further triplets of
%               arguments will be interpreted as [sound_id, param, newvalue]
%               triplets.
%
%               * note *  snd_id may be a vector. In this case, newvalue
%               must be either length 1 or of length the same as snd_id.
%               This feature cannot be used if the param is 'S1_Style' or
%               'S2_Style'; in the latter case, length(snd_id) must be 1. 
%				snd_id may be the string 'all', in which case it is
%				converted to a vector of all snd_ids.
%
%
% 'set_tableparam' tablename 'Gap1'|'Gap2'|'loop'|'HitFracTau'|'BiasTau'|'Beta'  newvlue
%
%               The 'set_tableparam' action allows setting the value of
%               parameters that affect all sounds in a table, or affect
%               the antibias portion of a table. The next argument
%               after 'set_tableparam' must be a string, identifying the
%               table to work on; the next argument should be one of the
%               strings above; and the last argument should be the value
%               the corresponding setting will be changed to.
%
%
% 'get' tablename sound_id   'pprob' | 'side' | 'wtr_mul' | ...
%                  'S1_Vol'|'S1_Bal'|'S1_Freq1'|'S1_Freq2'|'S1_FMFreq'|'S1_FMAmp'| ...
%                  'S1_Style'|'S1_Dur1'|'S1_Dur2'|'S1_Tau'|'S1_Gap'|'S1_Loop'| ...
%                  'S2_Vol'|'S2_Bal'|'S2_Freq1'|'S2_Freq2'|'S2_FMFreq'|'S2_FMAmp'| ...
%                  'S2_Style'|'S2_Dur1'|'S2_Dur2'|'S2_Tau'|'S2_Gap'|'S2_Loop'
%
%               The 'get' action is just like 'set', but no newvalue is
%               passed; instead, the current value is returned.
%
%
% 'get_tableparam' tablename 'Gap1'|'Gap2'|'loop'|'HitFracTau'|'BiasTau'|'Beta' 
%
%               The 'get_tableparam' action is just like 'set_tableparam',
%               but no newvalue is passed; instead, the current value is
%               returned.
%


% BWB, May. 2008




function [x, y] = SoundTableSection(obj, action, tname, varargin)

GetSoloFunctionArgs(obj);

switch action,
    
%% init    
  case 'init'
    if length(varargin) < 2,
      error('Need at least two arguments, x and y position, to initialize %s', mfilename);
    end;
    x = varargin{1}; y = varargin{2};
    
    if SoundTableSection(obj, 'table_exists', tname),
        warning('Plugins:SoundTable:SoundExists', ['The table named ' tname ' already exists!']);
        return;
    end;

    SoloParamHandle(obj, [tname 'my_gui_info'], 'value', [x y double(gcf)]);
    
    
    ToggleParam(obj, [tname 'soundtable_show'], 0, x, y, ...
       'OnString', ['Sound Table ' tname ' Showing'], ...
       'OffString',['Sound Table ' tname ' Hidden'], ...
       'TooltipString', 'Show/Hide Sound Table window'); next_row(y);
    set_callback(eval([tname 'soundtable_show']), {mfilename, 'show_hide', tname;}); 
    
    screen_size = get(0, 'ScreenSize'); fig = double(gcf);
    SoloParamHandle(obj, [tname 'soundtablefig'], ...
        'value', double(figure('Position', [200 screen_size(4)-740, 700 500], ...
        'closerequestfcn', [mfilename '(' class(obj) ', ''hide'', ''' tname ''');'], 'MenuBar', 'none', ...
        'NumberTitle', 'off', 'Name', ['Sound Table ' tname])), 'saveable', 0);
    origfig_xy = [x y]; 
    
    x = 10; y = 10;
    ToggleParam(obj, [tname 'loop'], 1, x, y, 'position', [x y 50 20], ...
        'label', 'loop', ...
        'OnString', 'loop', ...
        'OffString', 'no loop', ...
        'TooltipString', 'whether or not sounds are looped (has no effect if sound1 and sound2 are triggered separately)');
    PushbuttonParam(obj, [tname 'play_snd'], x, y, 'position', [x+530 y 80 20], ...
      'label', 'Play');
    PushbuttonParam(obj, [tname 'stop_snd'], x, y, 'position', [x+610 y 80 20], ...
      'label', 'Stop');
    set_callback(eval([tname 'play_snd']), {mfilename, 'play_sound', tname});
    set_callback(eval([tname 'stop_snd']), {mfilename, 'stop_sound', tname});
    next_row(y);

    % the sph 'table' holds the rows of the stable as a character
    % array
    %
    % 'sttable' is the gui that displays what's held in table
    %
    % 'stims' is a cell array that stores all the stimulus pairs in
    % use in a reasonable format
    % Each row in stims is one sound (or sound pair).
    % The columns are as follows:
    %   1       2       3       4           5
    %   pprob   side    wtr_mul s1_saved    s2_saved
    %
    % 1. pprob is the prior probability of this sound being selected
    % 2. side is the correct side choice
    % 3. wtr_mul is a number that is multiplied by the water valve time
    %      when this sound is being played, which allows us to give more or
    %      less water for specific stimli
    % 4. s1_saved is a struct that stores the names and values of the 
    %      soloparam handles which, when loaded into SoundInterface, will 
    %      generate s1.
    % 5. s2_saved is much like s1_saved, except that it may be empty when
    %      only one sound is defined
    
    SoloParamHandle(obj, [tname 'table'], 'value', ...
      {'PProb R/L Wtr  S1                               S2'}, ...
      'saveable', 0);
    ListboxParam(obj, [tname 'sttable'], eval(['value(' tname 'table)']), ...
      rows(eval(['value(' tname 'table)'])), ...
      x, y, 'position', [x y 680 200], ...
      'FontName', 'Courier', 'FontSize', 13, ...
      'saveable', 0);
    set(get_ghandle(eval([tname 'sttable'])), 'BackgroundColor', [255 240 255]/255);
    SoloParamHandle(obj, [tname 'stims'], 'value', {}, 'save_with_settings', 1);
    set_callback(eval([tname 'stims']), {mfilename, 'display_table', tname; ...
                                         mfilename, 'check_norm', tname;...
										 mfilename, 'make_sounds',tname});
    set_callback_on_load(eval([tname 'stims']), 1);
    set_callback(eval([tname 'sttable']), {mfilename, 'sttable', tname});


    x = 10; y = y+200;
    ToggleParam(obj, [tname 'two_sounds'], 1, x, y, 'position', [x y 100 20], ...
        'label', 'two_sounds', ...
        'OnString', '2 Sounds', ...
        'OffString', '1 Sound', ...
        'TooltipString', 'Allows 1 or 2 stimuli to be defined as part of the current sound');
    PushbuttonParam(obj, [tname 'add'], x, y, 'position', [x+100 y 100 20], ...
        'label', 'Add Sound');
    PushbuttonParam(obj, [tname 'del'], x, y, 'position', [x+200 y 100 20], ...
        'label', 'Delete Sound');
    PushbuttonParam(obj, [tname 'up'], x, y, 'position', [x+300 y 100 20], ...
        'label', 'Update Sound', ...
        'TooltipString', 'Replaces the currently selected row with new specifications');
    set_callback(eval([tname 'two_sounds']), {mfilename, 'two_sounds', tname});
    set_callback(eval([tname 'add']), {mfilename, 'add_sound', tname});
    set_callback(eval([tname 'del']), {mfilename, 'delete_sound', tname});
    set_callback(eval([tname 'up']),  {mfilename, 'update_sound', tname});

    
    NumeditParam(obj, [tname 'Gap1'], 0, x, y, 'position', [x+450 y 100 20], ...
        'label', 'Gap1', ...
        'HorizontalAlignment', 'center', ...
        'labelfraction', 0.4, ...
        'TooltipString', 'Pause, in sec, between S1 and S2');
    NumeditParam(obj, [tname 'Gap2'], 0, x, y, 'position', [x+550 y 100 20], ...
        'label', 'Gap2', ...
        'HorizontalAlignment', 'center', ...
        'labelfraction', 0.4, ...
        'TooltipString', 'Pause, in sec, between end of S2 and between of next cycle');
    set_callback({eval([tname 'Gap1']), eval([tname 'Gap2'])}, {mfilename, 'gaps', tname});
    
    x = 10; y = y+25;
    
    SoundInterface(obj, 'add', [tname 'S1'], x, y);
    SoundInterface(obj, 'add', [tname 'S2'], x+205, y);
    
    % antibias stuff
    LogsliderParam(obj, [tname 'HitFracTau'], 30, 10, 400, x, y, 'position', [x+420 y 200 20], ...
        'label', 'hits frac tau', ...
        'TooltipString', 'Number of trials back over which to compute fraction correct (display only)');
    set_callback(eval([tname 'HitFracTau']), {mfilename, 'update_hitfrac', tname});
    DispParam(obj, [tname 'LtHitFrac'], 0, x, y, 'position', [x+420 y+20 200 20], ...
        'label', 'LtHitFrac');
    DispParam(obj, [tname 'RtHitFrac'], 0, x, y, 'position', [x+420 y+40 200 20], ...
        'label', 'RtHitFrac');
    DispParam(obj, [tname 'HitFrac']  , 0, x, y, 'position', [x+420 y+60 200 20], ...
        'label', 'HitFrac');
    LogsliderParam(obj, [tname 'BiasTau'], 30, 10, 400, x, y, 'position', [x+420 y+90 200 20], ...
        'label', 'antibias tau', ...
        'TooltipString', 'Number of trials back over which to compute antibias function');
    NumeditParam(obj, [tname 'Beta'], 0, x, y, 'position', [x+420 y+110 200 20], ...
        'label', 'Beta', ...
        'TooltipString', 'Antibias weight.  0 mean past performance has no effect on next trial.');
    set_callback({eval([tname 'BiasTau']), eval([tname 'Beta'])}, {mfilename, 'update_biashitfrac', tname});
    DispParam(obj, [tname 'BiasHitFrac'], 0, x, y, 'position', [x+420 y+140 250 20], ...
        'label', 'BiasHitFrac', ...
        'labelfraction', 0.3);
    DispParam(obj, [tname 'ChoicesProb'], 0, x, y, 'position', [x+420 y+160 250 20], ...
        'label', 'ChoicesProb', ...
        'labelfraction', 0.3);
    DispParam(obj, [tname 'PriorProb'], 0, x, y, 'position', [x+420 y+180 250 20], ...
        'label', 'PriorProb', ...
        'labelfraction', 0.3);
    SoloParamHandle(obj, [tname 'LocalHitHistory'], 'value', []);
    SoloParamHandle(obj, [tname 'LocalPrevSides'], 'value', []);
    SoloParamHandle(obj, [tname 'LocalPrevSounds'], 'value', []);
    
    
    x = 10; y = y+145; % skip 7 rows to allow for the soundui's
    NumeditParam(obj, [tname 'pprob'], 1, x, y, 'position', [x y 100 20], ...
        'label', 'pprob', ...
        'HorizontalAlignment', 'center', ...
        'TooltipString', 'the prior probability of choosing this sound row');
    EditParam(obj, [tname 'side'], 'l', x, y, 'position', [x+100 y 100 20], ...
        'label', 'side', ...
        'HorizontalAlignment', 'center', ...
        'TooltipString', 'the correct side response for this sound row');
    NumeditParam(obj, [tname 'wtr_mul'], 1, x, y, 'position', [x+200 y 100 20], ...
        'label', 'wtr_mul', ...
        'HorizontalAlignment', 'center', ...
        'TooltipString', 'water reward multiplier, allows more or less water to be given for this particular row');
    set_callback(eval([tname 'pprob']), {mfilename, 'pprob', tname});
    set_callback(eval([tname 'side']), {mfilename, 'side', tname});
    
    
    % top, title row
    x = 10; y = 475;
    HeaderParam(obj, [tname 'panel_title'], ['Sound Table v2: ' tname], x, y, ...
    'position', [x y 200 20]);
    set(get_ghandle(eval([tname 'panel_title'])), 'BackgroundColor', [215 190 200]/255);
    SubheaderParam(obj, [tname 'panel_message'], 'no sounds defined', x, y, 'position', [x+200 y 150 20]);
    set(get_ghandle(eval([tname 'panel_message'])), 'BackgroundColor', [255 10 10]/255);
    
    PushbuttonParam(obj, [tname 'normal'], x, y, 'position', [x+420 y 100 20], ...
      'label', 'Normalize PProb', ...
      'TooltipString', 'Normalizes the PProb (prior probabilities) column so that it sums to unity \nWhen RED, the sum is incorrect and this button needs to be pressed!'); 
    set_callback(eval([tname 'normal']), {mfilename, 'normalize', tname});
    PushbuttonParam(obj, [tname 'fsave'], x, y, 'position', [x+520 y 80 20], ...
      'label', 'Save to File', ...
      'TooltipString', 'saves defined sounds to .mat file');
    PushbuttonParam(obj, [tname 'fload'], x, y, 'position', [x+600 y 80 20], ...
      'label', 'Load from File',...
      'TooltipString', 'loads saved sounds from file');
    set_callback(eval([tname 'fsave']), {mfilename, 'fsave', tname});
    set_callback(eval([tname 'fload']), {mfilename, 'fload', tname});

    % go_flag keeps track of whether the sounds defined in the table are
    % valid and suitable for playing
    SoloParamHandle(obj, 'go_flag', 'value', 0);
    
    feval(mfilename, obj, 'show_hide', tname);                     
                         
    figure(fig);
    x = origfig_xy(1); y = origfig_xy(2);

   
    
    
%% table_exists
  case 'table_exists'
      try
          stims = eval([tname 'stims']); %#ok<NASGU>
          x = 1;
          return;
      catch
          x = 0;
          return;
      end;
      
%% display_table
  case 'display_table',
      if isempty(eval([tname 'stims'])), return; end;
      
      stims = eval([tname 'stims']);
      for k = 1:rows(stims),
          S1_saved = stims{k,4};
          S2_saved = stims{k,5};
          % backwards compatibility, saved sounds may be cell arrays
          if iscell(S1_saved), 
              S1_saved = cell2struct(S1_saved(:,2)', S1_saved(:,1)', 2);
              stims{k, 4} = S1_saved;
          end
          if ~isempty(S2_saved) && iscell(S2_saved),
              S2_saved = cell2struct(S2_saved(:,2)', S2_saved(:,1)', 2);
              stims{k, 5} = S2_saved;
          end
      end;
      temp = value(eval([tname 'table']));
      temp = temp(1);
      for k = 1:rows(stims),
          newrow = format_newrow(stims(k,:));
          temp = [temp; cell(1,1)];
          temp{end} = newrow;
      end;
      table = eval([tname 'table']);
      table.value = temp;
      
      sttable = eval([tname 'sttable']);
      set(get_ghandle(sttable), 'string', value(table));
      sttable.value = length(value(table));

      % --- From R2009a on, Matlab checks ListboxTop values.
      %     When we load with fewer sounds than before, this can get
      %     get out of sync; check that it is within bounds.
      try
         matlab_version = version('-release');
         matlab_version = str2double(matlab_version(1:4));
         if matlab_version >= 2009,
            if length(value(table)) < get(get_ghandle(sttable), 'ListboxTop'),
               set(get_ghandle(sttable), 'ListboxTop', 1);
            end;
         end;
      catch %#ok<CTCH>
      end;
      % --- end ListboxTop checking.
      % Now make sure the SoundInterface GUI matches what is being shown in
      % the table:
      feval(mfilename, obj, 'sttable', tname);

%% sttable
% evaluates when a row in the table is clicked
  case 'sttable',
      sttable_handle = eval([tname 'sttable']);
      n = get(get_ghandle(sttable_handle), 'value');
      n = n(1);
      if n==1, return; end;  %if the label row was selected, do nothing
      k = n-1;
      
      stims = eval([tname 'stims']);
      pprob = eval([tname 'pprob']);
      side  = eval([tname 'side']);
      wtr_mul = eval([tname 'wtr_mul']);
      pprob.value   = stims{k,1};
      side.value    = stims{k,2};
      wtr_mul.value = stims{k,3};
      
      stims = eval([tname 'stims']); 
      SoundInterface(obj, 'load_from_struct', [tname 'S1'], stims{k,4}); % load S1
      if isempty(stims{k,5}),
          two_sounds = eval([tname 'two_sounds']);
          two_sounds.value = 0;
          feval(mfilename, obj, 'two_sounds', tname);
      else
          SoundInterface(obj, 'load_from_struct', [tname 'S2'], stims{k,5});
          two_sounds = eval([tname 'two_sounds']);
          two_sounds.value = 1;
          feval(mfilename, obj, 'two_sounds', tname);
      end;
      
      if ~SoundManagerSection(obj, 'sound_exists', [tname sprintf('Sound%dS1', k)]),
          feval(mfilename, obj, 'make_sounds', tname);
      end;
      
      % assembles the currently selected sound so we can play it and hear
      % what it would be like when we click on the Play button
      snd1 = SoundManagerSection(obj, 'get_sound', [tname sprintf('Sound%dS1', k)]);
      snd2 = SoundManagerSection(obj, 'get_sound', [tname sprintf('Sound%dS2', k)]);
      % make silent gaps to go in between stimuli
      srate = SoundManagerSection(obj, 'get_sample_rate');
      gap1 = 0:1/srate:eval(['value(' tname 'Gap1)']);
      gap1 = zeros(2, size(gap1,2)-1); 
      gap2 = 0:1/srate:eval(['value(' tname 'Gap1)']);
      gap2 = zeros(2, size(gap2,2)-1); 
      
      if ~SoundManagerSection(obj, 'sound_exists', 'CurrentSound'),
          SoundManagerSection(obj, 'declare_new_sound', 'CurrentSound');
          SoundManagerSection(obj, 'set_sound', 'CurrentSound', [snd1 gap1 snd2 gap2], eval(['value(' tname 'loop)']));
      else
          SoundManagerSection(obj, 'set_sound', 'CurrentSound', [snd1 gap1 snd2 gap2], eval(['value(' tname 'loop)']));
      end;
     
%% side
  case 'side',
      side = eval([tname 'side']);
      side.value = lower(value(side)); %convert to upper case
      if length(value(side)) > 1 || ~(strcmp(value(side),'l') || strcmp(value(side),'r')),
          msgbox('Enter ''r'' or ''l'' for the side parameter!', 'Warning');
          return;
      end;
      
%% pprobe
  case 'pprob',
      pprob = eval([tname 'pprob']);
      if pprob > 1, pprob.value = 1; 
      elseif pprob < 0, pprob.value = 0;
      end;
      
%% get_gap_durations
  case 'get_gap_durations',
      x = eval(['value(' tname 'Gap1)']);
      y = eval(['value(' tname 'Gap2)']);
      
      
%% set
  case 'set',
      if length(varargin) < 3,
          warning('SOUNDTABLESECTION:Invalid', 'Not enough arguments for ''set'' action');
          return;
      end;

      stims = eval([tname 'stims']);
      list_of_sounds_to_make = [];    % List of which sounds need to be remade.

      while ~isempty(varargin),
        snd_id   = varargin{1};
        param    = varargin{2};
        newvalue = varargin{3};
		
		% if the snd_id is 'all', apply the update to all sounds.
		if strcmpi('all',snd_id)
			snd_id=1:rows(stims);
		end


        % --- Make sure newvalue and snd_id are of the same size ---
        if ~strcmp(param, 'S1_Style') && ~strcmp(param, 'S2_Style'),
		  if length(snd_id)~=length(newvalue),
            if length(newvalue)==1, newvalue = ones(size(snd_id))*newvalue; 
            else
              warning('SOUNDTABLESECTION:Invalid', 'If length(snd_id)~=length(newvalue), then length(newvalue) must be 1');
              return;
            end;
          end;
        else
          if length(snd_id)~=1.
            warning('SOUNDTABLESECTION:Invalid', 'for param=S1_Style or S2_Style, snd_id must be length 1');
            return;
          end;
        end;
        % ---------------

        
        % Now loop through each snd_id requested.
        for i = 1:numel(snd_id),
          if snd_id(i) > rows(stims),
            warning('SOUNDTABLESECTION:Invalid', 'Sound%d does not exist, newvalue could not be set.', snd_id(i));
            break;
          end;

          switch param,
            % --First the case where the parameter controls the nature of the sound
            case {'S1_Vol', 'S1_Bal', 'S1_Freq1', 'S1_Freq2', 'S1_FMFreq', 'S1_FMAmp', ...
                'S1_Dur1', 'S1_Dur2' 'S1_tau', 'S1_Gap', 'S1_Loop', ...
                'S2_Vol', 'S2_Bal', 'S2_Freq1', 'S2_Freq2', 'S2_FMFreq', 'S2_FMAmp',  ...
                'S2_Dur1', 'S2_Dur2' 'S2_tau', 'S2_Gap', 'S2_Loop'}, 

              soundname = param(1:2);
              sparam     = param(4:end);
              first_or_second_sound = str2double(soundname(2));
              stims{snd_id(i), 3+first_or_second_sound}.(sparam) = newvalue(i);                

              list_of_sounds_to_make = [list_of_sounds_to_make ; snd_id(i)];

            case {'S1_Style', 'S2_Style'}, % These two are like the prev case but need special treatment because the value is a string

              soundname = param(1:2);
              sparam     = param(4:end);
              first_or_second_sound = str2double(soundname(2));
              stims{snd_id(i), 3+first_or_second_sound}.(sparam) = newvalue;                

              list_of_sounds_to_make = [list_of_sounds_to_make ; snd_id(i)];
              
            case {'pprob', 'side', 'wtr_mul'}, % -- A parameter that doesn't control the sound itself                    
              switch param,
                case 'pprob',   stims{snd_id(i), 1} = newvalue(i);
                case 'side',    stims{snd_id(i), 2} = newvalue(i);
                case 'wtr_mul', stims{snd_id(i), 3} = newvalue(i);
              end
          otherwise, % Neither a soundparam, nor 'pprob', 'side', or 'wtr_mul'.
            warning('SOUNDTABLESECTION:Invalid', 'Don''t know parameter type "%s", ignoring rest of "set" call', param);
            return;
          end
        end;

        varargin = varargin(4:end);          
      end; % --- while ~isempty(varargin)
      
      if ~isempty(list_of_sounds_to_make),
        feval(mfilename, obj, 'make_sounds', tname, unique(list_of_sounds_to_make));
      end;
      feval(mfilename, obj, 'display_table', tname);
      feval(mfilename, obj, 'check_norm', tname);
      
      
      

%% get  
  case 'get',
      if length(varargin) < 1,
          warning('SOUNDTABLESECTION:Invalid', 'Not enough arguments for ''get'' action');
          x = [];
          return;
      end;
      
      stims = eval([tname 'stims']);      
      if isempty(stims),
          warning('SOUNDTABLESECTION:Invalid', 'No sound has been defined');
          x = 0;
          return;
      end;
      
      if length(varargin)==1,  % Asking for an overall table param
        param = varargin{1};

        switch param,
          case {'stims', 'nstims', 'all_sides', 'all_pprobs'},
            switch param,
              case 'stims',     x = value(stims);
              case 'nstims',    x = size(value(stims), 1);
              case 'all_sides', x = stims(:,2);
              case 'all_pprobs',x = stims(:,1);
            end;
          
          case {'Gap1', 'Gap2', 'loop', 'HitFracTau', 'BiasTau', 'Beta', 'PriorProb', ...
              'ChoicesProb', 'BiasHitFrac', 'HitFrac', 'RtHitFrac', 'LtHitFrac'}
            x = value(eval([tname param]));
            
        otherwise,
          warning('SOUNDTABLESECTION:Invalid', 'Don''t know how to ''get'' %s', param);
          x = [];
        end;
        
      else  % --- Asking for something from a particular sound
        if length(varargin) < 2,
          warning('SOUNDTABLESECTION:Invalid', 'Not enough arguments for ''get'' action');
          return;
        end;
        snd_id = varargin{1}; 
        param  = varargin{2};

        switch param,
          case 'pprob',   x = stims{snd_id, 1};
          case 'side',    x = stims{snd_id, 2};
          case 'wtr_mul', x = stims{snd_id, 3};

          case {'S1_Vol', 'S1_Bal', 'S1_Freq1', 'S1_Freq2', 'S1_FMFFreq', 'S1_FMAmp', 'S1_Style', ...
              'S1_Dur1', 'S1_Dur2' 'S1_tau', 'S1_Gap', 'S1_Loop', ...
              'S2_Vol', 'S2_Bal', 'S2_Freq1', 'S2_Freq2', 'S2_FMFreq', 'S2_FMAmp', 'S2_Style', ...
              'S2_Dur1', 'S2_Dur2' 'S2_tau', 'S2_Gap', 'S2_Loop'},
            
            soundname = param(1:2);
            param     = param(4:end);
            first_or_second_sound = str2double(soundname(2));
            x = stims{snd_id, 3+first_or_second_sound}.(param);
            
          otherwise,
            warning('SOUNDTABLESECTION:Invalid', 'Don''t know how to ''get'' %s', varargin{2});
            x = [];
        end;
      end;  % --- end if length(varargin)==1
      
      return;
      

%% set_tableparam

  case 'set_tableparam',
    while ~isempty(varargin),

      if length(varargin) < 2,
          warning('SOUNDTABLESECTION:Invalid', 'Not enough arguments for ''set_tableparam'' action');
          return;
      end;
      
      param = varargin{1};
      newvalue = varargin{2};

      switch param,
        case {'Gap1', 'Gap2', 'loop', 'HitFracTau', 'BiasTau', 'Beta'}
          sp = eval([tname param]);
          sp.value = newvalue;
          if ~strcmp(param, 'loop'),  % No need for callback on toggleparams
            callback(sp);
          end;
          
        otherwise,
          warning('SOUNDTABLESECTION:Invalid', 'Don''t know how to deal with parameter "%s"', param);
          return;
      end;
      
      varargin = varargin(3:end);
    end;
    

    
%% get_tableparam

  case 'get_tableparam'
    if length(varargin) ~= 1,
      warning('SOUNDTABLESECTION:Invalid', 'Wrong number of arguments for ''get'' action');
      x = [];
      return;
    end;
      
    stims = eval([tname 'stims']);
    if isempty(stims),
      warning('SOUNDTABLESECTION:Invalid', 'No sound has been defined');
      x = 0;
      return;
    end;
      
    param = varargin{1},
    switch param,
      case {'stims', 'nstims', 'allsides'},
        switch param,
          case 'stims',     x = value(stims);
          case 'nstims',    x = size(value(stims), 1);
          case 'all_sides', x = stims(:,2);
        end;
          
      case {'Gap1', 'Gap2', 'loop', 'HitFracTau', 'BiasTau', 'Beta', 'PriorProb', ...
          'ChoicesProb', 'BiasHitFrac', 'HitFrac', 'RtHitFrac', 'LtHitFrac','two_sounds'}
        x = value(eval([tname param]));
        
      otherwise,
        warning('SOUNDTABLESECTION:Invalid', 'Don''t know how to ''get'' %s', param);
        x = [];
    end;

      
%% two_sounds
  case 'two_sounds'
      two_sounds = eval([tname 'two_sounds']);
      if two_sounds,
          SoundInterface(obj, 'set_style', [tname 'S2']);
      else
          SoundInterface(obj, 'disable_all', [tname 'S2']);
      end;
      
%% add_sound
  case 'add_sound',
      side = eval([tname 'side']);
      side.value = lower(value(side)); %convert to lower case
      if length(value(side)) > 1 || ~(strcmp(value(side),'l') || strcmp(value(side),'r')),
          msgbox('Enter ''r'' or ''l'' for the side parameter!', 'Warning');
          return;
      end;

      
      S1_saved = SoundInterface(obj, 'save_to_struct', [tname 'S1']);
      if eval(['value(' tname 'two_sounds)']),
          S2_saved = SoundInterface(obj, 'save_to_struct', [tname 'S2']);
      else
          S2_saved = {};
      end;

      stims = eval([tname 'stims']);
      if ~isempty(stims),
          new = rows(stims)+1;
      else
          new = 1;
      end;
      
      stims.value = [value(stims); cell(1, 5)];
      pprob = eval([tname 'pprob']);
      side  = eval([tname 'side']);
      wtr_mul = eval([tname 'wtr_mul']);
      stims{new,1} = value(pprob);
      stims{new,2} = value(side);
      stims{new,3} = value(wtr_mul);
      stims{new,4} = S1_saved;
      stims{new,5} = S2_saved;

      newrow = format_newrow(stims(new,:));
      table = eval([tname 'table']);
      table.value = [value(table); cell(1,1)]; % make an empty row where newrow will go
      table{rows(table)} = newrow;
      
      sttable = eval([tname 'sttable']);
      set(get_ghandle(sttable), 'string', value(table));
      sttable.value = length(value(table));
      
      feval(mfilename, obj, 'check_norm', tname);
      feval(mfilename, obj, 'make_sounds', tname, new);
       
%% delete_sound
  case 'delete_sound',  
      sttable = eval([tname 'sttable']);
      n = get(get_ghandle(sttable), 'value');
      n = n(1);
      if n==1, return; end;  %if the label row was selected, do nothing
      table = eval([tname 'table']);
      temp = value(table);
      table.value = temp([1:n-1 n+1:end],:);
      
      celltable = cellstr(value(table));
      set(get_ghandle(sttable), 'string', celltable);
      sttable.value = min(n, rows(table));
      
      % the nth row in table corresponds to the (n-1)th row in stims
      k = n-1;
      stims = eval([tname 'stims']);
      stims.value = stims([1:k-1 k+1:rows(stims)],:);
      
      feval(mfilename, obj, 'check_norm', tname);
      feval(mfilename, obj, 'make_sounds', tname, k+1:rows(stims));
      
%% update_sound
  case 'update_sound',
      sttable = eval([tname 'sttable']);
      n = get(get_ghandle(sttable), 'value');
      n = n(1);
      if n==1, return; end;  %if the label row was selected, do nothing
      
      side = eval([tname 'side']);
      side.value = lower(value(side)); %convert to lower case
      if length(value(side)) > 1 || ~(strcmp(value(side),'l') || strcmp(value(side),'r')),
          msgbox('Enter ''r'' or ''l'' for the side parameter!', 'Warning');
          return;
      end;
      
      S1_saved = SoundInterface(obj, 'save_to_struct', [tname 'S1']);
      two_sounds = eval([tname 'two_sounds']);
      if two_sounds,
          S2_saved = SoundInterface(obj, 'save_to_struct', [tname 'S2']);
      else
          S2_saved = {};
      end;
      
      % the nth row in table corresponds to the (n-1)th row in stims
      k = n-1;      
      stims = eval([tname 'stims']);
      pprob = eval([tname 'pprob']);
      side  = eval([tname 'side']);
      wtr_mul = eval([tname 'wtr_mul']);      
      stims{k,1} = value(pprob);
      stims{k,2} = value(side);
      stims{k,3} = value(wtr_mul);
      stims{k,4} = S1_saved;
      stims{k,5} = S2_saved;
      
      table = eval([tname 'table']);
      temp = value(table);
      newrow = format_newrow(stims(k,:));
      table.value = [temp(1:n-1); cell(1,1); temp(n+1:end)];
      table{n} = newrow;
      
      set(get_ghandle(sttable), 'string', value(table));
      sttable.value = length(value(table));
      
      feval(mfilename, obj, 'check_norm', tname);
      feval(mfilename, obj, 'make_sounds', tname, k);      
      
      
%% gaps
  case 'gaps'
      Gap1 = eval([tname 'Gap1']);
      Gap2 = eval([tname 'Gap2']);
      if Gap1 < 0, Gap1.value = 0; end;
      if Gap2 < 0, Gap2.value = 1; end;


%% push_history
	case 'push_history'
		
		stims=eval([tname 'stims']);
		if ~isempty(stims)
			push_history(stims);
		end
%% next_trial
  case 'next_trial'
      if isempty(eval([tname 'stims'])) || go_flag == 0, %#ok<NODEF>
          warning('SOUNDTABLESECTION:Invalid', 'in the soundtable, sounds as defined are invalid; no sound will be played');
          x = 0;
          return;
      else
          if n_done_trials < 2,
              feval(mfilename, obj, 'make_sounds', tname);
          end;
          feval(mfilename, obj, 'check_norm', tname);

          LocalHitHistory = eval([tname 'LocalHitHistory']);
          LocalPrevSides = eval([tname 'LocalPrevSides']);
          LocalPrevSounds = eval([tname 'LocalPrevSounds']);
          if length(varargin) > 0, LocalHitHistory.value = varargin{1}; end;
          if length(varargin) > 1, LocalPrevSides.value  = varargin{2}; end;
          if length(varargin) > 2, LocalPrevSounds.value = varargin{3}; end;
          if isa(value(LocalHitHistory), 'SoloParamHandle'), LocalHitHistory.value = value(value(LocalHitHistory)); end;
          if isa(value(LocalPrevSides),  'SoloParamHandle'), LocalPrevSides.value  = value(value(LocalPrevSides));  end;
          if isa(value(LocalPrevSounds), 'SoloParamHandle'), LocalPrevSounds.value = value(value(LocalPrevSounds));  end;

          stims = eval([tname 'stims']);
          pprob = cell2mat(stims(:,1));
          PriorProb = eval([tname 'PriorProb']);
          PriorProb.value = pprob';

          feval(mfilename, obj, 'update_hitfrac', tname);
          if length(varargin) > 3, set_side = varargin{4};
          else                     set_side = '';
          end;
          feval(mfilename, obj, 'update_biashitfrac', tname, set_side);
          x = 1;
		  SoundTableSection(obj,'push_history',tname);
      end;
      
%% update_hitfrac
  case 'update_hitfrac'
  % these values are computed for display purposes only      
      LocalHitHistory = eval([tname 'LocalHitHistory']);
      LocalPrevSides = eval([tname 'LocalPrevSides']);
      hit_history = colvec(value(LocalHitHistory));
      PrevSides = colvec(value(LocalPrevSides));
      HitFracTau = eval([tname 'HitFracTau']);
      
      if ~isempty(hit_history),
          goodtrials = ~isnan(hit_history);  % ignore violation trials
          if sum(goodtrials)==0, return; end;
          hit_history = hit_history(goodtrials);
          PrevSides   = PrevSides(goodtrials);
          
          kernel = exp(-(0:length(hit_history)-1)/HitFracTau)';
          kernel = kernel(end:-1:1);
          HitFrac = eval([tname 'HitFrac']);
          HitFrac.value = sum(hit_history .* kernel)/sum(kernel);
          
          if ~isempty(PrevSides),
              PrevSides = PrevSides(1:length(hit_history))';
          end;
          
          u = find(PrevSides == 'l');
          LtHitFrac = eval([tname 'LtHitFrac']);
          if isempty(u), LtHitFrac.value = NaN;
          else           LtHitFrac.value = sum(hit_history(u) .* kernel(u))/sum(kernel(u));
          end;
          
          u = find(PrevSides == 'r');
          RtHitFrac = eval([tname 'RtHitFrac']);
          if isempty(u), RtHitFrac.value = NaN;
          else           RtHitFrac.value = sum(hit_history(u) .* kernel(u))/sum(kernel(u));
          end;
      end;
      
      
%% update_biashitfrac
  case 'update_biashitfrac'
      stims = eval([tname 'stims']);
      if isempty(stims), return; end;
      
      % if an extra argument is given indicating that a 'l' or 'r' sound is
      % desired, then compute choices among those only by setting the
      % pprobs of the other side to 0
      if length(varargin) > 0, set_side = varargin{1};
      else                     set_side = '';
      end;
      
      PProb = eval(['value(' tname 'PriorProb)']);
      Sides = cell2mat(stims(:,2));
      if strcmp(set_side, 'l') || strcmp(set_side, 'r'),
          sc = (Sides == set_side)';
          if all(PProb(sc)==0) && ~isempty(sc), PProb(sc) = 1/length(sc); end;
          PProb = PProb .* sc;
      end;
      LocalHitHistory = eval([tname 'LocalHitHistory']);
      LocalPrevSounds = eval([tname 'LocalPrevSounds']);
      hit_history = colvec(value(LocalHitHistory));
      PrevSounds = colvec(value(LocalPrevSounds));
      
      BiasHitFrac = eval([tname 'BiasHitFrac']);
      BiasHitFrac.value = ones(1, rows(stims));
      ChoicesProb = eval([tname 'ChoicesProb']);
      
      BiasTau = eval([tname 'BiasTau']);

      try
          if isempty(hit_history),
              PrevSounds = [];
          else
              PrevSounds = PrevSounds(1:length(hit_history));
          end
      catch
          PrevSounds = [];
      end;
      
      goodtrials = ~isnan(hit_history) & (PrevSounds ~= 0);
      if sum(goodtrials)==0, 
          BiasHitFrac.value = ones(1, rows(value(stims))); 
          ChoicesProb.value = value(PProb);
          return; 
      end;
      biashitfrac_value = exponential_hitfrac(PrevSounds(goodtrials), hit_history(goodtrials), value(BiasTau), 1:rows(stims));
      if ~isempty(biashitfrac_value),
          BiasHitFrac.value = biashitfrac_value;
      end
      
      choices = probabilistic_trial_selector(value(BiasHitFrac), PProb, eval(['value(' tname 'Beta)']));
      ChoicesProb.value = choices;

      
%% get_posterior_probs
  case 'get_posterior_probs'
      ChoicesProb = eval([tname 'ChoicesProb']);
      if ChoicesProb == 0,
          x = [];
      else
          x = value(ChoicesProb);
      end;
      
%% get_next_trial_sound
  case 'get_next_trial_sound',
      stims = eval([tname 'stims']);
      if isempty(stims), x = 0; return; end;
      
      pprobs = cell2mat(stims(:,1));
      sides  = cell2mat(stims(:,2));
      
      if nargin > 2,
          set_side = varargin{1};  % the desired side to be picked for the next trial
      else
          set_side = '';
      end;
      
      if strcmp(set_side, 'l') || strcmp(set_side, 'r'),
          sc = (sides == set_side);
          pprobs = pprobs .* sc;  % consider pprobs of the other side to be 0s.
      end;
      
      pprobs = pprobs / sum(pprobs);
      pprobs = cumsum(pprobs);
      
      x = find(pprobs > rand(1), 1);
      
%% make_sounds
  case 'make_sounds',
% a third argument specifies which sounds to update; if it is not passed, 
% all sounds stored in stims are made.
      stims = eval([tname 'stims']);
      if isempty(stims), return; end; %#ok<NODEF>
      
      if length(varargin) > 0,
          S = varargin{1};
      else
          S = 1:rows(stims);
      end;
      
      for i = 1:length(S),
          k = S(i);
          S1_saved = stims{k, 4};
          S2_saved = stims{k, 5};
          
%           % backwards compatibility, saved sounds may be cell arrays
%           if iscell(S1_saved), 
%               S1_saved = cell2struct(S1_saved(:,2)', S1_saved(:,1)', 2);
%               stims{k, 4} = S1_saved;
%           end
%           if ~isempty(S2_saved) && iscell(S2_saved),
%               S2_saved = cell2struct(S2_saved(:,2)', S2_saved(:,1)', 2);
%               stims{k, 5} = S2_saved;
%           end
          
          srate = SoundManagerSection(obj, 'get_sample_rate');
          gap1 = 0:1/srate:eval(['value(' tname 'Gap1)']);
          gap1 = zeros(2, size(gap1,2)-1); 
          gap2 = 0:1/srate:eval(['value(' tname 'Gap2)']);
          gap2 = zeros(2, size(gap2,2)-1); 

          % load all stored soloparam values into the soundui
          % then tell soundui to make the sound
          SoundInterface(obj, 'load_from_struct', [tname 'S1'], S1_saved);
          snd1 = SoundManagerSection(obj, 'get_sound', [tname 'S1']);
          
          snd_stitched = [snd1 gap1];
          
          if ~isempty(S2_saved) % if a second sound is to be added
              SoundInterface(obj, 'load_from_struct', [tname 'S2'], S2_saved);
              snd2 = SoundManagerSection(obj, 'get_sound', [tname 'S2']);
              snd_stitched = [snd_stitched snd2 gap2]; %#ok<AGROW>
          else
              snd2 = [0;0];
          end;

          % S1
          if ~SoundManagerSection(obj, 'sound_exists', [tname sprintf('Sound%dS1', k)]),
              SoundManagerSection(obj, 'declare_new_sound', [tname sprintf('Sound%dS1', k)]);
              SoundManagerSection(obj, 'set_sound', [tname sprintf('Sound%dS1', k)], snd1);
          else
              snd_prev = SoundManagerSection(obj, 'get_sound', [tname sprintf('Sound%dS1', k)]);
              if ~isequal(snd1, snd_prev),
                  SoundManagerSection(obj, 'set_sound', [tname sprintf('Sound%dS1', k)], snd1);
              end;
          end;
          
          % S2
          if ~SoundManagerSection(obj, 'sound_exists', [tname sprintf('Sound%dS2', k)]),
              SoundManagerSection(obj, 'declare_new_sound', [tname sprintf('Sound%dS2', k)]);
              SoundManagerSection(obj, 'set_sound', [tname sprintf('Sound%dS2', k)], snd2);
          else
              snd_prev = SoundManagerSection(obj, 'get_sound', [tname sprintf('Sound%dS2', k)]);
              if ~isequal(snd2, snd_prev),
                  SoundManagerSection(obj, 'set_sound', [tname sprintf('Sound%dS2', k)], snd2);
              end;
          end;
          
          % stitched sound, included for backwards compatibility for
          % Classical2, which does not currently use scheduled waves to
          % trigged the two sounds
          if ~SoundManagerSection(obj, 'sound_exists', [tname sprintf('Sound%d', k)]),
              SoundManagerSection(obj, 'declare_new_sound', [tname sprintf('Sound%d', k)]);
              SoundManagerSection(obj, 'set_sound', [tname sprintf('Sound%d', k)], snd_stitched);
          else
              snd_prev = SoundManagerSection(obj, 'get_sound', [tname sprintf('Sound%d', k)]);
              if ~isequal(snd_stitched, snd_prev),
                  SoundManagerSection(obj, 'set_sound', [tname sprintf('Sound%d', k)], snd_stitched, eval(['value(' tname 'loop)']));
              end;
          end;
      end;

      % if there's an extra sound, delete it
      SoundManagerSection(obj, 'delete_sound', [tname sprintf('Sound%d', rows(stims)+1)]);

%% check_norm
% checks the sounds defined and displays warning messages if something's
% wrong
  case 'check_norm',
	  stims = eval([tname 'stims']);
      panel_message = eval([tname 'panel_message']);
      go_flag.value = 1; % assume all systems go
      if isempty(stims),  % if no sounds defined
          panel_message.value = 'No sounds defined!!';
          set(get_ghandle(panel_message), 'BackgroundColor', 'r');
          go_flag.value = 0;
          return;
      end;
      
      normal = eval([tname 'normal']);
      prb = cell2mat(stims(:,1));
      if prb ~= 0,
          PProb = eval([tname 'PriorProb']);
          PProb.value = prb';
      end;
      if abs(sum(prb)-1) < 0.01,  
          % for some weird reason matlab's tolerance is insane, which means
          % we have to compare sum(prb) to 1 within some very small epsilon
          % (eps ~ 10^-16)
          set(get_ghandle(normal), 'BackgroundColor', [30 200 30]/255);
      else % if pprob's do not sum to unity
          set(get_ghandle(normal), 'BackgroundColor', 'r');
          panel_message.value = 'PProb does not sum to 1';
          set(get_ghandle(panel_message), 'BackgroundColor', 'r');
          go_flag.value = 0;
          return;
      end;
      
      s = cell2mat(stims(:,2));
      if all(s == 'l'),  % if all choices are left
          panel_message.value = 'No right choices defined!!';
          set(get_ghandle(panel_message), 'BackgroundColor', 'r');
      %    go_flag.value = 0;
      elseif all(s == 'r'), % if all choices are right
          panel_message.value = 'No left choices defined!!';
          set(get_ghandle(panel_message), 'BackgroundColor', 'r');
      %    go_flag.value = 0;
      end;
      
      if go_flag == 1,
          panel_message.value = 'All Sounds Valid';
          set(get_ghandle(panel_message), 'BackgroundColor', 'g');
      end;
      
%% normalize
  case 'normalize',
      stims = eval([tname 'stims']);
      if ~isempty(stims),
          normalize_pprob(obj, stims);
      else
          warning('No sounds defined');
      end;
      feval(mfilename, obj, 'display_table', tname);
      feval(mfilename, obj, 'check_norm', tname);
      
%% play_sound
  case 'play_sound',
      sttable = eval([tname 'sttable']);
      n = get(get_ghandle(sttable), 'value'); % get selected row
      n = n(1);
      if n==1, return; end;  %if the label row was selected, do nothing
      
      if ~SoundManagerSection(obj, 'sound_exists', 'CurrentSound'),
          feval(mfilename, obj, 'sttable', tname);
      end;
      SoundManagerSection(obj, 'play_sound', 'CurrentSound');
          
      
%% stop_sound      
  case 'stop_sound',
      sttable = eval([tname 'sttable']);
      n = get(get_ghandle(sttable), 'value'); % get selected row
      n = n(1);
      if n==1, return; end;  %if the label row was selected, do nothing
      
      SoundManagerSection(obj, 'stop_sound', 'CurrentSound');
      
%% fsave
  case 'fsave'
      stims_value = eval(['value(' tname 'stims)']);
      Gap1_value = eval(['value(' tname 'Gap1)']); %#ok<NASGU>
      Gap2_value = eval(['value(' tname 'Gap2)']); %#ok<NASGU>
      if ~isempty(stims_value),
          [FileName, PathName] = uiputfile('*.mat');
          try
              save([PathName FileName], 'stims_value', 'Gap1_value', 'Gap2_value');
          catch
              warning('SoundTableSection:Save', 'Save failed, nothing was saved');
          end;
      end;

%% fload
  case 'fload'
      uiopen('LOAD');
      try
          stims = eval([tname 'stims']);
          Gap1  = eval([tname 'Gap1']);
          Gap2  = eval([tname 'Gap2']);
          stims.value = stims_value;
          Gap1.value  = Gap1_value;
          Gap2.value  = Gap2_value;
      catch
          warning('SoundTableSection: Load from File failed');
          return;
      end;

      feval(mfilename, obj, 'display_table', tname);      
      feval(mfilename, obj, 'make_sounds', tname);
      feval(mfilename, obj, 'check_norm', tname);



%% hide, show_hide
  case 'hide',
    soundtable_show = eval([tname 'soundtable_show']);
    soundtable_show.value = 0;
    feval(mfilename, obj, 'show_hide', tname);
    
  case 'show_hide',
    soundtable_show = eval([tname 'soundtable_show']);
    soundtablefig = eval([tname 'soundtablefig']);
    if soundtable_show == 1, set(value(soundtablefig), 'Visible', 'on'); 
    else                     set(value(soundtablefig), 'Visible', 'off');
    end;
    
%% close
  case 'close'   
%     if nargin > 2,
%         SoundInterface(obj, 'close');
%         figs = get_sphandle('name', 'soundtablefig');
%         for i = 1:length(figs),
%             delete(value(figs{i}));
%         end;
%         delete_sphandle('owner',  ['^@' class(obj) '$'], 'fullname', [mfilename '_']);      
%     else
    try
        if ~isempty(eval([tname 'stims'])),  
            for k = 1:rows(eval([tname 'stims'])),
                SoundManagerSection(obj, 'delete_sound', [tname sprintf('Sound%d', k)]);
            end;
        end;
        SoundInterface(obj, 'close', [tname 'S1']);
        SoundInterface(obj, 'close', [tname 'S2']);

        % delete everything
        if ishandle(eval(['value(' tname 'soundtablefig)'])), delete(eval(['value(' tname 'soundtablefig)'])); end;
        delete_sphandle('owner', ['^@' class(obj) '$'], 'fullname', [mfilename '_' tname]);
    end;
%     end;
    
%% reinit
  case 'reinit'
    % Get the original GUI position and figure:
    my_gui_info = value(eval([tname 'my_gui_info']));
    x = my_gui_info(1); y = my_gui_info(2); figure(my_gui_info(3));
    
    % close everything involved with the plugin
    feval(mfilename, obj, 'close', tname);

    % Reinitialise at the original GUI position and figure:
    feval(mfilename, obj, 'init', tname, x, y);
        
%% otherwise    
  otherwise
    warning('%s : action "%s" is unknown!', mfilename, action); %#ok<WNTAG> (This line OK.)

end; %     end of switch action

%% supplemental functions
function [stims] = normalize_pprob(obj, stims)
    prb = cell2mat(stims(:,1));
    prb = prb/sum(prb);
    
    for i = 1:rows(stims)
        stims{i,1} = prb(i);
    end;
	return;
    
function [x] = colvec(x)
    if size(x,2) > size(x,1), x = x'; end;
    return;
   