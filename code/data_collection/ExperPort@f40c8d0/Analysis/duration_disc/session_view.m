function [] = session_view(ratname,date,varargin)

% Comprehensive view of many (but not all) task-relevant variable values as
% function of the session.

OLD_SOLODIR = ['~' filesep 'SoloData' filesep 'Data'];

pairs = { ...
    'f', 14 ; ...
    'DUR_DATE', datenum(2007,05,13) ; ...
    'PITCH_DATE', datenum(2007,05,23); ...
    'toneprog_only', 0 ; ... % set to 1 to only show progression of tone value.
    'fsize', 14 ; ...
    };
parse_knownargs(varargin,pairs);

ratrow = rat_task_table(ratname);
task = ratrow{1,2};
load_datafile(ratname,date);

hname = eval(['saved.' task '_hostname']);
figure; uicontrol('Style','text','String', hname, ...
    'FontWeight','bold','FontSize', 24,'ForegroundColor','w', ...
    'Position', [10 10 200 40]);
set(gcf,'Position',[550 820 260 90],'Color','b','Menubar','none','Toolbar','none', 'Tag','sessionview');

hh = eval(['saved.' task '_hit_history']);
tr = eval(['saved.' task '_n_done_trials']);

idx= find(~isnan(hh)); maxt= tr; %max(idx);
hh = hh(1:maxt);

% Sound params
if strcmpi(task(1:3),'dua')
    tdur_left = cell2mat(saved_history.ChordSection_Tone_Dur_L);
    tdur_right = cell2mat(saved_history.ChordSection_Tone_Dur_R);

    tfreq_left= saved.ChordSection_pitch1_list; tfreq_left = tfreq_left(1:maxt);%cell2mat(saved_history.ChordSection_Tone_Freq_L);
    tfreq_right= saved.ChordSection_pitch2_list;tfreq_right = tfreq_right(1:maxt);%cell2mat(saved_history.ChordSection_Tone_Freq_R);
else
    tdur_left = saved.ChordSection_tone1_list; tdur_left= tdur_left(1:maxt);
    tdur_right = saved.ChordSection_tone2_list; tdur_right = tdur_right(1:maxt);

    tfreq = cell2mat(saved_history.ChordSection_Tone_Freq);
end;

tone_loc = saved_history.ChordSection_Tone_Loc;
go_loc = saved_history.ChordSection_GO_Loc;
sl = saved.SidesSection_side_list; sl = sl(1:maxt);

% silent flanking periods
pre_gomin = cell2mat(saved_history.ChordSection_Min_2_GO);
pre_gomax = cell2mat(saved_history.ChordSection_Max_2_GO);
pre_cuemin = cell2mat(saved_history.VpdsSection_MinValidPokeDur);
pre_cuemax = cell2mat(saved_history.VpdsSection_MaxValidPokeDur);
if isfield(saved_history,'VpdsSection_VPDSetPoint')
    vpdset = cell2mat(saved_history.VpdsSection_VPDSetPoint);
end;
vpd = saved.VpdsSection_vpds_list;


% flipped flag
if isfield(saved_history,'ChordSection_right_is_low'),
    flp = cell2mat(saved_history.ChordSection_right_is_low);
    
    figure;
    
    plot(flp);
    set(gca,'YLim',[-1 2],'YTick',[0 1], 'YTickLabel',{'off','on'});
    t=title('Flipped flag'); set(t,'FontSize',fsize,'FontWeight','bold');
   % axes__format(gca);
    set(gcf,'Tag','sessionview','Position',[509   430   438   108],'Menubar','none','Toolbar','none');
    if sum(flp) > length(flp)/2, set(gca,'Color','y'); end;
end;

% sharpening stuff
vanilla_on = cell2mat(saved_history.ChordSection_vanilla_on);
logdiff = cell2mat(saved_history.ChordSection_logdiff);


psych_on = 0;
if strcmpi(task(1:3),'dur')
    psych_on = cell2mat(saved_history.ChordSection_psych_on);
else
    psych_on = cell2mat(saved_history.ChordSection_pitch_psych);
end;


% loc logic
goloc = zeros(length(go_loc), 1);
toneloc = zeros(length(tone_loc), 1);

idx = find(strcmpi(go_loc, 'on'));
goloc(idx) = 1;
idx = find(strcmpi(tone_loc, 'on'));
toneloc(idx) = 1;

