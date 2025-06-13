function [sm] = DoVTrig(sm, v)

    if (v < 0), 
      set(sm.ToneTrigLabel, 'String', sprintf('Stop %d', -v));
    elseif (v > 0),  
      set(sm.ToneTrigLabel, 'String', sprintf('Play %d', v));;        
    else
      %set(sm.ToneTrigLabel, 'String', '(None)');
    end;
 
    if (v & ~isempty(sm.VTrigCallback)),
      feval(sm.VTrigCallback{1}, sm.VTrigCallback{2}, v);
    end;
    
    return;
