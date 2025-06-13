function [sm] = UpdateRunningSchedWavesGUI(sm)
    % hmm..
    foundIt = 0;
    str = '';
    for i=1:size(sm.SchedWaves, 1)
      sw = sm.SchedWaves{i,1};
      if (sw.running),
        foundIt = 1;
        h = 'p';
        if (sw.didUP & ~sw.didDOWN),
          h = 's';
        elseif (sw.didUP & sw.didDOWN),
          h = 'r';
        end;
        str = sprintf('%s%d%s ', str, sw.id, h);
      end;
    end;
    
    if (~foundIt),
      str = '(None)';
    end;

    set(sm.SchedWaveLabel, 'String', str);
    
    return;
    