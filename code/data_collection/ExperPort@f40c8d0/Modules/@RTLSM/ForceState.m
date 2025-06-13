% Force an immediate jump to state 'state'
function [sm] = ForceState(sm, state)
try
     DoSimpleCmd(sm, sprintf('FORCE STATE %d', state));
     sm = sm;
catch
    warning(lasterr)
end
     return;
