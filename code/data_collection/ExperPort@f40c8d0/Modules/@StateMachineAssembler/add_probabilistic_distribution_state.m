% [sma] = add_probabilistic_distribution_state(sma, state_name, prob_vector, states_vector)
%
% Adds a state which immediately fans out to other states in a
% probabilistic manner. On entering state state_name, the FSM will jump to
% state state_vector{i} with probability prob_vector(i).
%
% PARAMETERS:
% -----------
%
% sma          The obligatory @StateMachineAssembler object
%
% state_name   A string defining the name of the state which will last only
%              a minimum amount of time and from which other states will be
%              jumped to.
%
% prob_vector  A numeric vector of the various probabilities with which the
%              other states will be reached. All entries must be >= 0, and
%              the sum of entries should add up to 1.
%
% states_vector A cell vector of strings indicating the states to jump to.
%              Thus on entering state_name, the FSM will jump to
%              state_vector{i} with probability prob_vector(i).
%
% 
% Note: depends on an FSM that is using "happenings", and the detector
% function "prob_jump" must be defined and compiled at the server end.
%

% CDB Sep 09

function [sma] = add_probabilistic_distribution_state(sma, state_name, prob_vector, states_vector)

%% input format error_checking
if ~isa(sma, 'StateMachineAssembler')
   error('argument sma must be a StateMachineAssembler')
end;

if ~isvector(state_name) || ~ischar(state_name),
   error('state_name must be a string');
end;

if ~isnumeric(prob_vector) || ~isvector(prob_vector) || ~all(prob_vector>=0) || ...
      ~any(prob_vector>0)  || ~all(~isnan(prob_vector)) || isempty(prob_vector),
   error(['argument prob_vector must be numeric, all elements >=0, no NaNs, and add up ' ...
      'to something strictly > 0']);
end;

if ~isvector(states_vector) || ~(numel(states_vector)==numel(prob_vector))
   error('argument states_vector must be same length as prob_vector');   
end;
for i=1:numel(states_vector)
   if ~ischar(states_vector{i}) || ~isvector(states_vector{i}),
      error('each element of states_vector must be a string');
   end;
end;



%% Set the successive out probabilities

% Successive out probs from sequential chain of tests:
prob_vector = prob_vector/sum(prob_vector);
prob_out = zeros(size(prob_vector));
for i=1:numel(prob_vector),
   if sum(prob_vector(i:end))==0, prob_out(i)=0; % in case it's all zeroes from here on
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

