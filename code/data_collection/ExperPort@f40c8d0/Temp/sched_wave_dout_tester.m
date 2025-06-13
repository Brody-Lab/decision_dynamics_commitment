
% The following two lines are just to clear and close stuff in case
% you ran this script previously.
if exist('sm', 'var'),   Close(sm); clear sm; end;
if exist('sma', 'var'),  clear sma;  end;
delete_sphandle('name', 'myguy');
if ishandle(321), delete(321); end;

global left1water;
global left1led;
global right1led;
global center1led;

figure(321);


% This variable acquires its proper values in
% ExperPort/mystartup.m; if empty, it means we're on a virtual rig, not a
% real one:
global state_machine_server;   
global sound_machine_server;   


% Now set up the State Machine:
if isempty(state_machine_server); sm = SoftSMMarkII;
else                              sm = RTLSM(state_machine_server, 3333, 1);   
end;
sm = Initialize(sm);


% Set up the sound machine:
if isempty(sound_machine_server)  
   sndm = softsound;
   % The virtual rig state machine needs to be told to talk to sound machine:
   sm   = SetTrigoutCallback(sm, @playsound, sndm);   
else                             
   sndm = RTLSoundMachine(sound_machine_server);
end;
Initialize(sndm);


% sndm = LoadSound(sndm, 1, 0.03*rand(1, 2*GetSampleRate(sndm)));
% sndm = LoadSound(sndm, 2, 0.005*MakeFMWiggle(GetSampleRate(sndm), 0, 1, 4000, ...
%   3, 1500), 'both', 3, 0, 1);
% sndm = LoadSound(sndm, 3, 0.02*MakeBupperSwoop(GetSampleRate(sndm), 0, 100, 100, 1000, 0, ...
%   0, 1), 'both', 3, 0, 1);


% Ok, now set up an assembler:
sma = StateMachineAssembler;
sma = add_scheduled_wave(sma, 'name', 'testing', 'preamble', 0.001, 'sustain', 1, 'DOut', right1led);

sma = add_state(sma, 'self_timer', 0.0001, 'input_to_statechange', {'Tup', 'current_state+1'} , ...
    'output_actions', {'SchedWaveTrig', 'testing'});
sma = add_state(sma, 'name', 'start', 'self_timer', 1.6, ...
    'input_to_statechange', {'Tup', 'current_state+1'});
sma = add_state(sma, 'self_timer', 0.0001, 'input_to_statechange', {'Tup', 'current_state-2'});



% Tell the assembler (sma) to assemble and send the program to the
% state machine (sm):
[stm, asn, sm] = send(sma, sm, 'dout_lines', '6-11');

% Ok! Start it up, and start at state 0 --standard intialization calls.
sm = Run(sm); sm = ForceState0(sm);

sm = ForceState0(sm);


% Run for 100 secs or so. 
for i=1:1000, 
   % Virtual state machine needs to periodically process its stuff:
   if isa(sm, 'SoftSMMarkII'), sm = FlushQueue(sm); end;
   pause(0.1);   
end;
% We're done!
sm = Halt(sm);



