
%This is a new version of the old stand alone rigtester.m did not run
%through dispatcher.  This is treated like any other protocol. It is
%designed to be plastic, looking at a rigs settings files, determining
%the input and output lines, and building a GUI specific to that rigs
%componants.  
%
%Written by Chuck 2017

% Make sure you ran newstartup, then dispatcher('init'), and you're good to
% go!
%

function [obj] = RigTester(varargin)

% Default object is of our own class (mfilename); in this simplest of
% protocols, we inherit only from Plugins/@pokesplot

obj = class(struct, mfilename, soundmanager, soundui);

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
  
  case 'init'

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

    alldio = bSettings('get','DIOLINES','ALL');
    allinp = bSettings('get','INPUTLINES','ALL');
    dionums = cell2mat(alldio(:,2));
    inpnums = cell2mat(allinp(:,2));
    
    for i = 1:16
        inp1 = find(inpnums == i,1,'first');
        dio1 = find(dionums == 2^(( i-1)*2),    1,'first');
        dio2 = find(dionums == 2^(((i-1)*2)+1),1,'first');
        
        if isempty(inp1) && isempty(dio1) && isempty(dio2)
            continue; 
        end
        
        if ~isempty(inp1)
            linegroups{i}{1,1} = allinp{inp1,2}; %#ok<AGROW>
            linegroups{i}{1,2} = allinp{inp1,1}; %#ok<AGROW>
        else
            linegroups{i}{1,1} = []; %#ok<AGROW>
            linegroups{i}{1,2} = []; %#ok<AGROW>
        end
        if ~isempty(dio1)
            linegroups{i}{2,1} = alldio{dio1,2}; %#ok<AGROW>
            linegroups{i}{2,2} = alldio{dio1,1}; %#ok<AGROW>
        else
            linegroups{i}{2,1} = []; %#ok<AGROW>
            linegroups{i}{2,2} = [];  %#ok<AGROW>
        end
        if ~isempty(dio2)
            linegroups{i}{3,1} = alldio{dio2,2}; %#ok<AGROW>
            linegroups{i}{3,2} = alldio{dio2,1}; %#ok<AGROW>
        else
            linegroups{i}{3,1} = []; %#ok<AGROW>
            linegroups{i}{3,2} = []; %#ok<AGROW>
        end
    end
    
    %     Generate the sounds we need.
    soundserver = bSettings('get','RIGS','sound_machine_server');
    if ~isempty(soundserver)
        dosounds = 1;
        sr = SoundManagerSection(obj,'get_sample_rate');
        freq = 100;
        len = 150;
        snd = MakeBupperSwoop(sr,0,freq,freq, len/2, len/2, 0, 0.1, 'F1_volume_factor',0.07,'F2_volume_factor',0.07);
        silence_length = 0;
        presound_silence = zeros(1,sr*silence_length/1000);
        snd = [presound_silence, snd];

        SoundManagerSection(obj,'declare_new_sound','left_sound',   [snd; zeros(1,size(snd,2))]);
        SoundManagerSection(obj,'declare_new_sound','right_sound',  [zeros(1,size(snd,2)); snd]);

        SoundManagerSection(obj,'loop_sound','left_sound',1);
        SoundManagerSection(obj,'loop_sound','right_sound',1);

        SoundManagerSection(obj,'declare_new_sound','center_sound',[snd;snd([ceil((sr / freq) / 2):end,1:ceil((sr / freq) / 2)-1])]);
        SoundManagerSection(obj,'loop_sound','center_sound',1);
        
        SoundManagerSection(obj, 'send_not_yet_uploaded_sounds');
    else
        dosounds = 0;
    end
    
    SoloParamHandle(obj,'DoSounds','value',dosounds);
    
    MP = get(0,'MonitorPositions');
    groupwidth = floor(MP(3)/numel(linegroups));
    
    % At this point we have one SoloParamHandle, myfig
    % Let's put the figure where we want it and give it a reasonable size:
    set(value(myfig), 'Position', [1,floor((MP(4)-600)/2),numel(linegroups)*groupwidth,600]);

    stereo_vol = bSettings('get','SOUND','volume_scaling');
    if isnan(stereo_vol); stereo_vol = 1; end
            
    line_names = [];
    for i = 1:numel(linegroups)
        if ~isempty(linegroups{i}) && ~isempty(linegroups{i}{1,2})
            SubheaderParam(obj,['Input',linegroups{i}{1,2}],{linegroups{i}{1,2};0},0,0,'position',[((i-1)*groupwidth)+1, 300, groupwidth-2,290]);
            set(get_ghandle(eval(['Input',linegroups{i}{1,2}])),'FontSize',32,'BackgroundColor',[0,1,0],'HorizontalAlignment','center');
            line_names(end+1) = linegroups{i}{1,2}; %#ok<AGROW>
            
            if strcmp(linegroups{i}{1,2},'L') && DoSounds == 1
                ToggleParam( obj,'LeftSound',     0,0,0,'position',[((i-1)*groupwidth)+1,10,groupwidth-102,50],'OnString', 'Left Speaker ON',        'OffString', 'Left Speaker OFF');
                NumeditParam(obj,'L_Vol',stereo_vol,0,0,'position',[(i*groupwidth)-101,  10,           100,50],'labelfraction', 0.5);
                set_callback(LeftSound,{mfilename,'play_left_sound'});
                set_callback(L_Vol,{mfilename,'update_sounds'});
                
            elseif strcmp(linegroups{i}{1,2},'R') && DoSounds == 1
                ToggleParam(obj,'RightSound',     0,0,0,'position',[((i-1)*groupwidth)+1,10, groupwidth-102,50],'OnString', 'Right Speaker ON',       'OffString', 'Right Speaker OFF');          
                NumeditParam(obj,'R_Vol',stereo_vol,0,0,'position',[(i*groupwidth)-101,  10,           100,50],'labelfraction', 0.5);
                set_callback(RightSound,{mfilename,'play_right_sound'});
                set_callback(R_Vol,{mfilename,'update_sounds'});
                
            elseif strcmp(linegroups{i}{1,2},'C') && DoSounds == 1
                ToggleParam(obj,'CenterSound',      0,0,0,'position',[((i-1)*groupwidth)+1,  10, groupwidth-2,50],'OnString', 'Both Speakers ON',       'OffString', 'Both Speakers OFF');          
                set_callback(CenterSound,{mfilename,'play_center_sound'});    
            end
        end
        if ~isempty(linegroups{i}) && ~isempty(linegroups{i}{2,2})
            ToggleParam(obj,['DIO',num2str(i),'_1'],0,0,0,'position',[((i-1)*groupwidth)+1, 210, groupwidth-2,50],'OnString', [linegroups{i}{2,2},' ON'], 'OffString', [linegroups{i}{2,2},' OFF']);
            set_callback(eval(['DIO',num2str(i),'_1']),{mfilename,['toggle',num2str(i),'_1']});
            
        end
        if ~isempty(linegroups{i}) && ~isempty(linegroups{i}{3,2})
            ToggleParam(obj,['DIO',num2str(i),'_2'],0,0,0,'position',[((i-1)*groupwidth)+1, 110, groupwidth-2,50],'OnString', [linegroups{i}{3,2},' ON'], 'OffString', [linegroups{i}{3,2},' OFF']);
            set_callback(eval(['DIO',num2str(i),'_2']),{mfilename,['toggle',num2str(i),'_2']});
        end
    end
    
    SoloParamHandle(obj,'LineGroups','value',linegroups);
    SoloParamHandle(obj,'LineNames','value',line_names);
    
    scr = timer;
    set(scr,'Period', 0.2,'ExecutionMode','FixedRate','TasksToExecute',Inf,...
        'BusyMode','drop','TimerFcn',[mfilename,'(''close_continued'')']);
    SoloParamHandle(obj, 'stopping_complete_timer', 'value', scr);
        
    RigTester(obj,'prepare_next_trial');
    
    dispatcher('Run');

    
    case 'play_left_sound' 
        %% play_left_sound
        if value(LeftSound) == 1
            SoundManagerSection(obj,'play_sound','left_sound');
        else
            SoundManagerSection(obj,'stop_sound','left_sound');
        end
        
    case 'play_right_sound' 
        %% play_right_sound
        if value(RightSound) == 1
            SoundManagerSection(obj,'play_sound','right_sound');
        else
            SoundManagerSection(obj,'stop_sound','right_sound');
        end    
        
    case 'play_center_sound' 
        %% play_center_sound
        if value(CenterSound) == 1
            SoundManagerSection(obj,'play_sound','center_sound');
        else
            SoundManagerSection(obj,'stop_sound','center_sound');
        end      
        
    case 'update_sounds'
        %% update_sounds
        
        if value(DoSounds) == 1
            sr = SoundManagerSection(obj,'get_sample_rate');
            
            stereo_vol = bSettings('get','SOUND','volume_scaling');
            if isnan(stereo_vol); stereo_vol = 1; end
            
            freq = 100;
            len = 150;
            snd = MakeBupperSwoop(sr,0,freq,freq, len/2, len/2, 0, 0.1, 'F1_volume_factor',0.07,'F2_volume_factor',0.07);
            silence_length = 0;
            presound_silence = zeros(1,sr*silence_length/1000);
            
            sndL = [presound_silence, snd];
            sndL = (sndL ./ stereo_vol) .* value(L_Vol);
            
            sndR = [presound_silence, snd];
            sndR = (sndR ./ stereo_vol) .* value(R_Vol);
            
            sndC = [sndL;sndR([ceil((sr / freq) / 2):end,1:ceil((sr / freq) / 2)-1])];
            sndL = [sndL; zeros(1,size(sndL,2))];
            sndR = [zeros(1,size(sndR,2));sndR];

            SoundManagerSection(obj,'set_sound','left_sound',  sndL,1);
            SoundManagerSection(obj,'set_sound','center_sound',sndC,1);
            SoundManagerSection(obj,'set_sound','right_sound', sndR,1);
            
            SoundManagerSection(obj, 'send_not_yet_uploaded_sounds');
        end

    case 'toggle1_1'
        %% case toggle1_1
        linegroups = value(LineGroups);
        dispatcher('toggle_bypass',log2(linegroups{1}{2,1}));

    case 'toggle1_2'
        %% case toggle1_2
        linegroups = value(LineGroups);
        dispatcher('toggle_bypass',log2(linegroups{1}{3,1}));
    
    case 'toggle2_1'
        %% case toggle1_1
        linegroups = value(LineGroups);
        dispatcher('toggle_bypass',log2(linegroups{2}{2,1}));

    case 'toggle2_2'
        %% case toggle1_2
        linegroups = value(LineGroups);
        dispatcher('toggle_bypass',log2(linegroups{2}{3,1}));
        
    case 'toggle3_1'
        %% case toggle1_1
        linegroups = value(LineGroups);
        dispatcher('toggle_bypass',log2(linegroups{3}{2,1}));

    case 'toggle3_2'
        %% case toggle1_2
        linegroups = value(LineGroups);
        dispatcher('toggle_bypass',log2(linegroups{3}{3,1}));
        
    case 'toggle4_1'
        %% case toggle1_1
        linegroups = value(LineGroups);
        dispatcher('toggle_bypass',log2(linegroups{4}{2,1}));

    case 'toggle4_2'
        %% case toggle1_2
        linegroups = value(LineGroups);
        dispatcher('toggle_bypass',log2(linegroups{4}{3,1}));
        
    case 'toggle5_1'
        %% case toggle1_1
        linegroups = value(LineGroups);
        dispatcher('toggle_bypass',log2(linegroups{5}{2,1}));

    case 'toggle5_2'
        %% case toggle1_2
        linegroups = value(LineGroups);
        dispatcher('toggle_bypass',log2(linegroups{5}{3,1}));
        
    case 'toggle6_1'
        %% case toggle1_1
        linegroups = value(LineGroups);
        dispatcher('toggle_bypass',log2(linegroups{6}{2,1}));

    case 'toggle6_2'
        %% case toggle1_2
        linegroups = value(LineGroups);
        dispatcher('toggle_bypass',log2(linegroups{6}{3,1}));
        
    case 'toggle7_1'
        %% case toggle1_1
        linegroups = value(LineGroups);
        dispatcher('toggle_bypass',log2(linegroups{7}{2,1}));

    case 'toggle7_2'
        %% case toggle1_2
        linegroups = value(LineGroups);
        dispatcher('toggle_bypass',log2(linegroups{7}{3,1}));
        
    case 'toggle8_1'
        %% case toggle1_1
        linegroups = value(LineGroups);
        dispatcher('toggle_bypass',log2(linegroups{8}{2,1}));

    case 'toggle8_2'
        %% case toggle1_2
        linegroups = value(LineGroups);
        dispatcher('toggle_bypass',log2(linegroups{8}{3,1}));    
    
    case 'toggle9_1'
        %% case toggle1_1
        linegroups = value(LineGroups);
        dispatcher('toggle_bypass',log2(linegroups{9}{2,1}));

    case 'toggle9_2'
        %% case toggle1_2
        linegroups = value(LineGroups);
        dispatcher('toggle_bypass',log2(linegroups{9}{3,1}));  
        
    case 'toggle10_1'
        %% case toggle1_1
        linegroups = value(LineGroups);
        dispatcher('toggle_bypass',log2(linegroups{10}{2,1}));

    case 'toggle10_2'
        %% case toggle1_2
        linegroups = value(LineGroups);
        dispatcher('toggle_bypass',log2(linegroups{10}{3,1}));  
        
    case 'toggle11_1'
        %% case toggle1_1
        linegroups = value(LineGroups);
        dispatcher('toggle_bypass',log2(linegroups{11}{2,1}));

    case 'toggle11_2'
        %% case toggle1_2
        linegroups = value(LineGroups);
        dispatcher('toggle_bypass',log2(linegroups{11}{3,1}));  
        
    case 'toggle12_1'
        %% case toggle1_1
        linegroups = value(LineGroups);
        dispatcher('toggle_bypass',log2(linegroups{12}{2,1}));

    case 'toggle12_2'
        %% case toggle1_2
        linegroups = value(LineGroups);
        dispatcher('toggle_bypass',log2(linegroups{12}{3,1}));  
        
    case 'toggle13_1'
        %% case toggle1_1
        linegroups = value(LineGroups);
        dispatcher('toggle_bypass',log2(linegroups{13}{2,1}));

    case 'toggle13_2'
        %% case toggle1_2
        linegroups = value(LineGroups);
        dispatcher('toggle_bypass',log2(linegroups{13}{3,1}));  
        
    case 'toggle14_1'
        %% case toggle1_1
        linegroups = value(LineGroups);
        dispatcher('toggle_bypass',log2(linegroups{14}{2,1}));

    case 'toggle14_2'
        %% case toggle1_2
        linegroups = value(LineGroups);
        dispatcher('toggle_bypass',log2(linegroups{14}{3,1}));  
        
    case 'toggle15_1'
        %% case toggle1_1
        linegroups = value(LineGroups);
        dispatcher('toggle_bypass',log2(linegroups{15}{2,1}));

    case 'toggle15_2'
        %% case toggle1_2
        linegroups = value(LineGroups);
        dispatcher('toggle_bypass',log2(linegroups{15}{3,1}));  
        
    case 'toggle16_1'
        %% case toggle1_1
        linegroups = value(LineGroups);
        dispatcher('toggle_bypass',log2(linegroups{16}{2,1}));

    case 'toggle16_2'
        %% case toggle1_2
        linegroups = value(LineGroups);
        dispatcher('toggle_bypass',log2(linegroups{16}{3,1}));      
        
  %---------------------------------------------------------------
  %          CASE PREPARE_NEXT_TRIAL
  %---------------------------------------------------------------
  case 'prepare_next_trial'
      
      if exist('LeftSound','var')   ~= 0; L_string = get(get_ghandle(LeftSound),  'string'); end
      if exist('CenterSound','var') ~= 0; C_string = get(get_ghandle(CenterSound),'string'); end
      if exist('RightSound','var')  ~= 0; R_string = get(get_ghandle(RightSound), 'string'); end
      
      if exist('LeftSound','var')   ~= 0; set(get_ghandle(LeftSound),  'string','Updating'); end
      if exist('CenterSound','var') ~= 0; set(get_ghandle(CenterSound),'string','Updating'); end
      if exist('RightSound','var')  ~= 0; set(get_ghandle(RightSound), 'string','Updating'); end
      pause(0.01);
      
      line_names = value(LineNames);
      sma = StateMachineAssembler('full_trial_structure','use_happenings',1,'n_input_lines',numel(line_names),'line_names',line_names);
      sma = add_state(sma, 'name', 'the_only_state', 'self_timer',8, 'input_to_statechange', {'Tup', 'final_state'});
      sma = add_state(sma, 'name', 'final_state',    'self_timer',2, 'input_to_statechange', {'Tup', 'check_next_trial_ready'});
      dispatcher('send_assembler', sma, 'final_state');  
    
      if exist('LeftSound','var')   ~= 0; set(get_ghandle(LeftSound),  'string',L_string); end
      if exist('CenterSound','var') ~= 0; set(get_ghandle(CenterSound),'string',C_string); end
      if exist('RightSound','var')  ~= 0; set(get_ghandle(RightSound), 'string',R_string); end
      pause(0.01);
      
  %---------------------------------------------------------------
  %          CASE TRIAL_COMPLETED
  %---------------------------------------------------------------
  case 'trial_completed'

    
  %---------------------------------------------------------------
  %          CASE UPDATE
  %---------------------------------------------------------------
  case 'update'
      peh = parsed_events_history;
      pe  = parsed_events; %#ok<NASGU>
      linenames = value(LineNames);
      
      %display the poke count
      for i = 1:numel(linenames)
          cnt = 0;
          for j = 1:numel(peh)
              poketimes = eval(['peh{j}.pokes.',linenames(i)]);
              cnt = cnt + size(poketimes,1);
          end
          poketimes = eval(['pe.pokes.',linenames(i)]);
          cnt = cnt + size(poketimes,1);
          
          str = get(get_ghandle(eval(['Input',linenames(i)])),'string');
          str{2} = num2str(cnt);
          set(get_ghandle(eval(['Input',linenames(i)])),'string',str);
      end
      
      %set the color, red poke in, green poke out
      for i = 1:numel(linenames)
          poketimes = eval(['pe.pokes.',linenames(i)]);
          if ~isempty(poketimes) && isnan(poketimes(end,2))
              set(get_ghandle(eval(['Input',linenames(i)])),'BackgroundColor',[1,0,0]);
          else
              set(get_ghandle(eval(['Input',linenames(i)])),'BackgroundColor',[0,1,0]);
          end
      end
      
  %---------------------------------------------------------------
  %          CASE CLOSE
  %---------------------------------------------------------------
  case 'close'

      dispatcher('Stop');
    
      %Let's pause until we know dispatcher is done running
      set(value(stopping_complete_timer),'TimerFcn',[mfilename,'(''close_continued'');']);
      start(value(stopping_complete_timer));
        
  case 'close_continued'
    
      if value(stopping_process_completed)
          stop(value(stopping_complete_timer)); %Stop looping.
          %dispatcher('set_protocol','');
        
        if exist('myfig', 'var') && isa(myfig, 'SoloParamHandle') && ishandle(value(myfig)), %#ok<NODEF>
          delete(value(myfig));
        end;
        delete_sphandle('owner', ['^@' class(obj) '$']);
        dispatcher('set_protocol','');
      end
  otherwise,
    warning('Unknown action! "%s"\n', action); %#ok<WNTAG>
end;

return;

