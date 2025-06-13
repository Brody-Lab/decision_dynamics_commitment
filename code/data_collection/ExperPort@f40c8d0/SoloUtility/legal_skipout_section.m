

% ----- LEGAL_SKIPOUT_SECTION

% Adds a chunk of statematrix in which an in poke has to be maintained
% for timelength secs, but during which brief poke outs are
% allowed. Takes the current state matrix and adds to it; uses
% scheduled waves, so does the necessary modifications to them through
% the FSM object. 
%
% NOTE!!!: The current implementation assumes (1) that there are only
% DIO scheduled waves declared, no analog out ones; (2) that apart from
% scheduled waves, input event mapping is the standard [1 -1 2 -2 3 -3]
% for three nose cones. (see @RTLSM/SetInputEvents.m). 
%
% The first state in the chunk of state matrix added is one where the
% system is simply waiting for the initiating poke; upon this
% initiating poke, it goes to the *second* state in the added state
% matrix. So, if you want to go straight to that upon poke, go to the
% second state.

% EXAMPLE CODE:
% -------------
%
% This is a self-sufficient bit of example code
%
% First create an FSM:
% >> sm = SoftSMMarkII; sm = Initialize(sm); 
%
% We start with a null state matrix; legal_skipout_section.m requires
% *some* starting state matrix:
% >> stm = zeros(0, 10); 
%
% Now create a section in which the animal has to poke into the Right
% port, stay there for 4 seconds, and is allowed pokeouts of <= 0.5
% secs. Trigger 1 is set off on the initial Right poke:
% >> [sm, stm] = legal_skipout_section(sm, stm, 4, 'legalskipout', 0.5, ...
%                                     'initial_trigger', 1, 'startpoke', ...
%                                     'R'); 
%
% Upon successful exit (stay in the poke for the 4 secs), the FSM will
% come out into the state immediately after the
% legal_skipout_section. Let's make sure to define that state. Here, it
% is defined simply as "jump back to state 0 after 1 ms.":
% >> stm = [stm ; 0 0 0 0 0 0 0 0 0.001 0 0 0]; 
%
% Send all the definitions to the FSM:
% >> sm = SetStateMatrix(sm, stm); 
%
% And run the thing:
% >> sm = Run(sm); sm = ForceState0(sm); for i=1:10000, sm = FlushQueue(sm); pause(0.1); end;
%
%


function [sm, stm] = legal_skipout_section(sm, stm, timelength, varargin)
   
   pairs = { ...
     'startpoke'         'C'      ; ...
     'penalty_state'      []      ; ...
     'legalskipout'       0       ; ...
     'initial_trigger'    0       ; ...
   }; parseargs(varargin, pairs);
   if isempty(penalty_state), penalty_state = rows(stm); end;
   
   st = rows(stm);  ps = penalty_state;    ls = legalskipout;
   tl = timelength; it = initial_trigger;
   
   scheds       = GetDIOScheduledWaves(sm);
   schedids     = scheds(:,1);
   schedincols  = scheds(:,2);
   schedoutcols = scheds(:,3);
   
   existing_cols = unique([schedincols ; schedoutcols]);
   existing_cols = existing_cols(find(existing_cols>5));
   if ~isempty(existing_cols), nx = max(existing_cols)-5;
   else                        nx = 0;
   end;

   if legalskipout == 0,
      switch startpoke,
       case 'C',
         nstm=[ ...
           st+1 st  st st  st st  st*ones(1, nx)  st  100  0 0  ; ...
           st+1 ps  ps ps  ps ps  ps*ones(1, nx) st+2  tl  0 it ];
         
       case 'L',
         nstm=[ ...
           st st  st+1 st  st st  st*ones(1, nx)  st  100  0 0  ; ...
           ps ps  st+1 ps  ps ps  ps*ones(1, nx) st+2  tl  0 it ];
         
       case 'R',
         nstm=[ ...
           st st  st st  st+1 st  st*ones(1, nx)  st  100  0 0  ; ...
           ps ps  ps ps  st+1 ps  ps*ones(1, nx) st+2  tl  0 it ];
       
       otherwise, error(['Don''t know startpoke ' startpoke]);
      end;

      % If there was a scedwaves trig column, put it in:
      nstm = [nstm zeros(2,nx)];

      % And conclude:
      stm  = [stm ; nstm];
      return;
   end;
   
   % If we didn't have the schedwaves trig column before, add it:
   if isempty(scheds), stm = [stm zeros(rows(stm),1)]; end;

   % Determine our new sched wave number:
   if isempty(schedids), wavenumber = 1;
   else wavenumber = max(unique(schedids))+1;
   end;

   % Make a new input column for our wavenumber:
   if ~isempty(existing_cols), newcol = max(existing_cols)+1;
   else                        newcol = 6;
   end;

   scheds = [scheds ; [wavenumber -1 newcol -1 timelength 0 0]];
   sm  = SetInputEvents(sm, newcol+1);
   sm  = SetScheduledWaves(sm, scheds);
   stm = [stm(:,1:newcol) [0:rows(stm)-1]' stm(:,newcol+1:end)];

   
   wn = wavenumber; nc = newcol;
   ignorepokes = ones(4,1)*[st st st st st*ones(1,nx)];
   ignorepokes = [0:3]'*ones(1,cols(ignorepokes)) + ignorepokes;
   igpk = ignorepokes;
   
   switch startpoke,
       case 'C'         
         stm=[stm ; ...
              st+1 st   ignorepokes(1,:)  st    st   100  0 0   0 ; ...  
              st+1 st+2 ignorepokes(2,:)  st+4  st+1 100  0 it  2^wn;...
              st+3 st+2 ignorepokes(3,:)  st+4  ps   ls   0 0   0 ; ...
              st+3 st+2 ignorepokes(4,:)  st+4  st+3 100  0 0   0 ; ...
             ];

       case 'L'         
         stm=[stm ; ...
              igpk(1,1:2) st+1 st   igpk(1,3:end) st   st   100 0 0   0 ; ...
              igpk(2,1:2) st+1 st+2 igpk(2,3:end) st+4 st+1 100 0 it  2^wn;...
              igpk(3,1:2) st+3 st+2 igpk(3,3:end) st+4 ps   ls  0 0   0 ; ...
              igpk(4,1:2) st+3 st+2 igpk(4,3:end) st+4 st+3 100 0 0   0 ; ...
             ];

       case 'R'         
         stm=[stm ; ...
              igpk(1,1:4) st+1 st   igpk(1,5:end) st   st   100 0 0   0 ; ...
              igpk(2,1:4) st+1 st+2 igpk(2,5:end) st+4 st+1 100 0 it  2^wn;...
              igpk(3,1:4) st+3 st+2 igpk(3,5:end) st+4 ps   ls  0 0   0 ; ...
              igpk(4,1:4) st+3 st+2 igpk(4,5:end) st+4 st+3 100 0 0   0 ; ...
             ];

    otherwise, error(['Don''t know startpoke ' startpoke]);
   end;

   return;
   
