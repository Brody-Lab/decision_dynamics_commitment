function [] = blah()
% 
% %        Cin    Cout    Lin    Lout     Rin     Rout    Tup    Timer    Dout   Aout
% Dout_col = 9;
% timer_col = 8;
% Tup_col = 7;
% sync_rows = 18;
% timer_len = 1/3;
% 
% % The signal on the DIO line will be, in sequence: High, Low, High, High,
% % Low, High, followed by a a 12-bit binary representation of the trial
% % number 
% smatstart = 41; % State # of the first row of the sync matrix.
% sync_matrix = zeros(sync_rows,10);
% 
% base_act = (smatstart:1:smatstart+(sync_rows-1))';
% first_six = repmat(base_act,1, 6);
% sync_matrix(1:sync_rows, 1:6) = first_six;
% 
% sync_matrix(1:6,Dout_col) = [1;0;1;1;0;1]; % special sequence of sync-ing I/O flips
% sync_matrix(1:sync_rows,Tup_col) = (smatstart+1:1:smatstart+sync_rows)';
% sync_matrix(1:sync_rows, timer_col) = ones(sync_rows,1) * timer_len;
% 
% 
% 
% state_num = 5;
% bin_state = dec2bin(state_num);
% start_pos = (sync_rows - length(bin_state)) + 1;
% 
% ctr = 1;
% for k = start_pos:sync_rows
%     sync_matrix(k, Dout_col) = str2double(bin_state(ctr)); 
%     ctr = ctr+1;
% end;
% sync_matrix(Dout_col,start_pos:end) = str2double(bin_state);
% 
% sync_matrix



ratname = 'Lascar';
dateset = get_files('Lascar','fromdate','080317', 'todate','080323');

psych_data = {};
for d = 1:length(dateset)
    [weber bfit bias xx yy xmid xcomm xfin replong tally bins] = ...
        psychometric_curve(ratname,0,'usedate', dateset{d},'noplot', 1);    
    
    eval(['psych_data.date' num2str(d) ' = 0;']);
    fnames = {'weber', 'bfit', 'bias', 'xx', 'yy', 'xmid', 'xcomm' ,'xfin' ,'replong', 'tally','bins'};
    for f = 1:length(fnames)
        eval(['psych_data.date' num2str(d) '.' fnames{f} ' = ' fnames{f} ';']);
    end;    
end;

;
