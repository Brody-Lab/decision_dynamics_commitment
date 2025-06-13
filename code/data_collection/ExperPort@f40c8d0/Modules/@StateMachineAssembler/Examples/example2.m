% example2.m :  USING THE DISASSEMBLER TO PARSE THE EVENTS THAT HAPPENED.
%
% This is an example script showing how to use the @StateMachineAssembler
% object. It is a very simple example, built mainly to illustrates using
% getting event information from the state machine. It doesn't use a trial
% structure-- the state machine keeps looping indefinitely.
%
% In this example, the state machine toggles between two states on poking
% *into* the center port: all three lights on, and all three lights off. As
% simple as example1.m. The extra twist is that it reports, to the Matlab
% command window, how many times it has been in each state, and whether the
% user has poked into any of the ports.
%
%
% To get started to be able to run this script, (1) Get the ExperPort code
% from the CVS sever. Assuming you've already done this, (2) Start Matlab
% and change directory to the main ExperPort directory. (3) At the prompt,
% type 
%    >> flush ; mystartup
% You should be good to go! NOTE: If you're going to run sounds on the Mac,
% also see Modules/@softsound/README.txt



% Written by Carlos Brody April 2007



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

% Let's add a lights off state from which we exit after two seconds or if a
% Center poke occurs. Here we illustrate using 'current_state' together
% with simple arithmetic: when the slef_timer expires, this state will jump
% to whatever the enxt defined state is.
sma = add_state(sma, 'name', 'lights_off', 'self_timer', 2, ...
  'input_to_statechange', {'Cin', 'lights_on'; 'Tup', 'current_state+1'});

% Now we define the state that we will jump to if the self-_timer goes off
% in the previous state. We'll leave this one nameless, which will
% illustrate the fact that, for event parsing purposes with the
% disassembler below, it will have the same name as the state above. For
% fun we've put going automatically to the lights_on state 1 sec after we
% reach here:
sma = add_state(sma, 'self_timer', 1, ...
  'input_to_statechange', {'Cin', 'lights_on'; 'Tup', 'lights_on'});

% Next the lights_on state. On a Center in poke, this jumps to the lights
% off state. Note that there only one of the two 'lights_on' states above;
% had its name explicitly defined; that is the one the machine will jump to
% when asked to jump to state 'lights_on'. 
sma = add_state(sma, 'name', 'lights_on', ...
  'output_actions', {'DOut', left1led + center1led + right1led}, ...
  'input_to_statechange', {'Cin', 'lights_off'});

% Finally, a state that we never use, just to illustrate what states that
% aren't reached look like in the disassembler's output.
sma = add_state(sma, 'name', 'never_reached');

% ------------ FINISHED DEFINITIONS, READY TO RUN ---------

% Now tell the assembler (sma) to assemble and send the program to the
% state machine (sm). 
send(sma, sm);

% Ok! Start it up, and start at state 0 --standard intialization calls.
sm = Run(sm); sm = ForceState0(sm);

% A variable that will hold all the events recorded up to now:
events = []; 

% Now run for 100 secs or so
for i=1:1000, 
   % Virtual state machine needs to periodically process its stuff:   
   pause(0.1); 

   % Now, every 100 ms or so, get info on what has happened and
   % report it to the command window:
   nevents = GetEventCounter(sm);
   if nevents > size(events, 1),  % Aha! new things have happened!
     % Get the new events from the State Machine:
     newevents = GetEvents(sm, size(events,1)+1, nevents);
     % And parse them into something legible using the disassembler:
     strevs = disassemble(sma, newevents);
     
     for i=1:size(strevs,1)
       fprintf(1, 'At time %.4f, %s caused %s --> %s\n', strevs{i,3}, ...
         strevs{i,2}, strevs{i,1}, strevs{i,4});
     end;
     
     % Finally, store all for posterity if we want them later:
     events = [events ; newevents];
   end;
end;


% If you want to see the events in a parsed structure format, do:
parsed_events = disassemble(sma, newevents, 'parsed_structure', 1);