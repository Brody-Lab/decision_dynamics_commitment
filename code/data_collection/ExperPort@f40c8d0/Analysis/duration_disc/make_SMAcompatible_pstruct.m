function [pstruct, prev_end_time] = make_SMAcompatible_pstruct(Events,RealTimeStates, varargin)

% Input params:
% Events: e-by-3 numeric events matrix
% RealTimeStates: Struct where keys are logical names for groups of state
% numbers, and value is a vector of corresponding state numbers
%
% Also accepts a cell array of Events and RealTimeStates
% ex. Imagine a session of duration_disc with 297 trials. The data file contains an Events cell array (cell 297 x 1) and RealTimeStates cell array (297 x 1)
% Call the Events array evs and the RealTimeStates array rts. This is what
% evs and rts contain for trial #18:
% >> e = evs{18};
% >> whos e
%  Name        Size            Bytes  Class     Attributes
%  e         152x3              3648  double
%
% >> r = rts{18}
% r =
%     wait_for_cpoke: 40
%          pre_chord: [1x41 double]
%              chord: [153 154 155 156 157 158]
%     wait_for_apoke: 159
%        left_dirdel: [164 165 166]
%       right_dirdel: [166 167 168]
%        left_reward: 160
%       right_reward: 162
%         drink_time: [161 163]
%            timeout: [181 182 183 184 185 186 187 188 189 190 191 192 193 194 195 196 197]
%                iti: [170 171 172 173 174]
%          dead_time: [1 2 3 4 5 6 7 8 9 10 35]
%            state35: 36
%          extra_iti: [175 176 177 178 179 180]
%                cue: [1x69 double]
%             pre_go: 152
%
% The output pstruct has the format as described on the Solo wiki at:
% http://brodylab.princeton.edu/bcontrol/index.php/StateMachineAssembler-pa
% rsing



% define the default value for pokeIDs:
pokeIDs = struct( ...
    'C',   [1 2],  ...
    'L',     [3 4],  ...
    'R',    [5 6]  ...
    );

pairs = { ...
    'pokeIDs'            pokeIDs    ; ...
    'statename_list'     'all'      ; ...
    'do_pokes'           true       ; ...
    }; parseargs(varargin, pairs);



if iscell(Events), % that is, if we're parsing multiple trials
    if ~all(size(Events)==size(RealTimeStates)) || ~iscell(RealTimeStates),
        error(['If one of Events or RealTimeStates is a cell, the other ' ...
            'must be too, and of the same size']);
    end;
    pstruct = cell(size(Events));
    for i=1:rows(Events), for j=1:cols(Events),
            [pstruct{i,j} prev_end_time] = make_SMAcompatible_pstruct(Events{i,j}, RealTimeStates{i,j}, ...
                'pokeIDs', pokeIDs, 'statename_list', statename_list, ...
                'do_pokes', do_pokes);

            if i > 1
                % set the previous trial's end time
                tmp = pstruct{i-1,j}.states.state_0;
                tmp(2,:) = [ prev_end_time NaN];
                pstruct{i-1,j}.states.state_0 = tmp;
            end;
        end; end;

    return;
end;


% Ok, not a cell of multiple trials-- proceed with regular single trial.

% Add state_0 to RealTimeStates
RealTimeStates.state_0 = 0;


if ischar(statename_list) && strcmp(statename_list, 'all'),
    statename_list = fieldnames(RealTimeStates);
elseif ~iscell(statename_list) || size(statename_list,2)>1,
    error('statename_list must be a cell column vector of strings');
end;


% Set up pstruct so it will have the necessary fieldnames
pstruct.states = 0;
pstruct.states = cell2struct(cell(size(statename_list)), statename_list, 1);
pstruct.states.starting_state = [];
pstruct.states.ending_state = [];

pstruct.pokes = 0;
f= fieldnames(pokeIDs);
spokes = cell2struct(cell(size(f)), f, 1);
pstruct.pokes = cell2struct(cell(size(f)), f, 1);
pstruct.pokes.starting_state = spokes;
pstruct.pokes.ending_state = spokes;

