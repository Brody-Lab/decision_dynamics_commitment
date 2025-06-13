% analyze_chanakya.m

function [] = analyze_chanakya(indate)

ratname = 'chanakya';
%dateset = {'051116b','051117a','051118a','051120a','051130a'};%'051202a','051203a','051204a','051205a'};
%dateset = get_files('chanakya','fromdate','051102','todate','051115');%{'051103a','051105a','051118a','051120a','051130a'};%'051202a','051203a','051204a','051205a'};


% load one day
task_type=0;
[sides tones_Dur tones_freq freql freqr durl durr hh vpd numtrials spll splr gol gor toneloc goloc task_type] = sub__oneday(indate);
sub___plotdata(sides, freql, freqr, durl, durr, hh ,vpd ,numtrials ,spll ,splr ,gol ,gor,toneloc, goloc, task_type, 'dual_discobj',{indate});

function [sides tones_dur tones_freq freql freqr durl durr hh vpd tr spll splr gol gor toneloc goloc ttype] = sub__oneday(indate)

ratname = 'chanakya';

load_datafile(ratname, indate);

freql = cell2mat(saved_history.ChordSection_Tone_Freq_L);
freqr =  cell2mat(saved_history.ChordSection_Tone_Freq_R);
durl =  cell2mat(saved_history.ChordSection_Tone_Dur_L);
durr =  cell2mat(saved_history.ChordSection_Tone_Dur_R);
hh = saved.dual_discobj_hit_history;
vpd = saved.VpdsSection_vpds_list;
tr = saved.dual_discobj_n_done_trials;
spll = cell2mat(saved_history.ChordSection_Tone_SPL_L);
splr = cell2mat(saved_history.ChordSection_Tone_SPL_R);
gol = cell2mat(saved_history.ChordSection_SoundSPL_L);
gor = cell2mat(saved_history.ChordSection_SoundSPL_R);
sides = saved.SidesSection_side_list;
tmp = saved_history.ChordSection_Tone_Loc;
tmp2 = zeros(1,length(tmp));
tmp2(find(strcmpi(tmp,'on')))=1;
toneloc =  tmp2;

2;

sides = sides(1:tr);

tones_dur = zeros(size(sides));
tones_freq = zeros(size(sides));
left = find(sides >0); right = find(sides == 0);
tones_dur(left) = durl(left);
tones_dur(right) = durr(right);
tones_freq(left) = freql(left);
tones_freq(right) = freqr(right);

2;

tmp = saved_history.ChordSection_GO_Loc;
tmp2 = zeros(1,length(tmp));
tmp2(find(strcmpi(tmp,'on')))=1;
goloc = tmp2;

tasktype = saved_history.ChordSection_Task_Type;
didx = find(strcmpi(tasktype, 'Duration Disc'));
pidx = find(strcmpi(tasktype, 'Pitch Disc'));
tmp = zeros(1,length(tasktype));
tmp(pidx)=2; tmp(didx)=3;
ttype =tmp;

hh = hh(1:tr);
%
% % sub__plot_toneparams('Duration Disc', tasktype, durl, durr, freql, freqr, 'Duration Trials');
% % sub__plot_toneparams('Pitch Disc', tasktype, durl, durr, freql, freqr, 'Pitch Trials');


function [] = sub___plotdata(sides, freql, freqr, durl, durr, hh ,vpd ,numtrials ,spll ,splr ,gol ,gor ,toneloc, goloc,task_type, taskname,dateset)
ratname = 'chanakya';
plot_others=0;


% plot hit rate ----------------------
figure;
axes('Position',[0.1 0.75 0.8 0.15]);
plot(sides,'.b'); set(gca,'YTick', [0 1], 'YTickLabel',{'R','L'}, 'YLim',[-1 2]);
title(['Chanakya - ' dateset{1}]);
axes('Position',[0.1 0.55 0.8 0.2]);

minnie=0.1;
maxie=1;

