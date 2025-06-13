% [stm, assembler_state_names, happList] = assemble(sma)
%
% Takes a StateMachineAssembler object, and resolves all state names and
% strings into the numerical matrix format that the state machine expects
% as inputs for its definition of the states and transitions. If there are
% references to states that haven't been defined yet, a warning and an
% error will ensue.
%
% This function is not usually called by users; instead, users more
% commonly call "@StateMachineAssembler/send.m," which itself calls
% assemble.m and sends the result to the state machine.
%
% PARAMETERS:
% -----------
%
% sma      A StateMachineAssembler object
%
%
% RETURNS:
% --------
%
% stm      A state matrix, in the format expected by
%          @RTLSM/SetStateMatrix.m   This is the result of assembling and
%          resolving all the states that were defined in sma. Each field in
%          this struct is a state name, and the values are the state
%          numbers corresponding to each state name.
%
% assembler_state_names   A structure in which <----- unfinished doc
%
%
% happList A happening list, same number of rows as stm. See
%          @RTLSM2/SetHappeningList for the format of this component. If
%          sma.use_happenings is 0, this will be an cell vector
%          (rows(stm),1), with each component empty.
%

% Written by Carlos Brody October 2006; modified by Sebastien Awwad 2007,2008
%
%<~>TODO: Complete doc. and revise code comments.
%
function [stm, assembler_state_names, happList] = assemble(sma)

