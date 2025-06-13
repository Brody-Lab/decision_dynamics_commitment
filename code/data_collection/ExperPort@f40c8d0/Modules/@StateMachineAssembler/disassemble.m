% [dis, dis2] = disassemble(sma, events, {'parsed_structure', 0}, {...
%           'also_non_parsed', 0}, {'pokes_starting_state', []})      
%
% Given a StateMachineAssembler object and a numeric events matrix, decodes the
% events matrix into legible form and prints out the sequence of events to
% the screen. If no output argument is given, the legible form is printed
% out to the screen on the command window. Either a complete sma or one
% that has gone through @StateMachineAssebler/compressed.m are fine to use
% for disassembling.
%
% PARAMETERS:
% -----------
%
% sma     A StateMachineAssembler object. This must be an sma with states
%         defined in it (through add_state.m, etc.) in the same form as the
%         state machine that was running when the events were obtained from
%         the state machine. Either the original sma or compressed(sma)
%         work fine.
%
% events  An events matrix, as obtained from @RTLSM/GetEvents.m
%
% 
% OPTIONAL PARAMETERS:
% --------------------
%
% 'parsed_structure'     If 1, a structure containing the start and stop
%         times of each type of state and poke is returned. If 0, a
%         sequential event by event cell is returned (each event occupying
%         one row). This optional parameter is only relevant if there is an
%         output argument, otherwise it is ignored. See RETURNS below.
%
% 'also_non_parsed'      Only relevant if parsed_structure is 1. This argument 
%         is by default 0. If it is 1 and parsed_structure is 1, then a
%         third return argument is also returned; this second argument is
%         of the same form as the first would have been if parsed_structure
%         had been 0 (so you can have access to both types of returns).
%
% 'pokes_starting_state'    By default empty, if passed should be a
%        structure that has fields as described for
%        dis.pokes_starting_state below when parsed_structure is 1. This
%        information will be used as seed information for the pokes state:
%        when the current set of events does not allow determining the
%        pokes state, then the structure passed as pokes_starting_state
%        will be used to provide that information. Phrased differently: if
%        in the current set of events, there were no poke-related events,
%        we cannot say whether any poke is occupied or unoccupied.
%        'pokes_starting_state' may be used to seed knowledge of the pokes
%        state.
%
%
% RETURNS:
% --------
%
% If no output argument is given, returns nothing, but prints the
% disassembly results out to the screen.
%
% dis     The disassembled events. This can be in one of two formats. If
%         the optional argument 'parsed_structure' is 0 (its default), then
%         dis will be an n-by-6 cell. Each row of the cell will represent
%         one event. The first column is the name of the state the machine
%         was in when the event happened; the second is the name of the
%         event that occurred (e.g., 'Cin'); the third is the time at which
%         it occurred; and the fourth is the name of the state to which the
%         machine jumped as a result of the event. The fifth is the state
%         _number_ of the state the machine was in when the event happened;
%         and the sixth is the state _number_ of the state to which the
%         machine jumped as a result of the event.
%            If the optional argument 'parsed_structure' is 1, then dis
%         will not be a cell but a structure with two fieldnames, 'states'
%         and 'pokes', with both fields containing a structure. Each of the
%         fieldnames of the dis.states will be one of the existing state
%         names of the sma. The content of each field will be an n-by-2
%         numeric matrix. n will be the number of times the machine was in
%         that state; the first row is the time at which the state was
%         entered; and the second row the time at which the state was left.
%         A NaN corresponds to lack of entering or leaving information. In
%         addition to the state names, two special fields will also be
%         returned: 'starting_state', which will contain the name of the
%         state the machine was in when the first event occurred, and
%         'ending_state', which will contain the name of the state the
%         machine ended in after the last event was processe. The second
%         field of dis, dis.pokes, will contain a fieldname for each
%         component of identify_pokes(sma).m. In a typical 3-poke setup,
%         this will be C, L, and R (for Center, Left, Right). The form of
%         entries for these fields is exactly as with the states above. The
%         difference is that while the machine can be in inly one state at
%         any given time, more than one poke may be occupied at any given
%         time. Two further fields, 'starting_state' and 'ending_state'
%         will also be created in dis.pokes. But unlike dis.states, each of
%         these will not contain a single name, but will once again contain
%         fieldnames corresponding to identify_pokes(sma). Each of these
%         fields will either contain the empty string, meaning no
%         information, or the string 'in', or the string 'out', indicating
%         what the disassembler can tell about the initial or final states
%         of the pokes.
%
% dis2    Only returned if the optional params parsed_structure and
%         also_non_parsed are both 1. In that case, dis2 will be equal to
%         what dis would have been if parsed_structure had been 0.
%
%
% EXAMPLES:
% ---------
%
% Suppose you run a state machine for a bit; for example, using
% @StateMachineAssembler/Example/example1.m
%  Then, if sm is the state machine, and sma is the state machine
%  assembler, do
%    >> nevents = GetEventCounter(sm);
%    >> events  = GetEvents(sm, 1, nevents);
%    >> disassemble(sma, events);
%  or, equivalently for the last line,
%    >> disassemble(compressed(sma), events);
%  or, to get the disassembly returned in a cell,
%    >> dis = disassemble(sma, events);
%  or, to get the disassembly returned in a parsed structure:
%    >> dis = disassemble(sma, events, 'parsed_structure', 1);
%
%

