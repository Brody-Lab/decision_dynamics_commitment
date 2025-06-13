function [] = surgery_effect_add_saline
% takes pre-post output from surgery_effect_hrate.
% To it, adds the points for saline-injected rats in both duration and
% frequency groups

postpsych=1;
dursaline = {'Silver','Stark'}; dpts = NaN(length(dursaline),2);
freqsaline = {'Hatty','Beryl'}; fpts = NaN(length(freqsaline),2);

% do duration group
for d = 1:length(dursaline),
    [blah blah2 bhits ahits] = surgery_effect(dursaline{d},'psychgraph_only',1);
    close all;
    bhits = bhits(~isnan(bhits)); ahits = ahits(~isnan(ahits));
    pre = nansum(bhits) ./ length(bhits); post = nansum(ahits) ./ length(ahits);
    
    dpts(d,:) = [pre post];
end;
  
% and then the frequency group
for d = 1:length(freqsaline),
    [blah blah2 bhits ahits] = surgery_effect(freqsaline{d},'psychgraph_only',1);
    close all;
    bhits = bhits(~isnan(bhits)); ahits = ahits(~isnan(ahits));
    pre = nansum(bhits) ./ length(bhits); post = nansum(ahits) ./ length(ahits);
    
    fpts(d,:) = [pre post];
end;

close all;
surgery_effect_hrate('ACx', postpsych);
set(0,'CurrentFigure',2);

% superimpose saline impairment values on ibo impairment values
msize = 20;
c = get(gca,'Children');
for k = 1:length(c), 
    y= get(c(k),'YData'); 
   if length(y) > 2, 
      set(c(k),'Color',[1 1 1] * 0.5);
       myx = get(c(k),'XData');
      if myx(1) == 1 % duration
          dpts = dpts(:,2) - dpts(:,1);
          plot(ones(size(dpts)) * myx(1), dpts, '.b','MarkerSize', msize); hold on;
      else
          fpts = fpts(:,2) - fpts(:,1);
          plot(ones(size(dpts)) * myx(1), fpts, '.b','MarkerSize', msize); hold on;
          
      end;
   end;
end;
2;