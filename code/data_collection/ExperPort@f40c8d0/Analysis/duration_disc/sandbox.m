function [] = sandbox()

% REACTION TIME ANALYSIS %%%%%%%%%%%%%%%%%%%%%%%%%
% ratname = 'Boromir';
% ratrow = rat_task_table(ratname);
% prepsych = ratrow{1,4};
% % get psych before dates
%
% %rxn_time2(ratname,'from',prepsych{1}, 'to',prepsych{2});
% tone_rxntime(ratname,'from','070727', 'to','070728','psych_only',1,'separate_hit_miss',1);
%
% 2;


% REACTION TIME ANALYSIS: Premature couts.
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ratname = 'Denethor';
% date = '070815a';
%
% p=get_pstruct(ratname,date);
% load_datafile(ratname,date);
% rts = saved_history.duration_discobj_RealTimeStates;
% evs = saved_history.duration_discobj_LastTrialEvents;
% if rows(rts) == rows(evs)+1, rts = rts(1:end-1);end;
%
% [rxn] = rxn_time(p,'inc_premature_couts',1,'rts', rts);
% %rxn = rxn(140:150);
% figure;
% plot(1:length(rxn),rxn, '.b');
% title(sprintf('%s (%s):Reaction time', ratname, date));
%
% load sig_struct;
% Boromir = sig_struct.Boromir;
% tones = Boromir{3}.hit; tones = tones*1000;
% rxns = Boromir{4}.hit;
% tone_bins = Boromir{1}.hit;
% rxn_bins = Boromir{2}.hit;
%
% [x idx] = sort(tones);
%
% figure;
% l=plot(tones(idx), rxns(idx), '.r');
% set(l, 'Color',[0.7 0.7 0.7]);
% hold on;
% l=errorbar(tone_bins*1000, rxn_bins(:,1),rxn_bins(:,2),
% rxn_bins(:,2),'.r');
%
% xlabel('Tone duration (ms)');
% ylabel('Reaction time (s)');
% [rxn dropped_idx cpoke_array dropped_bobs too_many_bobs bob_trial is_bob] = rxn_time(get_pstruct('Boromir','070728a'));
%
% zidx = find(rxn == 0);
% is_bob(zidx)



% % % Analysis:
% % % Why does my special logistic fit only fit a few days of Hare's pre-psych
% % % session?
% % % - I feed it the smallest and highest pct point in replong ./tally and it
% % % fits only these dates:
% % bins= [   5.2983    5.3982    5.5013    5.6021    5.7071    5.8081    5.9081    6.0113    6.1137];
% %
% % superimpose_psychs('Hare','use_dateset','psych_before');
% % close all;
% % betalist = [];
% % good = [];
% % scr = get(0,'ScreenSize');
% % scrh = scr(4); scrw=scr(3);
% % w=300; h =250;x=20;y=80;
% % badctr=0; maxbad=8;
% % xbad = 350; ybad =80;
% % good_tally = []; % # trials on good days
% % bad_tally = [];
% % shorttr_tally=[];
% % for r=1:length(psychdates) % [3 4 8 17] are good
% %         [out1 out2 out3 out4] = nlinfit_sandbox('init',dates{psychdates(r)}, pooled_replong(r,:), pooled_tally(r,:));
% %         betalist = vertcat(betalist, [out1 out2]);
% %         if out3 > 0
% %             good = horzcat(good, psychdates(r));
% %             set(gcf,'Position',[x y w h],'Toolbar','none');
% %             y = y+h; if y > scrh, y = 100; x = x+w; end;
% %             good_tally=horzcat(good_tally, sum(pooled_tally(r,:)));
% %         else
% %             set(gca,'XLim',[5 7]);
% %             set(gcf,'Position',[xbad ybad w h],'Toolbar','none','Color',[0.3 0.3 0.3]);
% %             ybad = ybad+h; if ybad > scrh, ybad = 100; xbad = xbad+w; end;
% %             badctr = badctr+1;
% %             if badctr > maxbad
% %                 close gcf;
% %             end;
% %             bad_tally = horzcat(bad_tally, sum(pooled_tally(r,:)));
% %         end;
% % %         l=plot(bins, pooled_replong(r,:)./pooled_tally(r,:), '.g'); set(l,'MarkerSize',20);
% % %             set(gcf,'Position',[xbad ybad w h],'Toolbar','none','Color',[0 0.3 0]);
% % %             ybad = ybad+h; if ybad > scrh, ybad = 100; xbad = xbad+w; end;
% % %       shorttr_tally = horzcat(shorttr_tally, sum(pooled_tally(r,:)));
% % end;
% %
% % psychd = dates(good);
% % fprintf(1,'Good dates\n');
% % psychd
% % 2;

