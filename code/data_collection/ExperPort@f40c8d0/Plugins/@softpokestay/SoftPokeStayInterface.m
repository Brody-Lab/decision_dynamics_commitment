% [x, y] = SoftPokeStayInterface(obj, action, softpokestay_name, x, y)
%
% Puts up a GUI for making a set of states for detecting when an animal 
% stays in a poke, while allowing brief excursions from the poke. You can
% define the maximum time the animal is outside the poke before the "in
% poke" state is considered terminated. This plugin also provides a simple
% call to add the necessary states to a @StateMachineAssembler you are
% constructing.
%
% KNOWN ISSUE: ONLY ONE SOFTPOKESTAYINTERFACE PER PROTOCOL CAN CURRENTLY BE
% USED. TO BE FIXED SOON.
%
%
% QUICKSTART USAGE:
% -----------------
%
% To create a soft poke stay GUI, call
%
%   [x, y] = SoftPokeStayInterface(obj, 'add', sps_name, x, y)
%
% where sps_name is a string that will identify this soft poke stay
% section, and x and y are the pixel position in the current figure on
% which a the GUI for this soft poke stay section appears. By using
% different sps_name strings, you can have separate, different soft poke
% stay sections. The GUI will have NumeditParams for 'Duration' (how long
% the animal must keep its nose in the poke to exit successfully) and
% 'Grace' (how long the animal is allowed to hop out of the poke before a
% full exit is flagged).
%
% There are two ways to exit from SoftPokeStays: (a) "success", meaning
% that the animal kept its nose in the poke for Duration seconds (ignoring
% any exits from the poke less that Grace seconds long). (b) "abort",
% meaning that the animal left the poke for more than Grace seconds before
% Duration was up. (Of course, whether you interpret these two exits as
% "good" or "bad" or viceversa is up to you.)
%
% Then, to use the soft poke stay section, when constructing your
% StateMachine Assembler, call
%
%   sma = SoftPokeStayInterface(obj, 'add_sma_states', sps_name, sma, ... 
%        'success_exitstate', success_exitstate_name, ...
%        'abort_exitstate',   abort_exitstate_name,  'pokeid', pokeid);
%
% where sma is a @StateMachineAssembler object, sps_name is the string
% identifying this soft poke stay section, success_exitstate_name is a string
% identifying the state to jump to after the soft poke stay ended with a
% "success", abort_exitstate_name is a string identifying the state to jump
% to if the soft poke state ended with an "abort" (i.e. the animal was
% outside the poke for more than Grace seconds), and pokeid is one of 'C',
% 'R', or 'L'. 
%
% In the State Machine, to start the SoftPokeStay section, jump to the
% state named sps_name, where sps_name is any of the soft poke stays you
% created. All of the states in the soft poke stay section will be named
% sps_name; you will be jumping to the first of those states.
%
% *** NOTE THAT SOFT POKE STAY ASSUMES THAT THE ANIMAL'S NOSE IS **IN** THE
% POKE GIVEN BY POKEID WHEN THE SOFT POKE STAY SECTION STARTS.
%
%
% In addition to its basic functionality of timing when an animal leaves a
% poke while allowing for Grace periods, SoftPokeStayInterface can
% concurrently detect some events and produce some outputs. It can do three
% things:
%   1) You can ask it to pull a digital line high X seconds after starting
%      SoftPokeStay and keeep it high for Y seconds thereafter.
%   2) You can ask it to send a trigger signal to the Sound Machine X
%      seconds after starting SoftPokeStay. This trigger signal can be
%      either "start a sound" or "stop a sound."
%   3) You can ask it to send a trigger signal to the Sound Machine if and 
%      when an event that you choose occurs. E.g., "start sound 3 if a
%      mywave_In event occurs."
%
% Each of these three are independent of each other, and are independent of
% Grace period accounting and so on. The first two are different from the
% third: when the SoftPokeStay ends, it always pulls the digital line
% back down and stops the sound in (1) and (2) above. The outputs in (1)
% and (2) are therefore guaranteed to be stopped at the end of SoftPokeStay
% states. In contrast, The sound referred to in (3) above is affected only
% once, if and when its triggering event occurs within the SoftPokeStay
% states. It is therefore not guaranteed to be neither started nor stopped
% at the end of SoftPokeStay states. To use 1, 2, and 3, see parameters for
% 'add_sma_states' below.
%
%
% RESOURCE USAGE:
% ---------------
%
% Each soft poke stay section uses 4 scheduled waves.
%
%
% PARAMETERS:
% -----------
%
% The first parameter, action, should be one of:
%
%  'add'     Make a GUI for a new sps section. This action requires three
%            more PARAMETERS:
%
%              sps_name    A string defining the name of the soft poke stay
%            
%              x, y            x and y position, in pixels from bottom
%                              left of current figure, at which to start
%                              putting in the GUI elements.
%         
%            This action, 'add', also takes a number of OPTIONAL PARAMETERS:
%
%              'TooltipString'   Default is ''; Tooltip string for title of
%                         GUI.
%
%            This action, 'add', RETURNS:  x, y  next open position on
%                         current figure.
%
% 'set' sps_name 'Duration'|'Grace' value
%        
%               The 'set' action allows setting the parameters for any of
%               the soft poke stays that have been created. The next argument
%               after 'set' must be a string, the name of the soft poke stay
%               that was created with 'add'; the next argument must also be
%               a string, as listed above; and the last argument should be
%               the value the corresponding setting will be changed to.
%               Example calls:
%                     SoftPokeStayInterface(obj, 'set', 'mysps', 'Duration', 2);
%                 or
%                     SoftPokeStayInterface(obj, 'set', 'mysps', 'Grace',   0.025);
%
%
% 'get' sps_name 'Duration'|'Grace'  
%
%               The 'get' action returns the setting of the parameters for any of
%               the soft poke stays that have been created. The next argument
%               after 'get' must be a string, the name of the soft poke stay
%               that was created with 'add'; the next argument must also be
%               a string, as listed above.
%               Example call:
%                     myvarstyle = SoftPokeStayInterface(obj, 'get', 'mysps', 'Duration')
%
%
% 'close_all'   Deletes all SoloParamHandles that were created with
%               SoftPokeStayInterface.
%
%
% 'add_sma_states'  sps_name,  sma, {'success_exitstate_name', 'current_state+4'}, ...
%                  {'abort_exitstate_name', 'current_state+3'}, ...
%                  {'DOut' -1}, {'DOutStartTime', 1e6}, {'DOutOnTime', 1e6}, ...
%                  {'Sound1Id', 0}, {'Sound1TrigTime', 1e6}, ...
%                  {'Sound2Id' 0},  {'Sound2TriggeringEvent', 'null'}, ...
%                  {'InitialSchedWaveTrig', 'null'}
%
%               The first argument after 'add_sma_states' must be a
%               string, sps_name, identifying the softpokestay section that
%               we are talking about; and the next must be a
%               @StateMachineAssembler object to which we are adding the
%               states. This call will return an updated sma. The defaults
%               for the name-value pairs 'success_exitstate_name' and
%               'abort_exitstate_name' are set to be the next state
%               immediately after the softpokestay states. You can specify
%               a different string for either or both.
%               'success_exitstate_name' will be jumped to if the animal
%               stays in the poke for at least Duration seconds, not
%               exiting for more than Grace seconds. 'abort_exitstate_name'
%               will be jumped to if the animal exited for more than Grace
%               seconds before Duration had elapsed. (Duration and Grace
%               are determined by the GUI, see above.)
%
%               The optional name-value pairs 'DOut', 'DOutStartTime', and
%               'DoutOnTime', identify a digital output signal that you
%               would like turned on DoutStartTime after entering the sps
%               states, and that should last a maximum of DoutOnTime (but
%               will be pulled low if the sps states end). (This is
%               typically used to deliver a certain amount of water.)
%                  Similarly, the optional name-value pairs 'Sound1Id' and
%               'Sound1TrigTime' identify a sound you want turned on or
%               off Sound1TrigTime secs after the beginning of the sps
%               section. (Sound1Id = +k means turn sound k on; Sound1Id=-k
%               means turns sound k off.) At the end of the SoftPokeStay,
%               whether it ends in success or abort, the sound is turned
%               off (a -abs(k) signal is sent) before jumping to
%               success_exitstate_name or abort_exitstate_name. 
%                  Finally, you can have yet another sound turn on or off,
%               this one not based on time since the soft poke stay start,
%               but based on some event (e.g., 'mysched_wave_In'). The
%               optional parameter 'Sound2TriggeringEvent' is used to
%               indicate what that event is; and  'Sound2Id'
%               indicates the id of the sound. (Once again, +k means turn
%               sound k on, -k means turn it off.) This sound is NOT
%               guaranteed to be neither off nor on when the softpokestay
%               states end. 
%                  The optional name-value pair 'InitialSchedWaveTrig'
%               indicates a scheduled wave that you might like to trigger
%               simultaneously with starting the SoftPokeStay states.
%
% 
% EXAMPLES
% --------
%
% To give a rat water for 0.2 secs as soon as he poked into the Left poke,
% and to not have the state machine progress to another state until he's
% been out of the port for at least 2.5 secs, or 40 secs have elapsed,
% whichever comes first: 
%
% >> SoftPokeStayInterface(obj, 'add', 'soft_drinktime', x, y);
% >> SoftPokeStayInterface(obj, 'set', 'soft_drinktime', 'Duration', 40); 
% >> SoftPokeStayInterface(obj, 'set', 'soft_drinktime', 'Grace', 2.5);
%
% sma = SoftPokeStayInterface(obj, 'add_sma_states', 'soft_drinktime', ...
%   'pokeid', 'L', 'DOut', left1water, 'DOutStartTime', 0, 'DOutOnTime', 0.2);
%
%
%
% To give a rat water for 0.2 secs immediately after he pokes into the Left
% poke; and turn both sound A and sound B off 2 seconds afterwards; and not
% progress to the next state until he's been out of the port for at least
% 2.5 secs, or 40 secs have elapsed, whichever comes first: 
%
% >> SoftPokeStayInterface(obj, 'add', 'soft_drinktime', x, y);
% >> SoftPokeStayInterface(obj, 'set', 'soft_drinktime', 'Duration', 40); 
% >> SoftPokeStayInterface(obj, 'set', 'soft_drinktime', 'Grace', 2.5);
% 
% sma = add_scheduled_wave(sma, 'name', 'soundAoff', 'preamble', 2);
%
% sma = SoftPokeStayInterface(obj, 'add_sma_states', 'soft_drinktime', ...
%   'pokeid', 'L', ...
%   'DOut', left1water, 'DOutStartTime', 0, 'DOutOnTime', 0.2, ...
%   'Sound1TrigTime', 2, 'Sound1Id', -B, ...
%   'InitialSchedWaveTrig',  'soundAoff', ...
%   'Sound2TriggeringEvent', 'soundAoff_In', 'Sound2Id', -A);
%
% sma = add_state(sma, 'self_timer', 0.0001, 'input_to_statechange',
%    {'Tup', 'current_state+1'}, 'output_actions', {'SoundOut', -A}); 
%      % this last is to guarantee that sound A gets turned off, in case the
%      % SoftPokeStay section ends before the 2 secs of the soundAoff
%      % scheduled wave have elapsed.

