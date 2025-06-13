function [poke_set] = get_pokes_during_state(pstruct, state_list,varargin)
% input args:
% rts - RealTimeStates
% pstruct
% state_list = {'pre_chord','dead_time','right_reward'}

pairs = { ...
    'poketype' ,'all' ; ... %can be 'left', 'right', 'center', or 'all'
    };
parse_knownargs(varargin,pairs);


% poke_set is a struct with keys 'center','left','right' (unrequested pokes
% will not be filled). The value is a cell array, each entry of which
% contains start/end times for a given trial.
poke_set.center = {};
poke_set.left = {};
poke_set.right = {};

for p = 1:rows(pstruct)
    curr =pstruct{p};
    for j = 1:length(state_list)
        currstate = eval(['curr.' state_list{j});
        for k = 1:rows(currstate)
            if strcmpi(poketype,'all')
             
        end;
    end;
end;