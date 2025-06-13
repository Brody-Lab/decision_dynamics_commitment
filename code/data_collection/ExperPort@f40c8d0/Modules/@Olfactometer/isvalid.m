function out = isvalid(olf)
% Returns 1 if olf is a valid Olfactometer object, or 0 otherwise
   out = 1;
   try
     if (~isa(olf, 'Olfactometer')), error('Not an olfactometer'); end;
     ChkCon(olf);
   catch
     out = 0;
   end;
