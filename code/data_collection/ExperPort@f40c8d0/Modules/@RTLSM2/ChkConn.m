function [] = ChkConn(sm)
  if (sm.in_chkconn),  return;  end;
  ret = FSMClient('sendstring', sm.handle, sprintf('NOOP\n'));
  if (isempty(ret) | isempty((FSMClient('readlines', sm.handle))))
    ret = FSMClient('connect', sm.handle);
    if (isempty(ret))
      error('Unable to connect to RTLinux FSM server.');
    end;
    sm.in_chkconn = 1;
    ChkVersion(sm);
    SetStateMachine(sm, sm.fsm_id); % tell state machine server
                                    % about which fsm id we have
                                    % since we just reconnected and
                                    % it defaults to fsm id 0
    sm.in_chkconn = 0;
  end;

