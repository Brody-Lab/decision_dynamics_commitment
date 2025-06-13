function [s,nc] = correct_sidebias(s, lprob, slack, maxsame)
% bias_correcter

% lprob = 0.5;
% slack = 0.2;
% s = rand(1,200) < lprob;
win = 10;
if maxsame >= win
    nc = 1; return;
end;

done = 0;
nc = 0; loops = 0;
lookahead = 7;
while ~done
    over_lt = 0; over_rt = 0; loops = loops + 1;
    for i = 1:length(s)-lookahead
        s2 = s(i:i+(lookahead-1)); num_left = length(find(s2 == 1)); num_right = lookahead-num_left;
        % excess left
        if (num_left - num_right)/win >= lprob + slack
            over_lt = over_lt+1;
%             sprintf('Before L: %s', num2str(s2))
            lef = find(s2 == 1);
            lef = ceil(rand * length(lef)); s((i-1)+lef) = 0; % set right (literally)
            lef = ceil(rand * length(lef)); s((i-1)+lef) = 0; % set right (literally)
%           sprintf('After L: %s', num2str(s(i:i+9)))
            % excess right
        elseif (num_right - num_left)/win >= (1-lprob) + slack
            over_rt = over_rt+1;
%           sprintf('Before R: %s', num2str(s2))
            rt = find(s2 == 0);
            rt = ceil(rand*length(rt)); s((i-1)+rt) = 1;  % set to left
            rt = ceil(rand*length(rt)); s((i-1)+rt) = 1;  % set to left
%            sprintf('After R: %s', num2str(s(i:i+9)))
        end;
    end;
    
    if ~(over_lt || over_rt), done=1; end;
    if ~(over_lt || over_rt) && loops == 1, nc = 1; end;
%    sprintf('Excess L: %s, Excess R: %s', num2str(over_lt), num2str(over_rt))
end;


