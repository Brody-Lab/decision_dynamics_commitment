% <~> function: verify_rat_status.m
%     Takes as input three strings:
%       experimenter    str, name of experimenter
%       ratname         str, name of rat
%       nameStatus      str, rat status flag to check
%                              ('training', 'free', 'recovering', etc.)
%       vStatus     bool, expected value of the flag (true/false / 0/1)
%
%     Returns one variable (and error values):
%       isCorrect       bool, 1 if given status matches rat status
%                             0 if status does not match
%       errID           0 if no errors occur in the comparison attempt
%       errmsg          '' if no errors occur in the comparison attempt
%
function [isCorrect errID errmsg] = verify_rat_status(experimenter, ratname, nameStatus, vStatus)
errID = -1;
errmsg = 'Code is unfinished or has been broken if this errmsg is being returned. Please inform a developer.';


%<~>TODO: First, verify that the args are of the right type and number.
%         I should also check that vStatus is really the name of a column
%           by using the corresponding mysql command to query column names.


rvStatus = bdata('select {S} from rats where experimenter="{S}" and ratname="{S}"',nameStatus,experimenter,ratname);

if vStatus~=rvStatus,
    isCorrect = 0;
else
    isCorrect = 1;
end;
errID = 0; errmsg = '';

end %     end of function interpret_wiki_schedule
