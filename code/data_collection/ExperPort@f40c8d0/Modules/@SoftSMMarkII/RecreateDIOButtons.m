function [sm] = RecreateDIOButtons(sm)

   nDIO = sm.NumContChans+sm.NumTrigChans;
   nDIOOld = size(sm.DIOState, 2);
   if (nDIO < nDIOOld)
     for i=nDIO:nDIOOld,
       delete(sm.DIOState(1,i));
     end;
     sm.DIOState(1, nDIO+1:nDIOOld) = [];
   elseif (nDIOOld < nDIO)
     sm.DIOState(1, nDIOOld+1:nDIO) = zeros(1, nDIO-nDIOOld);
   end;
   
    
   for i=1:nDIO,
     w = 1.0/nDIO;
     h = sm.InputButtonHeight;
     y = sm.DIOButtonPos;
     x = w * (i-1);
     
     if (~sm.DIOState(1, i)),
       theButton = uicontrol(sm.Fig,  'Style', 'ToggleButton', 'Units', ...
                               'normalized', 'Position', ...
                             [ x y w h]);
       set(theButton, 'Value', 0);
       set([theButton], 'FontSize', 8);
       set(theButton, 'Enable', 'inactive');
       sm.DIOState(1, i) = theButton; 
       sm = DIOWrite(sm, i-1, 0); % default is low..
     end;
   end;
   
   return;