goloc = zeros(length(go_loc), 1);
toneloc = zeros(length(tone_loc), 1);

idx = find(strcmpi(go_loc, 'on'));
goloc(idx) = 1;
idx = find(strcmpi(tone_loc, 'on'));
toneloc(idx) = 1;

%vol
if (strcmpi(task(1:3), 'dur') && older_data(date,DUR_DATE) || ...
        strcmpi(task(1:3),'dua') && older_data(date,PITCH_DATE)) % || strcmpi(task(1:3),'dua')
    gospl_left =  cell2mat(saved_history.ChordSection_SoundSPL_L);
    gospl_right =cell2mat(saved_history.ChordSection_SoundSPL_R);
    tonevol_left =  cell2mat(saved_history.ChordSection_Tone_SPL_L);
    tonevol_right =  cell2mat(saved_history.ChordSection_Tone_SPL_R);
else
    gospl =cell2mat(saved_history.ChordSection_SoundSPL);
    tonevol =  saved.ChordSection_spl_list; tonevol = tonevol(1:maxt);
end;


% Bad Boy SPL
bbspl = saved_history.TimesSection_BadBoySPL;
bb = zeros(length(bbspl), 1);
i = find(strcmpi(bbspl, 'normal'));
bb(i) = 1;
i = find(strcmpi(bbspl, 'Louder'));
bb(i) = 2;
i = find(strcmpi(bbspl,'Loudest'));
bb(i) = 3;



% Figure 1 Cue parameters ------------------------------------------------
% gcf,
ssize = get(0,'ScreenSize');
BIG_SCR = 1000; % height threshold of big screen
h_offset = 0;
if ssize(4) > BIG_SCR, h_offset = ssize(4)-BIG_SCR; end;% compensate for taller monitors

figure;set(gcf,'Menubar','none','Toolbar','none','Name',['Stimulus & Go ' ...
    'params'],'Position',  [ 41   293+h_offset   454   564]);
subplot(3,2,1); y_offset = 0.1; width = 1/8; height = 0.7; x_offset = 0.05;

% --- Top left - tone duration
leftt = find(sl==1); rightt=find(sl==0);

if isfield(saved,'ChordSection_effective_dur')
    if strcmpi(task(1:3),'dur')
        eff = saved.ChordSection_effective_dur;
        effleft = eff(leftt);
        effright = eff(rightt);
    else
        effleft = tdur_left(leftt);
        effright = tdur_right(rightt);
    end;
else
    effleft = tdur_left(leftt);
    effright = tdur_right(rightt);
end;
plot(leftt, effleft, '.b');hold on;
plot(rightt,effright,'.r');

    line([0 maxt], [316 316], 'LineStyle',':','Color','k','LineWidth',2);

set(gca,'YLim',[0 max(max(effleft),max(effright))+0.1]);
ylabel('Tone Duration (s)');
s = sprintf('%s: %s (%s)\nStimulus durations', make_title(ratname), make_title(task), date);
t = title(s); set(t,'FontSize',fsize);

% --- Center left - Tone frequency
subplot(3,2,3);
if strcmpi(task(1:3),'dua')
    leftt = find(sl==1); rightt=find(sl==0);
    if isfield(saved,'ChordSection_effective_pitch')
        eff = saved.ChordSection_effective_pitch;
    elseif isfield(saved,'ChordSection_tones_list')
        eff = saved.ChordSection_tones_list;
    else
        tonel = saved.ChordSection_pitch1_list;
        toner = saved.ChordSection_pitch2_list;
        eff=NaN(size(tonel));
        eff(leftt)= tonel(leftt);
        eff(rightt)=toner(rightt);
    end;
    
    leftt = find(sl==1); rightt=find(sl==0);
    effleft = eff(leftt);
    effright = eff(rightt);

    plot(leftt, effleft, '.b');hold on;
    plot(rightt,effright,'.r');
    
    line([0 maxt], [11.3 11.3], 'LineStyle',':','Color','k','LineWidth',2);
    

    set(gca,'YLim',[min(min(effleft),min(effright)) max(max(effleft), max(effright))]);

    un = unique(effleft);
    if length(un) < 5
        for k = 1:length(un), t=text(min(find(effleft == un(k)))+5, un(k)+2, sprintf('%2.1f',un(k)));
            set(t,'FontWeight','bold','FontSize',14,'Color','r'); end;

        un = unique(effright);
        for k = 1:length(un), t=text(min(find(effright == un(k)))+5, un(k)+2, sprintf('%2.1f',un(k)));
            set(t,'FontWeight','bold','FontSize',14,'Color','r'); end;

    end;
