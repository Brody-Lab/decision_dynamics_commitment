function [] = allfigs__scale(fac)

figs = get(0,'Children');
for k=1:length(figs),
    pos=get(figs(k),'Position');
    set(figs(k),'Position',[pos(1) pos(2) pos(3)*fac pos(4)*fac]);
end;
