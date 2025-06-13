% [pstruct] = parse_trial(Events, RealTimeStates, ...
%                  {'pokeIDs', --see below for default--}, ...
%                  {'statename_list', 'all'}, {'parse_pokes', true})
%
% Given an Event list and a RealTimeStates structure, returns a
% structure that has the same fieldnames as RealTimeStates; each value
% is a vector of n-by-2 entries, where the first column gives the
% time at the start of the corresponding state, and the second column
% gives the time at exit from that state. The number of rows is the
% number of times the state was entered. See below for details.
%
% In addition, there are fieldnames Center1, Left1, and Right1, with
% values corresponding to the times of entering and leaving the first
% Center, Left, or Right ports. And there are also fieldnames
% Center1_states, Left1_states, and Right1_states, for which the first
% and second column correspond to the state number when the poke in
% happened and the state number when the poke out happened.
%
% If Events is a cell, this is interpreted as representing many trials;
% RealTimeStates should then be a cell of the same size, and pstruct
% will also return as a cell of the same size. parse_trials will then
% be run on each element.
%
% PARAMETERS:
% -----------
%
% Events       and n-by-3 matrix indicating, in its first column, state
%              numbers, in its second column the event by which the
%              state in that row was exited, and in the third column
%              the time at which the event occurred.
%
% RealTimeStates   A structure, each entry of which indicates a set of
%              state id numbers. The corresponding fieldname gives
%              these state IDs meaning. For example,
%                 RealTtimeStates.wait_for_cpoke = [40 41]
%              means that states 40 and 41 are 'wait_for_cpoke' states.
%
%
% OPTIONAL PARAMETERS:
% -------------------
%
% pokeIDs      a struct that defines the event number type that
%              corresponds to the different actions the rat can
%              take. The default for this is
%                  pokeIDs.center1  = [1 2];
%                  pokeIDs.left1    = [3 4];
%                  pokeIDs.right1   = [5 6];
%
% statename_list  Either the string 'all' or a column cell vector of
%             strings, indicating the fieldnames desired in
%             pstruct. Only those fieldnames will be parsed. This is
%             useful because parsing for *all* the fieldnames in
%             RealTimeStates can be slow: if you just want extra_iti,
%             for example, indicating you only want that one can speed
%             things up considerably.  
%                The default is the string 'all', which means get all
%             fieldnames in RealTimeStates (plus the poke ones). 
%
%             If you choose to specify the statename_list, instead of
%             doing 'all', then YOU are responsible for making sure
%             that those RealTime state names actually exist in every trial
%             of that you are trying to parse!
%
% do_pokes    If true (the default), uses pokeIDs (see above) to find when
%             the rat was inside or outside the various poke stations.
%             If false, no pokeId fieldnames are generated, and pokeIds are
%             not parsed.
%
% RETURNS:
% --------
%
% pstruct      A structure with the same fieldnames as
%              RealTimeStates. The entry for each fieldname will be an
%              n-by-2 matrix. Each row in the matrix corresponds to
%              stretches of time in which the states belonged to the
%              corresponding group of states listed in
%              RealTimeStates. The first column in the matrix is time
%              of entry; the second column is time of exit.
%
%              For EXAMPLE:
%                 >> ps = parse_trial([40 0 101 ; 41 0 102 ; 41 0 105 ;
%                       65 0 106 ; 40 0 107 ; 90 0 110], ...
%                       struct('wait_for_cpoke', [40 41], 'timeout', 65));
%              returns ps with
%                 ps.wait_for_cpoke = [101 106 ; 107 110]
%                 ps.timeout        = [106 107]
%              This means: we were in one of the wait_for_cpoke states
%              from time=101 to time=106, and again from time=107 to
%              110; we were in one of the timeout states from time=106
%              to time=107.
%


function [pstruct] = parse_trial(Events, RealTimeStates, varargin)

    % define the default value for pokeIDs:
    pokeIDs = struct( ...
        'center1',   [1 2],  ...
        'left1',     [3 4],  ...
        'right1',    [5 6]  ...
        );
   
    pairs = { ...
      'pokeIDs'            pokeIDs    ; ...
      'statename_list'     'all'      ; ...
      'do_pokes'           true       ; ...
    }; parseargs(varargin, pairs);



if iscell(Events), % that is, if we're parsing multiple trials
    if ~isempty(RealTimeStates) &&(~all(size(Events)==size(RealTimeStates)) || ~iscell(RealTimeStates)),
        error(['If one of Events or RealTimeStates is a cell, the other ' ...
            'must be too, and of the same size']);
    end;
    pstruct = cell(size(Events));
    for i=1:rows(Events), for j=1:cols(Events),
            pstruct{i,j} = parse_trial(Events{i,j}, RealTimeStates{i,j}, ...
                'pokeIDs', pokeIDs, 'statename_list', statename_list, ...
                'do_pokes', do_pokes);
        end; end;

    return;
