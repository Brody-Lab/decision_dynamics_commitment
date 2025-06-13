% function [res] = Write(olf, component, val)
%    Write a 'cooked' value to a component named 'component'
%    See also WriteRaw and List methods.
%    $ Modified by GF 4/30/07 - uses rig-specific calibration lookup table
%    to command a flow rate that will yield the rate actually desired.
%    Assumption: the only way to set a flow rate via Write.m is with the command
%    Write(olf, 'BankFlowX_Actuator', [flow_rate]), where X = the flow controller number.

function [res] = Write(olf, component, val)

    if strncmpi(component, 'BankFlow', 8) % if this is a command to set a flow rate
        
        val = GetCalibFlowRate(olf, component, val); % get optimal calibrated value, according to lookup table
        
    end

    res = DoSimpleCmd(olf, sprintf('WRITE %s %d', component, val));
    