function [] = rat_score
% an attempt to make a scoring function which penalizes rat for having
% lower hitrate > 0 and higher hitrate < 100.


l=0:5:50;
h = [50 75 100];


for hidx = 1:length(h)
    currh = h(hidx);
score = l+(100-currh); %l-50/(100-currh);

figure;
k=plot(l, score,'.b');
% hold on;
% if currh ~= min(h) || currh ~= max(h)
%     set(l,'Color',rand(1,3));
% end;
title(sprintf('for h=%i',currh));
set(gcf,'Position',[100 hidx*200 200 200]);
end;
