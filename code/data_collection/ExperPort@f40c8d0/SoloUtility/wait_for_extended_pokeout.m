%



%
% NOTE!!!: The current implementation assumes (1) that there are only
% DIO scheduled waves declared, no analog out ones; (2) that apart from
% scheduled waves, input event mapping is the standard [1 -1 2 -2 3 -3]
% for three nose cones. (see @RTLSM/SetInputEvents.m). 
%

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
% >> [sm, stm] = wait_for_extended_pokeout(sm, stm, 'startpoke', 'L', ...
%                       'contout_line', 1, 'contout_time', 0.15, ...
%                       'minwait', 2, 'maxwait', 5, 'maxout', 0.5); 
%
% Upon final exit, the FSM will
% come out into the state immediately after the
% new section. Let's make sure to define that state. Here, it
% is defined simply as "jump back to state 0 after 1 ms.":
% >> stm = [stm ; 0 0 0 0 0 0 0 0 0 0 0 0.001 0 0 0]; 
%
% Send all the definitions to the FSM:
% >> sm = SetStateMatrix(sm, stm); 
%
% And run the thing:
% >> sm = Run(sm); sm = ForceState0(sm); for i=1:10000, sm = FlushQueue(sm); pause(0.1); end;
%
%


function [sm, stm] = wait_for_extended_pokeout(sm, stm, varargin)
   
   pairs = { ...
     'startpoke'         'L'      ; ...
     'contout_line'       0       ; ...
     'contout_time'       0       ; ...
     'init_trigout'       0       ; ...
     'minwait'            0       ; ...
     'maxwait'            0       ; ...
     'maxout'             0       ; ...
   }; parseargs(varargin, pairs);
   
   st = rows(stm);    mo = maxout;
   mn = minwait;      mx = maxwait;  
   cl = contout_line; ct = contout_time;
   it = init_trigout;
   
   if contout_time < 0.001,
      error('Sorry, contout_time must be at least 1 ms');
   end;
   if minwait <= contout_time,
      error('Sorry, minwait must be larger than contout_time');
   end;
   if maxwait <= minwait,
      error('Sorry, maxwait must be larger than minwait');
   end;
   if maxout < 0.001,
      error('Sorry, maxout must be at least 1 ms');
   end;
   
   scheds       = GetDIOScheduledWaves(sm);
   schedids     = scheds(:,1);
   schedincols  = scheds(:,2);
   schedoutcols = scheds(:,3);
   
   existing_cols = unique([schedincols ; schedoutcols]);
   existing_cols = existing_cols(find(existing_cols>5));
   if ~isempty(existing_cols), nx = max(existing_cols)-5;
   else                        nx = 0;
   end;

   % If we didn't have the schedwaves trig column before, add it:
   if isempty(scheds), stm = [stm zeros(rows(stm),1)]; end;

   % Determine our new sched wave numbers; start with continous out counter:
   if isempty(schedids), contout_wavenumber = 1;
   else                  contout_wavenumber = max(unique(schedids))+1; end;

   % Make new input column for our wavenumbers:
   if ~isempty(existing_cols), cocol = max(existing_cols)+1;
   else                        cocol = 6;
   end;

   % Now the mintime wavenumbers and the outtime wavenumbers
   mintime_wavenumber  = contout_wavenumber + 1;
   maxtime_wavenumber  = contout_wavenumber + 2;   
   outtime_wavenumber  = contout_wavenumber + 3;   
   mncol = cocol + 1; 
   mxcol = cocol + 2;
   otcol = cocol + 3;
   
   scheds = [scheds ; ...
             [contout_wavenumber -1 cocol   -1 contout_time 0 0] ; ...
             [mintime_wavenumber -1 cocol+1 -1 minwait      0 0] ; ...
             [maxtime_wavenumber -1 cocol+2 -1 maxwait      0 0] ; ...
             [outtime_wavenumber -1 cocol+3 -1 maxout       0 0] ; ...
            ];
   cw = 2^contout_wavenumber; mnw = 2^mintime_wavenumber;
   ow = 2^outtime_wavenumber; mxw = 2^maxtime_wavenumber;
     
   sm  = SetInputEvents(sm, cocol+4);
   sm  = SetScheduledWaves(sm, scheds);
   stm = [stm(:,1:cocol) [0:rows(stm)-1]'*ones(1,4) stm(:,cocol+1:end)];

   st = rows(stm);
   xxx = cw + mnw + mxw;
   
   switch startpoke
    case 'L',
      nstm = [ ...
        st   st   st+1 st   st   st   st  *ones(1,nx) 0    0    0    0    st   100 0  0  0 ; ...     % 0: Waiting for action
        st+1 st+1 st+1 st+2 st+1 st+1 st+1*ones(1,nx) st+4 0    0    0    st+1 100 cl it xxx ; ...   % 1: Inside, triggering alarms
        st+2 st+2 st+3 st+2 st+2 st+2 st+2*ones(1,nx) st+5 0    0    0    st+2 100 cl 0  0   ; ...   % 2: Outside,in contout mode
        st+3 st+3 st+3 st+2 st+3 st+3 st+3*ones(1,nx) st+4 0    0    0    st+3 100 cl 0  0   ; ...   % 3: Inside, in contout mode
        st+4 st+4 st+4 st+5 st+4 st+4 st+4*ones(1,nx) 0    st+6 0    0    st+4 100 0  0  0   ; ...   % 4: Inside, in mintime mode
        st+5 st+5 st+4 st+5 st+5 st+5 st+5*ones(1,nx) 0    st+7 0    0    st+5 100 0  0  0   ; ...   % 5: Outside,in mintime mode
        st+6 st+6 st+6 st+7 st+6 st+6 st+6*ones(1,nx) 0    0    st+8 st+6 st+6 100 0  0  -ow ; ...   % 6: Inside, in done mode
        st+7 st+7 st+6 st+7 st+7 st+7 st+7*ones(1,nx) 0    0    st+8 st+8 st+7 100 0  0  ow  ; ...   % 7: Outside,in done mode
             ]; 
     
    case 'R',
      nstm = [ ...
        st   st   st   st   st+1 st   st  *ones(1,nx) 0    0    0    0    st   100 0  0 0 ; ...     % 0: Waiting for action
        st+1 st+1 st+1 st+1 st+1 st+1 st+1*ones(1,nx) st+4 0    0    0    st+1 100 cl 0 xxx ; ...   % 1: Inside, triggering alarms
        st+2 st+2 st+2 st+2 st+3 st+2 st+2*ones(1,nx) st+5 0    0    0    st+2 100 cl 0 0   ; ...   % 2: Outside,in contout mode
        st+3 st+3 st+3 st+3 st+3 st+3 st+3*ones(1,nx) st+4 0    0    0    st+3 100 cl 0 0   ; ...   % 3: Inside, in contout mode
        st+4 st+4 st+4 st+4 st+4 st+5 st+4*ones(1,nx) 0    st+6 0    0    st+4 100 0  0 0   ; ...   % 4: Inside, in mintime mode
        st+5 st+5 st+5 st+5 st+4 st+5 st+5*ones(1,nx) 0    st+7 0    0    st+5 100 0  0 0   ; ...   % 5: Outside,in mintime mode
        st+6 st+6 st+6 st+6 st+6 st+7 st+6*ones(1,nx) 0    0    st+8 st+6 st+6 100 0  0 -ow ; ...   % 6: Inside, in done mode
        st+7 st+7 st+7 st+7 st+6 st+7 st+7*ones(1,nx) 0    0    st+8 st+8 st+7 100 0  0 ow  ; ...   % 7: Outside,in done mode
             ]; 
     
    otherwise
      error(['Sorry, don''t know startpoke ''' startpoke '''']);
   end;
       

   stm = [stm ; nstm];
   return;

   