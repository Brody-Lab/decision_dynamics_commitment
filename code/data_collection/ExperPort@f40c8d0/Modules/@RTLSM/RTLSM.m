% function [sm] = RTLSM(host,port,which_sm)
%                Create a new RTLinux state machine handle that
%                connects to the state machine server running on
%                host, port.  Since a state machine server can
%                handle more than one virtual state machine,
%                which_state_machine specifies which of the 6 state
%                machines on the server to use.  See
%                GetStateMachine.m for more details. 
%
%                Parameter #2, port, defaults  to 3333 if not
%                specified.  
%
%                Parameter #3, which_state_machine defaults to 0
%
%                The new state machine will have the following
%                default properties set:
%
%                  fsm = SetOutputRouting(fsm, struct('type', 'dout', ...
%                                         'data', '0-15') ; ...
%                                         struct('type', 'sound', ...
%                                         'data', sprintf('%d', which_state_machine)))
%                  fsm = SetInputEvents(sm, 6);
%
%                The sm will not have any SchedWave matrix, or any
%                state matrix.
%
function [sm] = RTLSM(host,port,which_sm)
  sm.host = 'localhost';
  sm.port = 3333;
  sm.fsm_id = 0;
  sm.in_chan_type = 'ai'; % use analog input for input
  sm.sched_waves = zeros(0,7); % default to no scheduled waves
  sm.sched_waves_ao = cell(0,4); % default to no ao sched waves
  sm.input_event_mapping = []; % input_event_mapping is written-to by SetInputEvents below..
  sm.ready_for_trial_jumpstate = 35;
  
  switch nargin
    case 0
      error('Please pass a hostname to RTLSM constructor');
    case 1
      if (isa(host,'RTLSM')), sm = host; return; end;
      sm.host = host;
    case 2
      sm.host = host;
      sm.port = port;
    case 3
      sm.host = host;
      sm.port = port;
      sm.fsm_id = which_sm;
    otherwise
      error('Please pass 3 or fewer arguments to RTLSM');
  end;

  sm.output_routing = { struct('type', 'dout', ...
                               'data', '0-15') ; ...
                        struct('type', 'sound', ...
                               'data', sprintf('%d', sm.fsm_id)) };
  
  sm.handle = FSMClient('create', sm.host, sm.port);

  % bless this to be a class
  sm = class(sm, 'RTLSM');
  
  % just to make sure to explode here if the connection failed
  FSMClient('connect', sm.handle);
  ChkConn(sm);
  sm = SetStateMachine(sm, sm.fsm_id);
  sm = SetInputEvents(sm, 6, 'ai'); % 6 input events, two for each nosecone

  return;
%end


