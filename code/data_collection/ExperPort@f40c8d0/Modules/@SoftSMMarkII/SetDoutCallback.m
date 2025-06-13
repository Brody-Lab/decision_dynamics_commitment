function [ssm] = SetDoutCallback(sm, callback, arg)
   
   sm = get(sm.Fig, 'UserData');
   sm.DoutCallback = {callback arg};
   set(sm.Fig, 'UserData', sm);