% figure;
% subplot(1,2,1); hist(good_tally); title('good tally');
% subplot(1,2,2); hist(bad_tally); title('bad tally');

% % Look at learning over time.
%  ratlist = rat_task_table('','action','get_pitch_psych','area_filter','ACx');
%
%  figure;
%  for r = 1:length(ratlist)
%      ratname = ratlist{r};
%      fprintf(1,'%s...\n',ratname);
% %     learning_over_sessions(ratname,'use_dateset', 'span_surgery','first_few',3,'psych_only',0);
% [cb ca] = psych_proportion(ratname);
% cb, ca
%
% end

%   ratlist =  rat_task_table('','action','get_pitch_psych','area_filter','ACx');
%   for r=1:length(ratlist)
%       ratname=ratlist{r};
%       surgery_effect(ratname, 'psychgraph_only',1, 'days_after',[1 5], 'lastfew_before',5);
%       set(gcf,'Tag','blahblah');
%   end;

% ratname = 'Evenstar';
% d = '071014';
% datafields = {'pitch_psych','pitch_low','sides','pitch_high',...
%     'pitch_tonedurL','pitch_tonedurR','tone_spl', 'events','Tone_Loc','GO_Loc'};
% get_fields(ratname,'from',d,'to',d, 'datafields',datafields);
%
% % make tones list
% left = find(sides == 1);
% right = find(sides == 0);
%
% tones = size(hit_history);
% tones(left) = pitch_low(left);
% tones(right) = pitch_high(right);
%
% idx= find(pitch_psych> 0);
% sc = side_choice(hit_history, sides);
%
% sc_idx= sc(idx);
% hh = hit_history(idx);
% sl = sides(idx);
% tones = tones(idx);
%
% figure;
% plot(1:length(sc_idx), sc_idx,'-k');
%
%
% hold on;
% hits = find(hh >0); misses = find(hh == 0);
% sl = sl  +2;
%
% left = find(sl == 1+2); right = find(sl == 0+2);
%
% % plot sides/hit plot on top of side choice plot
% % Left at Y = 3; Right  at Y = 2.
% % Hits are green, misses are red.
% tmp = intersect(left,hits);
% plot(tmp, ones(size(tmp))*3, '.g');
% tmp = intersect(left, misses);
% plot(tmp, ones(size(tmp))*3, '.r');
% tmp = intersect(right,hits);
% plot(tmp, ones(size(tmp))*2, '.g');
% tmp = intersect(right,misses);
% plot(tmp, ones(size(tmp))*2, '.r');
%
% left_spl = tone_spl(find(sides > 0));
% right_spl = tone_spl(find(sides == 0));
% %overlap_hists(left_spl,right_spl);
%
%
% little_tones = find(tones < 9); % little tones
% right4little = intersect(find(sc_idx == 0), little_tones);
% plot(right4little, ones(size(right4little))*4, 'vb');
%
% set(gca,'YLim',[-1 +5], 'YTick', [0 1 2 3], 'YTickLabel', {'Went RIGHT','Went LEFT', 'RIGHT','LEFT'});
% title(sprintf('%s on %s',ratname, d));
% set(gcf,'Position',[200 200 1000 300]);


