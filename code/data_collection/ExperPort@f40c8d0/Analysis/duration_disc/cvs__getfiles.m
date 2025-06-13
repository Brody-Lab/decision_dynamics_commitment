function [] = cvs__getfiles(type, date)

ratlist = rat_task_table({},'get_current',1);

if strcmpi(type,'d')
    fprefix = 'data';
    gotodir = 'Data';
elseif strcmpi(type,'s')
    fprefix= 'settings';
    gotodir = 'Settings';
else
    error('type should either be d or s');
end;


cvspref = ['cvs up ..' filesep 'SoloData' filesep 'Data' filesep 'Shraddha' filesep];
for k = 1:3
%    fprintf(1,'%s: %s\n', ratlist{k,1}, ratlist{k,2});
if ~strcmpi(ratlist{k,1},'orca') % --- test 
    fname = [ fprefix '_@' ratlist{k,2} '_Shraddha_' ratlist{k,1} '_' date '.mat'];
    fprintf(1,'%s\n', fname);
    cvscmd = [cvspref ratlist{k,1} filesep fname];
    system(cvscmd);
end;
end;

%    system('pwd'); 