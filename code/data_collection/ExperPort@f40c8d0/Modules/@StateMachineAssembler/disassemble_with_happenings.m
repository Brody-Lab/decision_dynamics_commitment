% [dis, dis2] = disassemble_with_happenings(sma, events, {'parsed_structure', 0}, {...
%           'also_non_parsed', 0}, {'pokes_starting_state', []})      
%
% Given a StateMachineAssembler object that is using Happenings, and a
% numeric events matrix, decodes the events matrix into legible form and
% prints out the sequence of events to the screen. If no output argument is
% given, the legible form is printed out to the screen on the command
% window. Either a complete sma or one that has gone through
% @StateMachineAssebler/compressed.m are fine to use for disassembling.
%
% PARAMETERS:
% -----------
%
% sma     A StateMachineAssembler object. This must be an sma with states
%         defined in it (through add_state.m, etc.) in the same form as the
%         state machine that was running when the events were obtained from
%         the state machine. Either the original sma or compressed(sma)
%         work fine. disassemble_with_happenings.m can only work with smas
%         that used Happenings.
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

function [ppstruct, pstruct2] = disassemble_with_happenings(sma, events, varargin)
   pairs = { ...
     'parsed_structure'      0   ; ...
     'also_non_parsed'       0   ; ...
     'pokes_starting_state'  []  ; ...
   }; parseargs(varargin, pairs);   

   [trash, I] = sort(cell2mat(sma.state_name_list(:,2)));
   sma.state_name_list = sma.state_name_list(I,:);
   state_numbers = [cell2mat(sma.state_name_list(:,2)); size(sma.states,1)+1];
   
   if ~parsed_structure || also_non_parsed==1,
      dis = cell(size(events,1),6);

      last_start_state = -1;
      for i=1:size(events,1),
         time        = events(i,3);
         start_state = events(i,1);
         end_state   = events(i,4);
         happId      = events(i,2);
         
         start_name_row = find(start_state < state_numbers, 1, 'first')-1;
         end_name_row   = find(end_state   < state_numbers, 1, 'first')-1;
         start_name     = sma.state_name_list{start_name_row,1};
         end_name       = sma.state_name_list{end_name_row,  1};
         
         if happId >= 1,      happName = sma.happSpec(happId).name;
         elseif happId == -1, happName = 'Tup';
         else                 happName = 'none';
         end;
         
         if nargout==0,
            fprintf(1, 't=%.4f :: %s causes %s --> %s (#%d-->#%d) ', time, ...
               happName, start_name, end_name, start_state, end_state);
            
            if start_state ~= last_start_state,
               if sma.states{start_state+1,1} ~= 0, fprintf(1, 'DOut=%d ',         sma.states{start_state+1,1}); end;
            end;
            if end_state ~= start_state,
               if sma.states{end_state+1,2} ~= 0, fprintf(1, 'SoundOut=%d ',     sma.states{end_state+1,2}); end;
               if sma.states{end_state+1,3} ~= 0, fprintf(1, 'SchedWaveTrig=%s', sma.states{end_state+1,3}); end;
            end;
            fprintf(1, '\n');
         end;
         
         last_start_state = start_state;
         
         dis{i,1} = start_name;  dis{i,2} = happName; dis{i,3} = time; dis{i,4} = end_name; 
         dis{i,5} = start_state; dis{i,6} = end_state;
      end;
   
      if also_non_parsed,
         pstruct2 = dis;
      else
         ppstruct = dis;
      end;
   end;
   
   if parsed_structure,
      % Let's get the names of all pokes. These are defined as objects that
      % use the line_on and line_out detectorFunctions with name Xin and
      % Xout, respectively, where X stands for the poke identifier.
      [detectorFunctionNames{1:numel(sma.happSpec)}] = deal(sma.happSpec.detectorFunctionName);
   
      u = find(strcmp(detectorFunctionNames, 'line_in'));
      [InNames{1:numel(u)} ] = deal(sma.happSpec(u).name);
      for i=1:numel(InNames),  if numel(InNames{i})>2,  InNames{i}  = InNames{i}(1:end-2);  end; end;
      u = find(strcmp(detectorFunctionNames, 'line_out'));
      [OutNames{1:numel(u)}] = deal(sma.happSpec(u).name);
      for i=1:numel(OutNames), if numel(OutNames{i})>3, OutNames{i} = OutNames{i}(1:end-3); end; end;
      
      pokelist = intersect(InNames, OutNames);
      statelist = sma.state_name_list(:,1);
      [waveslist{1:numel(sma.sched_waves)}] = deal(sma.sched_waves.name);
      
      pstruct = struct('pokes', [], 'waves', [], 'states', []);
      C = cell(size(pokelist));  for i=1:numel(C), C{i} = zeros(0,2); end;
      pstruct.pokes  = cell2struct(C(:), pokelist(:), 1);
      C = cell(size(statelist)); for i=1:numel(C), C{i} = zeros(0,2); end;
      pstruct.states = cell2struct(C(:), statelist(:), 1);
      C = cell(size(waveslist)); for i=1:numel(C), C{i} = zeros(0,2); end;
      pstruct.waves  = cell2struct(C(:), waveslist(:), 1);
      
      pstruct.states.starting_state = ''; pstruct.states.ending_state = '';
      pstruct.pokes.starting_state = cell2struct(cell(numel(pokelist),1),  pokelist(:), 1);
      pstruct.pokes.  ending_state = cell2struct(cell(numel(pokelist),1),  pokelist(:), 1);
      pstruct.waves.starting_state = cell2struct(cell(numel(waveslist),1), waveslist(:), 1);
      pstruct.waves.  ending_state = cell2struct(cell(numel(waveslist),1), waveslist(:), 1);

      if ~isempty(pokes_starting_state)
         if ~isempty(setdiff(fieldnames(pokes_starting_state), pokelist)), warning('pokes_starting_state has weird poke names -- ignoring it!'); %#ok<WNTAG>
         else
            pstruct.pokes.starting_state = pokes_starting_state;
            pstruct.pokes.ending_state   = pokes_starting_state;
         end;
      end;

      for i=1:size(events,1),
         time        = events(i,3);
         start_state = events(i,1);
         end_state   = events(i,4);
         happId      = events(i,2);
         
         start_name_row = find(start_state < state_numbers, 1, 'first')-1;
         end_name_row   = find(end_state   < state_numbers, 1, 'first')-1;
         start_name     = sma.state_name_list{start_name_row,1};
         end_name       = sma.state_name_list{end_name_row,  1};
         
         if happId >= 1,      happName = sma.happSpec(happId).name;
         elseif happId == -1, happName = 'Tup';
         else                 happName = 'none';
         end;
         
         if i==1,            pstruct.states.starting_state = start_name;  end;
         if i==rows(events), pstruct.states.ending_state   = end_name;    end;
              
         if ~strcmp(start_name, end_name),  % We exited state_str, entered state_str2
           if isempty(pstruct.states.(start_name)),  pstruct.states.(start_name) = [NaN time];  % Dang, we exited state_str but don't know when we entered it! NaN is the best we can say
           else                                      pstruct.states.(start_name)(end,2) = time; % Ok, pair the exit with the entry mark.
           end;
           % Now put in a new entry to state_str2 (don't know time of exit from state_str2 yet, so mark it as NaN):
           pstruct.states.(end_name) = [pstruct.states.(end_name) ; [time, NaN]];
         end;
         
         % And for the poking:
         for i=1:length(pokelist), %#ok<FXSET>
           if strcmp(happName, [pokelist{i} 'in']),      % Entering pokenames{i}
             pstruct.pokes.(pokelist{i}) = [pstruct.pokes.(pokelist{i}) ; [time, NaN]];
             if isempty(pstruct.pokes.starting_state.(pokelist{i})), pstruct.pokes.starting_state.(pokelist{i}) = 'out'; end;  % If we didn't know how we'd started, now we do! 
             pstruct.pokes.ending_state.(pokelist{i}) = 'in'; % If no other event with this poke happens, we'll have ended in an 'in' state...
           elseif strcmp(happName, [pokelist{i} 'out']), % Exiting pokenames{i}
             if isempty(pstruct.pokes.(pokelist{i})), pstruct.pokes.(pokelist{i}) = [NaN time]; % Woops, exiting, but don't know when we entered... NaN is best we can do
             else                                     pstruct.pokes.(pokelist{i})(end,2) = time;
             end;
             if isempty(pstruct.pokes.starting_state.(pokelist{i})), pstruct.pokes.starting_state.(pokelist{i}) = 'in'; end;  % If we didn't know how we'd started, now we do! 
             pstruct.pokes.ending_state.(pokelist{i}) = 'out'; % If no other event with this poke happens, we'll have ended in an 'out' state...
           end; 
         end; % End looping through pokenames
         
         % Now for the scheduled waves:
         for i=1:length(waveslist), %#ok<FXSET>
             if strcmp(happName, [waveslist{i} '_In']), % wavename{i} coming in
                pstruct.waves.(waveslist{i}) = [pstruct.waves.(waveslist{i}); [time, NaN]];
                if isempty(pstruct.waves.starting_state.(waveslist{i})), pstruct.waves.starting_state.(waveslist{i}) = 'out'; end;  % If we didn't know how we'd started, now we do!
                pstruct.waves.ending_state.(waveslist{i}) = 'in'; % If no other event with this wave happens, we'll have ended in an 'in' state...
             elseif strcmp(happName, [waveslist{i} '_Out']), % wavename{i} going out
                 if isempty(pstruct.waves.(waveslist{i})), pstruct.waves.(waveslist{i}) = [NaN, time]; % wave is out but we don't know when it came in...
                 else                                      pstruct.waves.(waveslist{i})(end,2) = time;
                 end
                 if isempty(pstruct.waves.starting_state.(waveslist{i})), pstruct.waves.starting_state.(waveslist{i}) = 'in'; end;  % If we didn't know how we'd started, now we do!
                 pstruct.waves.ending_state.(waveslist{i}) = 'out'; % If no other event with this poke happens, we'll have ended in an 'out' state...
             end
         end; % End looping through wavenames     
      end; % End looping through events
      if nargout>0, ppstruct = pstruct; end;
   end;
   