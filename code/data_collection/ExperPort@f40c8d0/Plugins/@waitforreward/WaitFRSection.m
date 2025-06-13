
% [varargout] = WaitFRSection(obj,action,varargin)  
%   
% A plugin that implements a "wait for reward" paradigm, whereby a subject  
% not only must make their response, but also stay at the response port for a 
% variable amount of time until reward is delievered.  If the subject leaves 
% the choice port before the reward is delivered they forfeit the reward on 
% that trial.
%
% The goal of this is to assess the confidence of the subject on each trial, 
% in addition to their choice.
%
% To use you must 
% 1) include the plugin in your class definition for your protocol
% 2) Initialize the plugin in your protocol init code:
%       [x, y] = WaitFRSection(obj, 'init', x, y); 
% 3) Call the plugin from your SMA section
 
%   sma = WaitFRSection(obj, 'add_states', sma,correct_poke,valve_time,{options});
% 
% By default the first state will be called "wait_for_spoke" and the exit
% state will simply be "current_state+1".
% Several states will get added by the plugin:
% "wait_for_spoke" : This is the first state of the plugin. 
%        This state will exit to "hit_state" on correct_poke. 
%        After errors the FSM will pass through "miss_state" 
% After "hit_state" or "miss_state" the plugin will generate a series of states that
% require the subject to stay (with allowed breaks as a parameter) at the
% reward port until delivery (or non-delivery, i.e. +inf wait time ). 
% If the animal successfully waits for reward they will pass through
% a "reward_delivered" state. If they abort they will pass through
% "reward_aborted".  On miss trials there will always be a "reward_aborted" 
% which will indicate when the rat gave up. After the "reward_delivered" 
% or "reward_aborted" the FSM will continue to the next state added in the
% SMA section.  Alternatively, pass in optional arguments for 'reward_exit'
% and 'abort_exit' to allow for seperate "paths" through the fsm after
% exit.
%
% Optional Parameters:
% "reward_exit": a named state that the plugin will exit to after successful wait.  defaults to
%   "current_state+1"
% "abort_exit": a named state that the plugin will exit to after abort.  defaults to
%   "current_state+1"
% "statename_suffix": defaults to "_wfrs" to avoid naming conflicts.
%
%
% Most details of the wait time will be set by NumEdit params in the
% waitforreward gui.  Please read through the init section to see the list
% of parameters.

function [x,y]=WaitFRSection(obj,action,varargin)


GetSoloFunctionArgs(obj);

switch action,

case init,
	%% Initialize


    if length(varargin) < 2,
      error('Need at least two arguments, x and y position, to initialize %s', mfilename);
    end;
    x = varargin{1}; y = varargin{2};
    
    SoloParamHandle(obj, 'my_xyfig', 'value', [x y double(gcf)]);
    ToggleParam(obj, 'WFRShow', 0, x, y, 'OnString', 'WaitForReward showing', ...
      'OffString', 'WaitForReward hidden', 'TooltipString', 'Show/Hide panel'); 
    set_callback(WFRShow, {mfilename, 'show_hide'}); %#ok<NODEF> (Defined just above)
    next_row(y);

    SoloParamHandle(obj, 'myfig', 'value', double(figure('Position', [100 100 560 440], ...
      'closerequestfcn', [mfilename '(' class(obj) ', ''hide'');'], 'MenuBar', 'none', ...
      'Name', mfilename)), 'saveable', 0);
    set(gcf, 'Visible', 'off');

    tx=10; ty=10;

    [tx,ty]=DistribInterface(obj,'add','WaitTime',tx,ty,'Style','exponential','Tau',0.01,'Min',0.001,'Max',100);
    NumeditParam(obj,'legal_rew_break',0.3,tx,ty,'Label','Legal Poke Break','TootipString','Leaving side port for less than this time will not count as an abort.  But will need to re-enter port to trigger reward.')
    next_row(y);
    NumeditParam(obj,'wait_for_spoke_TO',10,tx,ty,'Label','Wait for spoke Timeout','TootipString','How long to wait for initial side poke.  This starts the wait time')


    
    case add_states,
        
        sma=varargin{1};
        cp=varargin{2};
        valve_time=varargin{3};
        varargin=varargin(4:end);
        reward_exit='current_state+1';
        abort_exit='current_state+1';
        statename_suffix='_wfrs';
        wait_for_sto=wait_for_spoke_TO+0;
        overridedefaults(who,varargin);
        wait_time=DistribInterface(obj,'get_new_sample','WaitTime');
        ss=statename_suffix;
        
        if cp=='r'
           goodhi='Rhi'; goodlo='Rlo';
           badhi='Lhi';  badlo='Llo';
        elseif cp=='l'
           goodhi='Lhi'; goodlo='Llo';
           badhi='Rhi'; badlo='Rlo';
        else
            error('only can handle left and right');
        end
            
        sma=add_scheduled_wave(sma,'name',['waitforit_wave' ss],'preamble',wait_time,'sustain',0.1);
        
        sma=add_state(sma,'name',['wait_for_spoke' ss],...
            'self_timer',wait_for_sto,...
            'input_to_statechange',{'Tup',abort_exit;...
            badpoke, ['wait_norew' ss]; goodpoke, ['wait_forrew' ss]});

        sma=add_state(sma,'name',['wait_norew' ss],...
            'input_to_statechange',{badlo, 'current_state+1'});
        
        sma=add_state(sma,'self_time',legal_rew_break+0,...
            'input_to_statechange',{badhi,'current_state-1';...
            'Tup',abort_exit; 'Chi',abort_exit;goodhi,abort_exit;});
        
        
        
        
        
        

%% SHOWHIDE
  case 'hide',
    WFRShow.value = 0; set(value(myfig), 'Visible', 'off');

  case 'show',
    WFRShow.value = 1; set(value(myfig), 'Visible', 'on');

  case 'show_hide',
    if WFRShow == 1, set(value(myfig), 'Visible', 'on'); %#ok<NODEF> (defined by GetSoloFunctionArgs)
    else                   set(value(myfig), 'Visible', 'off');
    end;
    
    
  % ------------------------------------------------------------------
  %              CLOSE
  % ------------------------------------------------------------------    
  case 'close'    
    if exist('myfig', 'var') && isa(myfig, 'SoloParamHandle') && ishandle(value(myfig)),
      delete(value(myfig));
    end;    
    delete_sphandle('owner', ['^@' class(obj) '$'], 'fullname', ['^' mfilename '_']);

end