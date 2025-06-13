function [flat] = premature_withdrawal_hist(pstruct, varargin);
% Given a pstruct, returns the proportion of premature withdrawals that
% occurred in each state of the given set of states, depicted as a histogram.
% The default set of states is: {'pre_chord', 'cue', 'pre_go'}.
%
% Also returns the times for all such withdrawals for each state in a structure called 'flat'.
% Flat is a 2-by-R cell array, where each column contains time of
% withdrawal (relative to state start) for each state in the state set.
% The first row consists of state names (column headers), and the second contains the flattened (trial-merged)
% times for each state.

pairs = { ...
    'state_types',  {'pre_chord'; 'cue';'pre_go'};
    };
parse_knownargs(varargin, pairs);

state_times = premature_withdrawal_times(pstruct, 'state_types', state_types);
headers = state_times(:,1);
data = state_times(:,2:end);

flat = cell(0,0); for r = 1:rows(data), flat{r} = []; end;
for k=1:cols(data)
    for r = 1:rows(data)
        flat{r} = [flat{r} data{r,k}];
    end;
end;

counter = [];
for r=1:length(flat),
    counter(r) = length(flat{r});
end;

raw_counter = counter; 
counter = counter/sum(counter);
bar(1:length(counter), counter*100);

for r=1:length(flat),
    fprintf('%s : %i of %i (%2.1f)\n', ...
        headers{r}, raw_counter(r), sum(raw_counter), (raw_counter(r)/sum(raw_counter))*100);
    text(r-0.1, (counter(r)*100)+10, sprintf('%2.0f%%', counter(r)*100),'FontSize',11, 'FontWeight','bold');
end;

set(gcf,'Position', [200 200 300 200],'Menubar','none','Toolbar', 'none');
a = get(gcf, 'CurrentAxes');
set(a,'XTickLabel', headers, 'FontSize', 12, 'FontWeight','bold','YLim', [0 100]);
ylabel('# occurrences'); xlabel('States');
title(sprintf('Proportion of Timeout Occurrences\nin different pre-GO states'));

flat(2,1:length(counter)) = flat(1,1:length(counter));
flat(1,1:length(counter)) = headers';