sub__makepatches(task_type,numtrials, minnie,maxie);
running_avg=30;
nums=[];
t = (1:length(hh))';
a = zeros(size(t));
for i=1:length(hh),
    x = 1:i;
    kernel = exp(-(i-t(1:i))/running_avg);
    kernel = kernel(1:i) / sum(kernel(1:i));
    a(i) = sum(hh(x)' .*kernel);
end;
num = a;

plot(num, '.-g');
diffs = diff(num);
lesser = find(diffs < 0);
hold on;
plot(lesser+1,num(lesser+1),'.r');

y=ylabel('% Correct');set(y,'FontWEight','bold','fontsize',14);
set(gca,'FontSize',14,'FOntWEight','bold');
set(gca,'XGrid', 'off','XTick',[],'YTick',0:0.2:1, 'YTickLabel', 0:20:100);

% plot tone parameters ---------------

% trim stimulus parameters ---------------
% slist = {'durl','durr','freql','freqr','task_type'};
% for s=1:length(slist)
%     eval([slist{s} '=' slist{s} '(running_avg:end);']);
% end;

% tone duration --------------------------
axes('Position',[0.1 0.05 0.8 0.25]);
minnie = 0;
maxie = max(max(durl), max(durr))*1.35;
sub__makepatches(task_type, numtrials, minnie, maxie);

plot(durl, '.b');hold on;
plot(durr,'.r');
     didx = find(task_type == 3);
    pidx = find(task_type==2);
    p=plot(pidx,durl(pidx),'.k');   
    p=plot(pidx,durr(pidx),'.k');

y=ylabel('duration (sec)');set(y,'FontSize',14,'FOntWEight','bold');
set(gca,'FontSize',14,'FOntWEight','bold');
set(gca,'YLim',[0 maxie]);

% tone pitch ------------------------------
axes('Position',[0.1 0.3 0.8 0.25]);
% t=text(1, 2*mean([mean(freql) mean(freqr)]), 'Tone frequency');
% set(t,'Color',[1 0.7 0.7],'FOntSize', 36);hold on;

minnie =1/10; maxie = max(max(freql),max(freqr))*10;
sub__makepatches(task_type, numtrials, minnie, maxie);

plot(freql, '.b');hold on;
plot(freqr,'.r'); 
     didx = find(task_type == 3);
    pidx = find(task_type==2);
    p=plot(didx,freql(didx),'.k');  p=plot(didx,freqr(didx),'.k');


y=ylabel('frequency (KHz)');
set(y,'FontSize',14,'FOntWEight','bold');
set(gca,'FontSize',14,'FOntWEight','bold','XGrid', 'off','XTick',[],'YLim',[minnie maxie],'YScale','log',...
    'YTick',[1 15]);

t=text(1, maxie*0.6, 'Left'); set(t,'FontWEight','bold','Color','b');
t=text(1, maxie*0.3, 'Right'); set(t,'FontWEight','bold','Color','r');
draw_separators(numtrials,minnie,maxie);

% if ~strcmpi(taskname,'pitch_discobj')
% 
%     change = find(diff(task_type) ~=0);
%     curr_task = task_type(1);
% 
%     % mark first task
%      axes('Position',[0.1 0.55 0.8 0.1]);
%     if curr_task == 3, clr = [1 0.5 0]; else clr= [1 0.7 0.7]; end;
%     patch([1 1 change(1) change(1)],[-2 2 2 -2],clr,'EdgeColor','none');
% hold on;
%     for i = 2:length(change)
%         curr_task = task_type(change(i));
%         if curr_task == 3, clr = [1 0.5 0]; else clr= [1 0.7 0.7]; end;
%         patch([change(i-1)+1 change(i-1)+1 change(i)+1 change(i)+1],[-2 2 2 -2],clr,'EdgeColor','none');
%     end;
% 
%     
% % last patch
%   curr_task = task_type(change(end)+1);
%         if curr_task == 3, clr = [1 0.5 0]; else clr= [1 0.7 0.7]; end;
%         patch([change(end)+1 change(end)+1 numtrials numtrials],[-2 2 2 -2],clr,'EdgeColor','none');
% 
%         
%     didx = find(task_type == 3);
%     pidx = find(task_type==2);
%    
%     %     l=plot(didx, 0, '.b'); set(l, 'Color', [1 0.5 0]); hold on;
%     %     l=plot(pidx, 0, '.b'); set(l, 'Color', [1 0.7 0.7]);
%    % t=title([ratname ': ' dateset{1}]);
% %     set(t,'FontSize',18,'FontWeight','bold');
%     set(gca,'FontSize',14,'FOntWEight','bold','XGrid', 'off','XTick',[]);
%     draw_separators(numtrials,-1,2);
%     cumtrials = cumsum(numtrials);
% 
%     for t = 1:length(numtrials)
%         if t == 1, sidx = 1; else sidx=cumtrials(t-1); end;
%         eidx = cumtrials(end);
%         %text((sidx+eidx)/2, 1.5, sprintf('%s', dateset{t}));
%     end;
% end;

uicontrol('Tag', 'figname', 'Style','text', 'String', [ratname '_' date], 'Visible','off');

if plot_others
    figure;
    plot(vpd,'.g'); t=title('Length of initial silent period'); ylabel('seconds');
    set(t,'FontSize',18,'FontWeight','bold');
    draw_separators(numtrials,min(vpd),max(vpd));
    set(gcf,'Position',[  815    38   636   242]);

    figure;
    subplot(2,1,1);
    plot(spll,'-b'); hold on;
    plot(splr,'.r');
    subplot(2,1,2);
    plot(gol,'-g');hold on;
    plot(gor,'.g');
    draw_separators(numtrials,0,65)
    set(gcf,'Position',[ 942   353   535   177]);

    figure;
    plot(toneloc,'-b'); hold on;
    plot(goloc,'.g');
    draw_separators(numtrials,-1,2)
    set(gcf,'Position',[ 942   600   535   177]);
end;

function [] = sub__makepatches(task_type,numtrials, minnie, maxie)
    change = find(diff(task_type) ~=0);
    curr_task = task_type(1);

      % mark first task; 2 pitch 3 dur
       if curr_task == 3, clr = [1 0.95 0.8]; else clr = [0.95 0.95 0.95]; end;
    patch([1 1 change(1) change(1)],[minnie maxie maxie minnie],clr,'EdgeColor','none');
    
    hold on;
    for i = 2:length(change)
        curr_task = task_type(change(i));
           if curr_task == 3, clr = [1 0.95 0.8]; else clr = [0.95 0.95 0.95]; end;
        patch([change(i-1)+1 change(i-1)+1 change(i)+1 change(i)+1],[minnie maxie maxie minnie],clr,'EdgeColor','none');
    end;    
    
% last patch
   curr_task = task_type(change(end)+1);
           if curr_task == 3, clr = [1 0.95 0.8]; else clr = [0.95 0.95 0.95]; end;
        patch([change(end)+1 change(end)+1 numtrials numtrials],[minnie maxie maxie minnie],clr,'EdgeColor','none');


% function [freql freqr durl durr hh vpd tr spll splr gol gor ttype] = sub__loadmanydays(dateset)
% freql =[];
% freqr =  [];
% durl = [];
% durr = []; %cell2mat(saved_history.ChordSection_Tone_Dur_R);
% hh = [];%saved.dual_discobj_hit_history;
% vpd = []; %saved.VpdsSection_vpds_list;
% tr = []; %saved.dual_discobj_n_done_trials;
% spll = []; %cell2mat(saved_history.ChordSection_Tone_SPL_L);
% splr = []; %cell2mat(saved_history.ChordSection_Tone_SPL_R);
% gol = []; %cell2mat(saved_history.ChordSection_SoundSPL_L);
% gor = []; %cell2mat(saved_history.ChordSection_SoundSPL_R);
%
% ratname = 'chanakya';
%
% ttype = []; % 2 is pitch, 3 is duration
%
% for d = 1:length(dateset)
%
%     indir = [filesep 'Users' filesep 'oldpai' filesep 'Documents' filesep 'Brody_Lab' filesep 'Rat_training' filesep 'SoloData' filesep 'Data' filesep];
% fname = ['data_pitch_discobj_' ratname  '_' dateset{d} '.mat'];
% load([indir 'chanakya' filesep fname]);
%
%     freql = vertcat(freql,cell2mat(saved_history.ChordSection_Tone_Freq_L));
%     freqr = vertcat(freqr, cell2mat(saved_history.ChordSection_Tone_Freq_R));
%     durl = vertcat(durl,cell2mat(saved_history.ChordSection_Tone_Dur_L));
%     durr = vertcat(durr, cell2mat(saved_history.ChordSection_Tone_Dur_R));
%     n = saved.dual_discobj_n_done_trials;
%     hh =horzcat(hh,saved.dual_discobj_hit_history(1:n));
%     vpd = horzcat(vpd,saved.VpdsSection_vpds_list(1:n));
%     tr = horzcat(tr,n);
%     spll = vertcat(spll,cell2mat(saved_history.ChordSection_Tone_SPL_L));
%     splr = vertcat(splr,cell2mat(saved_history.ChordSection_Tone_SPL_R));
%     gol = vertcat(gol,cell2mat(saved_history.ChordSection_SoundSPL_L));
%     gor = vertcat(gor,cell2mat(saved_history.ChordSection_SoundSPL_R));
%
%     tasktype = saved_history.ChordSection_Task_Type;
%     didx = find(strcmpi(tasktype, 'Duration Disc'));
% pidx = find(strcmpi(tasktype, 'Pitch Disc'));
%    tmp = zeros(1,length(tasktype));
%    tmp(pidx)=2; tmp(didx)=3;
%    ttype = horzcat(ttype, tmp);
%
%
%
% end;
%
% % function [freql freqr durl durr hh vpd tr spll splr gol gor toneloc goloc ttype] = sub__pitchload(dateset)
% %
% % freql =[];
% % freqr =  [];
% % durl = [];
% % durr = []; %cell2mat(saved_history.ChordSection_Tone_Dur_R);
% % hh = [];%saved.dual_discobj_hit_history;
% % vpd = []; %saved.VpdsSection_vpds_list;
% % tr = []; %saved.dual_discobj_n_done_trials;
% % spll = []; %cell2mat(saved_history.ChordSection_Tone_SPL_L);
% % splr = []; %cell2mat(saved_history.ChordSection_Tone_SPL_R);
% % gol = []; %cell2mat(saved_history.ChordSection_SoundSPL_L);
% % gor = []; %cell2mat(saved_history.ChordSection_SoundSPL_R);
% % toneloc = [];
% % goloc=[];
% %
% % ratname = 'chanakya';
% %
% % ttype = []; % 2 is pitch, 3 is duration
% %
% % for d = 1:length(dateset)
% %
% %     indir = [filesep 'Users' filesep 'oldpai' filesep 'Documents' filesep 'Brody_Lab' filesep 'Rat_training' filesep 'SoloData' filesep 'Data' filesep];
% % fname = ['data_pitch_discobj_' ratname  '_' dateset{d} '.mat'];
% % load([indir 'chanakya' filesep fname]);
% %
% %     freql = vertcat(freql,cell2mat(saved_history.ChordSection_PD_Low_Freq));
% %     freqr = vertcat(freqr, cell2mat(saved_history.ChordSection_PD_Hi_Freq));
% %     durl = vertcat(durl,cell2mat(saved_history.ChordSection_PD_Duration));
% %     durr = vertcat(durr, cell2mat(saved_history.ChordSection_PD_Duration));
% %     n = saved.pitch_discobj_n_done_trials;
% %     hh =horzcat(hh,saved.pitch_discobj_hit_history(1:n));
% %     vpd = horzcat(vpd,saved.VpdsSection_vpds_list(1:n));
% %     tr = horzcat(tr,n);
% %     spll = vertcat(spll,cell2mat(saved_history.ChordSection_Tone_SPL_L));
% %     splr = vertcat(splr,cell2mat(saved_history.ChordSection_Tone_SPL_R));
% %     gol = vertcat(gol,cell2mat(saved_history.ChordSection_SoundSPL_L));
% %     gor = vertcat(gor,cell2mat(saved_history.ChordSection_SoundSPL_R));
% %     tmp = saved_history.ChordSection_Tone_Loc;
% %     tmp2 = zeros(1,length(tmp));
% %     tmp2(find(strcmpi(tmp,'on')))=1;
% %     toneloc = horzcat(toneloc, tmp2);
% %
% %         tmp = saved_history.ChordSection_GO_Loc;
% %     tmp2 = zeros(1,length(tmp));
% %     tmp2(find(strcmpi(tmp,'on')))=1;
% %     goloc = horzcat(goloc,tmp2);
% %
% %
% % end;
%


% Draws vertical lines separating session info
function [] = draw_separators(numtrials,low,hi);
return;
offset=0;
for k = 1:length(numtrials),
    offset=offset+numtrials(k);
    line([offset offset], [low hi], 'LineStyle','-', 'Color','k');
end
% 
% function [] = sub__plot_toneparams(ttype, tasktype, durl, durr, freql, freqr, figname);
% % get duration trials
% idx = find(strcmpi(tasktype, ttype));
% % plot tone params for sanity's sake
% figure; subplot(2,1,1);
% plot(durl(idx), '-b');hold on;
% plot(durr(idx),'-r');
% title('duration');
% subplot(2,1,2);
% plot(freql(idx),'.b'); hold on;
% plot(freqr(idx),'-r');
% title('pitch');
% set(gcf,'Name',figname);
