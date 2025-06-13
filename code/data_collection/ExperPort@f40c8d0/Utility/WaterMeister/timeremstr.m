function output = timeremstr(timewaited,minwait)

M = (minwait/60) - ceil(timewaited/60);
S = 60 - ceil(rem(timewaited,60));
if S == 60; S = 0; end

M = num2str(M);
if S < 10; S = ['0',num2str(S)];
else       S = num2str(S);
end

output = [M,':',S];
