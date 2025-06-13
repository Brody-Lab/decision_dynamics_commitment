%     .../Modules/@dispatcher/RecalculateBypass.m
%     Calculates bypass bitfield and sends to state machine server;
%       BControl system;
%     this file written by Sebastien Awwad, 2007
%
%     Recalculates the bitfield that is or'd against the current state's
%       output bitfield. This bypass bitfield turns on output channels
%       despite the on/off values assigned them by the current state in the
%       state matrix. Turning a bypass on causes the output channel to be
%       turned on, but turning it off only returns the channel to the
%       unrestricted state. Toggles in the GUI are used to determine which
%       bypasses to turn on/off.
%
%     Please note that the underlying bypass function in RTLSM and the
%       emulator appears to be broken:
%           When bypass is turned off, the *output* is turned off, instead
%             the output simply relaxing to whatever state is indicated in
%             the state machine. This does not match comments in the bypass
%             method.
%           Behavior with this function and dispatcher is the same as with
%             RPBox, its predecessor.
%
function [errID errmsg] = RecalculateBypass(obj) %#ok<INUSD> (obj OK despite unused)

GetSoloFunctionArgs;
errID = -1; errmsg = ''; %#ok<NASGU> (errID=-1 OK despite unused)

%     Fetch the output line toggle values.
arguments = who;
base_name_for_override_toggles = 'override_output';
len_base_name = length(base_name_for_override_toggles);

%     Indices for the output line toggles within the set of Solo arguments
%       to this function.
output_line_toggle_indices = strmatch(base_name_for_override_toggles, arguments);
DOut_Bypass_Bitfield.value = 0; %for this brief moment, the value will be *not as intended*



for i=1:length(output_line_toggle_indices),
    %     Grab the toggle's name.
    this_outline_toggle_name = arguments{output_line_toggle_indices(i)};
    %     Extract the toggle's channel ID (number after 'override_output')
    this_outline_toggle_channel = str2double(this_outline_toggle_name(len_base_name+1:end));
    %     There are some _history SoloParamHandles (e.g.
    %       override_output12_history) scattered among the real handles we
    %       want, so we ignore anything with trailing non-numeric
    %       characters.
    if isnan(this_outline_toggle_channel), continue; end;
    %     Add in 0 or 1 for that channel to the bypass bitfield.
    DOut_Bypass_Bitfield.value = ...
        bitor(...
        value(DOut_Bypass_Bitfield),...
        pow2(this_outline_toggle_channel) * eval(this_outline_toggle_name));
end;

%     Send command to state machine server to activate outputs found to
%       have been toggled in the gui.
BypassDout(state_machine, value(DOut_Bypass_Bitfield));

errID = 0;


return;


end
