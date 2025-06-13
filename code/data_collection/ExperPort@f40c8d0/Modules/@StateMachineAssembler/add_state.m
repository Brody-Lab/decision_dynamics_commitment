% [sma] = add_state( sma,                                     ... %required
%                   'name',                 '',               ... %optional
%                   'iti_state',            0,                ... %optional
%                   'output_actions',       [],               ... %optional
%                   'input_to_statechange', {},               ... %optional
%                   'self_timer',           100,              ... %optional
%                   'default_statechange',  'current_state',  ... %optional
%                   'entryfunc'             '',               ... %optional
%                   'entrycode'             '',               ... %optional
%                   'exitfunc'              '',               ... %optional
%                   'exitcode'              '',               ... %optional
%                  );
%
% Adds a new state to the list of states registered with the sma State
% Machine assembler object. Returns the updated sma object.
%
% RETURNS: 
% --------
%
% sma      The updated State Machine Assembler object, after the new state
%          has been added.
%
%
% PARAMETERS:
% -----------
%
% sma      The instantiation of the StateMachineAssembler object to which
%          the new state will be added.
%
%
% OPTIONAL PARAMETERS:
% --------------------
%
% name     A string that indicates the name of the new state to be added.
%          It is an error to add a state with a name that was previously 
%          added to this sma. If this parameter is not passed, then the
%          state will still exist but will not have a specific name. The
%          very first state will have the name 'state_0' by default.
%
% iti_state   A scalar, either 0 or 1. Default value is 0. This scalar is
%          only relevant if the state machine assembler was initialised
%          using the 'no_dead_time_technology' flag (see
%          StateMachineAssembler.m). If iti_state is passed as 1, it
%          indicates that the state being added belongs to the set of
%          states that run in the iti, the Inter-Trial-Interval (i,e.,
%          whatever time exists in between the end of one trial and the
%          start of the next). Default value for this parameter is 0. For
%          information on the 'no_dead_time_technology', see
%          StateMachineAssembler.m
% 
% output_actions   An n-by-2  cell that indicates what the outputs, 
%          issued to the world by the state being added, should be. The
%          kinds of outputs a state may have are: (1) DOut, Digital Output
%          signals (lines on the DIO card that stay high or low, as
%          indicated, as long as the machine remains in this state); (2)
%          SoundOut, triggering start of playing sounds or turning sounds
%          off; (3) SchedWaveTrig, triggering start of Scheduled Waves (or
%          turning them off). This last type can only be used if at least one
%          scheduled wave has already been registered (see
%          add_scheduled_waves.m).
%             For each type of output you want to specify, the output_actions 
%          cell should have a corresponding row. The first element in the
%          row indicates the type of output, with the element being one of
%          the three strings: 'Dout' or 'SoundOut' or 'SchedWaveTtrig'. The
%          second element in the row indicates the specific outputs of this
%          type that should be issued. Row types that are missing are
%          assumed to have no outputs from the current state.
%
%          'Dout' : The second element of a DOut row should be a binary
%          number that indicates the state of the digital output lines of 
%          the DIO card. The lowest digit corresponds to line 1; the next 
%          highest digit to line 2; etc. Thus {'DOut', 9} indicates that 
%          the first and the fourth DIO lines should be high, all others
%          low. Unspecified DIO lines are low by default. (In a typical
%          application, using the Solo system, what each line is connected
%          to is indicated in mystartup.m. For example, that is where
%          globals called left1water and left1led are defined, so that if
%          we wanted to turn on the left water and the left LED, we could
%          write: {'DOut', left1water + left1led}. ) Digital lines take on
%          the indicated values as soon as we enter the current state, and
%          remain at those values until we exit the state.
%
%          'SoundOut' : The second element of SoundOut row should be a
%          binary number that indicates the identity of the sound being
%          turned on or off. A positive number means a
%          sound being triggered ON; a negative number means a sound being
%          turned OFF. Thus, for example, {'SoundOut', 5} means "start
%          playing sound 5" and {'SoundOut', -6} means "turn off 
%          sound 6."  Note that sounds are defined (e.g., what sound
%          n means) using the SoundMachineServer, not the
%          StateMachineServer. Sounds are turned on or off at state
%          transitions: that is, when first entering the current state. 
%          After that, no new sound on/off commands will be issued while we
%          remain in the current state. Only one sound can be turned on or
%          off per state; use a sequence of rapid states to turn many
%          sounds on or off.
%
%          'SchedWaveTrig' : The second element of a SchedWaveTrig row
%          should be a *string* (not a number!) that identifies which
%          scheduled waves should be triggered on at the time of entering 
%          the current state. We use the *names* of the scheduled waves, as
%          used with @StateMAchineAssembler/add_scheduled_wave.m . Thus,
%          for example, {'SchedWaveTrig', 'mywave'} indicates that on
%          entering the current state, a previously registered scheduled
%          wave called 'mywave' should be started. To start multiple waves,
%          use the + symbol. Thus, the following syntax is allowed to start
%          two waves at once: {'SchedWaveTrig', 'mywave1 + mywave2'}. The
%          string 'null' is valid, and has no effect. Thus
%          {'SchedWaveTrig', 'mywave+null'} is the same as 
%          {'SchedWaveTrig', 'mywave'}
%              You can use the - sign to indicate UNtriggering of waves.
%          However, note that you can only do ALL triggering or ALL
%          UNtriggering in one command, you can't mix them up. (The reason
%          is that currently all the triggering/untriggering from a single 
%          state are mixed into a single unsigned 32-bit mask. If you mix,
%          the mask loses meaning.) Thus you can do this: 
%             {'SchedWaveTrig', '-mywave1-mywave2'}   to untrigger both
%             waves,
%          but do NOT use the following, it'll result in meaningless
%          behavior:
%             {'SchedWaveTrig', '-mywave1+mywave2'}   to untrigger both
%
% self_timer   A scalar, default 100, that represents how many seconds after 
%          transitioning to this state from a different state a Tup event 
%          should be triggered. Whenever the state the system is in
%          changes, i.e., there is a state transition, there is a clock
%          that gets reset to 0 and that starts running. When that clock
%          hits the value of 'self-timer', a 'Tup' event gets generated. By
%          default, self_timer is 100 secs. Thus, if you want to stay in a
%          state for three seconds and then jump to state 'bluh', you
%          might write:
%               sma = add_state('self_timer', 3, 'input_to_statechange', ...
%               {'Tup', 'bluh'});
%
% input_to_statechange   A 2-by-n cell, by default empty, that lists what state
%          transitions should ensue in response to the different possible
%          input events that can happen. The response to input events not
%          listed in the input_to_statechange cell are to transition to the
%          value of 'default_statechange' (see below), which itself by
%          default is simply the current state. (Note that when a state
%          tries to transition to itself, that simply counts as no
%          transition occurring. ** Double check this is true for purposes
%          of sound triggering **) The first element of each row of the
%          input_to_statechange cell should be a string indicating the
%          event type; the second element should be a string indicating
%          the name of state to jump to in response to that event. 
%             The types of events that are recognized by default are:
%              'Tup'     the self_timer alarm (see 'self_timer' above).
%              'Cin'     center poke beam has just been broken
%              'Cout'    center poke beam has just been reestablished
%              'Lin'     left   poke beam has just been broken
%              'Lout'    left   poke beam has just been reestablished
%              'Rin'     right  poke beam has just been broken
%              'Rout'    right  poke beam has just been reestablished
%              'Chi'     center poke beam is already broken upon state entry
%              'Clo'     center poke beam is already established upon state entry
%              'Lhi'     left poke beam is already broken upon state entry
%              'Llo'     left poke beam is already established upon state entry
%              'Rhi'     right poke beam is already broken upon state entry
%              'Rlo'     right poke beam is already established upon state entry
%              'null'    no actual event matches this string; it has no effect.
%             In addition, every scheduled wave registered creates two new
%             events that can be used in the input_to_statechange cell.
%             (See add_scheduled_wave.m for information on scheduled
%             waves.) A wave with name 'blah' generates events 'blah_In'
%             when the preamble ends; and 'blah_Out' when the sustain ends.
%          There two special reserved words that can be used to indicate
%          states: 'current_state' stands for the current state being
%          added, whatever that is. In addition, simple arithemtic can be
%          used; for example, to jump to the next state, one could write
%          'current_state+1'. The second special reserved word is
%          'state35', which is used only if the 'no_dead_time_technology'
%          flag was used when the StateMachineAssembler object was created
%          (see StateMachineAssembler.m). 
%             Thus, for example, an input_to_statechange map that says to
%          jump to state 'red' upon a center poke; to jump to state 'goog'
%          if the preamble of the scheduled wave named 'fifi' ends; but jump
%          to the state added immediately after the current state if the
%          sustain of 'fifi' ends while we were in the current state; and
%          jump to the state added immediately after 'goog' if a right poke
%          happens, would be passed as:
%             'input_to_statechange', {'Cin',      'red'  ; ...
%                                      'fifi_In',  'goog' ; ...
%                                      'fifi_Out', 'current_state+1' ; ...
%                                      'Rin',      'goog+1'}
%
% default_statechange   A string, by default 'current_state'. This is the
%          state to jump to whenever any event not explicitly listed in the
%          input_to_statechange map happens (see above for
%          input_to_statechange).
%
%
%
% Additional features of new embedded C RT system below. NOT IMPLEMENTED YET
%     
% entryfunc
%   String, name of the C function to call upon entry into this state (the
%   state being added). The functions has type void(*)(void) and will be
%   called whenever said this state is entered, but before outputs are done
%   Note that the entryfuncs are called only when a new state is entered
%   and not for state transitions that 'jump to self'.  This is in
%   accordance with the state output semantics.
%
% entrycode
%   String, C expressions. Code gets executed upon state entry, inserted
%   into a C statement block '{ }'. Globals declared in the globals code
%   are available, and local variables can be defined. With entryfuncs you
%   specify just function names that need to be defined elsewhere (in the
%   'globals' section), whereas with this code you give actual C code that
%   gets executed upon entry into the state being added.
%
% exitfunc
%   As entryfunc, except called upon state exit.
%
% exitcode
%   As entrycode above, but upon exit.
%
%
%<~>TODO: Add examples using new RT system functionality below.
%
% EXAMPLES:
% ----------
%
% The following sequence of states will turn the left, center, and right
% lights on each for a second in succession; but if a center poke occurs or
% the preamble of the wave 'mywave' ends while this is happening, will jump
% to state 'yikes'.
%
%     sma = add_state(sma, 'name', 'light_sequence', 'self_timer', 1, ...
%             'output_actions', {'DOut', left1led}, ...
%             'input_to_statechange', {'Tup',       'current_state+1' ; ...
%                                      'Cin',       'yikes' ; ...
%                                      'mywave_In', 'yikes'});
%     sma = add_state(sma, 'self_timer', 1, 'output_actions', {'DOut', center1led}), ...
%             'input_to_statechange', {'Tup',       'current_state+1' ; ...
%                                      'Cin',       'yikes' ; ...
%                                      'mywave_In', 'yikes'});
%     sma = add_state(sma, 'self_timer', 1, 'output_actions', {'DOut', right1led}), ...
%             'input_to_statechange', {'Tup',       'current_state-2' ; ...
%                                      'Cin',       'yikes' ; ...
%                                      'mywave_In', 'yikes'});
%             
%
% Notice how we named only the first state of this sequence-- if you name
% *every* single state differently, sometimes you get name clutter! In the
% example above, this means that in the statenumber->name mapping produced
% by @StateMachineAssembler/assemble.m or @StateMachineAssembler/name.m,
% all three of the above states would be part of the 'light_sequence' state
% group.
%
 