% <~> Lookup the bit/channel number for the alarm/time-up input event. This
%     was generally (and by default) 7 at the time of this writing.
%     The point of doing this is so that we know the column number of the
%     last column in the state matrix that contains state numbers (of
%     states to jump to). The point of THAT is...
%        The ITI states and non-ITI states were kept separately and were
%        numbered separately. We must recombine them. We assume that all
%        columns up to and including the state-to-jump-to-on-timeup-event
%        column contain only state numbers, and that since this is so and
%        because of the separate numbering, and because we will recombine
%        them with all ITI states after non-ITI states, and since no ITI
%        states contain jumps to non-ITI states (except for one very
%        special target state, kinda), we must add that base iti state
%        number to all these fields. That's in the loop well below.
   TupCol = sma.input_map{find(strcmp('Tup', sma.input_map(:,1))), 2};
   % <~> The line above functions as follows:
   %     1:strcmp on (STRING, A) where A is a cell array of strings returns
   %       an array of size size(A) containing 1s in all positions
   %       corresponding (equal index) to positions where the value of A at
   %       that position was identical to STRING, and 0s elsewhere.
   %     2:find on the results of the strcmp above returns a column vector
   %       of the indices at which the value of the array returned by
   %       strcmp is 1, thus giving us the indices of the cells in A whose
   %       contents match STRING.
   %     3:In this case, that gives us the indices to cells in the first
   %       column of the input map (formatted as e.g.
   %               inputname  correspondingchannelnumber;
   %               inputname2 nextchannelnumber; ...)
   %       containing the string 'Tup', i.e. giving us the row number of
   %       the row in the input map dealing with a time-up event.
   %     4:The sma.input_map{[indexes], 2} returns the contents of the
   %       second column (channel number) for the Tup row.
   
   base_iti_state = rows(sma.states);
   if sma.pre35_curr_state == 1,
     if ~isempty(sma.iti_states),
       sma.states(36,1:TupCol) = num2cell(base_iti_state*ones(1,TupCol));
     else
       % No iti states were defined, so don't jump to anything from state
       % 35; just stay there.
       TimerCol = sma.self_timer_map{find(strcmp('Timer', sma.self_timer_map(:,1))), 2};
       sma.states(36,1:TupCol) = num2cell(35*ones(1,TupCol));
       % Have a sane self-timer here:
       sma.states{36,TimerCol} = 100;
     end;
   end;

   % <~> This combination significantly places the ITI states after the
   %     non-iti states; the first iti state will be numbered one higher
   %     than the last non-iti state.
   sma.states = [sma.states ; sma.iti_states];

   % <~> Prepare an appropriately-sized empty matrix. This will be a copy
   %     of the state matrix, in the familiar form you might see in older
   %     make_and_upload_state_matrix files.
   stm = zeros(size(sma.states));

   % <~> 'sw_outcol': scheduled wave output column/bit/channel,
   %     Load bit/channel number(s) for the scheduled wave output(s) in
   %     the sma.output_map into a temporary variable.
   %     Specifically:
   %         find output_map index(/ces) of the SchedWaveTrig entry, 
   sw_outcol = find(strcmp('SchedWaveTrig', sma.output_map(:,1))); 
   %         then load the output channel number(s) (column 2).
   if ~isempty(sw_outcol), sw_outcol = sma.output_map{sw_outcol,2}; end;

   % <~> Construct cell matrix with as many rows as there are states in the
   %     machine we're constructing, and 2 columns. Iterate over the rows.
   resolved_list = cell(rows(sma.state_name_list),2);
   for i=1:rows(sma.state_name_list),
      % <~> If this state is not flagged as an iti state (3rd col of
      %     state_name_list), create a variable with the name of the state
      %     name. In add_state.m, we screen putative state names for
      %     collisions with variables used here (e.g. i). NOTE THAT ANY
      %     ADDITIONAL VARIABLES ADDED HERE MUST HAVE THEIR NAMES ADDED TO
      %     THE RESERVED WORD LIST IN ./private/reserved_world_list.m!!!
      %     Set the state name variable equal to the state number (col 2).
      %     If the state IS FLAGGED as an iti state, add the base_iti_state
      %     value to the iti state number. This is how we renumber the
      %     states (originally separately numbered) into one numberspace.
      if sma.state_name_list{i,3} == 0,
         eval([lower(sma.state_name_list{i,1}) ' = ' ...
               num2str(sma.state_name_list{i,2}) ';']);
      else
         eval([lower(sma.state_name_list{i,1}) ' = base_iti_state + ' ...
               num2str(sma.state_name_list{i,2}) ';']);
      end;
      % <~> I think I'm misunderstanding, because what I'm seeing could
      %     have been done a lot more elegantly by simply taking the first
      %     two columns of the state_name_list and adding base_iti_state to
      %     the column 2 value for every iti state. Why did we eval and end
      %     up having to create a reserved name list, only to have to eval
      %     again?
      %
      % <~> Anyway, we create this resolved list using the state name list
      %     column 1 (state name) and the variables defined in the loop
      %     above.
      resolved_list{i,1} = lower(sma.state_name_list{i,1}); 
      resolved_list{i,2} = eval(lower(sma.state_name_list{i,1}));
   end;

   
   % <~> Iterate down the columns of sma.states (the state matrix), copying
   %     it into variable stm (created above the loop above) if the values
   %     are numeric (leaving it blank otherwise), and CORRECTING ALL THE
   %     STATE NUMBERS FOR ITI STATES IN JUMP-TO-STATE FIELDS BY ADDING THE
   %     BASE ITI STATE NUMBER TO THEM. See comments near the top of the
   %     file, where TupCol is set.
   for i=1:rows(stm),
      for j=1:cols(stm),
         if isnumeric(sma.states{i,j}) ||  islogical(sma.states{i,j}), 
            stm(i,j) = sma.states{i,j};
            if j <= TupCol && i > base_iti_state, 
               stm(i,j) = stm(i,j) + base_iti_state;
            end;
         else
            current_state = i-1;
            if ~isempty(sw_outcol) && j==sw_outcol,
               stm(i,j) =  resolve_schedwave_strs(i-1, sma.states{i,j}, ...
                                                  sma.sched_waves);
            else
               try 
                  entry = eval(lower(sma.states{i,j}));
                  
                  if ~isnumeric(entry), error_message(i-1, sma.states{i,j}, sma.state_name_list);
                  end;
                  
               catch
                  error_message(i-1, sma.states{i,j}, sma.state_name_list);
               end;
               stm(i,j) = entry;
               
               % stm(i,j)=resolve_strs(i-1,sma.states{i,j}, ...
               % sma.state_name_list);
            end;
         end;
      end;
      
      if sma.use_happenings,
        % Now resolve this state's entries in the happList
        current_state = i-1; %#ok<NASGU> % Make sure current_state has correct value, in case it was never updated for this state in loop above
        myHappList = sma.happList{i};
        for j=2:2:numel(myHappList),
          try
            entry = eval(lower(myHappList{j}));
            if ~isnumeric(entry), error_message(i-1, myHappList{j}, sma.state_name_list); end;
            
          catch
            error_message(i-1, myHappList{j}, sma.state_name_list);
          end;
          myHappList{j} = entry;
        end;
        sma.happList{i} = myHappList;
      end;
   
   end;
   

   assembler_state_names = compile_state_names(resolved_list, rows(sma.states));
   if sma.use_happenings,
     happList = sma.happList;
   else
     happList = cell(size(stm,1),1);
   end;
   
   return;
   
   
