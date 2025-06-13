% [spec] = get_happening_spec(sma)   
%
% Returns a list of the happening specs currently queued to be sent to the
% FSM upon the next SetStateMatrix
%
% spec will be vector structure, where the elements i have the fields:
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
% spec(i).happId   A unique integer identifying the spec. This ID is used
%                 internally within StateMachineAssembler and disassembler.
%                 Each unique combination of detectorFunctionName and
%                 inputNumber leads to a unique happId.
%
% An example of a spec structure that could be returned is:
%
% spec = struct( ...
%   'name',                  {'Cin',     'Cout',     'Lin',     'Lout'}, ...
%   'detectorFunctionName',  {'line_in', 'line_out', 'line_in', 'line_out'}, ...
%   'inputNumber',           {1,          1,          2,         2    }, ...
%   'happId',                {1,          2,          3,         4    });
%
% Note how the name is unique for each entry, but the
% detectorFunctionName and the inputNumber are not unique across entries.
% It is the *combination* of these last two that is unique and that maps
% 1-to-1 onto names and happIds.


% Carlos Brody Sep 2009

function [spec] = get_happening_spec(sma)

spec = sma.happSpec;


