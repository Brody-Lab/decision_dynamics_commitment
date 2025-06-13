
% Given an sa,sb pair, will generate the three remaining 
% pairs for symmetry. Example call:
%   pair = [3000 12000] 
%   StimulusSection(obj, 'computer_match_nonmatch_set', pair);
%   returns to table : [3000 12000; 12000 3000 ; 12000 12000 ; 3000 3000]
freqs = [3 12];
% stim_table.value = {} 

% TODO- find function that creates all unique combinations given X array
% duplicate the frequencies to create a n_freq x 2 matrix for combinations
freqs_mat = cat(2, freqs, freqs);
% find all combinations of pairs of 2 & grab unique (rows)
freq_combos = unique(nchoosek(freqs_mat, 2), 'rows');
% for ipair = 1 : length(pairs)
%     pprob.value = 1 / len(pairs);
%     side.value = 'L'; % will be corrected
%     Sa.value = pairs(ipair, 1);
%     Sb.value = pairs(ipair, 2);
%     StimulusSection(obj, 'add_pair');
% end
