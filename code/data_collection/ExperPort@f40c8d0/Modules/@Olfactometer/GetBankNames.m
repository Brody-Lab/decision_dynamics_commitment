% function [ banks ] = GetBankNames( olf )
%  Returns a cell array of strings, the name of all the banks in the olfactometer. 
%
% function [ banks ] = GetBankNames( olf, mixname )
% Returns a cell array of strings, the name of all the banks for a particular mix.  Pass in a mixname.
function [ banks ] = GetBankNames( varargin )
    if (nargin < 1 | nargin > 2), error ('Incorrect number of arguments.'); end;
    olf = varargin{1};
    if (nargin == 1), 
        banks = olf.banks(:,1);
    else
        banks = {};
        mix = varargin{2};
        for i=1:size(olf.banks,1),
            if (olf.banks{i, 2} == mix),
                banks = vertcat(banks, {olf.banks{i,1}});
            end;
        end;
    end;
    
    
    