% Written by Carlos Brody October 2006. Extensively re-written by CDB April
% 2007 


function [ppstruct, pstruct2] = disassemble(sma, events, varargin)
   global fake_rp_box; % <~> Added 2008.July.24 for determination of format of event type information in the events matrix
   pairs = { ...
     'parsed_structure'      0   ; ...
     'also_non_parsed'       0   ; ...
     'pokes_starting_state'  []  ; ...
   }; parseargs(varargin, pairs);

   % If we're using happenings, disassembly is different-- let's go to a
   % specialized function for that.
   if sma.use_happenings,
      if nargout==0, 
         disassemble_with_happenings(sma, events, 'parsed_structure', parsed_structure, ...
            'also_non_parsed', also_non_parsed, 'pokes_starting_state', pokes_starting_state);
      elseif nargout==1,
         ppstruct = disassemble_with_happenings(sma, events, 'parsed_structure', parsed_structure, ...
            'also_non_parsed', also_non_parsed, 'pokes_starting_state', pokes_starting_state);
      else
         [ppstruct, pstruct2] = disassemble_with_happenings(sma, events, 'parsed_structure', parsed_structure, ...
            'also_non_parsed', also_non_parsed, 'pokes_starting_state', pokes_starting_state);
      end;
      return;
   end;
   
   % Some backwards compatibility:
   if size(events,2)==3, events = from_oldstyle_to_newstyle(events); end;

   if size(sma.states,2) == size(sma.output_map,1),  sma_is_compressed = 1;
   else                                              sma_is_compressed = 0;
   end;

   statenames = get_labels(sma);
   colnames   = get_col_labels(sma);
   
   % Find the columns that correspond to pokes:
   pokenames = identify_pokes(sma); pokelist = {}; 
   for i=1:length(pokenames), pokelist = [pokelist ; {[pokenames{i} 'in'] ; [pokenames{i} 'out']}]; end;
   u = find(ismember(colnames(:,1), pokelist));
   poke_columns = cell2mat(colnames(u,2)); %#ok<FNDSB,NASGU>
   
   % Find the columns that correspond to scheduled waves
   [wavenames{1:length(sma.sched_waves),1}] = deal(sma.sched_waves.name);
   wavelist = {};
   for i=1:length(wavenames), wavelist = [wavelist; {[wavenames{i} '_In'] ; [wavenames{i} '_Out']}]; end;

   stateids = cell2mat(statenames(:,2)); 
   colids   = cell2mat(colnames(:,2));
   
   outcols = cell2mat(sma.output_map(:,2)');
   % Now how much we have to subtract to get the first output column:
   if sma_is_compressed,  mnoc    = min(outcols)-1;
   else                   mnoc    = 0;
   end;
   
   [trash, I] = sort(stateids);
   statenames = statenames(I,:);
   stateids = cell2mat(statenames(:,2)); 

   sma.states = [sma.states ; sma.iti_states];
   if ~parsed_structure, pstruct = {};
   else
     % Initialize the parsed_stucture to empties
     fnames = lower(statenames(:,1)); pnames = identify_pokes(sma); wnames = wavenames;
     pstruct = struct('states', cell2struct(cell(size(fnames,1),1), fnames, 1), ...
                      'pokes', cell2struct(cell(size(pnames,1),1), pnames, 1), ...
                      'waves', cell2struct(cell(size(wnames,1),1), wnames, 1));
     for i=1:size(fnames,1), pstruct.states.(fnames{i}) = zeros(0,2); end;  
     for i=1:size(pnames,1), pstruct.pokes. (pnames{i}) = zeros(0,2); end;
     for i=1:size(wnames,1), pstruct.waves. (wnames{i}) = zeros(0,2); end;
     pstruct.states.starting_state = ''; pstruct.states.ending_state = '';
     pstruct.pokes. starting_state = cell2struct(cell(size(pnames,1),1), pnames, 1);
     pstruct.pokes.   ending_state = cell2struct(cell(size(pnames,1),1), pnames, 1);
     pstruct.waves. starting_state = cell2struct(cell(size(wnames,1),1), wnames, 1);
     pstruct.waves.   ending_state = cell2struct(cell(size(wnames,1),1), wnames, 1);
     % Use the pokes_starting_state hint if it is provided:
     if ~isempty(pokes_starting_state)
       if ~isempty(setdiff(fieldnames(pokes_starting_state), pnames)), warning('pokes_starting_state has weird poke names -- ignoring it!'); %#ok<WNTAG>
       else
         pstruct.pokes.starting_state = pokes_starting_state;
         pstruct.pokes.ending_state   = pokes_starting_state;
       end;
     end;
     % May also need to initialised the other type of output:
     if also_non_parsed, pstruct2 = {}; end;
   end;
   
   % <~> Check to see what system we're on (e.g. emulator (SoftSMMarkII),
   %       RTLSM, or RTLSM2). Added 2008.July.24 locally.
   %     We use this information to determine whether the events matrix is
   %       using new or old representation of the event type (event # is
   %       new; 2^(event #) is old.)
   try
       [f_r_b errID] = bSettings('get','RIGS','fake_rp_box');
       if errID,    f_r_b       = fake_rp_box; end;
   catch
                    f_r_b       = fake_rp_box;
   end;
   if ismember(f_r_b,[3 20]),   use_new_event_type_format = true;
   else                         use_new_event_type_format = false;
   end;
   % <~> end added
               
   for i=1:rows(events),
     % Find the name of the current input column
     
     % <~> 2008.July.24 modified block below to use correct event type format.
     if use_new_event_type_format,
         cid = find(events(i,2)==colids-1); % <~> stripped power to match format of GetEvents2 (reports column #s instead of 2^#)
     else
         cid = find(events(i,2)==2.^(colids-1)); % <~> old way
     end;
     % <~> end modified
     if isempty(cid), col_str = 'none';
     else             col_str = colnames{cid,1};
     end;
      
     % Find the name of the starting state for the current event
     sid = find(events(i,1) >= stateids, 1, 'last'); 
     if isempty(sid), state_str = 'none';
     else             state_str = lower(statenames{sid,1});
     end;

     % Find the name of the ending state for the current event
     sid2 = find(events(i,4) >= stateids, 1, 'last');
     if isempty(sid2),state_str2= 'none';
     else             state_str2= lower(statenames{sid2,1});
     end;
      
     if nargout == 0,
       % We aren't returning a pstruct, we're printing to the screen:
       fprintf(1, 't=%.5f :: %s causes %s --> %s (#%d-->#%d) \t', events(i,3), col_str, ...
         state_str, state_str2, events(i,1), events(i,4));

       for j=1:length(outcols),
         outval  = sma.states{events(i,4)+1, outcols(j)-mnoc};
         if ~isempty(outval)  && (~isnumeric(outval) ||  outval ~= 0),
           outname = sma.output_map{j,1};
           switch outname,
             case 'DOut',         fprintf(1, 'DOut=%d \t', outval);
             case 'SoundOut',
               if i==1 || events(i,1) ~= events(i,4), fprintf(1, 'SoundOut=%d \t',      outval); end;
             case 'SchedWaveTrig',
               if i==1 || events(i,1) ~= events(i,4), fprintf(1, 'SchedWaveTrig=%s \t', outval); end;
             otherwise
               if i==1 || events(i,1) ~= events(i,4), fprintf(1, '%s=%d \t', outname,   outval); end;
           end;
         end;
       end;
       fprintf(1, '\n');
     else
       % We aren't printing to the screen, we're returning to the output arg:
       
       time = events(i,3);
       if ~parsed_structure,
         pstruct = [pstruct ; {state_str, col_str, time, state_str2, events(i,1), events(i,4)}];
         
       else
         if also_non_parsed,
           pstruct2 = [pstruct2 ; {state_str, col_str, time, state_str2, events(i,1), events(i,4)}];
         end;
         
         if i==1,            pstruct.states.starting_state = state_str;  end;
         if i==rows(events), pstruct.states.ending_state   = state_str2; end;
         
         % We're doing the parsed structure thing. Now, for state transitions:
         if ~strcmp(state_str, state_str2),  % We exited state_str, entered state_str2
           if isempty(pstruct.states.(state_str)),  pstruct.states.(state_str) = [NaN time];  % Dang, we exited state_str but don't know when we entered it! NaN is the best we can say
           else                                     pstruct.states.(state_str)(end,2) = time; % Ok, pair the exit with the entry mark.
           end;
           % Now put in a new entry to state_str2 (don't know time of exit from state_str2 yet, so mark it as NaN):
           pstruct.states.(state_str2) = [pstruct.states.(state_str2) ; [time, NaN]];
         end;
         
         % And for the poking:
         for i=1:length(pokenames), %#ok<FXSET>
           if strcmp(col_str, [pokenames{i} 'in']),      % Entering pokenames{i}
             pstruct.pokes.(pokenames{i}) = [pstruct.pokes.(pokenames{i}) ; [time, NaN]];
             if isempty(pstruct.pokes.starting_state.(pokenames{i})), pstruct.pokes.starting_state.(pokenames{i}) = 'out'; end;  % If we didn't know how we'd started, now we do! 
             pstruct.pokes.ending_state.(pokenames{i}) = 'in'; % If no other event with this poke happens, we'll have ended in an 'in' state...
           elseif strcmp(col_str, [pokenames{i} 'out']), % Exiting pokenames{i}
             if isempty(pstruct.pokes.(pokenames{i})), pstruct.pokes.(pokenames{i}) = [NaN time]; % Woops, exiting, but don't know when we entered... NaN is best we can do
             else                                      pstruct.pokes.(pokenames{i})(end,2) = time;
             end;
             if isempty(pstruct.pokes.starting_state.(pokenames{i})), pstruct.pokes.starting_state.(pokenames{i}) = 'in'; end;  % If we didn't know how we'd started, now we do! 
             pstruct.pokes.ending_state.(pokenames{i}) = 'out'; % If no other event with this poke happens, we'll have ended in an 'out' state...
           end; 
         end; % End looping through pokenames
         
         % Now for the scheduled waves:
         for i=1:length(wavenames), %#ok<FXSET>
             if strcmp(col_str, [wavenames{i} '_In']), % wavename{i} coming in
                 if strcmp(bSettings('get', 'RIGS', 'RTSM_Settings'), 'SoftSMMarkII') && sma.sched_waves(i).sustain == 0,  % CURRENT BUG IN EMULATOR MEANS SUSTAIN OF 0 HAS NO MARK FOR OUT EVENT; ADD HERE, MANUALLY:
                   pstruct.waves.(wavenames{i}) = [pstruct.waves.(wavenames{i}); [time, time]];
                   if isempty(pstruct.waves.starting_state.(wavenames{i})), pstruct.waves.starting_state.(wavenames{i}) = 'out'; end;
                   pstruct.waves.ending_state.(wavenames{i}) = 'out';
                 else
                   pstruct.waves.(wavenames{i}) = [pstruct.waves.(wavenames{i}); [time, NaN]];
                   if isempty(pstruct.waves.starting_state.(wavenames{i})), pstruct.waves.starting_state.(wavenames{i}) = 'out'; end;
                   pstruct.waves.ending_state.(wavenames{i}) = 'in';
                 end;
             elseif strcmp(col_str, [wavenames{i} '_Out']), % wavename{i} going out
                 if isempty(pstruct.waves.(wavenames{i})), pstruct.waves.(wavenames{i}) = [NaN, time]; % wave is out but we don't know when it came in...
                 else                                      pstruct.waves.(wavenames{i})(end,2) = time;
                 end
                 if isempty(pstruct.waves.starting_state.(wavenames{i})), pstruct.waves.starting_state.(wavenames{i}) = 'in'; end
                 pstruct.waves.ending_state.(wavenames{i}) = 'out';
             end
         end; % End looping through wavenames
       end; % End if/else ~parsed_structure
     end; % End if/else nargout==0  
   end; % End of looping through events

%    if parsed_structure==1,
%      % Ok, for each poke type we need to find the first and last poke event:
%      pokelist = identify_pokes(sma); pokeeventnames = {};     
%      pstruct.pokes_starting_state = cell2struct(cell(size(pokelist)), pokelist);
%      pstruct.pokes_ending_state   = cell2struct(cell(size(pokelist)), pokelist);
%      for i=1:length(pokelist), ...
%          pokeeventnames = [pokeeventnames {[pokelist{i} 'in'] [pokelist{i} 'out']}];
%          pstruct.pokes_starting_state.(pokelist{i}) = 'unknown';
%          pstruct.pokes_ending_state.(pokelist{i})   = 'unknown';
%      end;
%      u = find(ismember(colnames(:,1), pokeeventnames));
%      poke_columns = cell2mat(colnames(u,2));
%      all_poke_events = find(ismember(events(:,2), 2.^(poke_columns-1)));
%      
%      for i=1:length(pokelist),
%        u = find(ismember(colnames(:,1), {[pokelist{i} 'in'] [pokelist{i} 'out']}));
%        this_poke_columns = cell2mat(colnames(u,2));
%        firstpoke = find(events(all_poke_events,2) == 2.^(this_poke_columns(1)-1)  |  ...
%          events(all_poke_events,2) == 2.^(this_poke_columns(2)-1), 1, 'first');
%        lastpoke  = find(events(all_poke_events,2) == 2.^(this_poke_columns(1)-1)  |  ...
%          events(all_poke_events,2) == 2.^(this_poke_columns(2)-1), 1, 'last');
%        
%        firstpoke = all_poke_events(firstpoke);
%        lastpoke  = all_poke_events(lastpoke);
%        if ~isempty(firstpoke),
%          firstpokename = colnames{log2(events(firstpoke,2))+1,1};
%          if     strcmp(firstpokename(end-1:end), 'in' ), pstruct.pokes_starting_state.(pokelist{i}) = 'out';
%          elseif strcmp(firstpokename(end-2:end), 'out'), pstruct.pokes_starting_state.(pokelist{i}) = 'in';
%          end;
%        elseif ~isempty(pokes_starting_state) && isfield(pokes_starting_state, pokelist{i}),
%          pstruct.pokes_starting_state.(pokelist{i}) = pokes_starting_state.(pokelist{i});         
%        end;
%        if ~isempty(lastpoke),
%          lastpokename = colnames{log2(events(lastpoke,2))+1,1};
%          if     strcmp(lastpokename(end-1:end), 'in' ), pstruct.pokes_ending_state.(pokelist{i}) = 'in';
%          elseif strcmp(lastpokename(end-2:end), 'out'), pstruct.pokes_ending_state.(pokelist{i}) = 'out';
%          end;
%        elseif ~isempty(pokes_starting_state) && isfield(pokes_starting_state, pokelist{i}),
%          pstruct.pokes_ending_state.(pokelist{i}) = pokes_starting_state.(pokelist{i});         
%        end;
%      end;
%    end;
   
   
   if nargout > 0, ppstruct = pstruct; end;
   
   return;
   
   
   
   
% -------------------------------------

function [newevs] = from_oldstyle_to_newstyle(evs)

   if rem(size(evs,1),2) ~= 0,
     error('Woops, not an even number of oldstyle events!');
   end;

   newevs = zeros(size(evs,1)/2, 4);
   for i=1:size(evs,1)/2,
     from = evs((i-1)*2+1,:); to = evs((i-1)*2+2,:);
     newevs(i,:) = [from(1) 2.^(from(2)-1) from(3) to(1)];
   end;
   