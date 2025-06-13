function [lhs rhs]  = calc_pair(type, mp, logdiff,varargin)
% function []  = calc_pair(type, mp, logdiff)
% Given mid-point and distance between stimulus pairs, generates the
% end-pairs.
% Type can be either 'p' (for 'pitch') or 'd' (for 'duration')

% e.g. calc_pair('p', 2.0, 2) would return 1 and 4, since the 1 and 4
% (KHz) are 2 octaves apart (logdiff = 2), and their geometric mean is
% 2 KHz.

pairs = {...
    'suppress_out', 0 ; ...
    };
parse_knownargs(varargin,pairs);



base = exp(1); unit = 'ms';
if strcmpi(type, 'p'), base = 2; unit = 'KHz';
elseif ~strcmpi(type, 'd'), error('Invalid type'); end;

denom = base .^ (logdiff ./2);


lhs = mp ./ denom;
rhs = mp .* denom;

if suppress_out < 1
    fprintf(1,'Low point: %1.1f%s, High point: %1.1f%s\n', lhs, unit, rhs,unit);
    if strcmpi(type,'d'),
        fprintf(1,'Absolute difference = %1.1fms\n\n', rhs-lhs);
    end;
end;
% lhs, rhs