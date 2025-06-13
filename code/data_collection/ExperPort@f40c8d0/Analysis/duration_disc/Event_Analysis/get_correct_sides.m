function [correct_side] = get_correct_sides(p, varargin)

%Uses pstruct to determine whether for each trial, the left side was the
%correct answer side (in which case correct_side =1) or whether the correct
%side was right (correct_side = 0);

% p is the output of parse_trials
% a cell array, each cell of which contains a struct
% For description of the struct fields and values, see
% Analysis/parse_trial.m

pairs = { ...
    'single_trial', 0   ; ...
    };
parse_knownargs(varargin,pairs);

if single_trial > 0
    correct_side = curr_side(p);
    return;
end;

correct_side = zeros(rows(p),1); % 1 if left, 0 if right
for i = 1:rows(p)
    correct_side(i) = curr_side(p{i});
end;

% --------------------------------------------------------
function [correct_side] = curr_side(q)
if rows(q.right_reward)>0,   % Right-side hit
    correct_side = 0;
elseif rows(q.left_reward)>0,% Left-side hit
    correct_side = 1;
else                            % Must've been a miss
    % Wrong poke is 1ms before error state
    % starts (i.e. lag till error state is 1ms)
    error_start = q.extra_iti(1,1)-0.001;

    first_left =  get_pokes_rel_timepoint(q,'left',error_start, 'after');
    first_right = get_pokes_rel_timepoint(q,'right',error_start, 'after');
    if isempty(first_left) & ~isempty(first_right), % right is wrong
        correct_side = 1;
    elseif isempty(first_right) & ~isempty(first_left), % left is wrong
        correct_side = 0;
    elseif ~isempty(first_right) & ~isempty(first_left),
        if first_right(1) < first_left(1),
            correct_side = 1;
        else
            correct_side = 0;
        end;
    else error('Wot? error but no poke??');
    end;
end;