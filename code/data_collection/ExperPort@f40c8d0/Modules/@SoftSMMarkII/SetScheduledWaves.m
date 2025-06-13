% sm = SetScheduledWaves(sm, sched_matrix)
%                Specifies the scheduled waves matrix for a state machine.  
%                This is an M by 7 matrix of the following format
%                per row:
%                ID IN_EVENT_COL OUT_EVENT_COL DIO_LINE PREAMBLE SUSTAIN REFRACTION
%                Note that this function doesn't actually modify the 
%                SchedWaves of the FSM immediately.  Instead, a new 
%                SetStateMatrix call needs to be issued for the effects of 
%                this function to actually take effect.
%
% Detailed Explanation
% --------------------
%
% The sched matrix is an M by 7 matrix of the following format:
%
% ID IN_EVENT_COL OUT_EVENT_COL DIO_LINE PREAMBLE SUSTAIN REFRACTION
%
% Note that this function doesn't acrually modify the SchedWaves of the 
% FSM.  Instead, a new SetStateMatrix call needs to be issued 
% for the effects of this function to actually take effect.
%
% As for the matrix this function expected, column has the following 
% definition:
% ID -
%      the numeric id of the scheduled wave.  Each wave is numbered from
%      0-31.  (NOTE: 0 is a valid ID!). The ID is later used in the 
%      StateMatrix SCHED_WAVE column as a bitposition.  So for example if 
%      you want wave number with ID 10 to fire, you use 2^10 in the 
%      SCHED_WAVE column of the state matrix and 10 as the ID in this 
%      matrix.
% IN_EVENT_COL -
%      The column of the state matrix (0 being the first column) which
%      is to be used as the INPUT event column when this wave goes HIGH
%      (edge up). Think of this as a WAVE-IN event. Set this value to -1 to
%      have the state machine not trigger a state matrix input event for
%      edge-up transitions.
% OUT_EVENT_COL -
%      The column of the state matrix (0 being the first column) which
%      is to be used as the INPUT event column when this wave goes LOW
%      (edge down).  Think of this as a WAVE-OUT event.
%      Set this value to -1 to have the state machine not trigger a state 
%      matrix input event for edge-down transitions.
% DIO_LINE -
%      The DIO line on which to echo the output of this waveform.  Note
%      that not all waves need have a real DIO line associated with them.
%      Set this value to -1 to not use a DIO line.
% PREAMBLE (seconds) -
%      The amount of time to wait (in seconds) from the time the scheduled
%      wave is triggered in the state matrix SCHED_WAVE column to the time
%      it actually goes high.  Fractional numbers are ok.  Note the
%      granularity of this time specification is 1 millisecond, so values 
%      less than 1ms (0.001) are equivalent to 0.
% SUSTAIN (seconds) -
%      The amount of time to wait (in seconds) from the time the scheduled
%      wave is goes high to the time it should go low again.  Stated 
%      another way, the amount of time a scheduled wave sustains a high 
%      state.  Fractional numbers are ok.  Note the granularity of this 
%      time is 1 millisecond, so values less than 1ms (0.001) are equivalent
%      to 0.
% REFRACTION (seconds) -
%      The amount of time to wait (in seconds) from the time the scheduled
%      wave is goes low to the time it can successfully be triggered again 
%      by the SCHED_WAVE column of the state matrix. Fractional numbers are
%      ok.  Note the granularity of this time is 1 millisecond, so values 
%      less than 1ms (0.001) are equivalent to 0.
%
%
% EXAMPLE CODE:
% -------------
%
% Here is a full, self-contained, piece of example code using the
% Scheduled Waves. (As of 3/Aug/06, it has been written and tested with
% the FSM simulator, @SoftSMMarkII, not with the actual RT Linux FSM,
% but we have every reason to believe it should work fine on the actual
% RT Linux machine.)
%
% First we define a shceuled wave. It is wave number 1, does nothing on
% the rise, on the fall it triggers an input event on column 6 of the
% state matrix (note that the first column of the state matrix is column
% number 0), doesn't produce an output on any physical DIO line, has a
% 2 second preamble, a 0 secs sustain, and a 0 secs refractory period:
% >> scheds = [1 -1 6 -1 2 0 0];
%
% Now we define the state matrix. On startup, the machine is in state
% 0 and, at least in SoftSMMarkII, schedwave triggers are not set off
% there; so the first thing we do is just go to state 1. This will make
% a state transition as soon as the machine starts running, which below
% we will use to trigger the scheduled wave. In state 1, we
% just stay there forever (even when 100 secs go by, we just go to
% state 1 again). However, we do indicate that sched wave number 1
% should be started on entering state 1; and, in column 6, we further
% indicate that if wave number 1 goes "ping!", that should send us to
% state 2 (see scheds line above for the definition of how sched wave
% number 1 works). Finally, in state 2 we just hang
% there for one second, holding DIO line 1 up while there, and after
% that return to state 1. 
% (The columns are: Cin Cout Rin Rout Lin Lout SchedIn TUPstate Timer
% ContOut TrigOut SchedTrigs)
% >> statmat = [[0 0 0 0 0 0 0 1 0.001 0 0 0]; [1 1 1 1 1 1 2 1 100 0 0 2^1] ; [2 2 2 2 2 2 2 1 1 1 0 0]]
%
% Now lets start up a new state machine:
% >> sm = SoftSMMarkII; sm = Initialize(sm); 
%
% Let it know that it won't just have the default Cin, Cout, Lin, Lout,
% Rin Rout input events; in addition, we will make an extra input event
% column for the scheduled wave, making a total of 7 input columns:
% >> sm = SetInputEvents(sm, 7); 
%
% Now set up the definition of scheduled wave number 1:
% >> sm = SetScheduledWaves(sm, scheds); 
%
% To finalize the setup, set the state matrix, which makes the
% SetInputEvents and SetScheduledWaves statements also take effect:
% >> sm = SetStateMatrix(sm, statmat); 
%
% Finally, run the thing for a while:
% >> sm = Run(sm); sm = ForceState0(sm); for i=1:1000, sm = FlushQueue(sm); pause(0.1); end;
%
% With the RT Linux FSM, of course, we don't need the FlushQueue or
% pause statements.
%
% This example machine will stay 2 secs in state 1, then, triggered by
% the sched wave, go to state 2 and hold DIO line high for 1 second; and
% it will then repeat infinitely.
%


function [sm] = SetScheduledWaves(sm, sched_matrix)


    sm = get(sm.Fig, 'UserData');


    [m,n] = size(sched_matrix);
    if (n ~= 7 || m < 0), warning('Argument 2 to SetScheduledWaves needs to be an m x 7 matrix!'); end;
    id_ctr = zeros(32);
% check for dupes
    for i = 1:m
        id = sched_matrix(i, 1)+1;
        id_ctr(id) = id_ctr(id) + 1;
        if (id_ctr(id) > 1)
            error('In SetScheduledWaves: there is more than one wave having id %d', id-1); 
        end;        
    end;
    % no dupes, accept

    sm.NextSchedWaves = sched_matrix;
    
    set(sm.Fig, 'UserData',sm);


   return;
    
    