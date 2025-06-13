% <~> Fetches the Rig ID of this machine.
%       (part of the Zut suite of code for the Brodylab).
%
%     This was written as part of the Zut suite for the Brodylab.
%
%     [iRig e m] = getRigID()
%
%     Sebastien Awwad, 2008.Sep
%
%
%     RETURNS:
%     --------
%     1. iRig          int, the rig number for this machine.
%                        If the setting [RIGS; Rig_ID] is set in a settings
%                          file (e.g. Settings/Settings_Custom.conf) and is
%                          numeric, then that number is used.
%                        Otherwise, return NaN.
%
%     2. errID           0 if there are no errors
%                       -1 for a programming error
%                        1 if unable to make a guess at the rig number
%     3. errmsg         '' if there are no errors, else a descriptive str.
%
function [rigID errID errmsg] = getRigID()
errID           = -1; %#ok<NASGU>
errmsg          = ''; %#ok<NASGU>

%     FIRST: attempt to retrieve the [RIGS;Rig_ID] setting.
[rigID e m] = bSettings('get','RIGS','Rig_ID');
