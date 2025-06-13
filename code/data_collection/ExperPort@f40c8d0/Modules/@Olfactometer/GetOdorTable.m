% function [ odorTable ] = GetOdorTable(olf, bankname)
%   returns a NUM_ODORSx3 cell matrix. 
%   Col 1 is a numeric odor id
%   Col 2 is the bankname string 
%   Col 3 is the odor description text string
function [ odorTable ] = GetOdorTable(olf, bankname)
    
    bank_idx = GetBankIndex_INTERNAL(olf, bankname);
    numOdors = GetNumOdors(olf, bankname);
    table = cell(numOdors, 3);
    odorLines = DoQueryCmd(olf, sprintf('GET ODOR TABLE %s', bankname), numOdors+1);        
    [m, n] = size(odorLines);
    if (m ~= numOdors+1), 
            error(sprintf('Error receiving odor table from server -- it appears to contain less than %d odors!', numOdors));
    end;
    % x-form odor table into a numOdors x 3 cell matrix
    for i=1:numOdors,
            theLine = odorLines(i, 1:n);
            for j=1:3,
                [ field, theLine ] = strtok(theLine, sprintf('\t'));
                if (j == 1), field = str2num(field); end;
                odorTable{i,j} = field;
            end;
    end;
    