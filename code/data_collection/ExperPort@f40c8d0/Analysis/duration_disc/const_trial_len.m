function [] = const_trial_len(s1,s2, minpre, minpost, len)
% This analysis has been written for duration_disc.
% Considers situation where trial length is constant.
% Shows the best the rat can perfom based on poke timing of:
% 1. Cue onset to GO signal
% 2. Cin to cue offset
%%% Cin to GO signal doesn't matter since trial length is constant
  
short_vartime = len - s1;
long_vartime = len - s2;

short_varmax = short_vartime - (minpre+minpost);
long_varmax = long_vartime - (minpre+minpost);

figure;
set(gcf,'Menubar','none','Toolbar','none');

line([0 len],[1 1], 'Color','b','LineWidth',4);
text(0.1, 1.5, sprintf('%1.1f-%1.1f', minpre, short_varmax));
 hold on;
 line([0 len], [3 3], 'Color','g','LineWidth',4);
text(0.1, 3.5, sprintf('%1.1f-%1.1f', minpre, long_varmax));
 
 set(gca,'XLim', [-0.2 len+0.2], ...
         'YTickLabel',{},'YTick',[],  'YLim',[0 4], ...
         'XTick', 0:0.2:len);