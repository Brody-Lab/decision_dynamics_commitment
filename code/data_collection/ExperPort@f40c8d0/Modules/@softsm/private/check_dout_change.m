function [md] = check_dout_change(md)
% Sets the current md.Dout to be whatever the state matrix and the
% Dout_bypass say; if there is a change to Dout, sets the GUI and
% calls the callback
% 
   
   olddout = md.Dout;
   md.Dout = bitor(md.StateMatrix(md.CurrentState+1,9), md.Dout_bypass);

   if md.Dout ~= olddout,
      drawnow;
      str = dec2bin(md.Dout);
      if length(str < 8), str = ['0'*ones(1, 8-length(str)) str]; end;
      set(md.doutbutton, 'String', ['Dout = ' str]);
      if ~isempty(md.dout_callback), 
         feval(md.dout_callback{1}, md.dout_callback{2}, md.Dout); 
      end;    
      drawnow;
   end;
   
   