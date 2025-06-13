% [] = plot_single_trial(evs, RTS, bh, alignon, ax)  show states/pokes sequence
%
% Plots a set of colored patches and lines that indicate a sequence of
% states and pokes during a trial. This is done not on the current
% axes, but on the axes passed by 'ax' (which are never made current).
%
% PARAMETERS:
% -----------
%
% evs          and n-by-3 matrix indicating, in its first column, state
%              numbers, in its second column the event by which the
%              state in that row was exited, and in the third column
%              the time at which the event occurred.
%
% RTS          A structure, each entry of which indicates a set of
%              state id numbers. The corresponding fieldname gives
%              these state IDs meaning. For example,
%                   RTS.wait_for_cpoke = [40 41]
%              means that states 40 and 41 are 'wait_for_cpoke' states.
%
% bh           The patches to be drawn start at vertical position bh (for
%              (base height), and extend vertically to bh+1.
%
% alignon      A string indicating what to take as t=0 in the
%              trial. Current possibilities are: 'base state'
%              '1st Cpoke'  'wait_for_apoke'   '1st Side poke'
%              'Outcome'
%
% ax           Handle to graphics axes on which all of this will be drawn.
%

% DOCUMENT THE VARARGINS !!!

% CDB wrote me Sep 05

function [] = plot_single_trial(evs, RTS, bh, alignon, ax, varargin)

persistent last_plotted_handles; 
% Delete any graphics objects from the last call to plot_single_trial, so
% they don't accumulate up:
if ~isempty(last_plotted_handles),
    u = find(ishandle(last_plotted_handles)); delete(last_plotted_handles(u));
    last_plotted_handles = [];
end;

pairs = { ...
    'trial_types'        []   ; ...
    'trial_selection'    []   ; ...
    'custom_colors',     []   ; ...
    'plottables',        []   ; ...
    }; parseargs(varargin, pairs);

if ~isempty(trial_selection) && ~isempty(trial_types),
    % Check whether trial_selection allows us to do this trial
    doit = evaluate_trial(trial_types, trial_selection);
    if ~doit, return; end;
end;

if isempty(evs), return; end;

% If necessary, translate from old-style alignon menu to new style:
alignon = backwards_compatible_alignon(alignon);
   
EventIds = struct( ...
    'cin',   1,  'cout',   2,  ...
    'lin',   3,  'lout',   4,  ...
    'rin',   5,  'rout',   6,  ...
    'tup',   7);

pstruct = parse_trial(evs, RTS);

t0 = [];
try,   t0 = eval(['pstruct.' alignon]);
catch, 
end;

if isempty(t0), return; end;

if isempty(custom_colors)
    state_colors; % This script determines vars "plottables" and "SC"
else
    SC = custom_colors;
    if isempty(plottables),
        error('When custom state colours are provided, custom plottables must be, too!');
    end;
end;

% First the states:
for i=1:size(plottables,1),
   start_stop = pstruct.(plottables{i,1});
   X = []; Y = [];
   for j=1:rows(start_stop),
      X = [X start_stop(j,[1 1 2 2])'-t0];
      Y = [Y bh+[0.05 0.95 0.95 0.05]'];
   end;
   h = fill(X, Y, SC.(plottables{i,1}), 'EdgeColor', 'none', 'Parent', ax);
   last_plotted_handles = [last_plotted_handles ; h];
end;

% Now the nose pokes:
guys = pstruct.left1' - t0; 
l = line(guys, 0.8+bh*ones(size(guys)), 'Parent', ax);
set(l, 'Color', 0.6*[1 0.66 0], 'LineWidth', 4);
last_plotted_handles = [last_plotted_handles ; l];

guys = pstruct.center1' - t0; 
l = line(guys, 0.5+bh*ones(size(guys)), 'Parent', ax);
set(l, 'Color', 0.0*[1 0.66 0], 'LineWidth', 4);
last_plotted_handles = [last_plotted_handles ; l];

guys = pstruct.right1' - t0; 
l = line(guys, 0.2+bh*ones(size(guys)), 'Parent', ax);
set(l, 'Color', 0.9*[1 0.66 0], 'LineWidth', 4);
last_plotted_handles = [last_plotted_handles ; l];

return;


% -------------------------

function [private_doit] = evaluate_trial(trial_types, trial_selection)

try,
    private_doit = eval(trial_selection);
catch,
    private_doit = 1;
    fprintf(1, ['\n\n ** Warning **\n\nString %s couldn''t be ' ...
        'evaluated.\n\n'], trial_selection);
end;


% -------------------------


function [alignon] = backwards_compatible_alignon(alignon)
   
   switch alignon,
    case 'base state',     alignon = 'wait_for_cpoke(1,1)';         
    case '1st Cpoke',      alignon = 'center1(1,1)'; 
    case 'wait_for_apoke', alignon = 'wait_for_apoke(1,1)';
    case 'wait_for_cpoke', alignon = 'wait_for_cpoke(end,2)';
    case 'Outcome',        alignon = 'wait_for_apoke(end,2)';
    case '1st Side poke',
      fprintf(1, ['\n\n *** Sorry ! *** \n\n1st Side poke no longer ' ...
                  'supported in alignon; will do Outcome instead\n\n']);      
      alignon = 'wait_for_apoke(end,2)';
   end;
   