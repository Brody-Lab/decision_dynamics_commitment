% function [ banks ] = GetBankInfo_INTERNAL( olf, mix )
%
% Returns a Mx3 cell array of (mostly) strings, the name of all the banks in a mix.  Pass in
% a mixname.
%
% Format for cell matrix rows:
% bankname(string) mixname(string) numodors(number) 
%
function [ banks ] = GetBankInfo_INTERNAL( olf, mix )
    banks = {};
    
    % now get the actual banks
    line = DoQueryCmd(olf, sprintf('GET BANKS %s', mix));

    while 1, 
        [ bank, line ] = strtok(line);
        if (isempty(bank)), break; end;
        numOdors = str2num(DoQueryCmd(olf, sprintf('GET NUM ODORS %s', bank)));
        banks = [ banks; ...
            % row fields
            % bankname, mixname, number of odors
            {bank}, mix, numOdors ];
    end;
    