% [sma] = add_happening_spec(sma, spec)   Add to the available happening specs.
%                        Will not take effect until next SetStateMatrix
%
% Adds new specs to the existing specs by concatenating to the current list.
%
% spec must be vector structure, where the elements i have the fields:
%
% spec(i).name    A string-- this is what this happening will be known
%                 as to the user. E.g., "mywave_High" or "Cin".
%
% spec(i).detectorFunctionName   Another string. This one defines the
%                 internal happening detector function to use. For 
%                 example, "line_high". To get a description of available
%                 happening detector function, do 
%                    >> DoLinesCmd(sm, 'GET HAPPENING DETECTOR FUNCTIONS');
%
% spec(i).inputNumber  An integer. This will be a parameter passed to the
%                 detector function when checking for this happening. For
%                 example, Cin typically uses "line_in" on input line 1,
%                 so Cin would use a 1 here.
%
% An example of a spec structure that could be used is:
%
% spec = struct( ...
%   'name',                  {'Cin',     'Cout',     'Lin',     'Lout'}, ...
%   'detectorFunctionName',  {'line_in', 'line_out', 'line_in', 'line_out'}, ...
%   'inputNumber',           {1,          1,          2,         2    }, ...
%
% Note how the name is unique for each entry, but the
% detectorFunctionName and the inputNumber are not unique across entries.
% It is the *combination* of these last two that is unique and that maps
% 1-to-1 onto names and happeIds.
%    You don't have to enter all possible combinations into your spec--
% just the ones you want to use.
%

% Carlos Brody August 2009
% edited by Chuck 9/4/2019 to prevent adding duplicate happenings which can
% break bpod rigs

function [sma] = add_happening_spec(sma, spec)

reqfields = {'name', 'detectorFunctionName', 'inputNumber'};

if ~isstruct(spec) || ~isempty(setdiff(reqfields, fields(spec))),
    error('StateMachineAssembler:BadSyntax', 'spec must be a structure with fields %s', reqfields);
end;

for j=1:numel(spec),
    if isempty(sma.happSpec(end).name) || ~ischar(sma.happSpec(end).name),
        error('Format:BadHappening', 'happening names must be strings');
    end;
    if isempty(sma.happSpec(end).detectorFunctionName) || ~ischar(sma.happSpec(end).detectorFunctionName),
        error('Format:BadHappening', ['detector function names must be strings (and you are responsible for' ...
            'checking that these names exist in the RTFSM using the ' ...
            '"DoLinesCmd(sm, ''GET HAPPENING DETECTOR FUNCTIONS'')" command']);
    end;
    if isempty(sma.happSpec(end).inputNumber) || ~isnumeric(sma.happSpec(end).inputNumber) || ...
        isnan(sma.happSpec(end).inputNumber),
        error('Format:BadHappening', 'happening inputNumbers must be non-empty non-NaN numbers');
    end;
   
    found_duplicate = 0;
    for i = 1:numel(sma.happSpec)
        if strcmp(sma.happSpec(i).name,spec(j).name)
            found_duplicate = 1;
            break;
        end
    end
    if found_duplicate == 1
        warning(['Happening ',spec(j).name,' not added since one already exists with that name.']);
    else
        sma.happSpec(numel(sma.happSpec)+1).name = spec(j).name;
        sma.happSpec(end).detectorFunctionName   = spec(j).detectorFunctionName;
        sma.happSpec(end).inputNumber            = spec(j).inputNumber;
        sma.happSpec(end).happId                 = numel(sma.happSpec);
    end
end

