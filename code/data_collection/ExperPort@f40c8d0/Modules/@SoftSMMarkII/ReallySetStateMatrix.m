function [sm] = ReallySetStateMatrix(sm)
   
    sm = get(sm.Fig, 'UserData');
    if isempty(sm.NextStateMatrix), return; end;
    
    sm.InputEvents = sm.UpAndComingInputEvents;

    sm.StateMatrix = sm.NextStateMatrix;
    sm.NextStateMatrix = [];
        
    % ------

    if ~isempty(sm.NextSchedWaves),
       sched_matrix = sm.NextSchedWaves; sm.NextSchedWaves = [];

       sm.SchedWaves = cell(size(sched_matrix,1),1);
       for i=1:size(sched_matrix,1),
          sw = struct('id', sched_matrix(i,1), ...
                      'inEvtCol', sched_matrix(i, 2), ...
                      'outEvtCol', sched_matrix(i, 3), ...                  
                      'dioLine', sched_matrix(i, 4), ...                  
                      'preamble', sched_matrix(i, 5), ...           
                      'sustain', sched_matrix(i, 6), ...          
                      'refraction', sched_matrix(i, 7), ...       
                      'running', 0, ...            
                      'startTS', 0, ...                
                      'didUP', 0,  ...               
                      'didDOWN', 0, ...
                      'untrigdInSustain', 0, ... % <~> added 2008.Aug.16 to generate Out events when a wave is untriggered during sustain
                      'untrigdInSustain_ts', 0); % <~> added 2008.Aug.16 to generate Out events when a wave is untriggered during sustain
          sm.SchedWaves{i,1} = sw;
       end;

    end;
        
    % ------

    if size(sm.SchedWaves,1) > 0, sm.HasSchedWaves = 1;
    else                          sm.HasSchedWaves = 0;
    end;
            
    
    % ------
    
    set(sm.Fig, 'UserData', sm);

    sm = UpdateInputUI(sm);

    set(sm.Fig, 'UserData', sm);
    
    sm = RecreateDIOButtons(sm);
    sm.NeedSMListBoxUpdate = 1;
    sm = UpdateStateUI(sm);
    
    set(sm.Fig, 'UserData', sm);

    return;
