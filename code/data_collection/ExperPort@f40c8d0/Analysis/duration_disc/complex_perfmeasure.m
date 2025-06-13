Function [] = complex_perfmeasure(rat, task, varargin)

pairs =  { ...
      'from', '000000'; ...
      'to', '999999'; };
  parse_knownargs(varargin, pairs);
  
  dates = get_files(rat, 'fromdate', from, 'todate', to);