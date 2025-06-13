function closeout_runrats_datalog

file = which('runrats_datalog_temp.txt');
path = bSettings('get','GENERAL','Main_Data_Directory');
rigid = bSettings('get','RIGS','Rig_ID');
newfile = [path,filesep,'Data',filesep,'RunRats',filesep,'Rig',sprintf('%03.0f',rigid),filesep,...
    datestr(now,'yymmdd'),'_','Rig',sprintf('%03.0f',rigid),'_runrats_datalog.txt'];
system(['echo f | xcopy "',file,'" "',newfile,'"']);
add_and_commit(newfile);
f = fopen(file,'w');
fprintf(f,['New File Generated ',datestr(now,'yyyy-mm-dd HH:MM:SS')]);
fclose(f);
pause(0.01);
disp('COMPLETED')