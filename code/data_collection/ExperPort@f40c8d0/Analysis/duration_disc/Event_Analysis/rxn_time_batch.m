function [rxn clen] = rxn_time_batch(ratname, varargin)
% runs rxn_time over a range of dates
pairs = { ...
    'from', '000000'; ...
    'to', '999999'; ...
    'trim_first',1; ...
    };
parse_knownargs(varargin, pairs);

rxn = [];
clen = [];


dates = get_files(ratname,'fromdate',from,'todate',to);
for d=1:rows(dates)
    [r c] = rxn_time(get_pstruct(ratname, dates{d}));
    if trim_first > 0
        rxn = vertcat(rxn, r(2:end));
        clen = vertcat(clen,c(2:end));
    else
        rxn = vertcat(rxn, r);
        clen = vertcat(clen,c);
    end;
end;

