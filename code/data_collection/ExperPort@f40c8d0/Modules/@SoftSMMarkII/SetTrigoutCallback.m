function [sm] = SetTrigoutCallback(sm, callback, arg)

   sm = get(sm.Fig, 'UserData');
   sm.VTrigCallback = {callback arg};
   set(sm.Fig, 'UserData', sm);
   
   