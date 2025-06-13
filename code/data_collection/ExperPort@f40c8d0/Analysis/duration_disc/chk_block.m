function [] = chk_block(ratname)

doffset=0;
date = getdate(doffset);

ratrow = rat_task_table(ratname);
task = ratrow{1,2};
load_datafile(ratname, date);

% if isfield(saved_history, 'BlocksSection_Blocks_Switch')
%     fprintf(1,'Field exists\n');
%     c = cell2mat(saved_history.BlocksSection_Blocks_Switch);
%     sumc=sum(c);
%     fprintf(1,'# trials with blocks on = %i\n', sumc);
% end;

if isfield(saved, [task '_psychday_counter'])
    fprintf(1,'Field exists\n');
    c = eval(['saved.' task '_psychday_counter']);
    fprintf(1,'psychday_counter = %i\n', c);
end;
