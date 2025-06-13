% bias_correcter

lprob = 0.5;
slack = 0.2;
s = rand(1,200) < lprob;
win = 10;

over_lt = 0;
over_rt = 0;
for i = 1:length(s)-10
    s2 = s(i:i+9); num_left = length(find(s2 == 1)); num_right = 10-num_left;

    % excess left
    if (num_left - num_right)/win > lprob + 0.2
        over_lt = over_lt+1;
        lef = find(s2 == 1);
        lef = floor(rand * length(lef)); s((i-1)+lef) = 0; % set right (literally)
        lef = floor(rand * length(lef)); s((i-1)+lef) = 0; % set right (literally)
        % excess right
    elseif (num_right - num_left)/win > (1-lprob) + 0.2
        over_rt = over_rt+1;
        rt = find(s2 == 0);
        rt = floor(rand*length(rt)); s((i-1)+rt) = 1;  % set to left
        rt = floor(rand*length(rt)); s((i-1)+rt) = 1;  % set to left
    end;
end;

sprintf('Excess L: %s, Excess R: %s', num2str(over_lt), num2str(over_rt))
