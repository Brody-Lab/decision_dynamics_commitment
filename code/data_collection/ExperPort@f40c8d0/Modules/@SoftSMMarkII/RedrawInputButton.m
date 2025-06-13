function [] = RedrawInputButton(sm, butNum)
    state = sm.InputState(1,butNum);
    but = sm.InputButtons(1,butNum);
    
    if (state), 
      set(but, 'String',  sprintf('Line %d is HIGH', butNum));
      set(but, 'BackGroundColor', 'r');
      set(but, 'Value',  1);
    else
      set(but, 'String',  sprintf('Line %d is LOW', butNum));
      set(but, 'BackGroundColor', 'g');
      set(but, 'Value',  0);
    end;
        
    return;
    