% Written by Carlos Brody Dec 2007


function [varargout] = SoftPokeStayInterface(obj, action, pname, x,y , varargin)

GetSoloFunctionArgs(obj);

switch action,

%% add

    % ------------------------------------------------------------------------
    %
    %   CASE ADD
    %
    % ------------------------------------------------------------------------

  
  case 'add'  
    if nargin < 5, error('Action ''add'' also requires pname, x, y, as parameters'); end;
    pairs = { ...
      'Duration'        1   ; ...
      'Grace'        0.025 ; ...
      'TooltipString' '' ; ...
    }; parseargs(varargin, pairs);
    
    NumeditParam(obj, [pname '_Duration'], 1,   x, y, 'label', 'Duration', 'labelfraction', 0.6, 'TooltipString', sprintf('\nTime animal must stay in poke to successfully exit'), 'position', [x y 100 20]); 
    NumeditParam(obj, [pname '_Grace'], 0.025, x, y, 'label', 'Grace',   'labelfraction', 0.6, 'TooltipString', sprintf('\nTime animal may be out of poke before it is considered an unsuccessful exit'), 'position', [x+100 y 100 20]); next_row(y);
    SubheaderParam(obj, [pname '_Title'], ['SoftPokeStay: ' pname], x, y, 'TooltipString', TooltipString); next_row(y);
    
    varargout{1} = x;
    varargout{2} = y;
    
    