else
    plot(1:length(tfreq), tfreq, '-k');

    un = unique(tfreq);
    for k = 1:length(un), t=text(min(find(tfreq == un(k)))+2, un(k)+2, sprintf('%2.1f',un(k)));
        set(t,'FontWeight','bold','FontSize',14,'Color','r'); end;
    set(gca,'YLim',[0 20]);
end;
ylabel('Tone frequency (kHz)');

s = sprintf('Tone frequency');
t = title(s); set(t,'FontSize',fsize);

% --- Bottom-left: Localization
subplot(3,2,5);


plot(1:length(goloc), goloc, '.g', 1:length(toneloc), toneloc, '-b');

mainfig = gcf;
if  (sum(toneloc) > 1 || sum(goloc) > 1)
    set(0,'CurrentFigure',mainfig);
    set(gca,'Color', 'y');
end;

set(gca, 'YLim', [-1 2], 'YTickLabel', {'', 'off', 'on', ''}, 'YTick', -1:1:2);
s = sprintf('Tone & GO Localisation');

t = title(s); set(t,'FontSize',f);

% --- Top-right: volume
d2 = DUR_DATE; if strcmpi(task(1:3),'dua'), d2 = PITCH_DATE; end;
subplot(3,2,2);
if older_data(date,d2) % || strcmpi(task(1:3),'dua')
    plot(1:length(gospl_left), gospl_left, '-g', 1:length(gospl_left),gospl_right,'.g');
    hold on;
    plot(1:length(gospl_left), tonevol_left, '.r',1:length(gospl_left), tonevol_right,'-b');
else
    plot(1:length(gospl), gospl, '.g');
    hold on;
    plot(1:length(tonevol), tonevol, '-r');
    if strcmpi(task(1:3),'dua') && ~isempty(find(gospl > 5)) ,
        f= get(0,'CurrentFigure');
        a=get(f,'CurrentAxes');
        set(gca,'Color','y');
    end;
end;
set(gca,'YLim',[0  85]);
ylabel('Volume in SPL');
s = sprintf('Tone & GO Volume');
t = title(s); set(t,'FontSize',14);

% --- Center-right: Vanilla on
subplot(3,2,4);
p=patch([0 0 length(vanilla_on) length(vanilla_on)], [2 5 5 2], [1 1 0.6]);
set(p,'EdgeColor','none');
hold on;
l = plot(1:length(vanilla_on), vanilla_on+3,'-r'); set(l,'Color',[1 0.7 0.7],'LineWidth',2);
text(10, 4.7, 'Sharpening flag');

l = plot(1:length(psych_on), psych_on,'-r'); set(l,'Color',[0.7 1 0.7],'LineWidth',2);
text(10, 1.7, 'Psych flag');

% --- Bottom-right: Blocks_switch on
if isfield(saved_history,'BlocksSection_Blocks_Switch')

    blocks = cell2mat(saved_history.BlocksSection_Blocks_Switch);
    p=patch([0 0 length(blocks) length(blocks)], [5 8 8 5], [0.8 0.8 0.9]);
    set(p,'EdgeColor','none');
    l=plot(1:length(blocks), blocks+6, '-b'); set(l,'LineWidth',2);

end;


line([1 length(vanilla_on)], [2 2],'Color', [0.5 0.5 0.5],'LineStyle',':');

set(gca, 'YLim', [-1 8], 'YTickLabel', {'off', 'on','off','on','off','on'}, 'YTick', ...
    [0 1 3 4 6 7]);

t = title(sprintf('Sharpening (PINK)\nPsych trials (GREEN) switches'));
set(t,'FontSize',fsize);

subplot(3,2,6);
%set(gca,'Position',[x_offset y_offset width height]);
l = plot(1:length(logdiff), logdiff,'.r'); set(l,'Color', [0.5 0 0.5]);
set(gca,'YLim',[0.2 1.2]);
t= title('Logdiff values');
set(t,'FontSize',fsize);
if (sum(vanilla_on(2:end)) == 0), set(gca,'Color',[0.5 0.5 0.5]); end;

set(gcf,'Tag','sessionview');

datacursormode on;


%%%%%%%%%%
% FIGURE 1b: Psychometric curve if there were psych trials
%%%%%%%%%%

