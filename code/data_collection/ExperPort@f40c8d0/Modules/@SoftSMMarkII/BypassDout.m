function [sm] = BypassDout(sm, d)

   sm = get(sm.Fig, 'UserData');
   
   diffBits = bitxor(sm.DoutBypass, d);
   
   sm.DoutBypass = d;     
   
   for i=0:sm.NumContChans+sm.NumTrigChans-1,
     if (bitand(diffBits, 2^i)),
       sm = DIODo(sm, i, bitand(sm.DoutBypass,2^i));
     end;
   end;
   
   set(sm.Fig, 'UserData', sm);
   
   return;