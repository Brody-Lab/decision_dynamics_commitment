
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
[x, y] = SoftPokeStayInterface(softpokestay, 'add', 'myguy', 10, 10)
SoftPokeStayInterface(softpokestay, 'set', 'myguy', 'Duration', 5)
SoftPokeStayInterface(softpokestay, 'set', 'myguy', 'Grace',    2)

NumeditParam('base', 'Sound1TrigTime', 2, x, y); next_row(y);
NumeditParam('base', 'Sound2TrigTime', 2, x, y); next_row(y);
NumeditParam('base', 'DOutStartTime',  0, x, y); next_row(y);
NumeditParam('base', 'DOutOnTime',     1, x, y); next_row(y);



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
   SetCard(sndm, 1)
   fprintf(1, '\n\n\n**** softpoke_tester configured to be middle of 3 rigs!!! **** \n\n\n');
end;
Initialize(sndm);


sndm = LoadSound(sndm, 1, 0.03*rand(1, 2*GetSampleRate(sndm)));
sndm = LoadSound(sndm, 2, 0.005*MakeFMWiggle(GetSampleRate(sndm), 0, 1, 4000, ...
  3, 1500), 'both', 3, 0, 1);
sndm = LoadSound(sndm, 3, 0.02*MakeBupperSwoop(GetSampleRate(sndm), 0, 100, 100, 1000, 0, ...
  0, 1), 'both', 3, 0, 1);


% Ok, now set up an assembler:
sma = StateMachineAssembler;
sma = add_scheduled_wave(sma, 'name', 'ProSound', 'preamble', Sound2TrigTime(1));

sma = add_state(sma, 'default_statechange', 'base_state', ...
  'self_timer', 0.001);
sma = add_state(sma, 'name', 'base_state', 'self_timer', 0.0001, ...
  'output_actions', {'SoundOut', 2}, ...
  'input_to_statechange', {'Tup', 'current_state+1'});
sma = add_state(sma, 'output_actions', {'SoundOut', 3}, ...              
  'input_to_statechange', {'Cin', 'myguy'});

sma = SoftPokeStayInterface(softpokestay, 'add_sma_states', 'myguy', sma, ...
  'success_exitstate_name',    'success', ...
  'abort_exitstate_name',      'abort',   ...
  'pokeid', 'C' , 'DOut', right1led, 'DOutStartTime', DOutStartTime(1), 'DOutOnTime', DOutOnTime(1), ...
  'Sound1TrigTime', Sound1TrigTime(1), 'Sound1Id', -3, ...
  'InitialSchedWaveTrig', 'ProSound', ...
  'Sound2TriggeringEvent', 'ProSound_In', 'Sound2Id', -2);
sma = add_state(sma, 'name', 'success', 'self_timer', 2, ...
  'output_actions', {'DOut', right1led+left1led+center1led, 'SoundOut', -2}, ...
  'input_to_statechange', {'Tup', 'end_trial'});
sma = add_state(sma, 'name', 'abort', 'self_timer', 2, ...
  'output_actions', {'DOut', right1led+left1led, 'SoundOut', -2}, ...
  'input_to_statechange', {'Tup', 'end_trial'});
sma = add_state(sma, 'name', 'end_trial');



% Tell the assembler (sma) to assemble and send the program to the
% state machine (sm):
if isempty(sound_machine_server)  
  [stm, asn, sm] = send(sma, sm); % , 'dout_lines', '6-11');
else
  [stm, asn, sm] = send(sma, sm, 'dout_lines', '6-11');
end;

% Ok! Start it up, and start at state 0 --standard intialization calls.
sm = Run(sm); sm = ForceState0(sm);

sm = ForceState0(sm);

all_trials_events = {};
this_trial_events = [];
n_previous_events = 0;


% Run for 100 secs or so. 
for i=1:1000, 
   % Virtual state machine needs to periodically process its stuff:
   if isa(sm, 'SoftSMMarkII'), sm = FlushQueue(sm); end;
   pause(0.1); 
   
   nevents = GetEventCounter(sm);
   if nevents > n_previous_events,  % Aha! new things have happened!
     % Get the new events from the State Machine:
     newevents = GetEvents(sm, n_previous_events+1, nevents);
     % Update our total already-gathered event counter:
     n_previous_events = nevents;

     u = find(newevents(:,4) == asn.end_trial);
     if isempty(u),
       % Haven't gotten to end of trial
       this_trial_events = [this_trial_events ; newevents];
     else
       % Trial is over!
       fprintf(1, 'Trial %d has ended\n', size(all_trials_events,1)+1);
       % Append all new events, until the jump to state 35, to the list of
       % this trial's events:
       this_trial_events = [this_trial_events ; newevents(1:u,:)];
       disassemble(sma, this_trial_events);
       
       % Append this trial's events to the list of all trial events:
       all_trials_events = [all_trials_events ; {this_trial_events}];
       % Any remaining events are now part of the new trial's events:
       this_trial_events = newevents(u+1:end,:);

       % At this point we could clear sma and redefine it entirely to
       % whatever we want. Whatever the new sma is (here, same as old one),
       % we now send it to the state machine. We don't just keep the old one in
       % case the user changed some of the SoloparamHandle values int he meantime.  
       sma = StateMachineAssembler;
       sma = add_scheduled_wave(sma, 'name', 'ProSound', 'preamble', Sound2TrigTime(1));

       sma = add_state(sma, 'default_statechange', 'base_state', ...
         'self_timer', 0.001);
       sma = add_state(sma, 'name', 'base_state', 'self_timer', 0.0001, ...
         'output_actions', {'SoundOut', 2}, ...
         'input_to_statechange', {'Tup', 'current_state+1'});
       sma = add_state(sma, 'output_actions', {'SoundOut', 3}, ...
         'input_to_statechange', {'Cin', 'myguy'});

       sma = SoftPokeStayInterface(softpokestay, 'add_sma_states', 'myguy', sma, ...
         'success_exitstate_name',    'success', ...
         'abort_exitstate_name',      'abort',   ...
         'pokeid', 'C' , 'DOut', right1led, 'DOutStartTime', DOutStartTime(1), 'DOutOnTime', DOutOnTime(1), ...
         'Sound1TrigTime', Sound1TrigTime(1), 'Sound1Id', -3, ...
         'InitialSchedWaveTrig', 'ProSound', ...
         'Sound2TriggeringEvent', 'ProSound_In', 'Sound2Id', -2);
       sma = add_state(sma, 'name', 'success', 'self_timer', 2, ...
         'output_actions', {'DOut', right1led+left1led+center1led, 'SoundOut', -2}, ...
         'input_to_statechange', {'Tup', 'end_trial'});
       sma = add_state(sma, 'name', 'abort', 'self_timer', 2, ...
         'output_actions', {'DOut', right1led+left1led, 'SoundOut', -2}, ...
         'input_to_statechange', {'Tup', 'end_trial'});
       sma = add_state(sma, 'name', 'end_trial');

       if isempty(sound_machine_server),
         send(sma, sm);
       else
         send(sma, sm, 'dout_lines', '6-11');
       end;
       % And let the state machine know that we're good to go on the next
       % trial:
       sm = ReadyToStartTrial(sm);
       sm = ForceState0(sm);
     end;
   end;
   
end;
% We're done!
sm = Halt(sm);



