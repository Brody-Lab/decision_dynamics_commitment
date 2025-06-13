function out = GetEnabled(olf, bankname)
% function out = GetEnabled(olf, bankname)
% Returns 1 if the specified bankname is enabled, or 0 otherwise

  out = str2num(DoQueryCmd(olf, sprintf('IS BANK ENABLED %s', bankname)));
