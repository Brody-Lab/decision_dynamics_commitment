% [pokelist] = identify_pokes(sma)   Return a list of pokes that are
%                                    defined in the input map. If
%                                    sma.use_happenings is true, then
%                                    looks through the sma's happening Spec                                    
%                                    and returns a list of all happening
%                                    name stems where happenings named
%                                    'stemin'and 'stemout' exist.
%
% The input_map in StateMachineAssembler object is a list of strings and
% integers, mapping how different input events get mapped onto event ids.
% What identify_pokes.m does is go through that input map, and finds all
% pairs of inputs that have an 'Xin' string for one pair and an 'Xout'
% string for the other. A list of all the X strings that exist in such
% pairs is identified. All scheduled wave names are then removed from the
% list. The resulting list is returned.
%
% For the format of happenings, see @RTLSM/SetHappeningSpec
%
% PARAMETERS:
% -----------
%
% sma     A @StateMachineAssembler object
%
%
% RETURNS:
% --------
%
% pokelist    A cell, n-by-1 in size, where each entry is a unique string
%             identifying a poke.
%
%
% EXAMPLE:
% --------
%
% Suppose that the input_map is {'Cin'  1 ; 'Cout'  2 ; 'Gugin' 3 ; ...
%         'Gugout' 4 ; 'mywave_In' 5 ; 'mywave_Out' 6 ; 'Tup' 7}.
%
%   >> identify_pokes(sma)
%
%     ans = {'C' ; 'Gug'}
%

% Written by C. Brody May 2007



function [pokelist] = identify_pokes(sma)

pins = {}; pouts = {};

if ~sma.use_happenings, % the input_map is functional
  events = sma.input_map(:,1);
else
  events = cell(numel(sma.happSpec), 1);
  [events{:}] = deal(sma.happSpec.name);
end;
  
for i=1:numel(events),
  if length(events{i}) > 2 && strcmp(events{i}(end-1:end), 'in'),
    pins = [pins ; events{i}(1:end-2)]; %#ok<AGROW>
  end;
  if length(events{i}) > 3 && strcmp(events{i}(end-2:end), 'out'),
    pouts = [pouts ; events{i}(1:end-3)]; %#ok<AGROW>
  end;
end;


candidates = unique(intersect(pins, pouts));

[wavenames{1:length(sma.sched_waves)}] = deal(sma.sched_waves.name);
for i=1:length(wavenames), wavenames{i} = [wavenames{i} '_']; end;
candidates = setdiff(candidates, wavenames);

pokelist = candidates(:);

  
