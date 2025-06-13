% [sma] = ProbabilisticJump(sma, state_name, prob_vector, states_vector)

function [sma] = ProbabilisticJump(sma, state_name, prob_vector, states_vector)

%% input format error_checking
if ~isa(sma, 'StateMachineAssembler')
   error('argument sma must be a StateMachineAssembler')
end;

if ~isnumeric(prob_vector) || ~isvector(prob_vector) || ~all(prob_vector>=0) || ...
      ~any(prob_vector>0)  || ~all(~isnan(prob_vector)) || isempty(prob_vector),
   error(['argument prob_vector must be numeric, all elements >=0, no NaNs, and add up ' ...
      'to something strictly > 0']);
end;

if ~isvector(states_vector) || ~(numel(states_vector)==numel(prob_vector))
   error('argument states_vector must be same length as prob_vector');
end;


% should add error_checking for other input args


%% Set the successive out probabilities

% Successive out probs from sequential chain of tests:
prob_vector = prob_vector/sum(prob_vector);
prob_out = zeros(size(prob_vector));
for i=1:numel(prob_vector),
   if sum(prob_vector(i:end))==0, prob_out(i)=0;
   else prob_out(i) = prob_vector(i)/sum(prob_vector(i:end));
   end;
end;
% Then round to integer percentage probabilities:
prob_out = round(prob_out*100);


%% Build new specs
for i=1:numel(prob_out)-1,
   old_specs = get_happening_spec(sma);
   old_names = cell(size(old_specs)); [old_names{:}] = deal(old_specs.name);
   if isempty(find(strcmp(['prob' num2str(prob_out(i))], old_names),1))
      new_spec = struct('name', ['prob' num2str(prob_out(i))], ...
         'detectorFunctionName', 'prob_jump', 'inputNumber', prob_out(i));
      sma = add_happening_spec(sma, new_spec);
   end;
end;


%% Build the conditions chain
input_to_statechange = cell(numel(prob_out), 2);
for i=1:numel(prob_out)-1,
   input_to_statechange{i,1} = ['prob' num2str(prob_out(i))];
   input_to_statechange{i,2} = states_vector{i};
end;
input_to_statechange{end,1} = 'Tup';
input_to_statechange{end,2} = states_vector{end};

%% add state

sma = add_state(sma, 'name', state_name, 'self_timer', 0.0001, ...
   'input_to_statechange', input_to_statechange);

