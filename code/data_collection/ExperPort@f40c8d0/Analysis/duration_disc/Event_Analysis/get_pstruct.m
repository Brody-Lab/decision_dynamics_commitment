function [pstruct] = get_pstruct(ratname, date,varargin)

% correct trial (example shown is a right trial): state progression:
% [p{3}.wait_for_apoke; p{3}.right_reward; p{3}.drink_time; p{3}.iti;
% p{3}.dead_time(2,:); p{4}.dead_time(1,:)]
%
% incorrect state progression:
%  [p{8}.wait_for_apoke; p{8}.extra_iti; p{8}.iti; p{8}.dead_time(2,:);
%  p{9}.dead_time(1,:)]

pairs = { ...
    'pstruct_format', 'old'; ...
    };
parse_knownargs(varargin,pairs);

ratlist = rat_task_table(ratname);
task = ratlist{1,2};

  load_datafile(ratname,date);

  evs = eval(['saved_history.' task '_LastTrialEvents']);
  rts = eval(['saved_history.' task '_RealTimeStates']);
  
  
  if length(rts) == length(evs) + 1,
    rts = rts(1:end-1);
  elseif length(rts) == length(evs)
      % do nothing      
  else 
    error(['# rows in RealTimeStates must match those in ' ...
           'LastTrialEvents']);
  end;
  
  if strcmpi(pstruct_format, 'old')
  pstruct = parse_trial(evs, rts);
  else
 pstruct = make_SMAcompatible_pstruct(evs,rts);
  end;
  2;
  
