
function [] = tone_freq(rat, task, varargin)
  
  pairs = { ...
      'from', '000000'; ...
     'to', '999999'; ...
      };
  parse_knownargs(varargin, pairs);
  
  
  date_set = get_files(rat, 'fromdate', from, 'todate', to);
  
  tones = {}; % each row is an array of unique tone frequencies
  
  for d = 1:rows(date_set)
    load_datafile(rat, task, date_set{d});
    tf = cell2mat(saved_history.ChordSection_Tone_Freq);
    
    tones{d,1} = unique(tf);
  end;
  
  figure; 
  for r = 1:rows(tones)
    plot(r .* ones(length(tones{r}),1), tones{r,1}, '.r');
    hold on;
    end;