%  % plot residuals
%         figure;
%         ratcolour={};
%         fnames = fieldnames(allrat_residuals);
%         for idx = 1:length(fnames)
%             curr_c = rand(1,3);
%             currat = fnames{idx};
%             eval(['ratcolour.' currat ' = curr_c;']);
%             curr_res = eval(['allrat_residuals.' currat ';']);
%             l=plot(1:length(curr_res), curr_res,'.b');hold on;
%             l2 = plot(1:length(curr_res), curr_res,'-b');
%             hold on;
%             set(l,'Color',curr_c);
%             set(l2,'Color',curr_c);
%         end;
%
%               % map colours to rats
%         figure;set(gcf,'Position',[1200 100 100 500]);
%         fnames = fieldnames(ratcolour);
%         for idx=1:length(fnames)
%             t=text(1, idx, fnames{idx});
%             set(t,'Color', eval(['ratcolour.' fnames{idx}]) ,'FontWeight','bold','FontSize',12);
%
%             t=title('Rat colours');
%             set(t,'FontWeight','bold','FontSize',14);
%             set(gca,'XLim',[0.5 1.5],'YLim',[0 length(fnames)+1]);
%         end;
%
% %
%
% array_name = 'pitch_basic';
% area_filter = 'MGB';
%
% %ratlist = rat_task_table('','action',['get_' array_name],'area_filter',area_filter);
%
% ratlist = {'Isildur','Gaffer','Proudfoot','Elrond'};
% for r= 1:length(ratlist)
%     ratname = ratlist{r};
%   %  surgery_effect(ratname,'psychgraph_only',1);
%   surgery_effect_fixedlog(ratname,'brief_title',1);
%   %  uicontrol('Tag', 'fname', 'Style','text', 'String', ratname, 'Visible','off');
%     set(gcf,'Tag', 'blah');
% end;
% function [] = overlap_hists(x1,x2)
%
% hist(x2);
% p=findobj(gca,'Type','patch'); set(p,'FaceColor', [1 0 0],'EdgeColor',[1 0 0],'facealpha',0.75);
% hold on;
% hist(x1);
% p=findobj(gca,'Type','patch');
% set(p,'facealpha',0.25, 'EdgeColor','none');
%
% global Solo_datadir;
% outdir = [Solo_datadir filesep 'Data' filesep 'Shraddha' filesep];
% fname = [outdir 'ACx_curve_sigs'];
% load(fname);
%
%
% dur = duration_curve_diffs;
% fnames =fieldnames(dur);
% buffer = [];
% for idx =1:length(fnames)
%     curr = fnames{idx};
%     buffer = horzcat(buffer, eval(['dur.' curr '(2)']));
% end;
%
% dur = pitch_curve_diffs;
% fnames =fieldnames(dur);
% buffer2 = [];
% for idx =1:length(fnames)
%     curr = fnames{idx};
%     buffer2 = horzcat(buffer2, eval(['dur.' curr '(2)']));
% end;
%
% figure;
% l=plot(ones(5,1), buffer,'.r');
% set(l,'Color',[1 0.5 0],'MarkerSize',20);
% hold on;
% l=plot(ones(5,1)*2, buffer2,'.r');
% set(l,'Color',[0.8 0 1],'MarkerSize',20);
%
% set(gca,'XTick',[ 1 2], 'XLim', [0.5 2.5],'FontSize',20,'FontWeight','bold');
% set(gca,'XTickLabel',{'Duration','Pitch'});
% set(get(gca,'XLabel'),'FontSize',20,'FontWeight','bold');
% ylabel('p-value');
% set(get(gca,'YLabel'),'FontSize',20,'FontWeight','bold');
% line([0 3], [0.05 0.05], 'LineStyle',':','Color','k','LineWidth',2);
%
% uicontrol('Tag', 'figname', 'Style','text', 'String', 'ACx_curve_sigs', 'Visible','off');

% ratlist = {'S002','S006','S008','Adler','Hudson','Boscombe','Grimesby'};
% for r=1:length(ratlist)
%     fprintf(1,'****************** %s\n', ratlist{r});
%     showprogress2final(ratlist{r},'action','save');
% end;
%
% ratlist = {'Watson','Sherlock','Shelob','Wraith','Shadowfax'};
% for r = 1:length(ratlist)
%     fprintf(1,'****************** %s\n', ratlist{r});
%     savepsychinfo(ratlist{r},'action','before');
%     savepsychinfo(ratlist{r},'action','after');
% end;

% x =2:5:17;
% y = 1:4;
% m = sub__getslope(x,y)
% m2 = sub__getslope(x*m, y)
%
% function slope= sub__getslope(x,y)
% slope = (y(2)-y(1)) /(x(2)-x(1));

%   'Bilbo' ,   'p',
%   {'070329','070417'},{'070427','070517'},{'070530','070702'},    0,{}, {}; ...
% loadpsychinfo('Bilbo','infile','psych_before','justgetdata',1,...
%     'dstart', 3,'dend', 6);


