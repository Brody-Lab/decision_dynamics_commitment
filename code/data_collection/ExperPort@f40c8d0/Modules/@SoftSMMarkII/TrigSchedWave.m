function [sm] = TrigSchedWave(sm, idx, ts)
    untrig = 0;
    if (idx < 0), % negative idx means untrigger an already-running wave
      idx = -idx;
      untrig = 1;
    end;
    
    sw = sm.SchedWaves{idx,1};
    
    if (~isstruct(sw)),
      error(['INTERNAL ERROR sm.SchedWaves does not contain a struct!']);
    end;
    
    if (sw.running && ~untrig), 
      if (sm.debug),
        warning(sprintf(['Triggered already-running sched-wave' ...
        ' %d, ignoring...'], sw.id));
      end;
      return;
    elseif (~sw.running && untrig)
      if (sm.debug),
        warning(sprintf(['UnTriggered already-not-running sched-wave' ...
        ' %d, ignoring...'], sw.id));
      end;
      return;
    end;
    
    if (~untrig),
      % request was to trigger this wave
      sw.startTS = ts;
      sw.running = 1;
      sw.didUP = 0;
      sw.didDOWN = 0;
      sw.untrigdInSustain    = 0; % <~> added 2008.Aug.16 locally
      sw.untrigdInSustain_ts = 0; % <~> added 2008.Aug.16 locally
    else
      % request was to untrigger this wave
      % <~> added 2008.Aug.16 locally (next 4 lines of code)
      %     The sw.untrigdInSustain flag is placed if the wave was
      %       untriggered by a state transition Output command after the In
      %       event occurred but before any Out event occurred. It is used
      %       in ProcessTimers to generate an Out event on the next
      %       FlushQueue to correspond with this untriggering. At that
      %       point, the flag is cleared.
      %     sw.untrigdInSustain_ts saves the time at which this
      %       untriggering occurred so that the Out event can be registered
      %       with that time.
      if sw.didUP && ~sw.didDOWN,
          sw.untrigdInSustain    = 1;
          sw.untrigdInSustain_ts = ts;
      end;
      sw.running = 0;
      sw.didUP = 0;
      sw.didDOWN = 0;
    end;
    
    sm.SchedWaves{idx, 1} = sw;
    
    return;