% -------------

% <~> Given the two-column list of state names and corresponding state
%     numbers (numbers after remapping that adds iti states into the mix
%     with non-iti states), along with the number of states, returns
%         !!!!!!!!!!
%         !!!!!!!!!! review and complete after verifying intuition
%         !!!!!!!!!!
function [asn] = compile_state_names(resolved_list, nstates)

  if isempty(resolved_list) | nstates == 0, asn = struct; end;
  
  % <~> Find the map from the current order of states as listed in the
  %     input list to a list of those states sorted by state number from
  %     low to high. This might look, for example, like this:
  %        states:              4, 3, 1, 5, 2
  %        indices for sorting: 3, 5, 2, 1, 4
  %                (the earliest is in position 3;
  %                 the 2nd ear. is in position 5;
  %                 the 3rd ear. is in position 2....)
  u = cell2mat(resolved_list(:,2));
  [trash, I] = sort(u);
  % <~> Note that 'trash' is trash because it is only a sorted version of
  %     the column of state numbers. That alone is useless.
  % <~> Sort the whole matrix according to the map produced. i.e. sort the
  %     <state, state number> pairs by state number.
  resolved_list = resolved_list(I,:);
  
  % <~> Read the reordered state list into a struct with each state name
  %     set as a field whose value is/are its corresponding state
  %     number(s) by creating an appropriately sized struct, defining its
  %     fields using the first column of our state list, and iterating
  %     through the states in a for loop that assigns the state numbers to
  %     the corresponding fields (named after the state names).
  asn = cell2struct(cell(rows(resolved_list),1), resolved_list(:,1), 1);
  for i=1:rows(resolved_list)-1,
    asn.(resolved_list{i,1}) = resolved_list{i,2} : resolved_list{i+1,2}-1;
  end;
  
  asn.(resolved_list{end,1}) = resolved_list{end,2} : nstates-1;
  
  return;
  
  
   
% -------------

function [] = error_message(current_state, str, state_name_list)

   u = find(current_state == cell2mat(state_name_list(:,2)));
   if ~isempty(u), state_name = state_name_list{u(1),1};
   else            state_name = '';
   end;

   error(['StateMachineAssembler ERROR:\n\n' ...
     'in state #%d "%s", the entry "%s" ' ...
     'could not be resolved!!!\n'], current_state, state_name, str);
   
   
   
% -------------

function [entry] = resolve_strs(current_state, str, state_names)
   
   for i=1:rows(state_names),
      eval([lower(state_names{i,1}) ' = ' num2str(state_names{i,2}) ';']);
   end;
   
   try,
      entry = eval(lower(str));
   
      if ~isnumeric(entry),
         error(sprintf(['StateMachineAssembler ERROR:\n\n' ...
                        'in state %d, the entry "%s" ' ...
                        'could not be resolved!!!\n'], current_state,str));
      end;
   catch,
      error(sprintf(['StateMachineAssembler ERROR:\n\n' ...
                     'in state %d, the entry "%s" ' ...
                     'could not be resolved!!!\n'], current_state,str));
   end;
   
   return;
   
   
% -----------

function [entry] = resolve_schedwave_strs(current_state, str, sched_waves)

   if isempty(str), entry = 0; return; end;
   
   for i=1:length(sched_waves),
      eval([sched_waves(i).name ' = 2.^(' num2str(sched_waves(i).id) ');']);
   end;
   null = 0; %#ok<NASGU>
   
   try
      entry = eval(str);
   
      if ~isnumeric(entry),
         error(['StateMachineAssembler ERROR:\n\n' ...
                        'in state %d, the SchedWaveTrig entry "%s" ' ...
                        'could not be resolved!!!\n'], current_state,str);
      end;
   catch
      error(['StateMachineAssembler ERROR:\n\n' ...
                     'in state %d, the SchedWaveTrig entry "%s" ' ...
                     'could not be resolved!!!\n'], current_state,str);
   end;
   