% 2;
% %   'Treebeard','d',    {'070828','999999'},{'070913','071002'},{'071009','071019'},    0,{}, {'070730','070827'}; ...
% loadpsychinfo('Sauron','infile','psych_before', 'justgetdata',0);
% 2;

% this section runs hit rates spanning surgery for all rats in a given
% area/task group and then tests to see if first day post is outside SD of
% pre averages
% if 0
%     area_filter = 'mPFC';
%     ratlist = rat_task_table('','action','get_duration_psych','area_filter',area_filter);
%
%     if 0
%         for r = 1:length(ratlist)
%             ratname = ratlist{r};
%             learning_over_sessions(ratname, 'use_dateset','span_surgery');
%         end;
%         saveps_figures;
%         close all;
%     end;
%     first_day_outlier_test(ratlist,'brainarea', area_filter);
% end;
%
% % gets psychometric curves for the first two days of a rats' post data
% if 0
%     ratlist = {'Celeborn'};
%
%     for r = 1:length(ratlist)
%         ratname = ratlist{r};
%         ratrow = rat_task_table(ratname, 'action','get_ratrow');
%         postrange = ratrow{1,rat_task_table('','action','get_postpsych_col')};
%         2;
%         firstday = postrange{1};
%         psychometric_curve(ratname, 0,'usedate', [firstday 'a']);
% uicontrol('Tag', 'figname', 'Style','text', 'String',[ratname '_postday1'], 'Visible','off');
%         secondday = [firstday(1:4) num2str(str2double(firstday(5:6))+1)];
%               psychometric_curve(ratname, 0,'usedate', [secondday 'a']);
%    uicontrol('Tag', 'figname', 'Style','text', 'String',[ratname '_postday2'], 'Visible','off');
%
%     end;
% end;
%
%
% x=sub__stim_at(xx,yy, 0.5)
% x= xx(x)
%
% function [stim] = sub__stim_at(x,y, pt)
% if min(y) > pt || max(y) < pt % you're asking for a point that isn't on the curve
%     stim=-1;
%     return;
% end;
%
% stim = find(abs(y - pt) == min(abs(y-pt)));

