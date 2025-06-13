% [sma, sched_wave_name] = add_scheduled_wave(...
%                      sma,                 ... %     required argument
%                      'name',              '',    ... %     optional
%                      'preamble',           1,    ... %     optional
%                      'sustain',            0,    ... %     optional
%                      'refraction',         0,    ... %     optional
%                      'dio_line',          -1,    ... %     optional
%                      'DOut'               -1,    ... %     optional
%                      'sound_trig',         0,    ... %     optional 
%                      'trigger_on_up',     '',    ... %     optional
%                      'untrigger_on_down', '',    ... %     optional
%                      'no_wave_events',     0,    ... %     optional
%                      'loop',               0,    ... %     optional
%                      'ao_line',           [],    ... %     optional
%                      'analog_waveform',   [],    ... %     optional
%                      );
%
% Add a Scheduled Wave to the list of waves registered with the sma State
% Machine assembler object. Returns the updated sma object, and the name of
% the new scheduled wave. Waves come in two main forms: digital ones (for
% which the ao_line and analog_waveform parameters should not be set); and
% analog ones (for which _only_ the loop, ao_line, and analog_waveform
% parameters are valid).
%
% For an introduction to what scheduled waves are, see the section below
% entitled "WHAT IS A SCHEDULED WAVE." Note that as currently configured,
% you can have up to 32 different scheduled waves defined per state
% machine, no more. 
%
% 
% RETURNS: 
% --------
%
% sma      The updated State Machine Assembler object, after the scheduled
%          wave has been added.
%
% name     The name of the new added wave. This is a useful return
%          parameter if no name was specified when creating the new wave
%          (see below); here you can find out the unique name that was
%          automatically assigned to the new wave. (Usually, however, when
%          you don't specify a name, its because you don't care what it is 
%          and you don't need this return paranmeter.)
%
%
% PARAMETERS:
% -----------
%
% sma      The instantiation of the StateMachineAssembler object to which
%          the scheduled wave will be added.
%
% OPTIONAL PARAMETERS:
% ---------------------
%
% name      A string that will be the name of the new scheduled wave. If a
%           scheduled wave with this name already exists in this sma, a
%           warning and error will ensue. If this parameter is left empty,
%           then a new unique name for this sma will be created. 
%
%           To refer to the "In" and "Out" events for the scheduled waves
%           (for example, you might do this if you want to add a state from 
%           which such events trigger a state change), use name_In and
%           name_Out. After replacing "name" with whatever the name
%           actually is, of course.
%
%      DIGITAL SCHEDULED WAVE PARAMETERS:
%      ----------------------------------
%
% preamble  Time, in secs, which elapses before the scheduled wave is
%           triggered and its "In" event occurs. Default value is 1 sec.
%
% sustain   Time, in secs, which elapses between the scheduled waves' "In" 
%           event and its "Out" event. Default value is 0.
%
% refraction   Time, in secs, which elapses after a scheduled wave's "Out"
%           event and the time at which triggering it again is effective.
%           Before this time, triggering requests are ignored. Default
%           value of refraction is 0. [**must double-check that refraction
%           starts at "Out" event, not "In" event**]
%
% DOut      If non-zero, indicates which line on the DIO card will carry
%           the scheduled wave signal: during the sustain, this value will
%           be high (+5V). The actual line number will be log2(DOut), which
%           means that we can use values like bSettings('get', 'DIOLINES',
%           'center1led'). Using DOut is therefore recommended over using
%           dio_line, for clarity, but the functionality of the two is
%           essentially the same.
%
% dio_line  Physical line on the DIO card that will carry the scheduled
%           wave signal: between preamble and preamble+sustain this line
%           will be High (+5V). [** Double-check that it is indeed +5**]
%           A value of -1 here indicates that the scheduled wave is purely 
%           virtual and doesn't correspond to a physical out line. Default 
%           value of dio_line is -1. If you want to use binary-encoded
%           values to indicate the dio_line, take the log2 of them first
%           (see DOut above).
%
% sound_trig   Sound ID of a sound to trigger when the sustain period of
%           this scheduled wave begins. The sound is turned off (whether or
%           not it has completed play) when the sustain period ends (i.e.
%           at the beginning of the refractory period). See examples below.
%           *NEW feature available in new-RT system
%           (June 2008; requires server running RTFSM version 100+)
%
% no_wave_events   By default, scheduled waves generate _In and _Out
%           events, at the end of the preamble and the sustain,
%           respectively. If this parameter is passed as 1, then the
%           scheduled wave being added will generate no events. (Default
%           for this param is 0, i.e., generate the events.) Suppressing
%           the events is useful when one is using a rapidly looping
%           scheduled wave that doesn't drive state transitions; for
%           example, for stimulus delivery purposes.
%
% trigger_on_up   By default, ''.  This entry indicates any scheduled wave
%           names that should be triggered when this wave goes High (i.e.,
%           goes from the preamble to the sustain. Use the names of the
%           scheduled waves, and use '+' to separate names if you want to
%           trigger more than one wave-- e.g., 'wave1 + wave2'. You cannot
%           UNtrigger waves here. To do that, see untrigger_on_down.
%
% untrigger_on_down   By default, ''.  This entry indicates any scheduled wave
%           names that should be UNtriggered when this wave goes Low (i.e.,
%           goes from the sustain to the preamble. Use the names of the
%           scheduled waves, and use '+' to separate names if you want to
%           UNtrigger more than one wave-- e.g., 'wave1 + wave2'. You cannot
%           trigger waves here. To do that, see trigger_on_up.
%
%      PARAMETERS VALID FOR BOTH DIGITAL AND ANALOG WAVES:
%      ---------------------------------------------------  
%
% loop      The number of times the scheduled wave should repeat (i.e.,
%           after finishing the refraction, start the preamble again). The
%           default for this is 0, meaning the scheduled wave plays only
%           once. If a negative number is passed here, this means loop the
%           scheduled wave indefinitely, until the next trial start is
%           indicated by a jump to state 0.
%
%      ANALOG SCHEDULED WAVE PARAMETERS:
%      ----------------------------------
%
% ao_line   The physical line for the output. These start at line=1.
%
% analog_waveform    A row vector containing values within the range [-1,
%           1]. These will be scaled up to the range of the voltage output
%           (e.g., 0 to +6V). Once the wave is triggered, then at each
%           timestep of the state machine, the analog output line will take
%           on the next value in this vector until it runs through the
%           whole set of values.
%                 FURTHER FUNCIONALITY CURRENTLY NOT SUPPORTED:  The
%                 @RTLSM2/SetScheduledWaves.m function allows defining a
%                 second row to analog_waveform, used to trigger state
%                 transitions in the state machine. Currently
%                 add_scheduled_wave.m and send.m of the
%                 @StateMachineAssembler do not support that functionality,
%                 so analog_waveform here should be a single-row vector.
%                 That is, current functionality is simply to provide an
%                 analog output waveform to the external world.
%
% EXAMPLES:
% ----------
%
% >> sma = add_scheduled_wave(sma, 'name', 'twosecs',  'preamble', 2);
%
%       Registers a scheduled wave called 'twosecs' that will have both "In" 
%       and "Out" events two seconds after being triggered, and has no
%       refractory period nor does it have a physical DIO line.
%          Later, to use such a wave, you might add a state in which its
%       start is triggered:
%          >> sma = add_state('output_actions', {'SchedWaveTrig', 'twosecs'});
%       And you later add another state in which the end of the preamble
%       triggers a state change:
%          >> sma = add_state('input_to_statechange', {'twosecs_In', ...
%                     'state_to_jump_to_when_twosec_preamble_finishes'});
%
% >> [sma, name] = add_scheduled_wave(sma, 'sustain', 3);
%
%       Registers a scheduled wave with the default preamble of 1 sec, a
%       wait between its "In" and "Out" events of 3 secs, and get back the
%       automatic name assigned by the assembler.
%
% >> [sma] = add_scheduled_wave(sma, 'name','telephone',            ...
%                               'preamble',0.01, 'sustain',1,       ...
%                               'dioline', 3,    'sound_trig', 1);
%       
%       Registers a scheduled wave named 'telephone' that plays the sound
%       with Sound ID 1 0.01 seconds (preamble) after being triggered and
%       simultaneously turns on DIO line 3 (e.g. turns on a light or
%       releases water). Both sound 1 and DIO line 3 are then turned off
%       one second (sustain) after they are turned on. There is no
%       refractory period in this case, so the scheduled wave can be
%       triggered again immediately after it stops.
%       
%<~>TODO: Look into the mechanics of the refractory period and
%           clear up the documentation above.
%<~>TODO: Add DOut comments below to the documentation above.
%
%
% WHAT IS A SCHEDULED WAVE, ANYWAY?
% ---------------------------------
%
% Scheduled waves are alarm clocks that you can set and use in your state
% machine. True finite state machines are very clear but quite limited;
% having these alarm clocks makes a number of things much easier to code,
% although it means our state machine isn't really a simple finite state
% machine any longer.
%
% A scheduled wave is defined by three parameters, which are specified when
% you register the scheduled wave using add_scheduled_wave.m these three
% parameters are: the 'preamble', the 'sustain', and the 'refraction.
%    When you trigger the start of a scheduled wave, preamble seconds
% elapse before anything occurs due to the scheduled wave. When the
% preamble time is over, an '_In' event from the wave occurs (and can be
% used in the state machine to trigger state transitions-- see
% input_to_statechange in add_state.m). After that, sustain seconds elapse,
% and then an '_Out' event occurs. After that, 'refraction' seconds elapse
% before you can trigger the start of a scheduled wave again (by default
% 'refraction' is 0).
%
% Most often, people use only the preamble, and use the scheduled wave as a
% simple alarm clock thatcan be made to trigger state transitions. As
% currently configured, you can use up to 32 scheduled waves.
%
%  *** Analog waveform scheduled waves:  This type of scheduled wave,
%  instead of triggering internal state changes, is used to define a
%  voltage-as-a-function-of-time waveform that is sent out to the world.
%


% Written by Carlos Brody October 2006; modified by Sebastien Awwad
% 2007,2008; analog output functionality added by Carlos Brody 2012

function [sma, sched_wave_name] = add_scheduled_wave(sma, varargin)
   
   pairs = { ...
     'name'               ''    ;  ...
     'preamble'            1    ;  ...
     'sustain'             0    ;  ...
     'refraction'          0    ;  ...
     'dio_line'           -1    ;  ... %     overridden by DOut if DOut is nonzero
     'DOut'                0    ;  ... %     optional argument that overrides dio_line. DOut takes a channel value (e.g. 2^n, e.g. value of left1water) instead of a channel number (e.g. n, e.g. value of log2(left1water))
     'sound_trig'          0    ;  ... 
     'loop'                0    ;  ...
     'trigger_on_up'      ''    ;  ...
     'untrigger_on_down'  ''    ;  ...
     'no_wave_events'      0    ;  ...
	 'analog_waveform'    []    ;  ...
	 'ao_line'            []    ;  ...
   }; parseargs(varargin, pairs);

   %     DOut is a friendlier way of specifying dio_line. It takes e.g. the
   %       value of right1water instead of log2 of that. If specified, it
   %       overrides dio_line.
   if DOut~=0, dio_line = log2(DOut); end;
   if (dio_line - round(dio_line)) ~= 0
       warning('WARNING: Scheduled Wave dio_line must be a integer power of 2'); %should make an error
   end
       
   already_have_schedwave_out = ~isempty(sma.sched_waves);   
   if isempty(name),
      sched_wave_name = ['timer' num2str(length(sma.sched_waves)+1)];
   else
      sched_wave_name = name;
   end;
   
   
   % --- BEGIN error-checking ---
   Tup = find(strcmp('Tup', sma.input_map(:,1)));
   if isempty(Tup),
      error('Huh??? input map has no Tup entry?');
   end;
      
   [prev_names{1:length(sma.sched_waves)}] = deal(sma.sched_waves.name);
   if ~isempty(find(strcmp(sched_wave_name, prev_names),1)),
      error(['A scheduled wave with name ' sched_wave_name ' already ' ...
             'exists.']);
   end;   
   
   if ~isempty(strfind(trigger_on_up, '-')) || ~isempty(strfind(untrigger_on_down, '-')),
     error(['Do not use - signs in trigger_on_up or untrigger_on_down: only + signs\n' ...
       '   if you want to trigger/untrigger more than one wave. Wave name "%s".\n'], name);
   end;
   
   if xor(isempty(analog_waveform), isempty(ao_line))
	   error(['Must specify *either* (both analog_waveform and ao_line; you''re defining an ANALOG wave);\n' ...
		   '*or* neither of them (you''re defining a DIGITAL wave). Wave name "%s"\n'], name)
   end;
   % If we're using an analog waveform, only loop, ao_line, and analog_waveform are valid params
   if ~isempty(analog_waveform) analog_or_digital_flag = 'ANALOG'; %#ok<SEPEX>
   else                         analog_or_digital_flag = 'DIGITAL';
   end;
   
   if strcmp(analog_or_digital_flag, 'ANALOG')
	   for guys = {'preamble', 'sustain', 'refraction', 'dio_line', 'DOut', 'sound_trig', 'no_wave_events'},
		   def = extract_default(pairs, guys{1});
		   if eval(guys{1}) ~= def
			   error('You''re using an analog waveform, can''t specify %d.  Wave "%s"\n', guys{1}, name);
		   end;
	   end;
	   for guys = {'trigger_on_up', 'untrigger_on_down'}
		   if ~isempty(eval(guys{1})),
			   error('You''re using an analog waveform, can''t specify %d.  Wave "%s"\n', guys{1}, name);
		   end;
	   end;
   
	   if size(analog_waveform,1) ~= 1,
		   error('analog_waveform should be a single row vector. Second row functionality not yet supported. Wave "%s"\n', name);
	   end;
   end;
   
   % --- END error-checking ---
   
   if ~sma.use_happenings,  % not using happenings but using old matrix input columns mechanism
     if no_wave_events || strcmp(analog_or_digital_flag, 'ANALOG'), % don't generate _In and _Out columns for this wave
       in_col  = 0;
       out_col = 0;
     else
       % We'll add columns for the In and Out events of this sched wave,
       % and we'll put them right behind the Tup:
       in_col  = sma.input_map{Tup, 2};
       out_col = sma.input_map{Tup, 2}+1;
       % make space for the two new cols and move everything after and
       % including Tup forwards by two columns:
       sma.states = [sma.states cell(rows(sma.states),2)];
       sma.states(:,in_col+2:end) = sma.states(:,in_col:end-2);
       sma.states(:,in_col)  = sma.default_actions;
       sma.states(:,out_col) = sma.default_actions;
       % repeat for iti_states:
       sma.iti_states = [sma.iti_states cell(rows(sma.iti_states),2)];
       sma.iti_states(:,in_col+2:end) = sma.iti_states(:,in_col:end-2);
       sma.iti_states(:,in_col)  = sma.default_iti_actions;
       sma.iti_states(:,out_col) = sma.default_iti_actions;
       
       
       % Now add our new entries to the input map:
       sma.input_map = [sma.input_map(1:in_col-1,:) ; ...
         {[sched_wave_name '_In'],  in_col ; ...
         [sched_wave_name '_Out'], out_col} ; ...
         sma.input_map(in_col:end,:)];
       
       % And adjust the Tup entry in the input map:
       sma.input_map{Tup+2,2} = sma.input_map{Tup+2,2} + 2;
       
       % As well as adjusting the self_timer map:
       for i=1:rows(sma.self_timer_map),
         sma.self_timer_map{i,2} = sma.self_timer_map{i,2}+2;
       end;
       % And the output map:
       for i=1:rows(sma.output_map),
         sma.output_map{i,2} = sma.output_map{i,2} + 2;
       end;
     end;

   else % We *ARE* using happenings
     in_col  = 0; % With happenings, waves don't use input cols
     out_col = 0;  

     if strcmp(analog_or_digital_flag, 'DIGITAL') && ~no_wave_events, % Unless asked not to, we'll have this wave's in 
                         % and out events recognized, recorded, and
                         % potentially used to drive state transitions.
       sma.happSpec(numel(sma.happSpec)+1).name = [sched_wave_name '_In'];
       sma.happSpec(end).detectorFunctionName = 'wave_in';
       sma.happSpec(end).inputNumber          = numel(sma.sched_waves);
       sma.happSpec(end).happId               = numel(sma.happSpec);
       
       sma.happSpec(numel(sma.happSpec)+1).name = [sched_wave_name '_Out'];
       sma.happSpec(end).detectorFunctionName = 'wave_out';
       sma.happSpec(end).inputNumber          = numel(sma.sched_waves);
       sma.happSpec(end).happId               = numel(sma.happSpec);
       
       sma.happSpec(numel(sma.happSpec)+1).name = [sched_wave_name '_Hi'];
       sma.happSpec(end).detectorFunctionName = 'wave_high';
       sma.happSpec(end).inputNumber          = numel(sma.sched_waves);
       sma.happSpec(end).happId               = numel(sma.happSpec);
       
       sma.happSpec(numel(sma.happSpec)+1).name = [sched_wave_name '_Lo'];
       sma.happSpec(end).detectorFunctionName = 'wave_low';
       sma.happSpec(end).inputNumber          = numel(sma.sched_waves);
       sma.happSpec(end).happId               = numel(sma.happSpec);
     end;
   end;

   if ~already_have_schedwave_out,
      % --- create a column for the scheduled wave triggering signals:
      if ~isempty(sma.states),         
         sma.states = [sma.states num2cell(zeros(rows(sma.states),1))];
      else
         sma.states = cell(0, cols(sma.states)+1);
      end;
      % repeat for iti_states:
      if ~isempty(sma.iti_states),         
         sma.iti_states = [sma.iti_states num2cell(zeros(rows(sma.iti_states),1))];
      else
         sma.iti_states = cell(0, cols(sma.iti_states)+1);
      end;
      
      sma.output_map = [sma.output_map ; {'SchedWaveTrig' cols(sma.states)}];
   end;
   
   
   % Now store it in the scheduled waves list
   snum = length(sma.sched_waves)+1;   
   sma.sched_waves(snum).name              = sched_wave_name;
   sma.sched_waves(snum).id                = snum-1;
   sma.sched_waves(snum).in_column         = in_col;
   sma.sched_waves(snum).out_column        = out_col;
   sma.sched_waves(snum).dio_line          = dio_line;
   sma.sched_waves(snum).preamble          = preamble;
   sma.sched_waves(snum).sustain           = sustain;
   sma.sched_waves(snum).refraction        = refraction;
   sma.sched_waves(snum).sound_trig        = sound_trig;       
   sma.sched_waves(snum).loop              = loop;
   sma.sched_waves(snum).trigger_on_up     = trigger_on_up;
   sma.sched_waves(snum).untrigger_on_down = untrigger_on_down;
   sma.sched_waves(snum).ao_line           = ao_line;
   sma.sched_waves(snum).analog_waveform   = analog_waveform;
   
   % If any of the sched wave properties requiring more than 8 columns
   % have been asked for, request all 11 columns:
   if loop ~= 0 || ~isempty(trigger_on_up) || ~isempty(untrigger_on_down),
      sma.dio_sched_wave_cols = 11;
   end;

end

% ---------
   
function [def] = extract_default(pairs, varname)

r = find(strcmp(pairs(:,1), varname));

if isempty(r), def = [];
else           def = pairs{r,2};
end;

end
	