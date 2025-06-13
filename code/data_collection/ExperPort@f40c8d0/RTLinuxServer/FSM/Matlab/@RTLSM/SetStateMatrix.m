% sm = SetStateMatrix(sm, Matrix state_matrix) 
% sm = SetStateMatrix(sm, Matrix state_matrix, bool_for_pend_sm_swap_flg) 
%
%                This command defines the state matrix that governs
%                the control algorithm during behavior trials. 
%           
%                It is an M x N matrix where M is the number of
%                states (so each row corresponds to a state) and N
%                is the number of input events + output events per state.
%
%                This state_matrix can have nearly unlimited rows 
%                (i.e., states), and has a variable number of
%                columns, depending on how many input events are
%                defined.  
%
%                To specify the number of input events,
%                see SetInputEvents().  The default number of input
%                events is 6 (CIN, COUT, LIN, LOUT, RIN, ROUT).  In
%                addition to the input event columns, the state matrix
%                also has 4 or 5 additional columns: TIMEOUT_STATE
%                TIMEOUT_TIME CONT_OUT TRIG_OUT and the optional
%                SCHED_WAVE.
%
%
%                The second usage of this function specifies an
%                optional flag.  If the flag is true, then the state
%                machine will not swap state matrices right away, but
%                rather, will wait for the next jump to state 0 in
%                the current FSM before swapping state matrices.
%                This is so that one can cleanly exit one FSM by
%                jumping to state 0 of another, and thus have cleaner
%                inter-trial interval handling. 
%
%                Note:
%                   (1) the part of the state matrix that is being
%                   run during intertrial intervals should remain
%                   constant in between any two calls of
%                   Initialize()
%                   (2) that SetStateMatrix() should only be called
%                   in between trials.
%
function [sm] = SetStateMatrix(varargin)
  if (nargin < 2 | nargin > 3),  error ('invalid number of arguments'); end;
  sm = varargin{1};
  mat = varargin{2};
  pend_sm_swap_flg = 0;
  if (nargin == 3), pend_sm_swap_flg = varargin{3}; end;
  ChkConn(sm);
  [m,n] = size(mat);
  [m_i, n_i] = size(sm.input_event_mapping);  
  orouting = sm.output_routing;
  endcols = 2 + size(orouting,1); % 2 fixed columns for timer at the
                                  % end, plus output cols
  if (~isempty(sm.sched_waves) || ~isempty(sm.sched_waves_ao)), 
    % verify that there is at least 1 sched_waves output column
    found = 0;
    for i=1:size(orouting,1),
      if (strcmp(orouting{i}.type, 'sched_wave')),
        found = 1; 
        break;
      end;
    end;
    if (~found),
      warning(sprintf(['The state machine has a sched_waves specification but\n' ...
                     ' no sched_wave output routing defined!\n' ...
                     'Please specify a sched_wave output column using SetOutputRouting!\n' ...
                     'Will try to auto-add an output routing specifying the last column\n' ...
                     'as the sched_wave trigger column, but please fix your code!\n\n' ...
                     '  See SetOutputRouting.m help for more details.']));
      orouting = [ orouting; struct('type', ...
                                    'sched_wave', ...
                                    'data', ...
                                    'THIS STRUCT FIELD IGNORED') ];
      endcols = endcols + 1;
    end;
  end;
  
  if (n ~= endcols + n_i), 
    % verify matrix is sane with respect to number of columns
    error(['Specified matrix has %d columns but\n' ...
           '%d(input) + 2(timeout) + %d(outputs) = %d total\n' ...
           'columns are required due to FSM specification\n' ...
           'such as the number of input events, the output\n' ...
           'routing specified, etc.  Please pass a sane matrix\n'...
           'that meets your input and output routing specification!'], ...
           n, n_i, endcols-2, endcols+n_i); 
  end;
  if (n_i > n), 
    error(['INTERNAL ERROR: How can the number of input events exceed' ...
           ' the space allocated them in the matrix??']); 
  end;
  % now concatenate the input_event_mapping vector as the last row of the matrix
  % -- server side will deconcatenate it
  vec = zeros(1, n);
  for i = 1:n
      if (i <= n_i) vec(1,i) = sm.input_event_mapping(1,i);
      else vec(1,i) = 0;
      end;
  end;
  m = m + 1; % increment m since we added this vector
  mat(m,1:n) =  vec; 
  
  % now, for each scheduled wave, simply add the spec as elements to the
  % matrix -- note these elements are not at all row-aligned and you can
  % end up with multiple sched_waves per matrix row, or 1 sched_wave taking
  % up more than 1 matrix row.  The server-side will just pop these out in
  % FIFO order to build its own sched_waves data structure.  It just knows
  % there are 7 columns per scheduled wave.
  [m_s, n_s] = size(sm.sched_waves);
  new_m = m + ceil(m_s * (n_s / n));
  row = m+1;
  col = 1;
  row_s = 1;
  col_s = 1;
  for i = 1:((new_m - m) * n)
      if (row_s > m_s)
          mat(row, col) = 0; % we already consumed sm.sched_wave, so just pad with zeros until row finishes
      else
          mat(row, col) = sm.sched_waves(row_s, col_s);          
      end;
      col = col + 1;
      col_s = col_s + 1;
      if (mod(col_s, n_s)==1) % wrap sm.sched_wave column pointer
          col_s = 1;
          row_s = row_s + 1; 
      end;
      
      if (mod(col, n)==1) % wrap mat column pointer
          col = 1;
          row = row + 1;
      end;
  end;
  if (size(mat) ~= [new_m, n]), 
    error(['INTERNAL ERROR: new matrix size is incorrect when' ...
           ' concatenating sched_waves to the end of the state' ...
           ' matrix!! DEBUG ME!']); 
  end;
  
  % format and urlencode the output_spec_str..  it is of format:
  % \1.type\2.data\1.type\2.data... where everything is
  % urlencoded (so \1 becomes %01, \2 becomes %02, etc)
  output_spec_str = '';
  for i = 1:size(orouting,1),
    s = orouting{i};
    switch (s.type)
     case { 'tcp', 'udp' }
        % force trailing newline for tcp/udp text packets..
        if (s.data(length(s.data)) ~= sprintf('\n')),
          s.data = [ s.data sprintf('\n') ];
        end;
    end;
    output_spec_str = [ ...
        output_spec_str sprintf('\1') s.type sprintf('\2') s.data ...
                      ];      
  end;
  output_spec_str = UrlEncode(sm, output_spec_str);
  
  [m,n] = size(mat);
  % format for SET STATE MATRIX command is 
  % SET STATE MATRIX rows cols num_in_events num_sched_waves in_chan_type ready_for_trial_jumpstate IGNORED IGNORED IGNORED OUTPUT_SPEC_STR_URL_ENCODED
  [res] = FSMClient('sendstring', sm.handle, sprintf(['SET STATE' ...
                    ' MATRIX %u %u %u %u %s %u %u %u %u %s %u\n'], m, n, n_i, m_s, sm.in_chan_type, sm.ready_for_trial_jumpstate, 0, 0, 0, output_spec_str, pend_sm_swap_flg));
  ReceiveREADY(sm, 'SET STATE MATRIX');
  [res] = FSMClient('sendmatrix', sm.handle, mat);
  ReceiveOK(sm, 'SET STATE MATRIX');
  
  % now, send the AO waves *that changed* Note that sending an empty matrix
  % is like clearing a specific wave
  for idx=1:size(sm.sched_waves_ao, 1),
      id = sm.sched_waves_ao{idx,1};
      ao = sm.sched_waves_ao{idx,2}-1;
      loop = sm.sched_waves_ao{idx,3};
      mat = sm.sched_waves_ao{idx,4};
      mat(2,:) = mat(2,:)-1; % translate matrix to 0-indexed -- meaning invalid evt cols are negative
      [m,n] = size(mat);
      [res] = FSMClient('sendstring', sm.handle, sprintf('SET AO WAVE %u %u %u %u %u\n', m, n, id, ao, loop));
      if (m && n), 
           ReceiveREADY(sm, 'SET AO WAVE'); 
          [res] = FSMClient('sendmatrix', sm.handle, mat);
      end;          
      ReceiveOK(sm, 'SET AO WAVE');  
  end;
  
  return;
