% example3.m  USING TRIAL STRUCTURE AND THE 'NO_DEAD_TIME_TECHNOLOGY'
%
% This is an example script showing how to use the @StateMachineAssembler
% object. It is a reasonably complex example, and illustrates our "no dead
% time technology" (i.e., keeping the real time machine responsive to the
% rat in between trials). This example uses most of what is necessary for
% doing things in separate trials (e.g., state35 is used to indicate end
% of a trial), and it also illustrates using scheduled waves.
%
% The script is intended to be self-contained-- after starting up the
% system, you run the script and it will set up a state machine and start
% running it and communicating with it. (ExperPort/mystartup.m must
% have been run for this script to execute properly, though.)
%
% The simple example protocol used here plays a tone upon poking in the
% center; and then rewards a Left response by lighting an LED, and
% punishes a Right response with 2 secs of white noise. Then there is
% an intertrial interval which is at least 2 more secs of white
% noise. If the animal pokes during the ITI, the 2 secs of white noise
% are reinitialised.
%
%
%
% To get started to be able to run this script, (1) Get the ExperPort code
% from the CVS sever. Assuming you've already done this, (2) Start Matlab
% and change directory to the main ExperPort directory. (3) At the prompt,
% type 
%    >> flush ; mystartup
% You should be good to go! NOTE: If you're going to run sounds on the Mac,
% also see Modules/@softsound/README.txt

% Written by Carlos Brody Oct 2006; rewritten April 2007




% -- REMEMBER TO RUN ExperPort/mystartup.m before running this script!
% mystartup.m holds all the stuff that defines the state_machine_server
% name, etc.

% The following three lines are just to clear and close stuff in case
% you ran this script previously.
if exist('sm'),   Close(sm); clear sm; end;
if exist('sma'),  clear sma;  end;
if exist('sndm'), clear sndm; end;

% These two variables acquire their proper values in
% ExperPort/mystartup.m;
% If you using an emulator, go to /Setting/Settings_Custom.conf and set 
% the parameters 'state_machine_server' and 'sound_machine_server' to
% 'localhost'

% Now set up the State Machine:
sm = RTLSM2('localhost');
sm = Initialize(sm);


% Set up the sound machine:
sndm = RTLSoundMachine('localhost');

% Make sound 1 a two second white noise sound; sound 2 a 1-sec 2 KHz tone
sndm = LoadSound(sndm, 1, 0.3*rand(1, 2*GetSampleRate(sndm)));
sndm = LoadSound(sndm, 2, 0.3*sin(2*pi*2000*(0:1/GetSampleRate(sndm):1)));

center1led = bSettings('get', 'DIOLINES', 'center1led');
left1led = bSettings('get', 'DIOLINES', 'left1led');
right1led = bSettings('get', 'DIOLINES', 'right1led');

% Now we start up an assembler object. When we start it up with the
% 'no_dead_time_technology' flag, as below, it means that all the states
% designated 'iti_state' (see ITI SECTION below) will be running *in
% between trials*. This is so the real-time machine can be responsive to
% the rat even while other processes (i.e., the Matlab process) are
% pausing to figure out what they want for the next trial. The default is
% not to do anything in the iti-- that is, if you use the
% 'no_dead_time_technology' flag, but don't write an ITI SECTION, that's
% totally fine, there is well-defined behavior, but the box will not be
% responsive to anything the rat does in between trials. Your choice; if
% you want responsiveness in the iti, define what you want in an iti
% section.
%
%
sma  = StateMachineAssembler('no_dead_time_technology');


% ---------------------- MAIN PROGRAMMING SECTION --------
%
%   This is main section, where you define what you want to happen in a
%   trial.
%

% At the very beginning, we'll just wait for a center poke. We'll give
% this state the name 'wait_for_cpoke' (names are arbitrary; anything that
% could be a variable name is ok). Note that state names are *in*sensitive
% to case. We also specify that when a "Cin" event occurs, we'll go to the
% state called "trigger_tone":
sma = add_state(sma, 'name', 'WAIT_FOR_CPOKE', ...
                'input_to_statechange', {'Cin', 'trigger_tone_and_wait_for_answer'});
% Next, we play the tone and wait for an answering poke on Right or Left.
% If Left in, we'll go to reward, if Right in, we'll go to penalty. The
% default for other input events is just to stay in the current state, so
% anything else just gets ignored:
sma = add_state(sma, 'name', 'TRIGGER_TONE_AND_WAIT_FOR_ANSWER', ...
                'output_actions', {'SoundOut', 2}, ...
                'input_to_statechange', { ...
                  'Lin', 'left_reward' ; ...
                  'Rin', 'penalty' ; ...
                   });

% In left_reward we'll shine the left LED for 300 ms, and then go to the
% next state (left_reward+1)-- notice how you can do simple arithmetic
% when specifying which state you want to go to. States are added in
% sequence, so left_reward+1 will correspond to the "add_state" command
% after this one:
sma = add_state(sma, 'name', 'LEFT_REWARD', ...
                'output_actions', {'DOut', left1led}, ...
                'self_timer', 0.3, ...
                'input_to_statechange', {'Tup', 'left_reward+1'});
