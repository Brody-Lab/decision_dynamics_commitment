%tester.m

clear classes;
dbstop if error;
global private_lunghao_list;

% % A trivial state machine that toggles between two states
% statematrix = [ ...
%         0 0 0 0 0 0 1 ; ...
%         1 1 1 1 1 1 0 ; ...
%     ];
% timdurmatrix = [1; 0.5];

% A state machine that requires going left, center, then right, then out,
% to complete a trial
%      Cin Cout Lin Lout Rin Rout Tup Tdur  Dout  Aout
statematrix = [ ...
         0   0   1   0    0   0   0   999     0    0      ; ...  % start outside; must go to left in to start trial
         7   7   7   2    7   7   7   2       0    0      ; ...  % now go out of the left port within 2 secs
         3   7   7   7    7   7   7   2       0    0      ; ...  % now into center port within 2 secs
         7   4   7   7    7   7   7   2       0    0      ; ...  % out of center
         7   7   7   7    5   7   7   2       0    0      ; ...  % into right
         7   7   7   7    7   6   7   2       0    0      ; ...  % success!
         6   6   6   6    6   6   0   6       255  1      ; ...  % bask in success for 6 secs; then go again
         7   7   7   7    7   7   0   6       170  2      ; ...  % stay in error state for 4 secs; then start again
    ];
aoutmatrix   = statematrix(:,end);
doutmatrix   = statematrix(:,end-1);
timdurmatrix = statematrix(:,end-2); 
statematrix  = statematrix(:,1:end-3);

lh1 = lunghao1;
WriteTagV(lh1, 'StateMatrix', 0, state_to_state_addr(statematrix));
WriteTagV(lh1, 'TimDurMatrix', 0, timdurmatrix);
WriteTagV(lh1, 'DIO_Out', 0, doutmatrix);
WriteTagV(lh1, 'AO_Out',  0, aoutmatrix);

setup_lunghao1_gui(lh1);

% ------------

lh2 = lunghao2;
G = load('chirp'); t = (1:48828)/48828; lowtone = 0.3*sin(2*pi*300*t);

WriteTagV(lh2, 'datain1', 0, G.y/12000);     SetTagVal(lh2, 'datalngth1', length(G.y));
WriteTagV(lh2, 'datain2', 0, lowtone/12000); SetTagVal(lh2, 'datalngth2', length(lowtone));

% ------------

set(lh1, 'aoutchange_callback', {'tester_aoutchange_callback' lh2});

Run(lh1);


