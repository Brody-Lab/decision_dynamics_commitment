function [sm] = DIOWrite(sm, dioLine, highlow)
    

   if (highlow), 
     highlow = 1; 
   end;
   
   if (highlow | bitand(sm.DoutBypass, 2^dioLine)),
     sm = DIODo(sm, dioLine, 1);
   else
     sm = DIODo(sm, dioLine, 0);
   end;
      
    
   if (highlow),
     sm.DoutLines = bitor(sm.DoutLines, 2^dioLine);
   else
     sm.DoutLines = bitor(sm.DoutLines, 2^dioLine);
     sm.DoutLines = bitxor(sm.DoutLines, 2^dioLine);
   end;
   
   return;