% Written by Carlos Brody October 2006; edited by Sebastien Awwad 2007,2008

function [sma] = add_state(sma, varargin)
   
   pairs = { ...
     'name',                 ''   ; ...
     'default_statechange'   []   ; ...
     'input_to_statechange'  {}   ; ...
     'self_timer'           100   ; ...
     'output_actions'        []   ; ...
     'iti_state'              0   ; ...
...%     'entryfunc'             ''   ; ... % <~> new RT system functionality
...%     'entrycode'             ''   ; ... % <~> new RT system functionality
...%     'exitfunc'              ''   ; ... % <~> new RT system functionality
...%     'exitcode'              ''   ; ... % <~> new RT system functionality
   }; parseargs(varargin, pairs);
   
   name = lower(name);
   default_statechange = lower(default_statechange);
   if ~isempty(input_to_statechange)
       input_to_statechange(:,2) = lower(input_to_statechange(:,2));
   end
   
   state_name = name;
   
   if ~isnumeric(self_timer) || numel(self_timer)>1, 
      error('On adding state name="%s", error-- self_timer should be a scalar number', name);
   end;
   
   % --- BEGIN error_checking ---
   %     Reserved words can be found in
   %         ./private/reserved_word_list.m
   %       and include such things as sma, TupCol, base_iti_state,
   %       current_state, state_names, .... The point is to prevent
   %       collisions with variable names in assemble.m (and perhaps
   %       elsewhere), where there is a runtime eval that creates variables
   %       named after each state name.
   if ~isempty(state_name) && is_reserved(state_name),
      error(['Sorry, "' state_name '" is a reserved word, cannot ' ...
             'be used as a state name']);
   end;
   %     If the state name given as the 'name' argument is not an empty
   %       string and there is already a state in the state machine
   %       assembler that has an identical name, error out.
   if ~isempty(state_name) && any(strcmp(state_name,sma.state_name_list(:,1))),
      error(['Sorry, "' state_name '" has already been used for a ' ...
             'different state']);
   end;
   
   % If this is the very first non-iti state and it wasn't given a name, it
   %   takes the default name 'state_0'.
   if isempty(state_name)  &&  iti_state==0  &&  isempty(sma.states),
     state_name = 'state_0';
   end;
   
   input_to_statechange = rowvec(input_to_statechange'); %#ok<NODEF>
   if rem(length(input_to_statechange),2) ~= 0,
      error('input_to_statechange must have an even number of elements');
   end;
   for i=1:2:length(input_to_statechange),
      if ~ischar(input_to_statechange{i}),
         error('even elements of input_to_statechange must be strings');
      end;
   end;

   if iti_state && sma.pre35_curr_state==-1 && sma.full_trial_structure==0,
      error(['To use the ''iti_state'' flag, you must have initialised ' ...
             'the @StateMachineAssembler with either the full_trial_structure' ...
             'flag or the no_dead_time_technology flag']);
   end;
   
   % There is a bug (#80, http://brodylab.princeton.edu/trac/ticket/80)
   % where zero time timers hang the state machine. 
   
   
   self_timer=max(self_timer, 0.00001); %#ok<NODEF>
   
   % Check that SchedWaveTrig spec doesn't mix + and - 
   if ~isempty(output_actions),
     u = find(strcmp('SchedWaveTrig', output_actions(:,1)));
     if ~isempty(u),       
       if has_mixed_plus_and_minus(rowvec(output_actions{u,2})),
         if iti_state, this_state = sma.current_iti_state;
           error('StateMachineAssembler:Syntax', ['Can''t mix + and - triggering of scheduled waves in a single state.\n' ...
             '   ITI state #%d, name "%s".\n'], this_state, name);
           
         else this_state = sma.current_state;
           error('StateMachineAssembler:Syntax', ['Can''t mix + and - triggering of scheduled waves in a single state.\n' ...
             '   State #%d, name "%s".\n'], this_state, name);
         end;
       end;
     end;
   end;
   
   % --- END error_checking ---
   

   if iti_state, this_state = sma.current_iti_state;
   else          this_state = sma.current_state;
   end;
   
   if sma.use_happenings,
     if numel(sma.happList)<this_state+1, sma.happList{this_state+1} = {}; end;
   end;
   
   if ~isempty(state_name),
      if iti_state,
         sma.state_name_list = [sma.state_name_list ; ...
                             {state_name  this_state  1}];
      else
         sma.state_name_list = [sma.state_name_list ; ...
                             {state_name  this_state  0}];
      end;
   end;

   new_state = cell(1, size(sma.input_map,1) + size(sma.self_timer_map,1) + ...
                    size(sma.output_map,1));

   % Default statechange:
   if isempty(default_statechange), default_statechange=this_state; end;
   for i=1:size(sma.input_map,1), new_state{i} = default_statechange; end;
   
  
   % Now whatever input to statechange acts we are passed:
   for i=1:2:length(input_to_statechange),
      input       = input_to_statechange{i};
      statechange = input_to_statechange{i+1};
      
      if ~isequal(input, 'null'),
        % If we have a non-null event, then look to see which column
        % corresponds to that event, and write it in:
        if strcmp(input, 'Tup'),
          new_state{sma.input_map{strcmp(input, sma.input_map(:,1)),2}} = statechange;
        elseif ~sma.use_happenings, % using the input map
          u = find(strcmp(input, sma.input_map(:,1)));
          if ~isempty(u),
            new_state{sma.input_map{u,2}} = statechange;
          else
              error(['Don''t know input "' input '".']);
          end;
        else % using the happenings spec
          happnames = cell(numel(sma.happSpec), 1);
          [happnames{:}] = deal(sma.happSpec.name);
          u = find(strcmp(input, happnames), 1);
          if isempty(u),
            error(['Don''t know input "' input '".']);
          else
            sma.happList{this_state+1} = [sma.happList{this_state+1} {input statechange}];
          end;
        end; % end if strcmp(input, 'Tup')
      end; % end if ~isequal(input, 'null')
   end; % end for i
   
   % Self_timer:
   new_state{sma.self_timer_map{2}} = self_timer;
   % Default output_actions are zero, except for DOut:
   for i=1:rows(sma.output_map), 
     if strcmp(sma.output_map{i,1}, 'DOut'),
       new_state{sma.output_map{i,2}} = sma.default_DOut;
     else
       new_state{sma.output_map{i,2}} = 0;
     end;
   end;
   
   
   output_actions       = rowvec(output_actions'); %#ok<NODEF>

   % Now whatever we are passed:
   for i=1:2:length(output_actions),
      output = output_actions{i};
      outval = output_actions{i+1};
      
      u = find(strcmp(output, sma.output_map(:,1)));
      if isempty(u),
         error(['Don''t know output "' output '".']);
      else
         new_state{sma.output_map{u,2}} = outval;
      end;
   end;
      
      
   if ~iti_state,
      % If statenum is bigger than states we have, append to current list:
      if this_state >= size(sma.states,1)
        sma.states = [sma.states ; new_state];
        sma.default_actions = [sma.default_actions ; {default_statechange}];
      else  % we're replacing an already existing state
        sma.states = [sma.states(1:this_state,:) ; new_state ; sma.states(this_state+2:end,:)];
        sma.default_actions = ...
          [sma.default_actions(1:this_state,:) ; {default_statechange} ; sma.default_actions(this_state+2:end,:)];        
      end;
      sma.current_state = sma.current_state + 1;
   else
      % If statenum is bigger than the iti states we have, append to current list:
      if this_state >= size(sma.iti_states,1)
        sma.iti_states = [sma.iti_states ; new_state];
        sma.default_iti_actions=[sma.default_iti_actions ; {default_statechange}];
      else
        sma.iti_states = [sma.iti_states(1:this_state,:) ; new_state ; sma.iti_states(this_state+2:end,:)];
        sma.default_iti_actions = ...
          [sma.default_iti_actions(1:this_state,:) ; {default_statechange} ; sma.default_iti_actions(this_state+2:end,:)];
      end
      sma.current_iti_state = sma.current_iti_state + 1;
   end;
   
   
   
   % <~> The new embedded-C feature of the new RT software is now
   %       officially disabled. This is because its performance is slow
   %       and nobody is currently employing it, and because the
   %       StateMachineAssembler modifications I made to accommodate it
   %       cause problems for dispatcher('disassemble') that do not merit
   %       remedy unless someone is actually using embedded-C.
%    %<~>TODO: Make sure the state numbering I'm using is correct. There's
%    %           some strangeness above in which it's implied that we can be
%    %           modifying some state instead of adding a new one, but the
%    %           state number information is extracted from
%    %           sma.current_state, which I don't think is ever anything
%    %           other than the number of states already added....
%    % <~> new RT system functionality
%    %     For each featurename-featurevalue pair, add the given values
%    %       for this state to the matrices for all states formatted for
%    %       passing to Modules/@RTLSM/SetStateProgram. Empty values need not
%    %       be added to the matrix. (The s's below are not typos.)
%    for feature = {'entryfuncs', 'entrycode', 'exitcode', 'exitfuncs'; entryfunc, entrycode, exitcode, exitfunc},
%        if ~isempty(feature{2}) %     If value is not an empty string,
%            sma.(feature{1}) = { ...
%                sma.(feature{1}) ; ... %     old info
%                this_state+1 feature{2}... % additional row of the form {intStateNumber strCExpression}. ('this_state' is a misleading variable name.)
%                };
%        end; %     end if feature value is not an empty string
%    end; %     end for each feature


end %     end of method Modules/@StateMachineAssembler/add_state.m