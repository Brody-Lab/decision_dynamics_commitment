function [sma] = only_labels_and_outcols(sma)
   
   outcols             = sort(cell2mat(sma.output_map(:,2)));
   sma.states          = sma.states(:,outcols);
   sma.iti_states      = sma.iti_states(:,outcols);
   sma.default_actions = [];
   
   