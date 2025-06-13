% <~> function: getZutConstant(nameConstant)
%     Returns the values of some constants.
%     This function exists simply to centralize constant definitions.
%
function [o errID errmsg] = getZutConstant(nameConstant)
o = NaN; errID = 1; errmsg = ['Constant not defined (' nameConstant ')'];
if ~ischar(nameConstant), return; end;
switch(nameConstant)
    case 'nameSchedTable',      errID=0; errmsg=''; o='ratinfo.schedule';
    otherwise,
        return;
end; %     end of switch(nameConstant)
end %     end of function zut_constants
