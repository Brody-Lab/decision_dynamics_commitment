function [] = reward_state_length(ratname, indate)

get_fields(ratname, 'use_dateset', 'given', 'given_dateset', {indate}, ...
    'datafields', {'pstruct', 'sides'});

dklen = NaN(size(pstruct));
for k = 1:rows(pstruct)
    if hit_history(k) > 0
        if sides(k) > 0
        dklen(k) = pstruct{k}.left_reward(1,2) - pstruct{k}.left_reward(1,1);        
        else
                    dklen(k) = pstruct{k}.right_reward(1,2) - pstruct{k}.right_reward(1,1);        
        end;
    end;
end;
figure; 
plot(find(sides == 1), dklen(sides ==1), '.b'); hold on;
plot(find(sides == 0), dklen(sides ==0), '.r'); hold on;
legend({'left','right'});
ylabel('reward state (s)'); 
title(sprintf('%s (%s)', ratname, indate));
axes__format(gca);