function [diff_list fname_list grpnames] = webers_seh_format(area_filter,postpsych,psychthresh, ignore_trialtype)
% returns output of webers_beforeafter in a way that lesion_cvg2impair and
% lesion_compare2groups
% likes.
% seh stands for "(in the format of) Surgery_Effect_Hitrate"
% 
% all outputs are 1x2 cells.
% grpnames tells you which group has container 1 and which, 2.
% diff_list - 1x2 cell, each cell being g-by-1 array. Contains diff_listerence in
% webers of respective group.
% fname_list - 1x2 cell, each cell being g-by-1 names list. Contains
% corresponding names of rats.


%function [diff_list fname_list grpnames] = sub__getweber(area_filter)
[wdur wfreq] = webers_beforeafter(area_filter,'justgetdata',postpsych,psychthresh, ignore_trialtype);
diff_list={}; fname_list={}; grpnames={'duration','frequency'};

fnames=fieldnames(wdur);
tmp=[];
tmplist={};
for f=1:length(fnames)
    wb = eval(['wdur.' fnames{f} ';']);
    wb(find(wb==-1))=1;
    try
        tmp=horzcat(tmp, wb(2)-wb(1));
    catch
        2;
    end;
    tmplist{end+1} = fnames{f};
end;
diff_list{1} = tmp;
fname_list{1} = tmplist;

fnames=fieldnames(wfreq);
tmp=[];
tmplist={};
for f=1:length(fnames)
    wb = eval(['wfreq.' fnames{f} ';']);
    wb(find(wb==-1))=1;
    tmp=horzcat(tmp, wb(2)-wb(1));
    tmplist{end+1}=fnames{f};
end;
diff_list{2}=tmp;
fname_list{2} =tmplist;
