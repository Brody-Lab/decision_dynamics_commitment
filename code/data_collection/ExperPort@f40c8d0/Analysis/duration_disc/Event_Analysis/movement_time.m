function [mvmt_time clen ss] = mvmt_time(p,varargin)
% input: pstruct
% output:
% 1 - mvmt_time: time from cout of valid cpoke to the first side poke
% 2 - clen: duration of valid cpoke

pairs = { ...
    'pitch', 0 ; ...
    };
parse_knownargs(varargin,pairs);

clen = zeros(rows(p),1);
mvmt_time = zeros(rows(p),1);
ss = zeros(rows(p),1);

if pitch == 0
    for k = 1:rows(p) % for each trial
 
        basestate = p{k}.wait_for_cpoke(end, 1);
        lastgo_1 = p{k}.chord(end,1) + 0.03;
        lastgo_2 = p{k}.chord(end,2);
        wp1 = p{k}.wait_for_apoke(end,1);

        % "trial" pokes which ended before wait_for_apoke
        cond = {'in', 'after', basestate; ...
            'in', 'before', wp1; ... % discount pokes made during wait_for_apoke
            'out', 'after', lastgo_1; ...
            'out', 'before', lastgo_2};
        cpokes = get_pokes_fancy(p{k}, 'center', cond, 'all');

        % cout was made during wait_for_apoke state
        if rows(cpokes) < 1
            cpokes = get_pokes_fancy(p{k}, 'center', ...
                {'in', 'after', basestate; ...
                'in', 'before', wp1 ; ...
                'out', 'after', wp1}, ...
                'all');
        end;

        if rows(cpokes) > 1,
            error(['There should only be one long valid poke ' ...
                'per trial']);
        end;

        Lin = p{k}.left1(:,1); Rin = p{k}.right1(:,1);
        first_Lin = Lin(Lin > cpokes(1,2)); first_Lin = min(first_Lin);

        first_Rin = Rin(Rin > cpokes(1,2)); first_Rin = min(first_Rin);
        %     smallest_left = min(p{k}.left1(p{k}.left1(:,1) > cpokes(1,2),1));
        %     smallest_right = min(p{k}.right1(p{k}.right1(:,1) > cpokes(1,2),1));

        if isempty(first_Lin), smallest_side = first_Rin;
            side_picked = 0; %right
        elseif isempty(first_Rin), smallest_side = first_Lin;
            side_picked = 1;
        else
            if first_Lin < first_Rin, side_picked = 1; else side_picked = 0; end;
            smallest_side = min(first_Lin, first_Rin);
        end;

        mvmt_time(k) = smallest_side - cpokes(1,2);
        ss(k) = side_picked; %smallest_side;
        clen(k) = cpokes(1,2) - cpokes(1,1);
    end;

else
    for k = 1:rows(p) % for each trial
        
               if k == 1476 || k == 2222
            2;
        end;
        % for pitch tasks, mvmt time is measured
        % FROM last cout before wait_for_apoke state
        % TO the first side poke closest to FROM        
        basestate = p{k}.wait_for_cpoke(end, 1);
        wp1 = p{k}.wait_for_apoke(end,1);

        % "trial" pokes which ended before wait_for_apoke
        outcometype = 'left_reward';
        if rows(p{k}.left_reward) > 0,
            outcometype = 'left_reward';
        elseif rows(p{k}.right_reward) > 0,
            outcometype = 'right_reward';
        elseif rows(p{k}.extra_iti) > 0,
            outcometype = 'extra_iti';
        else
            error('Invalid outcometype')
        end;

        cond = {'out', 'before', eval(['p{k}.' outcometype '(1,1)'])};
        cpokes = get_pokes_fancy(p{k}, 'center', cond, 'all');
        cpokes = cpokes(find(cpokes(:,2) == max(cpokes(:,2))),:);

        if rows(cpokes) > 1, error('Only 1 valid cpoke to compute reaction time!'); end;

        Lin = p{k}.left1(:,1); Rin = p{k}.right1(:,1);
        first_Lin = Lin(Lin > cpokes(1,2)); first_Lin = min(first_Lin);

        first_Rin = Rin(Rin > cpokes(1,2)); first_Rin = min(first_Rin);
  
        if isempty(first_Lin), smallest_side = first_Rin;
            side_picked = 0; %right
        elseif isempty(first_Rin), smallest_side = first_Lin;
            side_picked = 1;
        else
            if first_Lin < first_Rin, side_picked = 1; else side_picked = 0; end;
            smallest_side = min(first_Lin, first_Rin);
        end;

        mvmt_time(k) = smallest_side - cpokes(1,2);
        ss(k) = side_picked; %smallest_side;
        clen(k) = cpokes(1,2) - cpokes(1,1);

    end;
end;