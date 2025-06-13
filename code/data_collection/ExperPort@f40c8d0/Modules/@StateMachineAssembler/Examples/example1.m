% example1.m    USING THE STATE MACHINE ASSEMBLER AND SCHEDULED WAVES
%
% This is an example script showing how to use the @StateMachineAssembler
% object. It is a very simple example, and illustrates using scheduled
% waves. It doesn't use a trial structure-- the state machine keeps
% looping indefinitely.
%

% Written by Carlos Brody October 2006



% To get started to be able to run this script, (1) Get the ExperPort code
% from the CVS sever. Assuming you've already done this, (2) Start Matlab
% and change directory to the main ExperPort directory. (3) At the prompt,
% type 
%    >> flush ; mystartup
% You should be good to go! NOTE: If you're going to run sounds on the Mac,
% also see Modules/@softsound/README.txt


% The following two lines are just to clear and close stuff in case
% you ran this script previously.
if exist('sm'),   Close(sm); clear sm; end;
if exist('sma'),  clear sma;  end;


% This variable acquires its proper values in
% ExperPort/mystartup.m;
% If you using an emulator, go to /Setting/Settings_Custom.conf and set 
% the parameters 'state_machine_server' and 'sound_machine_server' to
% 'localhost'

% Now set up the State Machine:
sm = RTLSM2('localhost');
sm = Initialize(sm);


% Ok, now set up an assembler:
sma = StateMachineAssembler;

center1led = bSettings('get', 'DIOLINES', 'center1led');
left1led = bSettings('get', 'DIOLINES', 'left1led');
right1led = bSettings('get', 'DIOLINES', 'right1led');

% Let's declare two scheduled waves to start, the first with a two
% second preamble, the second with a 3-sec preamble. We give them two
% illustrative names; the names could be anything.
sma = add_scheduled_wave(sma, 'name', 'twosecs',  'preamble', 2);
sma = add_scheduled_wave(sma, 'name', 'threesecs','preamble', 3);

% Note: When you declare a wave with name "blah", the end of the
% preamble will cause a "blah_In" event. The end of the sustain will
% cause a "blah_Out" event. (See @RTLSM/SetScheduledWaves.m for an
% explanation of scheduled waves, and their preamble.)

% Now add the very first state (this'll be state 0). We won't give this
% state a name, since we'll just use it to pass through it on our way
% to the state that we'll name "base_state." When the state machine
% starts up, it'll start up already in State 0. Outputs are only
% set off when *entering* a state. So making sure that we *enter* the
% base_state when we start up  means that we make sure to trigger any
% outputs we want triggered in the base_state.
sma = add_state(sma, 'default_statechange', 'base_state', ...
                'self_timer', 0.001);

% Note: the default thing to do is to stay in your current state. The
% 'default_statechange' part above sets that to change to 'base_state', in
% response to *any* event, including Tup or anything else. We can use
% 'input_to_statechange' (see below) to indicate other possible states to
% jump to, in response to specific input events.


% Ok, now the start of the program. On entering this state, we start both
% the 2-sec and the 3-sec scheduled waves; and we turn on the left
% led. Furthermore, we specify that when a "twosec_In" event (from the
% 'twosec' scheduled wave) occurs, we should jump to a state that will be
% named "intermediate_state."
sma = add_state(sma, 'name', 'base_state', ...
                'output_actions', { ...
                  'SchedWaveTrig', 'twosecs+threesecs' ; ...
                  'DOut',          left1led            ; ...
                   }, ...
                'input_to_statechange', { ...
                  'twosecs_In', 'intermediate_state' ; ...
                  });

% This is a state we label 'intermediate_state' (for no good reason--
% names are arbitrary). Here we just wait for the 3-sec scheduled wave
% to go ping! At which point we jump to "alternate_state" (another
% arbitrary name).
sma = add_state(sma, 'name', 'intermediate_state', ...
                'input_to_statechange', { ...
                  'threesecs_In', 'alternate_state' ; ...
                  });

% Let's declare a 1-sec scheduled wave that we'll use in alternate_state:
sma = add_scheduled_wave(sma, 'name', 'onesec',   'preamble', 1);

% In alternate_state, we turn on the right LED, and set off the 1-sec
% wave; also, when the one-sec wave goes ping! we jump back to
% base_state, to keep looping.
sma = add_state(sma, 'name', 'alternate_state', ...
                'output_actions', { ...
                  'DOut',                right1led, ; ...
                  'SchedWaveTrig', 'onesec' ; ...
                   }, ...
                'input_to_statechange', { ...
                  'onesec_In', 'base_state' ; ...
                   });



% Tell the assembler (sma) to assemble and send the program to the
% state machine (sm):
send(sma, sm);

% Ok! Start it up, and start at state 0 --standard intialization calls.
sm = Run(sm); sm = ForceState0(sm);

% Now run for 100 secs or so
for i=1:1000, 
   % Virtual state machine needs to periodically process its stuff:   
   pause(0.1); 
end;