%% add_sma_states

    % ------------------------------------------------------------------------
    %
    %   CASE ADD_SMA_STATES
    %
    % ------------------------------------------------------------------------
    
  case 'add_sma_states'
    if nargin < 4, error('SOFTPOKESTAY:nargin', 'action=add_sma_states requires sps_name and sma as next arguments'); end;
    sma   = x;
    if ~isa(sma, 'StateMachineAssembler'), error('SOFTPOKESTAY:badargs', 'action=add_sma_states requires the 4th arg to be a @StateMachineAssembler object'); end;

    if     nargin == 5, varargin = {y};
    elseif nargin > 5,  varargin = [{y} varargin];
    end;
    pairs = { ...
      'success_exitstate_name'    'current_state+2' ; ...
      'abort_exitstate_name'      'current_state+1' ; ...
      'pokeid'                    '' ; ...
      'DOut'                      1/2; ... % <~> -1 changed to 1/2. We need to take the log2 of DOut to get the channel number. As the log2 command is added below, this value is adjusted to result in -1 after the log2. Bugfix 2007.Dec.17 19:07.
      'DOutStartTime'            1e6 ; ...
      'DOutOnTime'               1e6 ; ...
      'Sound1TrigTime'           1e6 ; ...
      'Sound1Id'                   0 ; ...
      'Sound2TriggeringEvent'  'null' ; ...
      'Sound2Id'                   0 ; ... 
      'InitialSchedWaveTrig'  'null' ; ...
    }; parseargs(varargin, pairs);
    if isempty(success_exitstate_name) ||  isempty(abort_exitstate_name), 
      error('SOFTPOKESTAY:badargs', ['action=add_sma_states requires the name-value pairs ''success_exitstate_name''\n' ...
        'and ''abort_exitstate_name'' to be given explicit defined values-- default values not legal.']);
    end;
    if ~ismember(pokeid, {'C' 'L' 'R'}),
      error('SOFTPOKESTAY:badargs', 'pokeid must be one of ''C'' ''L'' or ''R''');
    end;
    Sound1TrigTime = max(0.001, Sound1TrigTime); %#ok<NODEF> % No triggers before we go past first state.
    DOutStartTime  = max(0.001, DOutStartTime);  %#ok<NODEF> % No triggers before we go past first state.

    otherpokes = setdiff({'C' 'L' 'R'}, pokeid);
    Nin  = [pokeid 'in'];
    Nout = [pokeid 'out'];
    other1_In = [otherpokes{1} 'in'];
    other2_In = [otherpokes{2} 'in'];
    
    Grace    = value(eval([pname '_Grace']));
    Duration = value(eval([pname '_Duration']));
    
    sma = add_scheduled_wave(sma, 'name', [pname '_Duration'], 'preamble', Duration);    
    sma = add_scheduled_wave(sma, 'name', [pname '_Sound1'],   'preamble', Sound1TrigTime);
    sma = add_scheduled_wave(sma, 'name', [pname '_DOutWave'], 'preamble', DOutStartTime, 'sustain', DOutOnTime); 
    sma = add_scheduled_wave(sma, 'name', [pname '_Grace'],    'preamble', Grace);

    for guys = {'Duration' 'DOutWave' 'Sound1' 'Grace'},
      eval(sprintf('%s     = [pname ''_%s''];',     guys{1}, guys{1}));
      eval(sprintf('%s_In  = [pname ''_%s_In''];',  guys{1}, guys{1}));
      eval(sprintf('%s_Out = [pname ''_%s_Out''];', guys{1}, guys{1}));
    end;
    Sound2_In = Sound2TriggeringEvent;
    
    sma = add_state(sma, 'name', pname, 'self_timer', 0.0001, ...
      'output_actions', {'SchedWaveTrig',  [Duration ' + ' DOutWave ' + ' ...
                                            Sound1 ' + ' InitialSchedWaveTrig]}, ...
      'input_to_statechange', {'Tup', 'current_state+1'}); % nose in

    % -- 1) NoseIn, Doff ---
    sma = add_state(sma, 'name', 'NoseInDoff', ...
      'output_actions', {'SchedWaveTrig', ['-' Grace]}, ...
      'input_to_statechange', { ...
      Duration_In,  'success_cleanup', ... 
      Nout,         'StartNoseOutDoff', ...
      DOutWave_In,      'NoseInDon', ...
      Sound1_In,    'NoseInDoffSound1Trig', ... 
      Sound2_In,    'NoseInDoffSound2Trig'}); 
    
    % -- 2) Start Nose Out, Doff  ---
    sma = add_state(sma, 'name', 'StartNoseOutDoff', 'self_timer', 0.0001, ...
      'output_actions', {'SchedWaveTrig', Grace}, ...
      'input_to_statechange', { ...
      'Tup', 'NoseOutDoff', ...  % Nose out
      Duration_In,  'success_cleanup', ... 
      Nin,          'NoseInDoff', ...
      other1_In,    'abort_cleanup', ...
      other2_In,    'abort_cleanup', ...
      DOutWave_In,  'NoseOutDon', ...
      Sound1_In,    'NoseOutDoffSound1Trig', ... 
      Sound2_In,    'NoseOutDoffSound2Trig'}); 

    % -- 3) Nose Out, Doff  ---
    sma = add_state(sma, 'name', 'NoseOutDoff', ...
      'input_to_statechange', { ...
      Grace_In,     'abort_cleanup', ...
      Duration_In,  'success_cleanup', ... 
      Nin,          'NoseInDoff', ...
      other1_In,    'abort_cleanup', ...
      other2_In,    'abort_cleanup', ...
      DOutWave_In,  'NoseOutDon', ...
      Sound1_In,    'NoseOutDoffSound1Trig', ... 
      Sound2_In,    'NoseOutDoffSound2Trig'}); 
        
    % -- 4) NoseIn, Don ---
    sma = add_state(sma, 'name', 'NoseInDon', ...
      'output_actions', {'SchedWaveTrig', ['-' Grace], 'DOut', DOut}, ...
      'input_to_statechange', { ...
      Duration_In,  'success_cleanup', ... 
      Nout,         'StartNoseOutDon', ...
      DOutWave_Out, 'NoseInDoff', ...
      Sound1_In,    'NoseInDonSound1Trig', ... 
      Sound2_In,    'NoseInDonSound2Trig'}); 
    
    % -- 5) Start Nose Out, Don  ---
    sma = add_state(sma, 'name', 'StartNoseOutDon', 'self_timer', 0.0001, ...
      'output_actions', {'SchedWaveTrig', Grace, 'DOut', DOut}, ...
      'input_to_statechange', { ...
      'Tup', 'NoseOutDon', ...  % Nose out
      Duration_In,  'success_cleanup', ... 
      Nin,          'NoseInDon', ...
      other1_In,    'abort_cleanup', ...
      other2_In,    'abort_cleanup', ...
      DOutWave_Out, 'NoseOutDoff', ...
      Sound1_In,    'NoseOutDonSound1Trig', ... 
      Sound2_In,    'NoseOutDonSound2Trig'}); 

    % -- 6) Nose Out, Don  ---
    sma = add_state(sma, 'name', 'NoseOutDon', ...
      'output_actions', {'DOut', DOut}, ...
      'input_to_statechange', { ...
      Grace_In,     'abort_cleanup', ...
      Duration_In,  'success_cleanup', ... 
      Nin,          'NoseInDon', ...
      other1_In,    'abort_cleanup', ...
      other2_In,    'abort_cleanup', ...
      DOutWave_Out, 'NoseOutDoff', ...
      Sound1_In,    'NoseOutDonSound1Trig', ... 
      Sound2_In,    'NoseOutDonSound2Trig'}); 
    
    % ---------------
    % -- 7) Nose In, DOut off Sound 1 Trig    
    sma = add_state(sma, 'name', 'NoseInDoffSound1Trig', 'self_timer', 0.0001, ...
      'output_actions', {'SoundOut', Sound1Id}, ...
      'input_to_statechange', { ...
      'Tup',        'NoseInDoff', ...
      Duration_In,  'success_cleanup', ... 
      Nout,         'StartNoseOutDoff', ...
      DOutWave_In,  'NoseInDon', ...
      Sound2_In,    'NoseInDoffSound2Trig'}); 

    % -- 8) Nose In, DOut off Sound 2 Trig    
    sma = add_state(sma, 'name', 'NoseInDoffSound2Trig', 'self_timer', 0.0001, ...
      'output_actions', {'SoundOut', Sound2Id}, ...
      'input_to_statechange', { ...
      'Tup',        'NoseInDoff', ...
      Duration_In,  'success_cleanup', ... 
      Nout,         'StartNoseOutDoff', ...
      DOutWave_In,  'NoseInDon', ...
      Sound1_In,    'NoseInDoffSound1Trig'}); 
    
    % ---------------
    % -- 9) Nose In, DOut on Sound 1 Trig    
    sma = add_state(sma, 'name', 'NoseInDonSound1Trig', 'self_timer', 0.0001, ...
      'output_actions', {'SoundOut', Sound1Id, 'DOut', DOut}, ...
      'input_to_statechange', { ...
      'Tup',        'NoseInDon', ...
      Duration_In,  'success_cleanup', ... 
      Nout,         'StartNoseOutDon', ...
      DOutWave_Out, 'NoseInDoff', ...
      Sound2_In,    'NoseInDonSound2Trig'}); 

    % -- 10) Nose In, DOut on Sound 2 Trig    
    sma = add_state(sma, 'name', 'NoseInDonSound2Trig', 'self_timer', 0.0001, ...
      'output_actions', {'SoundOut', Sound2Id, 'DOut', DOut}, ...
      'input_to_statechange', { ...
      'Tup',        'NoseInDon', ...
      Duration_In,  'success_cleanup', ... 
      Nout,         'StartNoseOutDon', ...
      DOutWave_Out, 'NoseInDoff', ...
      Sound1_In,    'NoseInDonSound1Trig'}); 

    
    % ---------------
    % -- 11) Nose Out, Doff  Sound 1 Trig ---
    sma = add_state(sma, 'name', 'NoseOutDoffSound1Trig', 'self_timer', 0.0001, ...
      'output_actions', {'SoundOut', Sound1Id}, ...
      'input_to_statechange', { ...
      'Tup',        'NoseOutDoff', ...
      Grace_In,     'abort_cleanup', ...
      Duration_In,  'success_cleanup', ... 
      Nin,          'NoseInDoff', ...
      other1_In,    'abort_cleanup', ...
      other2_In,    'abort_cleanup', ...
      DOutWave_In,  'NoseOutDon', ...
      Sound2_In,    'NoseOutDoffSound2Trig'}); 

    % -- 12) Nose Out, Doff  Sound 2 Trig ---
    sma = add_state(sma, 'name', 'NoseOutDoffSound2Trig', 'self_timer', 0.0001, ...
      'output_actions', {'SoundOut', Sound2Id}, ...
      'input_to_statechange', { ...
      'Tup',        'NoseOutDoff', ...
      Grace_In,     'abort_cleanup', ...
      Duration_In,  'success_cleanup', ... 
      Nin,          'NoseInDoff', ...
      other1_In,    'abort_cleanup', ...
      other2_In,    'abort_cleanup', ...
      DOutWave_In,  'NoseOutDon', ...
      Sound1_In,    'NoseOutDoffSound1Trig'}); 

    % ---------------
    % -- 13) Nose Out, Don  Sound 1 Trig ---
    sma = add_state(sma, 'name', 'NoseOutDonSound1Trig', 'self_timer', 0.0001, ...
      'output_actions', {'SoundOut', Sound1Id, 'DOut', DOut}, ...
      'input_to_statechange', { ...
      'Tup',        'NoseOutDon', ...
      Grace_In,     'abort_cleanup', ...
      Duration_In,  'success_cleanup', ... 
      Nin,          'NoseInDon', ...
      other1_In,    'abort_cleanup', ...
      other2_In,    'abort_cleanup', ...
      DOutWave_Out, 'NoseOutDoff', ...
      Sound2_In,    'NoseOutDoffSound2Trig'}); 

    % -- 14) Nose Out, Don  Sound 2 Trig ---
    sma = add_state(sma, 'name', 'NoseOutDonSound2Trig', 'self_timer', 0.0001, ...
      'output_actions', {'SoundOut', Sound2Id}, ...
      'input_to_statechange', { ...
      'Tup',        'NoseOutDoff', ...
      Grace_In,     'abort_cleanup', ...
      Duration_In,  'success_cleanup', ... 
      Nin,          'NoseInDoff', ...
      other1_In,    'abort_cleanup', ...
      other2_In,    'abort_cleanup', ...
      DOutWave_Out, 'NoseOutDoff', ...
      Sound1_In,    'NoseOutDoffSound1Trig'}); 

    
    % -- 5) Success cleanup and exit
    sma = add_state(sma, 'name', 'success_cleanup', 'self_timer', 0.0001, ...
      'output_actions', {'SoundOut', -abs(Sound1Id), ...
      'SchedWaveTrig', ['-(' Duration ' + ' Grace ' + ' Sound1 ' + ' DOutWave ')']}, ...
      'input_to_statechange', {'Tup', success_exitstate_name});
    
    % -- 6) Abort cleanup and exit
    sma = add_state(sma, 'name', 'abort_cleanup', 'self_timer', 0.0001, ...
      'output_actions', {'SoundOut', -abs(Sound1Id), ...
      'SchedWaveTrig', ['-(' Duration ' + ' Grace ' + ' Sound1 ' + ' DOutWave ')']}, ...
      'input_to_statechange', {'Tup', abort_exitstate_name});

    mystates = {'NoseInDoff', 'StartNoseOutDoff', 'NoseOutDoff', ...
      'NoseInDon', 'StartNoseOutDon', 'NoseOutDon', 'NoseInDoffSound1Trig', ...
      'NoseInDoffSound2Trig', 'NoseInDonSound1Trig', 'NoseInDonSound2Trig',  ...
      'NoseOutDoffSound1Trig', 'NoseOutDoffSound2Trig', ...
      'NoseOutDonSound1Trig', 'NoseOutDonSound2Trig', 'success_cleanup', 'abort_cleanup'};    
    % sma = rename_states(sma, mystates, pname, 'since_state', pname);
    
    varargout{1} = sma;
    
    
    
