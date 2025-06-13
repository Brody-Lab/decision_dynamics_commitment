% [sma] = add_trialnum_indicator(sma, trialnum, {'indicator_states_name', 'sending_trialnum'}, ...
%                           {'time_per_state', 3e-4}, {'preamble', [1]}, 'DIOLINE', 'from_settings')
%
% The intent behind this method is to provide a time-sync signal on a DIO
% line, indicating start of a trial, for use by neural recording systems.
% That same signal is also used to indicate the trial number.
%
% When this method is called, the sma will be modified so that state_0
% will not jump straight to the user's first state, but will instead first
% go through a very swift sequence of states that put out, on one of the DIO
% lines, a binary signature of the number trialnum; after that, there is a
% jump to the user's first state. None of the user-defined states are
% changed by a call to this method.
%
% The signal on the DIO line will be: High,
% followed by a a 15-bit binary representation of trialnum (1 is High, 0 is
% Low), with most significant bit sent out first. That is, we go through a
% total of 16 states that cover both the initial sync signal and the
% trialnum. The default is to go through each of these states in 1/3th of a
% ms, twice the FSM's cycle time. This
% can be modified using the optional argument 'time_per_state'. All of
% these added states will have the name 'sending_trialnum'.
% 
% This method can ONLY be used with StateMachineAssemblers that were
% initialized with the 'full_trial_structure' flag. 
%
% The DIO line on which all this will happen is determined, by default,
% using the Settings.m system, with DIOLINES; trialnum_indicator being the
% setting name. For example, the line 
%      DIOLINES; trialnum_indicator; 32
% in Settings_Custom.conf would mean DIO line 6 (in binary, 32 is 100000,
% so it is the 6th bit). If no such setting is found, no DOut is generated.
%
%
% RETURNS: 
% --------
%
% sma      The updated State Machine Assembler object, after the
%          trialnum-sending states have been added.
%
%
% PARAMETERS:
% -----------
%
% sma      The instantiation of the StateMachineAssembler object to which
%          the new states will be added.
%
%
% OPTIONAL PARAMETERS:
% --------------------
%
% 'time_per_state'    A scalar positive number indicating the time, in
%          seconds, that will be spent on each of the states, that put out
%          a signal. Default is 1/3 of a ms. Total time for all added
%          states will be time_per_state*(15+length(preamble)).
%
% 'preamble'  Sync signal that is sent before the trialnum. Default is
%         [1], meaning a single High bit.
%
% 'indicator_states_name'   String that defines the name of all the states
%          that will be added by this method. Default is
%          'sending_trialnum_data'.
%
% 'DIOLINE'  Default value is the string 'from_settings', which indicates
%          that the Settings.m system should be used to find setting named
%          DIOLINES; trialnum_indicator. However, you can use this optional
%          parameter to override the value from the settings files.
% 
 
% Written by Carlos Brody Aug 2007

function [sma] = add_trialnum_indicator(sma, trialnum, varargin)
   
   time_per_state = []; %     hack: time_per_state is a function. unfortunately, assignin (called by parseargs below) will fail when what it is assigning already exists with some meaning. This must be fixed. Perhaps if evalin does not have the same problem, we can evalin to 0 first, then assignin.  -s & CB
   pairs = { ...
     'time_per_state'         800e-6      ;  ...
     'preamble'               [1]  ;  ...
     'indicator_states_name'  'sending_trialnum' ; ...  
     'DIOLINE'                'from_settings'    ;  ...
   }; parseargs(varargin, pairs);
   
% NOTE: even though 'time_per_state' is 0.8 ms, the actual time per state is
% 1 ms, which is the nearest multiple of the FSM clock.
% Experimentation shows that requesting exactly 0.5 ms often gives states
% that are 1 ms but sometimes 0.5 ms, but asking for 0.8 gives 1

   nbits = 15;  % This is the number of bits used to encode trialnum.
 
   if strcmp(DIOLINE, 'from_settings'),
     % Try the settings system; if any problem, set to zero meaning go
     % through states, but do nothing.
     try, DIOLINE = bSettings('get', 'DIOLINES', 'trialnum_indicator');
     catch, DIOLINE = 0;
         return
     end;
   end;
   if isnan(DIOLINE), DIOLINE = 0; end;
 
   % --- BEGIN error_checking ---
   if ~is_full_trial_structure(sma),
     error(['Sorry, ' mfilename ' can only be used with StateMachineAssemblers ' ...
       'initialized with the ''full_trial_structure'' flag on']);
   end;
   if nargin < 2, error('Need at least two args, sma and trialnum'); end;
   % --- END error checking ---

   orig_current_state = sma.current_state;
   % Temporarily set current_state marker to state 1, so we start adding
   % states there:
   sma.current_state = 1;

   % Now add the set of states going through the signal:
   dout = preamble(1);  % The preamble is a numeric vector.
   sma = add_state(sma, 'name', indicator_states_name, 'self_timer', time_per_state, ...
     'input_to_statechange', {'Tup', 'current_state+1'}, ...
     'output_actions', {'DOut', sma.default_DOut + dout*DIOLINE});

   for i=2:length(preamble)
     dout = preamble(i);  % The preamble is a numeric vector.
     sma = add_state(sma, 'self_timer', time_per_state, ...
       'input_to_statechange', {'Tup', 'current_state+1'}, ...
       'output_actions', {'DOut', sma.default_DOut + dout*DIOLINE});       
   end;
   trialnum = dec2bin(trialnum);
   trialnum = ['0'*ones(1, nbits-length(trialnum)) trialnum];
   for i=1:length(trialnum),
     dout = str2num(trialnum(i));  % trialnum at this point is char vector
     sma = add_state(sma, 'self_timer', time_per_state, ...
       'input_to_statechange', {'Tup', 'current_state+1'}, ...
       'output_actions', {'DOut', sma.default_DOut + dout*DIOLINE});          
   end;
   
   % Now change the Tup action of the last added state to jump to state 40,
   % the regular first user state in 'full_trial_structure'.
   TupCol = find(strcmp('Tup', sma.input_map(:,1))); TupCol = sma.input_map{TupCol,2};
   sma.states{sma.current_state, TupCol} = 40;
   
   % Now change state_0 so it jumps to state 1 instead of state 40:
   all_input_cols = cell2mat(sma.input_map(:,2))';
   for i=1:length(all_input_cols), sma.states{1,all_input_cols(i)} = 1; end;
   
   % We're done: return the current_state marker to its proper value.
   sma.current_state = orig_current_state;   
   
   return;
   