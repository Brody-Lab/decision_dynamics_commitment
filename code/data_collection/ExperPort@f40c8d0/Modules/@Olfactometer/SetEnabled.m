function olf = SetEnabled(olf, bankname, onoff)
% function olf = SetEnabled(olf, bankname, onoff)
% Returns a new olf.
% Soft enables/disables a particular bank.  Onoff is a boolean value.

  if (onoff)
    DoSimpleCmd(olf, sprintf('ENABLE BANK %s', bankname));
  else
    DoSimpleCmd(olf, sprintf('DISABLE BANK %s', bankname));
  end;
