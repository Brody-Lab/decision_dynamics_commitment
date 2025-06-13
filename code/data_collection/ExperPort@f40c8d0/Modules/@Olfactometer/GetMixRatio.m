% function mixratio = GetMixRatio(olf, mixname)
%   returns a Mx2 cell array of columns: BankName(string) MixRatio(double)
%   for each bank in the mix,  Pass in an olf and a mixname
function mrs = GetMixRatio(olf, mix)

    mrs = {};    
    % now get the mix ratios for each bank and put them in the temp mrs
    % Mx2 cell matrix
    mrlines = cellstr(DoQueryCmd(olf, sprintf('GET MIX RATIO %s', mix)));
    for i=1:size(mrlines,1), 
        line = mrlines{i};
        [ theBank, line ] = strtok(line, ' ');
        [ theRatio, line ] = strtok(line, ' ');
        mrs = vertcat(mrs, { theBank, str2num(theRatio) });
    end;
