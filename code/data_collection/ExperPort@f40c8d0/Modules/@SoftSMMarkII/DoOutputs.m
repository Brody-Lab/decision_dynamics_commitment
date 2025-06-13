function [sm] = DoOutputs(sm, ts)
   
    if (sm.debug),
      display(sprintf('DoOutputs called for state %d', sm.CurrentState));
    end;
    
    nCols = size(sm.StateMatrix, 2);
    stateRow = sm.StateMatrix(sm.CurrentState+1,1:nCols);
 
    for i=1:length(sm.OutputRouting),
        ort = sm.OutputRouting{i};
        % Why did Calin make it uint32 here? Don't understand. -CDB
        theCol     = uint32(stateRow(1, size(sm.InputEvents, 2) + 2 + i));
        theColOrig =        stateRow(1, size(sm.InputEvents, 2) + 2 + i);
        if (sm.debug), display(sprintf('DoOutputs type=%s data=%s state=%d val=%d', ort.type, ort.data, sm.CurrentState, theCol)); end;
        switch ort.type
            case 'dout'
                % cont col
                for bitPos=0:sm.NumContChans-1, 
                    if (bitand(theCol, 2^bitPos) & ~bitand(sm.ContOut, 2^bitPos)),
                        sm = DIOWrite(sm, bitPos + sm.ContChanOffset, 1);
                        sm.ContOut = bitor(sm.ContOut, 2^bitPos);
                    elseif (~bitand(theCol, 2^bitPos) & bitand(sm.ContOut, 2^bitPos))
                        sm = DIOWrite(sm, bitPos + sm.ContChanOffset, 0); 
                        sm.ContOut = bitxor(sm.ContOut, 2^bitPos);
                    end;
                end;
            case 'trig'
                % trig col
                for bitPos=0:sm.NumTrigChans-1, 
                    if (bitand(theCol, 2^bitPos)),
                        sm = DIOWrite(sm, bitPos + sm.TrigChanOffset, 1);
                        sm.TrigOut = bitor(sm.TrigOut, 2^bitPos);
                    elseif (~bitand(theCol, 2^bitPos) & bitand(sm.TrigOut, 2^bitPos)),      
                        sm = DIOWrite(sm, bitPos + sm.TrigChanOffset, 0); 
                        sm.TrigOut = bitxor(sm.TrigOut, 2^bitPos);
                    end;
                end;
            case 'sound'
                % vtrig col
                theCol2 = stateRow(1, size(sm.InputEvents, 2) + 2 + i);
                sm = DoVTrig(sm, theCol2);
            case 'sched_wave'
                % Now, trigger scheduled waves..    (if the column exists.. )
                alarmCol = uint32(abs(theColOrig));
                theColSign = sign(theColOrig);
                id = 0;
                op = 1;
                % if untrigger is requested (alarmCol is negative) then 
                % untrigger the absolute value of alarmCol
                if (alarmCol < 0), 
                  alarmCol = -alarmCol;
                  op = -1;
                elseif (theColSign < 0),
                  op = -1;
                end;
                while(alarmCol && sm.HasSchedWaves),
                  bit = 2^id;
                  if (bitand(alarmCol, bit)),
                    % this id is triggered
                    for i=1:size(sm.SchedWaves, 1), % find the ID
                      swStruct = sm.SchedWaves{i, 1};
                      if (id == swStruct.id),
                        sm = TrigSchedWave(sm, op * i, ts); % found,
                                                            % trigger it (or
                                                            % untrigger if op
                                                            % is negative
                                                            
                        % if untriggering and it had a DOut line up, make sure to pull the DOut line down                                                           
                        if (op==-1 && swStruct.dioLine > -1), DIOWrite(sm, swStruct.dioLine, 0); end;                                                            
                      end;
                    end;
                    alarmCol = bitxor(alarmCol, bit); % clear the bit
                  end;
                  id = id + 1;
                end;
            case {'udp', 'tcp' }
                display(sprintf('%s event %s for state column value %d in state %d at time %d', ort.type, ort.data, theCol, sm.CurrentState, ts));
            case 'noop'
                %
            otherwise
                warning(sprintf('Unknown output routing type %s triggered for column value %d in state %d', ort.type, theCol, sm.CurrentState));
        end;
    end;
    % Now, process scheduled waves & timers, if any
    sm = ProcessTimers(sm, ts);
    
    return;
    