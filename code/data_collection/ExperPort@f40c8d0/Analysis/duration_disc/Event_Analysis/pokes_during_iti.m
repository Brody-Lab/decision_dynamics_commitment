function [cpokes lpokes rpokes] = pokes_during_iti(pstruct)
%
% Given the output of Analysis/parse_trial.m (pstruct), 
% returns the number of pokes made during ITIs.
% Specifically, it returns the center pokes, left pokes and right pokes
% (each in a separate structure), made during the following RealTimeStates:
% * iti
% * dead_time
% * extra_iti
% Output:
%   Three cell arrays of identical structure, one for each type of poke.
%   There is a row for every trial, which contains the array of start and
%   endtimes of the particular pokes during the trial.
%
% e.g. [cpokes lpokes rpokes] pokes_during_iti(pstruct)
% >> cpokes{5}
% ans =
% 
%   780.4855  781.4078
%   783.1033  783.5067
%   791.4746  791.7648
%   793.2047  793.4459
%   795.5236  795.7657
%

cpokes = cell(0,0);
lpokes = cell(0,0);
rpokes = cell(0,0);

for k = 1:rows(pstruct)
    temp_c = []; temp_r = []; temp_l = [];
    for itir = 1:rows(pstruct{k}.iti)
        [tc, tl, tr] = cpoke_mini(pstruct{k}, pstruct{k}.iti(itir,1), pstruct{k}.iti(itir,2));
        temp_c = [temp_c; tc]; temp_l = [temp_l; tl]; temp_r = [temp_r; tr];
    end;
    for dr = 1:rows(pstruct{k}.dead_time)
        [tc, tl, tr]  = cpoke_mini(pstruct{k}, ...
            pstruct{k}.dead_time(dr,1), pstruct{k}.dead_time(dr,2));
        temp_c = [temp_c; tc]; temp_l = [temp_l; tl]; temp_r = [temp_r; tr];
    end;
    for eitir = 1:rows(pstruct{k}.extra_iti)
        [tc, tl, tr]  = cpoke_mini(pstruct{k}, ...
            pstruct{k}.extra_iti(eitir,1), pstruct{k}.extra_iti(eitir,2));
        temp_c = [temp_c; tc]; temp_l = [temp_l; tl]; temp_r = [temp_r; tr];
    end;

    cpokes{k} = temp_c; lpokes{k} = temp_l; rpokes{k} = temp_r;
end;

function [outrow_c outrow_l outrow_r] = cpoke_mini(minip, st_time, fin_time)
conditions = {'in', 'after', st_time};
conditions(2,1:3) = {'out', 'before', fin_time};
outrow_c = get_pokes_fancy(minip, 'center', conditions, 'all');
outrow_l = get_pokes_fancy(minip, 'left', conditions, 'all');
outrow_r = get_pokes_fancy(minip, 'right', conditions, 'all');

