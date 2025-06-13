function [sm] = EnqueueEvent(varargin) 

    if (nargin ~= 2 & nargin ~= 3),
      error('Wrong number of args to EnqueueEvent');      
    end;
    
    sm = varargin{1};

    currentState = GetCurrentState(sm);
        
    if (nargin == 3),
      % EnqueueEvent(sm, col, ts)
      col = varargin{2};
      if (col > size(sm.StateMatrix, 2)-3),
        error(sprintf(['No such event column in statematrix: %d!'], ...
                      col));
      end;

      ts = varargin{3};
      nextState = sm.StateMatrix((currentState+1), col);
      evtId = 2^(col-1);    
    elseif (nargin == 2),
      nextState = varargin{2};
      if (nextState > size(sm.StateMatrix, 1)),
        error(sprintf(['No such state in statematrix: %d!'], ...
              nextState));
      end;
      
      evtId = 0;
      ts = etime(clock, sm.T0);
    end;        
    
    if (sm.ReadyForTrialFlg & nextState == sm.ReadyForTrialJumpstate),
      nextState = 0;
      sm.ReadyForTrialFlg = 0;
    end;

    ct = size(sm.EventQueue, 1);
    sm.EventQueue(ct+1,1:4) = ...
        [ currentState evtId ts nextState ];

    if (currentState == nextState),      
      if (sm.debug),
        display(sprintf(['CurrentState (%d) == NextState in ' ...
                         'EnqueueEvent at time: %d'], currentState, ...
                        ts));
      end;
    end;
    
    return;
    