if sum(psych_on) > 5,
    psychometric_curve(ratname, 0,'usedate', date);
    set(gcf,'Tag','sessionview');
end;

if toneprog_only > 0
    return;
end;

%%%%%%%%%%
% FIGURE 2: Silent periods
%%%%%%%%%%
figure;set(gcf,'Menubar','none','Toolbar','none','Name',['Silent ' ...
    'periods'],'Position',[ 59    11+h_offset   323   293]);
subplot(2,2,[1 2]);
plot(1:length(pre_cuemin), pre_cuemin, '.k', 1:length(pre_cuemin), ...
    pre_cuemax, '.b');
if isfield(saved_history,'VpdsSection_VPDSetPoint')
    hold on;
    l=plot(1:length(vpdset), vpdset, '-r');
    set(l,'LineWidth',2);
end;

ylabel('Silent period duration (s)');
set(gca,'YLim',[0 max(pre_cuemax)+0.2]);
s = sprintf('%s: %s (%s)\nInitial silent period', make_title(ratname), make_title(task), date);
t = title(s); set(t,'FontSize',fsize);

subplot(2,2,3);
hist(vpd);
t = title('VPD distr''n'); set(t,'FontSize',fsize);
set(gca,'XLim',[0 max(vpd)+0.2]); xlabel('VPD length (s)'); ylabel('# trials');

subplot(2,2,4);
plot(1:length(pre_gomin), pre_gomin, '.g', 1:length(pre_gomax), ...
    pre_gomax, '-r');
set(gca,'YLim',[0 0.4]);
if (sum([sum(pre_gomin(2:end)) sum(pre_gomax(2:end))]) > 0), set(gca,'Color','y');  end;

ylabel('Silent period duration (s)');
t = title('Post-cue silent period');set(t,'FontSize',fsize);

set(gcf,'Tag','sessionview');

datacursormode on;
%%%%%%%%%%%%%%%%%%%%
% FIGURE 3: Performance
%%%%%%%%%%%%%%%%%%%%
sessionperf(ratname, task, date);
set(gcf,'Position',[411     2+h_offset   597   400]);
set(gcf,'Tag','sessionview');
datacursormode on;

%%%%%%%%%%%%%%%%%%%%
% FIGURE 4: Penalty params
%%%%%%%%%%%%%%%%%%%%
figure;
% badboyspl
subplot(2,1,1);
set(gcf,'Position',[1082          10+h_offset         360         280] , 'Menubar', 'none','Toolbar','none')
plot(1:length(bb), bb, '.r');
ylabel('BadboySPL');
set(gca,'YTick', 1:3, 'YTickLabel', {'normal','Louder','LOUDEST'}, 'XLim', ...
    [1 max(2,length(bb))], 'YLim', [0 4]);
xlabel('Trial #');
s = sprintf('%s: %s (%s)\nBadBoySPL', make_title(ratname), make_title(task), date);
t = title(s); set(t,'FontSize',fsize);

% lprob
subplot(2,1,2);
lp = lprob(ratname, task, date, 'newfig', 0, 'from', 1);
if 0 && length(unique(lp)) > 2
    %warndlg('LProb is being changed!','LProb alert');
    set(gca,'Color','y');
end;

set(gcf,'Tag','sessionview');
datacursormode on;
%%%%%%%%%%%%%%%%%%%%
% FIGURE 5: Timeout
%%%%%%%%%%%%%%%%%%%%
%if strcmpi(task(1:3),'dur')
timeout_count(ratname,task,date);
set(gcf,'Position', [1020         550         350         304]);
set(gcf,'Tag','sessionview');
datacursormode on;
%end;

%%%%%%%%%%%%%%%%%%%%
% FIGURE 6: last_change
%%%%%%%%%%%%%%%%%%%
l=view_automation_progress(ratname, date);
mainfig =gcf;
if sum(l(1:end)) == 0, set(gca,'Color','y'); end;
set(0,'CurrentFigure',mainfig);
set(gcf,'Position', [1020         327        250  200],'Menubar','none','Toolbar','none');
set(gcf,'Tag','sessionview');
datacursormode on;

% d is in form yymmdd
function [is_older] = older_data(d,d2)
yy = str2double(d(1:2)) + 2000;
mm = str2double(d(3:4));
dd = str2double(d(5:6));
this_date = datenum(yy,mm,dd);
changed_spl_date = d2;

is_older = (this_date - changed_spl_date) < 0;