% a = get(gca,'Children');
% for num = 1:length(a)
%     if ~strcmpi(get(a(num),'Type'), 'text')
%     x = get(a(num), 'XData');
%     if length(x) > 40
%         xx = x;
%         yy = get(a(num),'YData');
%
%         x75 = xx(sub__stim_at(xx,yy,0.75));
%         x25 = xx(sub__stim_at(xx,yy,0.25));
%         x50 = xx(sub__stim_at(xx,yy,0.5));
%
% %         minx = min(xx);
% %         text(1.01*minx, 0.28, sprintf('x=%i ms',round(exp(x25))),'FontSize',18','FontAngle','italic','FontWeight','bold');
% %         text(minx*1.01, 0.78, sprintf('x=%i ms',round(exp(x75))),'FontSize',18','FontAngle','italic','FontWeight','bold');
% %
% %         line([x50 x50], [0 1], 'LineStyle',':','Color','r','LineWidth',2);
% %
% %         line([x25 x25], [0 0.25], 'LineStyle',':','Color','k','LineWidth',2);
% %         line([0 x25],[0.25 0.25], 'LineStyle',':','Color','k','LineWidth',2);
% %         line([x75 x75], [0 0.75], 'LineStyle',':','Color','k','LineWidth',2);
% %                 line([0 x75],[0.75 0.75], 'LineStyle',':','Color','k','LineWidth',2);
%       %  weber=(2^(x75) - 2^(x25))/(2^(x50))
%         weber=(exp(x75) - exp(x25))/(exp(x50))
% %         set(gca,'YTick', 0:0.25:1, 'YTickLabel',0:25:100);
%     end;
%     end;
% end;


% % mPFC --------------------------------------------------------------------
% ratlist = {'Sherlock','Shadowfax','Moria','Evenstar'};
% sub__plot_hitrate('mPFC-lesioned frequency','mpfc_freq',ratlist);
%
% ratlist = {'Celeborn','Wraith','Shelob','Nazgul','Hudson'};
% sub__plot_hitrate('mPFC-lesioned duration','mpfc_dur',ratlist);
%
% function [] = sub__plot_hitrate(figtitle, figsuffix, ratlist)
% first_few = 3;
% use_dateset='span_surgery';
%
%
% [fig1 fig2] = plot_hitrate(ratlist,'use_dateset',use_dateset,'first_few',first_few,'figtitle', figtitle,'plot_means',1);
% set(0,'CurrentFigure',fig1);
% uicontrol('Tag', 'figname', 'Style','text', 'String', ['hitrate_' figsuffix], 'Visible','off');
% set(0,'CurrentFigure',fig2);
% uicontrol('Tag', 'figname', 'Style','text', 'String', ['hitrate_diff_' figsuffix], 'Visible','off');
%

%  psych_tally(ratname, 'psych_before');
% psych_tally(ratname, 'psych_after');

% for r = 1:length(ratname)
%     learning_over_sessions(ratname{r}, 'use_dateset', 'span_surgery', 'first_few', 7);
% end;


% saveps_figures;

%load_datafile('Evenstar','071023a');

%ratname ='Shadowfax';
%date='080106a';
% ratname = 'Grimesby';
% date='080331a';
%ratname = 'Watson';
%date='080111a';

% load_datafile(ratname,date);
% p = cell2mat(saved_history.BlocksSection_Blocks_Switch);
%
% minbon = min(find(p > 0));
%
% fprintf(1,'Blocks on from # %i\n', minbon);
% t1 = saved.ChordSection_tone1_list; t2= saved.ChordSection_tone2_list;
% figure;
%
% sidx = minbon;
% eidx = minbon+50;
%
% plot(t1(sidx:eidx), '.b');
% hold on;
% l=plot(t2(sidx:eidx), '*k');
% set(l,'MarkerSize', 20);
% legend({'tones1', 'tones2'});
% title(sprintf('%s: %s', ratname,date));
%
% set(gca,'YLim',[-0.2 1]);


% durlist = { 'S002', 'S005', 'S007', 'S019', 'S018','S014'};
% freqlist = { 'S008','S013','S016','S015','S017','S020'};
% wildlist = {'Stark','Rucastle','Cushing'};
% wildlist = {'S009','S010'};
%
% ratlist = wildlist;
% for k = 1:length(ratlist)
%     try
%        % psychometric_curve(ratlist{k}, -1);
%        psychnums_over_time(ratlist{k},'from','080601','to','999999','mkover',1);
%     catch
%         fprintf(1,'No psych curve for %s\n', ratlist{k});
%     end;
% end;
% 
% ratlist = {'Lucius', 'S002', 'S005', 'S014','S007','S019','S009','S008','S020','S013','S017','S016','S015','S011','S012'};
% 
% 
% %timeout_multiplerats(ratlist, '080301','080310','savedata', 1,'loaddata',0,'infile', 'timeout_March')
% %sessionduration(ratlist, -3)
% global Solo_datadir;
% indir = [Solo_datadir filesep 'Data' filesep 'Shraddha' filesep 'Set_Analysis' filesep];
% load([indir 'pitch_psych_mPFC_psychdata_LAST7FIRST3PSYCH.mat']);
% 
% ratlist = fieldnames(rat_before);
% 
% figwd = 400; fight = 330;
% currx = 10; curry= 200;
% for r = 1:length(ratlist)
%     ratname = ratlist{r};
%     bef = eval(['rat_before.' ratname ';']);
% 
%     f=figure;
%     sub__plotpsych(ratname, bef, 'b',f);
% 
%     aft = eval(['rat_after.' ratname ';']);
%     sub__plotpsych(ratname, aft, 'r', f);
% 
%     
%     set(f,'Position',[currx curry figwd fight]);
%     currx = currx+figwd;
% end;
% 
% 
% function [] = sub__plotpsych(ratname, data, clr, fig)
% ratrow = rat_task_table(ratname);
% task = ratrow{1,2};
% 
% firstdate = data.dates; firstdate = firstdate{1};
% if strcmpi(task, 'dual_discobj'),
%     pitch = 1;
%     mm = firstdate(3:4);
%     yy = firstdate(1:2);
%     if (str2double(yy) < 8) && (str2double(mm) < 29)
%         [l h] = calc_pair('p',11.31,1.4);
%     else
%         [l h]= calc_pair('p',11.31,1);
%     end;
%     binmin =l;
%     binmax =h;
%     mybase = 2;
%     unittxt='kHz';
%     unitfmt = '%2.1f';
%     roundmult  = 10;
%     logt = 'log2(';
% elseif strcmpi(task, 'duration_discobj'),
%     pitch = 0;
%     [l h]= calc_pair('d',sqrt(200*500),0.95);
%     binmin =l;
%     binmax =h;
%     mybase = exp(1);
%     unittxt = 'ms';
%     unitfmt = '%i';
%     roundmult = 1;
%     logt = 'log(';
% end;
% 
% myf = {'dates', 'ltone', 'rtone','hit_history', 'numtrials', 'psych_on', ...
%     'slist','binmin','binmax'};
% 
% in = 0; % input struct for psych_oversessions
% for k = 1:length(myf)
%     eval(['in.' myf{k} ' = data.' myf{k} ';']);
% end;
% 
% tmp = in.ltone;
% in.flipped = zeros(size(tmp)); % none of the rats in this set had flipped stimuli
% 
% % out = psych_oversessions(ratname, in, 'pitch', pitch, 'noplot',1);
% % 
% % set(0,'CurrentFigure', fig);
% % if strcmpi(ratname,'Gandalf')
% %     2;
% % end;
% % plot(out.xx, out.yy, '.b', 'Color', clr,'LineWidth',2);
% % hold on;
% 
% plot(data.xx, data.yy,'-b', 'Color', clr,'LineWidth',2);
% hold on;
% 
% notempty = find(data.replongs(:,1) ~= -1);
% replongs = data.replongs(notempty,:);
% tallies = data.tallies(notempty,:);
% 
% bins = data.bins;
% mybins = eval([ logt 'bins);']);
% pct__right = replongs ./ tallies;
% if rows(replongs) > 1
% sumpct_right = sum(replongs) ./ sum(tallies);
% else
%     sumpct_right = replongs ./ tallies;
% end;
% pctavg = nanmean(pct__right);
% pctstd = nanstd(pct__right);
% for k = 1:length(pctstd)
% %    line([mybins(k) mybins(k)],[pctavg(k)-pctstd(k) pctavg(k)+pctstd(k)], 'Color', clr, 'LineWidth',2);
% end;
% plot(mybins, sumpct_right, 'ob', 'Color', clr,'LineWidth',2,'MarkerSize', 10);
% 
% % formatting of axis, labels etc
% miniaxis = [bins(1), sqrt(binmin*binmax) bins(end)];
% if pitch > 0
%     hist__lblfmt = '%1.1f';
%     hist__xlbl = 'Bins of frequencies (kHz)';
%     psych__xtick = log2(miniaxis);
%     psych__xlbl = 'Tone frequency (kHz)';
% 
%     psych__ylbl = 'frequency of reporting "High" (%)';
%     txtform =  '[%1.1f,%1.1f] kHz';
%     unittxt = 'kHz';
%     roundmult = 10;
%     log_mp = log2(sqrt(binmin*binmax));
% else
%     hist__lblfmt='%i';
%     hist__xlbl = 'Bins of durations (ms)';
%     psych__xtick = log(miniaxis);
%     psych__xlbl = 'Tone duration (ms)';
%     psych__ylbl = 'frequency of reporting "Long" (%)';
%     txtform =  '[%i,%i] ms';
%     log_mp = log(sqrt(binmin*binmax));
%     roundmult = 1;
% end;
% 
% xlim=[mybins(1) mybins(end)];
% mymin = round(binmin*roundmult)/roundmult;
% mymax=round(binmax*roundmult)/roundmult;
% psych__xtklbl = round(miniaxis * roundmult)/roundmult;
% 
%       set(gca,'XTick',psych__xtick,'XLim', xlim, 'XTickLabel', psych__xtklbl, ...
%             'YTick',0:0.25:1, 'YTickLabel', 0:25:100, 'YLim',[0 1], ...
%             'FontSize',18,'FontWeight','bold');
%         xlabel(psych__xlbl);
%         ylabel(psych__ylbl);
% title(ratname);

% ntfrc = 1:5;
% n2m = zeros(1,5);
% %drctn = '-';rrobin = length(ntfrc)
% drctn = '+';rrobin = 1
% 
% curr = [];
% myrr = [];
% for k = 1:(length(ntfrc)*3)-2
%     n2m(ntfrc(rrobin)) = n2m(ntfrc(rrobin))+1;    
%             
%             curr = horzcat(curr, rrobin);
%             rrobin = eval(['mod(rrobin' drctn '1,length(ntfrc))']);
%             if rrobin == 0, rrobin = length(ntfrc); end;
%             myrr = horzcat(myrr, rrobin);
% end;
% 
% vertcat(curr, myrr)

% global Solo_datadir;
% ratname = 'Gandalf';
% histodir = [Solo_datadir filesep 'Data' filesep 'Shraddha' filesep 'Histo' filesep 'ACx' filesep];
% indir = [histodir ratname filesep];
% 
% % 1 -- load raw polygon coordinates
% infile = [indir  ratname '_coords.mat'];
% try
%     load(infile);
% catch
%     error('Error *** !\nCheck ratname: **%s**\nCheck fname: **%s**\n', ratname, infile);
% end;
% 
% clear lesion_coords;
% 
% % 2 -- now load interpolated
% infile = [indir  ratname '_interpolcoords.mat'];
% load(infile);
% 
% if 0 
% save(infile, 'lesion_coords', 'coord_set','zvals', ...
%     'V','xorig','yorig','zorig', ...
%     'VI','xlims','ylims','zlims', ...
%     'offsetx','offsety');
% end;

%function [cpokes lpokes rpokes] = pokes_during_iti(pstruct)
%
% Given the output of Analysis/parse_trial.m (pstruct), 
% returns the number of pokes made during ITIs.
% Specifically, it returns the center pokes, left pokes and right pokes
% (each in a separate structure), made during the following RealTimeStates:
% * iti
% * dead_time
% * extra_iti
% Output:
%   Three cell arrays of identical structure, one for each type of poke.
%   There is a row for every trial, which contains the array of start and
%   endtimes of the particular pokes during the trial.
%
% e.g. [cpokes lpokes rpokes] pokes_during_iti(pstruct)
% >> cpokes{5}
% ans =
% 
%   780.4855  781.4078
%   783.1033  783.5067
%   791.4746  791.7648
%   793.2047  793.4459
%   795.5236  795.7657

% 
% ratname ='S014';
% salset=[];
% dset ={'080804a'}; for d = 1:length(dset), [w b] =psychometric_curve(ratname,dset{d},'nodist',1); salset = horzcat(salset, b(1)); end;
% muscset=[];
% dset={'080818a','080821a','080825a','080828a'}; for d = 1:length(dset), [w b] =psychometric_curve(ratname,dset{d},'nodist',1); muscset = horzcat(muscset, b(1)); end;
% %
% 2;

  x = mvnrnd([0;0], [1 .9;.9 1], 100);
       y = [1 1;1 -1;-1 1;-1 -1];
       mahal(y,x)

% pstruct = get_pstruct(xx,yy);
% 
% cpokes = cell(0,0);
% lpokes = cell(0,0);
% rpokes = cell(0,0);
% 
% for k = 1:rows(pstruct)
%     temp_c = []; temp_r = []; temp_l = [];
%     
%     for itir = 1:rows(pstruct{k}.cue)
%         [tc, tl, tr] = sub__cpoke_mini(pstruct{k}, pstruct{k}.cue(itir,1), pstruct{k}.cue(itir,2));
%         if rows(tc) > 1
%             2;
%         end;
%         temp_c = [temp_c; tc]; temp_l = [temp_l; tl]; temp_r = [temp_r; tr];
%     end;
%     cpokes{k} = temp_c; lpokes{k} = temp_l; rpokes{k} = temp_r;
% end;
% 
% function [outrow_c outrow_l outrow_r] = sub__cpoke_mini(minip, st_time, fin_time)
% conditions = {'in', 'after', st_time};
% conditions(2,1:3) = {'out', 'before', fin_time};
% outrow_c = get_pokes_fancy(minip, 'center', conditions, 'all');
% outrow_l = get_pokes_fancy(minip, 'left', conditions, 'all');
% outrow_r = get_pokes_fancy(minip, 'right', conditions, 'all');