% (Note: the "self_timer" is a timer that gets started every time that you
% enter a state from a different state. When this timer runs out, a 'Tup'
% input event is generated. The default length of time for the self_timer
% is 100 secs; above we specified a different value, 0.3 sec, for this
% state.) 
%
% This next one is the left_reward+1 state. Here we're just going to wait
% for 2 secs, ignoring everything in peaceful silence, before declaring the
% end of the trial by jumping to the specially-named state 'state35'.
sma = add_state(sma, 'self_timer', 2, ...
                'input_to_statechange', {'Tup' 'state35'});  


% In the following penalty state, we trigger the 2-sec long white noise, we
% wait for two secs, and then we go to the iti. We could use the self_timer
% to wait for two secs. But instead we'll use a scheduled wave, just to
% illustrate using one.
%
% First we declare the scheduled wave with a two second preamble:
sma = add_scheduled_wave(sma, 'name', 'twosec_wave', 'preamble', 2);
%
% Now we add starting the wave to the output actions to be performed on
% entering this state; and in the input_to_statechange list, we specify
% that when this wave goes ping!, the trial is over, namely, we jump to the
% specially-named state 'state35'.
sma = add_state(sma, 'name', 'PENALTY', ...
                'output_actions', {...
                  'SoundOut',      1              ; ...
                  'SchedWaveTrig', 'twosec_wave'  ; ...
                   }, ...
                'input_to_statechange', {'twosec_wave_In', 'state35'});


% Note: When you declare a wave with name "blah", the end of the
% preamble will cause a "blah_In" event. The end of the sustain will
% cause a "blah_Out" event. (See @RTLSM/SetScheduledWaves.m for an
% explanation of scheduled waves, and their preamble.)


% ---------------------- ITI SECTION --------
%
%

% This is the section that will be running in between trials. Each trial
% ends by going to State 35. When the Matlab process monitoring the state
% machine detects that a State 35 has occurred in the last set of events
% it is picking up, it uses that as a cue to start figuring out what to do
% for the next trial (e.g., write a different code for "Main Section"
% above, perhaps now something where Rin leads to a hit and Lin leads to
% penalty; whatever you want). The Matlab process then sends the new code
% to the state machine (using send.m as below), and then calls
% ReadyToStartTrial.m. Meanwhile, the real-time machine should be set up
% to be periodically going to state 35. Every time it hits state 35, it
% asks whether it has received the ReadyToStartTrial signal. If it has,
% it'll then jump to the first state of the Main Section above;
% otherwise it goes again to the first state of the ITI section.
%
% In the current simplified example, all trials are the same; so below
% we will just resend the same state transition diagram and then call
% ReadyToStartTrial.m. 
%
%
% Note that all of the add_state commands in this section need to have
% "'iti_state', 1"-- this is what tells the assembler that these are for
% the intertrial interval states, not the regular during-a-trial states.


% Start by making sure sounds 1 and 2 are off:
sma = add_state(sma, 'iti_state', 1, ...
               'name', 'ITI_START', 'self_timer', 0.001, ...
               'output_actions', {'SoundOut', -1-2}, ...
               'default_statechange', 'iti_start+1');

% Now trigger sound 1; and iff nothing happens, go to state 35. But if
% anything (any input) does happen, go back to turning sounds off and
% restarting iti. This penalizes poking during the white noise sound. 
sma = add_state(sma, 'iti_state', 1, ...
                'name', 'TRIGGER_ITI_SOUND', 'self_timer', 2, ...
                'output_actions', {'SoundOut', 1}, ...
                'input_to_statechange', {'Tup', 'state35'}, ...
                'default_statechange', 'iti_start');


%
%
% ----------------- NOW ASSEMBLE, SEND, AND RUN!  ---------
%
%


% Tell the assembler (sma) to assemble and send the program to the
% state machine (sm):
send(sma, sm);

% Ok! Start it up, and start at state 0 --standard intialization calls.
sm = Run(sm); sm = ForceState0(sm);

all_trials_events = {};
this_trial_events = [];
n_previous_events = 0;

% Run for 100 secs or so. 
for i=1:1000, 
   % Virtual state machine needs to periodically process its stuff:   
   pause(0.1); 
   
   nevents = GetEventCounter(sm);
   if nevents > n_previous_events,  % Aha! new things have happened!
     % Get the new events from the State Machine:
     newevents = GetEvents(sm, n_previous_events+1, nevents);
     % Update our total already-gathered event counter:
     n_previous_events = nevents;

     % Look to see whether we jumped to state 35:
     u = find(newevents(:,4) == 35);
     if isempty(u),
       % Haven't gotten to end of trial
       this_trial_events = [this_trial_events ; newevents];
     else
       % Trial is over!
       fprintf(1, 'Trial %d has ended\n', size(all_trials_events,1)+1);
       % Append all new events, until the jump to state 35, to the list of
       % this trial's events:
       this_trial_events = [this_trial_events ; newevents(1:u,:)];
       % Append this trial's events to the list of all trial events:
       all_trials_events = [all_trials_events ; {this_trial_events}];
       % Any remaining events are now part of the new trial's events:
       this_trial_events = newevents(u+1:end,:);

       % At this point we could clear sma and redefine it entirely to
       % whatever we want. Whatever the new sma is (here, same as old one),
       % we now send it to the state machine:
       send(sma, sm);
       % And let the state machine know that we're good to go on the next
       % trial:
       sm = ReadyToStartTrial(sm);
     end;
   end;
   
end;
% We're done!
sm = Halt(sm);



% A good way to see what happened in a trial, say trial 2, would then be to
% do:

disassemble(sma, all_trials_events{2})