function [x, y] = ParseResponseSection(obj, action, x, y, varargin)

GetSoloFunctionArgs(obj);

% These are the things we should set: 
% {'trialclass', 'hit', 'hit_history', 'n_cpokes', 'n_cpokes_history', 'rejected_trials'});


switch action
   
   %% case reparse_all_trials
   case 'reparse_all_trials'
      for i=1:n_done_trials,
         parse_specific_trial(obj, i, parsed_events_history{i}, ...
            hit_history, n_cpokes_history, trialclass_history, sides_history, ...
            motor_history, rejected_trials); %#ok<USENS>
      end;
      n_cpokes.value   = n_cpokes_history  (n_done_trials); 
      hit.value        = hit_history       (n_done_trials);
      trialclass.value = trialclass_history(n_done_trials);
      
     
   %% case parse_just_finished_trial      
   case 'parse_just_finished_trial'
      if n_done_trials < 1,
         return;
      end;
      parse_specific_trial(obj, n_done_trials, parsed_events, ...
         hit_history, n_cpokes_history, trialclass_history, sides_history, motor_history, rejected_trials);
      n_cpokes.value   = n_cpokes_history  (n_done_trials); 
      hit.value        = hit_history       (n_done_trials);
      trialclass.value = trialclass_history(n_done_trials);
                  
end;


%% -----------------  function parse_specific_trial

function [] = parse_specific_trial(obj, trialnum, parsed_events, ...
   hit_history, n_cpokes_history, trialclass_history, sides_history, motor_history, rejected_trials)
   
   if isempty(parsed_events) || ~isstruct(parsed_events) || ...
         ~isfield(parsed_events, 'states') || trialnum<1,
      return;
   end;
           
   % Decide whether this trial was a hit or not:
   if    isempty(parsed_events.states.error_state)      && ...
         isempty(parsed_events.states.right_temp_error) && ...
         isempty(parsed_events.states.left_temp_error),
      hit = 1;
   else hit = 0;
   end;
   % Make sure hit_history is the right size and assign the current value:
   if numel(hit_history(:))<trialnum, 
      hit_history.value = [hit_history(:) ; zeros(trialnum-numel(hit_history(:)),1)];
   end;
   hit_history(trialnum) = hit;  %#ok<NASGU>
   
   
   % figure out what the cpoke track on this trial was:
   fnames = fieldnames(parsed_events.states);
   u = strmatch('cpoke', fnames);
   cpokes = struct('islegal', {}, 'cpokenum', {}, 'numpokes', {}, 'cpokeout_time', {});
   % First we'll collect all states with name "cpoke%d"
   for i=1:numel(u),
      g = str2double(fnames{u(i)}(6:end));
      if isnan(g),
         cpokes(i).islegal = false;
      else
         cpokes(i).islegal  = true;
         cpokes(i).cpokenum = g;
         cpokes(i).numpokes = size(parsed_events.states.(fnames{u(i)}),1);
         if cpokes(i).numpokes>0,
            cpokes(i).cpokeout_time = parsed_events.states.(fnames{u(i)})(end,2);
         end;
      end;
   end;
   cpokes = cpokes(struct2vector(cpokes, 'islegal'));
   
   % Assign n_cpokes:
   n_cpokes = size(parsed_events.states.cpoke,1);
   % Make sure n_cpokes_history is the right size and assign the current value:
   if numel(n_cpokes_history(:))<trialnum, 
      n_cpokes_history.value = [n_cpokes_history(:) ; zeros(trialnum-numel(n_cpokes_history(:)),1)];
   end;
   n_cpokes_history(trialnum) = n_cpokes; %#ok<NASGU>
   
   cpokes = cpokes(find(struct2vector(cpokes, 'numpokes')>0)); %#ok<FNDSB>
   cpokeout_times = struct2vector(cpokes, 'cpokeout_time');
   [trash, I] = sort(cpokeout_times);
   cpokes = cpokes(I);
   
   % Assign trialclass:
   trialclass = cpokes(end).cpokenum;
   % Make sure trialclass_history is the right size and assign the current value:
   if numel(trialclass_history(:))<trialnum,  
      trialclass_history.value = [trialclass_history(:) ; zeros(trialnum-numel(trialclass_history(:)),1)];
   end;
   trialclass_history(trialnum) = trialclass; %#ok<NASGU>
   
   this_side = TrialsSection(obj, 'get', value(trialclass), 'side');
   if hit==1, this_motor = this_side;
   else
      if this_side=='l', this_motor = 'r'; else this_motor = 'l'; end;
   end;
   if numel(sides_history(:))<trialnum,  
      sides_history.value = [sides_history(:) ; ' '*ones(trialnum-numel(sides_history(:)),1)];
   end;
   sides_history(trialnum) = this_side; %#ok<NASGU>
   if numel(motor_history(:))<trialnum,  
      motor_history.value = [motor_history(:) ; ' '*ones(trialnum-numel(motor_history(:)),1)];
   end;
   motor_history(trialnum) = this_motor; %#ok<NASGU>
   
   
      
   % Make sure rejected_trials is the right size. It's a SoloPramHandle,
   % so the (:,:) construct makes sure we ask about the size of its
   % contents.
   srt = size(rejected_trials(:,:)); 
   if srt(1) < trialnum,
      rejected_trials.value = [rejected_trials(:,:) ; zeros(trialnum-srt(1), srt(2))];
   end;
   srt = size(rejected_trials(:,:)); nClasses = TrialsSection(obj, 'get', 'nClasses');
   if srt(2) < nClasses,
      rejected_trials.value = [rejected_trials(:,:) zeros(srt(1), nClasses-srt(2))];
   end;
   
   for i=1:numel(cpokes),
      if cpokes(i).cpokenum ~= trialclass,
         rejected_trials(trialnum, cpokes(i).cpokenum) = ...
            size(parsed_events.waves.(['tc' num2str(cpokes(i).cpokenum) '_t1on']),1); 
      else
         rejected_trials(trialnum, cpokes(i).cpokenum) = ...
            size(parsed_events.waves.(['tc' num2str(cpokes(i).cpokenum) '_t1on']),1) - 1; 
      end;
   end;
   
   return;
      
         

      

%% -----------------  function struct2vector

function [X] = struct2vector(st, fieldname)

   [X{1:numel(st)}] = deal(st.(fieldname));
   try
      X = cell2mat(X);
   catch ME
      warning(ME.identifier, 'struct2vector couldn''t convert field "%s", got error "%s"', ...
         fieldname, ME.message);
      X = NaN;
   end;

   