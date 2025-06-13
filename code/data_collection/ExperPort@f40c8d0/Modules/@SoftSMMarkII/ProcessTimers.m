function [sm] = ProcessTimers(sm, ts)

% Since we only get called once in a while, we need to iterate
% through *all* possible timers that may have expired, and enqueue them
% as events that happened.  
       
   % Find the next timer event:
   [pingids sm] = next_scheduled_wave_or_tup(sm, ts);
   if ~isempty(pingids)
       switch pingids{1,2},
        case 'tup',
          sm = EventColTriggered(sm, GetTUPCol(sm), ...
                            GetCurrentStateTS(sm)+GetCurrentStateTUP(sm));
        
        case {'in', 'out'}
          sm = do_single_scheduled_wave(sm, pingids{1,1}, pingids{1,2}, ...
                                        pingids{1,3});  
       end;
       % Maybe that event switched us to a state that now causes
       % another timer event:
       % pingids = next_scheduled_wave_or_tup(sm, ts);
    end;
    
    % now do the 'forced' tups, if any
    if (sm.ForceTUP & GetCurrentStateTUP(sm))
      sm.ForceTUP = 0;
      sm = EventColTriggered(sm, GetTUPCol(sm), ts);
    end;

    
% ----

function [pingids sm] = next_scheduled_wave_or_tup(sm, ts)
   
   % Each row of the pingids cell will contain
   % {id (0 if TUP), 'in' or 'out' or 'tup',  time of ocurrence}:
   pingids = cell(0,3);   
   
   % Go through all scheduled waves:
   for i=1:size(sm.SchedWaves, 1),
      sw = sm.SchedWaves{i, 1};
      % <~> added the if block below (and changed if sw.running to elseif)
      %       2008.Aug.16
      if sw.untrigdInSustain,
          pingids = [pingids ; {i, 'out', sw.untrigdInSustain_ts}];
          sw.untrigdInSustain = 0;
          sw.untrigdInSustain_ts = 0;
          sm.SchedWaves{i,1} = sw; % <~> Save the flag changes.
      % <~> For each wave that is running,
      %       If no In event occurred yet and the preamble is over,
      %         add an in event to pingids.
      %       If no Out event occurred yet and the sustain is over,
      %         add an out event to pingids.
      elseif (sw.running),
        if ( (~sw.didUP) & ts >= sw.startTS + sw.preamble),
           pingids = [pingids ; {i, 'in', sw.startTS + sw.preamble}];
        end
        if ( (~sw.didDOWN) & ts>=sw.startTS + sw.preamble + sw.sustain),
           pingids = [pingids ; {i, 'out', ...
                               sw.startTS + sw.preamble + sw.sustain}];
        end;
      end;
   end;

   % Check for TUP on current state:
   if GetCurrentStateTUP(sm) ... 
        & GetCurrentStateTS(sm) + GetCurrentStateTUP(sm) <= ts,
      tuptime = GetCurrentStateTS(sm) + GetCurrentStateTUP(sm);
      pingids = [pingids ; {0, 'tup', tuptime}];
   end;
   
   % Now sort to find the first event:
   if size(pingids, 1)>0,
      [trash, I] = min(cell2mat(pingids(:,3)));
      pingids = pingids(I,:);
   end;
   
   return;


function [sm] = do_single_scheduled_wave(sm, id, in_or_out, ts),

   sw = sm.SchedWaves{id, 1};
      switch in_or_out,
       case 'in',
         sw.didUP = 1;

         if (sw.inEvtCol > -1), % if they specified an IN event column
            sm = EventColTriggered(sm, sw.inEvtCol+1, ts);
         end;
         if (sw.dioLine > -1), DIOWrite(sm, sw.dioLine, 1); end;          
      
      case 'out',
        sw.didDOWN = 1;
        
        if (sw.outEvtCol > -1), % if they specified an OUT event column
           sm = EventColTriggered(sm, sw.outEvtCol+1, ts);
        end;
        if (sw.dioLine > -1), DIOWrite(sm, sw.dioLine, 0); end;
          
      end;
      if ( ts >= sw.startTS + sw.preamble + sw.sustain + sw.refraction ),
         % entire alarm/sched_wave expired, flag it as not running.
         sw.running = 0;
      end;
      
      sm.SchedWaves{id, 1} = sw; % save it back to our cell array
      return;
      
  