function [] = debug_fsm(fsm, desc_stm)
% debug_fsm

fid = fopen('fsm.txt', 'w+');

% Assign indices to easily tell row numbers of states
indexing = 0:size(fsm,1)-1;
ind_fsm = [indexing' fsm];

% assign precision for states and time columns
state_width = '%8.0f';
time_width = '%8.3f';

width_string = '(%2.0f): ';    % first one for the indexing
for col = 1:10
    if col == 8 % time
        width_string = [width_string time_width];
    else
        width_string = [width_string state_width];
    end;
end;

% prefix with statenames where available
state_names = char(fieldnames(desc_stm.statecodes));
state_names2 = cell(0,0);
for s = 1:size(state_names,1)
    k = eval(['desc_stm.statecodes.' deblank(state_names(s,:))]);
    state_names2{k+1} = state_names(s,:);
end;
state_names = char(state_names2);

% pad for those rows where state name is not visible
space = ' ';
leader = ' ';
for i = 2:size(state_names,2)
    leader = [leader space];
end;


for row_num = 1:size(state_names,1)
    w_bytes = fprintf(fid, ['%s ' width_string '\n'], state_names(row_num,:)', ind_fsm(row_num,:)');
end;

for row_num = size(state_names,1)+1:size(ind_fsm,1)
    w_bytes = fprintf(fid, ['%s ' width_string '\n'], leader', ind_fsm(row_num,:)');
end;


status = fclose(fid);