%% set

    % ---------  CASE SET ------

  case 'set',
    varargin = [{x y} varargin];
    while ~isempty(varargin),
      if length(varargin)<2,
        error('SoftPokeStayInterface:BadArgs', '"set" needs name-value pairs');
      end;
      param = varargin{1}; newvalue = varargin{2}; 

      try
        sph = eval([pname '_' param]);
      catch
        warning('SOFTPOKESTAY:Not_found', 'Couldn''t find parameter named %s, nothing changed', [pname '_' param]);
        return;
      end;
      sph.value = newvalue;
      callback(sph);
      
      varargin = varargin(3:end);
    end;
    
    
%% get

    % ---------  CASE GET ------

  case 'get',
    param = x; 

    try
      sph = eval([pname '_' param]);
      varargout{1} = value(sph);
    catch
      warning('SOFTPOKESTAY:Not_found', 'Couldn''t find parameter named %s, returning NaN', [pname '_' param]);
      varargout{1} = NaN;
    end;
    
 
%% disable

    % ------------------------------------------------------------------------
    %
    %   CASE DISABLE
    %
    % ------------------------------------------------------------------------

      
  case 'disable'
    disable(eval([pname '_Duration']));
    disable(eval([pname '_Grace']));
    
    
%% enable

    % ------------------------------------------------------------------------
    %
    %   CASE ENABLE
    %
    % ------------------------------------------------------------------------

      
  case 'enable'
    enable(eval([pname '_Duration']));
    enable(eval([pname '_Grace']));

   
    
%% close_all    
      
  case 'close_all',       % ---------- CASE CLOSE_ALL -------------
    % Delete all SoloParamHandles who belong to this object and whose
    % fullname starts with the name of this mfile:
    delete_sphandle('owner', ['^@' class(obj) '$'], ...
      'fullname', ['^' mfilename]);
    


  otherwise,
    warning('SoftPokeStayInterface:Invalid', 'Don''t know action "%s", doing nothing', action);
   


end;