% mark trial start and stop times
statezero = find(Events(:,1) == 0);
% snipped from bwiki: then pstruct.states.state_0 will be guaranteed to
% have the form [NaN trial_start_time ; trial_end_time NaN]. That is, the
%trial started when you left state_0 to go into your state machine definition;
%and ended when you jumped to state_0 again.


% Real time states first

% starting_ and ending_state
first_state = Events(1,1);
last_state = Events(end,1);
fnames = statename_list;
for i=1:length(fnames),
    if ismember(first_state, RealTimeStates.(fnames{i})), pstruct.states.starting_state = fnames{i};end;
    if ismember(last_state, RealTimeStates.(fnames{i})), pstruct.states.ending_state = fnames{i};end;
    pstruct.states.(fnames{i})=state_stretches(Events, RealTimeStates.(fnames{i}));

end;

tmp = pstruct.states.state_0;
prev_end_time = tmp(1,1);
pstruct.states.state_0 = [ NaN tmp(1,2); NaN NaN];


% Now the pokes
if do_pokes
    fnames = fieldnames(pokeIDs);
    for i=1:length(fnames),
        [start_stop ss es] = poke_stretches(Events, pokeIDs.(fnames{i}));
        pstruct.pokes.(fnames{i})= start_stop;
        pstruct.pokes.starting_state.(fnames{i}) = ss;
        pstruct.pokes.ending_state.(fnames{i}) = es;
        %  pstruct.pokes.([fnames{i} '_states']) = states;
    end;
end;

return;

% ------------------------

function [start_stop start_string, end_string] = poke_stretches(evs, poketype, tnum)
% Returns two things:
% 1) n-by-2 matrix: the time of the starts of the poke
% type indicated; the time of the stops; And
% 2) n-by-2 matrix: the state number when the start happened; and the state when the stop
% happened.
%
% poketype(1) should be poke entry and
% poketype(2) should be poke exit.
% Number of rows in the returned matrices is number of times that the port was visited.

start_string = [];
end_string = [];

if isempty(evs), start_stop = zeros(0, 2); states =[]; return; end;

starts = find(evs(:,2)==poketype(1)); % starts = evs(ustarts, 3);
stops  = find(evs(:,2)==poketype(2)); % stops  = evs(ustops, 3);


start_stop = [];

% --- pasted-in state start/stop logic
% Base case: Either there are no stops or no starts... or both
if isempty(starts) && isempty(stops)
    start_stop = []; return;
    start_string = [];
    end_string = [];
elseif isempty(starts)
    if length(stops) > 1, error('Too many stops!');
    else start_stop = [NaN evs(stops,3)]; end;
    start_string = 'in';    end_string = 'out';
    return;
elseif isempty(stops)
    if length(starts) > 1, error('Too many starts!');
    else start_stop = [evs(starts,3) NaN]; end;
    start_string = 'out'; end_string = 'in';
    return;
end;

start_stop = [];
% we entered these events with this state already started
% ie it had to be STOPPED ere it was started again
if min(starts) > min(stops),
    start_stop = [NaN evs(stops(1),3)];
    stops = stops(2:end);
    start_string = 'in';
else
    start_string = 'out';
end;

% we left these events with an event started but not stopped
tmp_ending = [];
if (max(starts) > max(stops))
    tmp_ending = [evs(starts(end),3) NaN];
    starts = starts(1:end-1);
    end_string = 'in';
elseif isempty(stops)
    tmp_ending = [evs(starts(end),3) NaN];
    starts = starts(1:end-1);
    end_string = 'in';
else
    end_string = 'out';
end;

% at this point, start and end times should be matched
if length(starts) ~= length(stops)
    error('Unmatched number of starts and stops!');
end;

try
    if ~(isempty(starts)) && ~(isempty(stops))
        start_stop = vertcat(start_stop, [evs(starts,3) evs(stops,3)]);
    end;
    start_stop = vertcat(start_stop, tmp_ending);
catch
    error('Whoopsie, the in''s and out''s don''t match!');
end;
% --- end of pasted-in state start/stop logic

