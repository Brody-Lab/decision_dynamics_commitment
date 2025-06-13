% example0.m    MOST TRIVIAL STATE MACHINE
%
% This is an example script showing how to use the @StateMachineAssembler
% object. It is the most trivial example-- loops through 3 states indefinitely.

% Written by Carlos Brody Aug 2007



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
% the parameters 'state_machine_server' and 'sound_machine_server' to 'localhost'

% Now set up the State Machine:
sm = RTLSM2('localhost');
sm = Initialize(sm);


% Ok, now set up an assembler:
sma = StateMachineAssembler;



% Now add the very first state (this'll be state 0). We won't give this
% state a name, since we'll just use it to pass through it on our way
% to the state that we'll name "base_state." When the state machine
% starts up, it'll start up already in State 0. Outputs are only
% set off when *entering* a state. So making sure that we *enter* the
% base_state when we start up  means that we make sure to trigger any
% outputs we want triggered in the base_state.
sma = add_state(sma, 'default_statechange', 'state1', ...
                'self_timer', 0.001);

% Note: the default thing to do is to stay in your current state. The
% 'default_statechange' part above sets that to change to 'base_state', in
% response to *any* event, including Tup or anything else. We can use
% 'input_to_statechange' (see below) to indicate other possible states to
% jump to, in response to specific input events.


% Ok, now the start of the program. 
sma = add_state(sma, 'name', 'state1', 'self_timer', 1, ...
                'input_to_statechange', { 'Tup', 'state2'});
sma = add_state(sma, 'name', 'state2', 'self_timer', 1, ...
                'input_to_statechange', { 'Tup', 'state3'});
sma = add_state(sma, 'name', 'state3', 'self_timer', 1, ...
                'input_to_statechange', { 'Tup', 'state1'});



% Tell the assembler (sma) to assemble and send the program to the
% state machine (sm):
send(sma, sm);

% Ok! Start it up, and start at state 0 --standard intialization calls.
sm = Run(sm); sm = ForceState0(sm);

% Now run for 100 secs or so
oldevs = 0;
for i=1:1000, 
   % Virtual state machine needs to periodically process its stuff:   
   pause(0.1); 
   stevs = GetTimeEventsAndState(sm, 1);
   newevs = stevs.event_ct;
   if newevs ~= oldevs, fprintf(1, 'FSM time is %g, and %d events have happened\n', stevs.time, newevs); end;
   oldevs = newevs;
end;