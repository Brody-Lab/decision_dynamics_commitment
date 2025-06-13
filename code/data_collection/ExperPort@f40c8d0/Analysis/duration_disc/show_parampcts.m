function [] = show_parampcts(rat, task,varargin)
  
     pairs =  { ...
      'from', '000000'; ...
      'to', '999999'; };
  parse_knownargs(varargin, pairs);
  
  dates = get_files(rat, 'fromdate', from, 'todate', to);
  
  
  for d = 1:rows(dates)

  date = dates{d};
  fprintf(1, '%s\n',date);
    load_datafile(rat, task, date);
 
    psych = cell2mat(saved_history.ChordSection_psych_on); psych= ...
            psych(2:end);
    if sum(psych) > 0,
      warning(['Session contains psychometric trials! Not processing tone  ' ...
               'lengths...']);
    end;
  
  % Get variable period lengths
  pre_min = cell2mat(saved_history.VpdsSection_MinValidPokeDur); pre_min ...
            = pre_min(2:end);
  pre_max = cell2mat(saved_history.VpdsSection_MaxValidPokeDur); pre_max ...
            = pre_max(2:end);
  post_min = cell2mat(saved_history.ChordSection_Min_2_GO); post_min ...
            = post_min(2:end);
  post_max = cell2mat(saved_history.ChordSection_Max_2_GO); post_max ...
            = post_max(2:end);
  
   
  % Get tone duration lengths
  short_tone = cell2mat(saved_history.ChordSection_Tone_Dur1); 
  short_tone=short_tone(2:end);
 long_tone = cell2mat(saved_history.ChordSection_Tone_Dur2); 
 long_tone= long_tone(2:end);
 
 get_pct(pre_min, 'Pre-sound min');
 get_pct(pre_max, 'Pre-sound max');
 get_pct(post_min, 'Post-sound min');
 get_pct(post_max, 'Post-sound max');
 if sum(psych) < 1
 get_pct(short_tone, 'Short tone');
 get_pct(long_tone, 'Long tone');
 end;
    
 fprintf(1,'\n');
  end;
  
  
function [] = get_pct(param_list, name)
  unq = unique(param_list);
  
  pct_dist = [];
  fprintf(1, '\t%s: ', name);
  for k = 1:length(unq)
    num = length(find(param_list == unq(k))) / length(param_list);
   
    num = round(num*100);
    fprintf(1, '%1.1f (%i%%)', unq(k), num);
  end;
  fprintf(1,'\n');