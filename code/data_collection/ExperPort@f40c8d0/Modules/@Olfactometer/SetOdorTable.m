% Takes 3 args, the olf object, a bankname, and an odortable cell matrix.
% The dimensions of the matrix are M x 3 where M is the number of odors in
% the bank (see GetNumOdors(olf, bankname)).  The odortable should contain
% the following cells per row:
% [double]  'string' 'string2'
% Where the first field is the odor number (0 is the first odor), 'string'
% is the odor name, and the last string is the odor description (for
% display purposes only).
% Note: this odor table is the same format as the odor table returned from
% GetOdorTable(olf, bankname)
function olf = SetOdorTable(olf, bankname, ot)

    numEntries = size(ot,1);
    
    if (numEntries ~= GetNumOdors(olf, bankname)),
        error('The odor table must contain %d entries!', GetNumOdors(olf, bankname));
    end;
    
    lines = cell(numEntries, 1);
    for i=1:numEntries,
        lines{i,1} = sprintf('%d\t%s\t%s\n', ot{i,1}, ot{i,2}, ot{i,3});
    end;
    
    olf = DoUpdateCmd(olf, sprintf('SET ODOR TABLE %s', bankname), lines);
    
    