end;

% Ok, not a cell of multiple trials-- proceed with regular single trial.

if ischar(statename_list) && strcmp(statename_list, 'all'),
   statename_list = fieldnames(RealTimeStates);
elseif ~iscell(statename_list) || size(statename_list,2)>1,
   error('statename_list must be a cell column vector of strings');
end;



% Set up pstruct so it will have the necessary fieldnames
if do_pokes, fnames = [statename_list ; fieldnames(pokeIDs)];
else         fnames = statename_list;
end;
pstruct = cell2struct(cell(size(fnames)), fnames, 1);

% Real time states first
fnames = statename_list;
for i=1:length(fnames),
    pstruct.(fnames{i})=state_stretches(Events, RealTimeStates.(fnames{i}));
end;

% Now the pokes
if do_pokes
   fnames = fieldnames(pokeIDs);
   for i=1:length(fnames),
      [start_stop states] = poke_stretches(Events, pokeIDs.(fnames{i}));
      pstruct.(fnames{i})= start_stop;
      pstruct.([fnames{i} '_states']) = states;
   end;
end;

return;



% ------------------------

function [start_stop states] = poke_stretches(evs, poketype, tnum)
% Returns a matrix with n-by-2 columns: the time of the starts of the poke
% type indicated; the time of the stops; And a second n-by-2 matrix, with:
% the state number when the start happened; and the state when the stop
% happened. poketype(1) should be poke entry and poketype(2) should be
% poke exit.  Number of rows in the returned matrices is number of times
% that the port was visited.

if isempty(evs), start_stop = zeros(0, 2); states = zeros(0, 2); return; end; 
   
starts = find(evs(:,2)==poketype(1)); % starts = evs(ustarts, 3);
stops  = find(evs(:,2)==poketype(2)); % stops  = evs(ustops, 3);

if  isempty(starts) & ~isempty(stops), starts = 1;  end;
if ~isempty(starts) &  isempty(stops), stops  = rows(evs);  end;
if min(starts) > min(stops), starts = [1 ; starts]; end;
if max(starts) > max(stops), stops  = [stops ; rows(evs)];   end;

stp=1;
while stp <= rows(stops)
    j = find(starts == stops(stp));
    for l = 1:length(j)
        if length(starts) > length(stops), starts = [starts(1:j-1); starts(j+1:end)];
        elseif length(starts) < length(stops), stops = [stops(1:stp-1); stops(stp+1:end)];
        end;
    end;
    stp = stp + 1;
end;

if length(stops) > length(starts),
    sprintf('WARNING: In some trial, poketype [%i %i] had more stops than starts even after all corrections.\n Truncating extra rows ...', poketype(1), poketype(2))
    maxie = length(starts); stops = stops(1:maxie);
elseif length(starts) > length(stops),
    sprintf('WARNING: Too many poke ins: ignoring poketype [%i %i]', poketype(1), poketype(2));
    start_stop = []; states = [];
    return;
end;
    
maxlen = max(length(starts), length(stops));
starts = starts(1:maxlen); stops = stops(1:maxlen);

start_stop = [evs(starts,3) evs(stops,3)];
states     = [evs(starts,1) evs(stops,1)];

return;


% ------------------------

function [start_stop] = state_stretches(evs, etype)
% Returns a matrix with the time of the starts and the time of the
% stops of any state numbers matching numbers in the vector etype.
% Matrix will be n-by-2, where first column is start time and last
% column is end time; number of rows is number of times that state
% group was visited.

if isempty(evs), start_stop = zeros(0, 2); return; end;   
   
% Find where any of our etype states are. +1 in d will indicate
% start points of stretches of etype states; -1 in d will
% indicate a stop point.
is_ours = ismember(evs(:,1), etype); d = diff(is_ours);


starts = find(d==1); if ~isempty(starts), starts = starts+1; end;
% If the very first state is an etype state, then that is a start:
if is_ours(1)==1, starts = [1 ; starts]; end;

stops = find(d==-1); if ~isempty(stops), stops = stops+1; end;
% If the very last state is an etype state, then that is a stop:
if is_ours(end)==1, stops = [stops ; length(is_ours)]; end;

if ~isempty(starts), start_stop = [evs(starts,3) evs(stops,3)];
else start_stop = [];
end;