% % Scenarios where a trial can have unmatched pokes in and out
% % we don't know when he started poking, but we do know that he stopped
% if  isempty(starts) & ~isempty(stops), starts = NaN;  start_string = 'in'; end_string = 'out';
% end;
% % the opposite: he began a poke but hasn't yet ended it
% if ~isempty(starts) &  isempty(stops), stops  = NaN;  start_string = 'out'; end_string = 'in'; end;
% % he poked out before he poked in, so he started in the poke
% if min(starts) > min(stops), starts = [NaN ; starts]; start_string = 'in'; else start_string = 'out'; end;
% % he poked in after his last poke out, so he ended the trial in the poke
% if max(starts) > max(stops), stops  = [stops ; NaN];  end_string = 'in';  else end_string = 'out'; end;
% % -------------------------------------------------------------
%
% stp=1;
% while stp <= rows(stops) % go through all stops
%     j = find(starts == stops(stp)); % correct super-short pokes ?
%     for l = 1:length(j)
%         if length(starts) > length(stops), starts = [starts(1:j-1); starts(j+1:end)];
%         elseif length(starts) < length(stops), stops = [stops(1:stp-1); stops(stp+1:end)];
%         end;
%     end;
%     stp = stp + 1;
% end;
%
% if length(stops) > length(starts),
%     sprintf('WARNING: In some trial, poketype [%i %i] had more stops than starts even after all corrections.\n Truncating extra rows ...', poketype(1), poketype(2))
%     maxie = length(starts); stops = stops(1:maxie);
% elseif length(starts) > length(stops),
%     sprintf('WARNING: Too many poke ins: ignoring poketype [%i %i]', poketype(1), poketype(2));
%     start_stop = []; states = [];
%     return;
% end;
%
% maxlen = max(length(starts), length(stops));
% starts = starts(1:maxlen); stops = stops(1:maxlen);
%
% try
% start_stop = [evs(starts,3) evs(stops,3)];
% states     = [evs(starts,1) evs(stops,1)];
% catch
%     error('Whoopsie');
%     end;

return;


% ------------------------

function [start_stop] = state_stretches(evs, etype)
% Returns a matrix with the time of the starts and the time of the
% stops of any state numbers matching numbers in the vector etype.
% Matrix will be n-by-2, where first column is start time and last
% column is end time; number of rows is number of times that state
% group was visited.

if isempty(evs), start_stop = []; return; end;

% Find where any of our etype states are. +1 in d will indicate
% start points of stretches of etype states; -1 in d will
% indicate a stop point.
is_ours = ismember(evs(:,1), etype); d = diff(is_ours);

starts = find(d==1); stops = find(d == -1);

% Base case: Either there are no stops or no starts... or both
if isempty(starts) && isempty(stops)
    start_stop = []; return;
elseif isempty(starts)
    if length(stops) > 1, error('Too many stops!');
        stops = stops+1;
    else start_stop = [NaN evs(stops,3)]; end;
    return;
elseif isempty(stops)
    if length(starts) > 1, error('Too many starts!');
        starts= starts+1;
    else start_stop = [evs(starts,3) NaN]; end;
    return;

else % both have
    starts = starts+1;
    stops = stops+1;
end;

start_stop = [];
% we entered these events with this state already started
% ie it had to be STOPPED ere it was started again
if min(starts) > min(stops),
    start_stop = [NaN evs(stops(1),3)];
    stops = stops(2:end);
end;

% we left these events with an event started but not stopped
tmp_ending = [];
if (max(starts) > max(stops))
    tmp_ending = [evs(starts(end),3) NaN];
    starts = starts(1:end-1);
elseif isempty(stops)
    tmp_ending = [evs(starts(end),3) NaN];
    starts = starts(1:end-1);

end;

% at this point, start and end times should be matched
if length(starts) ~= length(stops)
    error('Unmatched number of starts and stops!');
end;

if ~(isempty(starts)) && ~(isempty(stops))
    start_stop = vertcat(start_stop, [evs(starts,3) evs(stops,3)]);
end;
start_stop = vertcat(start_stop, tmp_ending);





