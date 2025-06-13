function [sm] = DIODo(sm, dioLine, highlow)

    %display('DIOWrite');
    
    txt = '(low)';
    color = 'yellow';
    if (highlow), 
      highlow = 1; 
      txt = '(high)';
      color = 'red';
    end;
    
    led = sm.DIOState(1, dioLine+1);
    set(led, 'Value', highlow);
    set(led, 'String', sprintf('%d %s', dioLine,  txt));
    set(led, 'BackGroundColor', color);
        
    if (~isempty(sm.DoutCallback)),
      warning('DIOCallback unimplemented...');
      %feval(sm.DoutCallback{1}, sm.DoutCallback{2}, ...
      %      bitor(sm.DoutLines, sm.DoutBypass) );
    end;

    return;
