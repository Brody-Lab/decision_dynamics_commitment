function [output_txt] = show_all_logdiffs(rat, sc, varargin)
  
  pairs = { 'action', 'plot_me'; ...
            'show_distance', 0; ...
          'todate',  '999999' ; ... 
          };
  parse_knownargs(varargin, pairs);
  
  persistent logdiffs_start;
  persistent logdiffs_end;
  persistent lowest_logdiff;
  persistent t1_start;
  persistent t1_end;
  persistent min_t1;
   persistent t2_start;
  persistent t2_end;
  persistent min_t2;
  
  
% Shows the progression of logdiffs across the entire training step of
% perceptual boundary sharpening.
  
% Plots 2 graphs: 1. The starting logdiff as a function of day 2. The
% difference between the logdiffs at the start and end of the session

switch action,
  
 case 'plot_me',
  
   logdiffs_start = []; logdiffs_end = []; lowest_logdiff = [];
  t1_start = []; t1_end = []; min_t1 = [];
  t2_start = []; t2_end = []; min_t2 = [];

  
ddir = Shraddha_filepath(rat, 'd');
data = dir(ddir);

breaks = [];
pd = cell(0,0);
dts = cell(0,0);
caps = cell(0,0);

prevdate = '';
for f = 1:length(data)
  fname = data(f).name;
  if length(fname) > 3 & strcmp(fname(1:4), 'data')
    dt = fname(end-10:end-5);
    
    if (str2num(dt) >= str2num(sc)) & (str2num(dt) <= str2num(todate))
      load([ddir fname]);
      t1 = cell2mat(saved_history.ChordSection_Tone_Dur1);
      t2 = cell2mat(saved_history.ChordSection_Tone_Dur2);
      ls =cell2mat(saved_history.ChordSection_logdiff);
      logdiffs_start = [logdiffs_start ls(2)];
      
      t1_start = [t1_start t1(2)*1000]; t2_start = [t2_start t2(2)* 1000];
      t1_end = [t1_end t1(end)*1000]; t2_end = [t2_end t2(end)*1000];
        
        minidx = find(ls == min(ls));
        min_t1 = [min_t1 t1(minidx(1))*1000]; min_t2 = [min_t2 ...
                            t2(minidx(1))*1000];
      
      logdiffs_end = [logdiffs_end ls(end)];
      lowest_logdiff = [lowest_logdiff min(ls)];
      
      pd{end+1} = prevdate; dts{end+1} = dt;
      caps{end+1} = [ dt(4) '/' dt(5:6) fname(end-4)];
      if str2num(dt) - str2num(prevdate) > 1
        breaks = [breaks 1];
      else
        breaks = [breaks 0];
      end;
      prevdate = dt;
      
    end;
  end;
end;


figure;
set(gcf,'Menubar','none','Toolbar','none', 'Position', [200 200 1000 400]);


% Plot of logdiffs at start of session
subplot(2,1,1);
if show_distance > 0
  tmp = t2_start-t1_start;
  currl = plot(1:length(tmp), tmp, '.b');
   set(currl, 'Tag', 'session_start','MarkerSize', 12);
  hold on; 
  currl = plot(1:length(t1_end), t2_end-t1_end,'.r');
  set(currl,'Tag','session_end', 'MarkerSize', 12);
  line([0 length(t1_end)], [200 200], 'LineStyle', '-.', 'Color',[0 0.4 0])
 
  for k = 1:length(caps)
  text(k, tmp(k)+50, caps{k}, 'Color', 'b');
end;
else  
currl= plot(1:length(logdiffs_start), logdiffs_start, '.b');
set(currl, 'Tag','session_start','MarkerSize', 12); hold on;
currl = plot(1:length(logdiffs_end), logdiffs_end, '.r');
set(currl,'Tag', 'session_end', 'MarkerSize', 12);

for k = 1:length(caps)
  text(k, logdiffs_start(k)+0.1, caps{k}, 'Color', 'b');
end;
end;

if show_distance > 0, ext = 'Distance'; extent = [0 500]; 
   fprintf(1,'Avg/Std Distance end: %ims, %ims\n', rnd(mean(t2_end-t1_end)), ...
       rnd(std(t2_end-t1_end))); 
else ext= 'Log-distance'; extent = [0 1];  
    fprintf(1,'Avg/Std logdiff end: %1.2f, %1.2f\n', mean(logdiffs_end), std(logdiffs_end));
end;
   

set(gca,'XTick',[], 'YLim', 1.1*extent);
title([rat 'Session START (blue) and END (red) values: Pair ' ext]);

bdays = find(breaks > 0);
for k = 1:length(bdays)
  line([bdays(k)-0.5 bdays(k)], extent, 'LineStyle', '--', 'Color', 'k');
end;

% Plot of overall difference in logdiff during session
subplot(2,1,2);
if show_distance > 0
  tmp = (t2_start-t1_start) - (t2_end-t1_end);
  currl = plot(1:length(tmp), tmp, '.r');
  set(currl,'Tag', 'session_progress', 'MarkerSize', 12);
   for k = 1:length(bdays)
      line([bdays(k)-0.5 bdays(k)], [-200 200], 'LineStyle', '--', 'Color', ...
           'k');
   end;
set(gca,'XTick',[]); % 'YTick', [-200:50:200], 'YLim', [-200 200]);
else
tmp = logdiffs_start - logdiffs_end;
currl = plot(1:length(logdiffs_start), tmp, '.r');
 set(currl,'Tag', 'session_progress','MarkerSize', 12);

for k = 1:length(bdays)
  line([bdays(k)-0.5 bdays(k)], [-0.2 0.5], 'LineStyle', '--', 'Color', 'k');
end;
set(gca,'XTick',[], 'YTick', [-0.2:0.1:0.4], 'YLim', [-0.2 0.5]);
end;

for k = 1:length(caps)
  text(k, tmp(k)+0.05, caps{k}, 'Color', 'b');
end;

title([rat ': Difference between START and END of a session']);

datacursormode on;
dcm_obj = datacursormode(gcf);
set(dcm_obj, 'SnapToDataVertex', 'on', 'DisplayStyle','datatip');
set(dcm_obj, 'Updatefcn', {@show_all_logdiffs,'action', 'update_me'});


% Plot 3: Plot start pair & drop as a function of day
figure;
set(gcf,'Menubar','none','Toolbar','none','Position', [910 420 430 350]);
tmp = t2_start-t1_start;
currl= plot3(1:length(t1_start), tmp, tmp-(t2_end-t1_end),'.b', ...
             1:length(t1_start), tmp, tmp-(t2_end-t1_end),'-r'); 
set(currl, 'Tag', 'drop_fn_start', 'MarkerSize', 12);
grid on;
xlabel('Session #');
ylabel('Start pair distance');
zlabel('Drop distance');
title([rat ': Drop as a function of starting pair distance']);
datacursormode on;
dcm_obj = datacursormode(gcf);
set(dcm_obj, 'SnapToDataVertex', 'on', 'DisplayStyle','datatip');
set(dcm_obj, 'Updatefcn', {@show_all_logdiffs,'action', 'update_me'});

 case 'update_me',
 
  evt_obj = sc;
   line_caller = get(evt_obj,'Target');
  pos = get(evt_obj, 'Position');
%  t1_start(pos(1)) t2_start(pos(1))
  

 if strcmp(get(line_caller,'Tag'), 'session_progress')
   output_txt = sprintf('FROM: (%ims, %ims) -- %i ms \nTO: (%ims, %ims) -- %ims', ...
                        rnd(t1_start(pos(1))), rnd(t2_start(pos(1))), rnd(t2_start(pos(1))-t1_start(pos(1))), ...
                        rnd(t1_end(pos(1))), rnd(t2_end(pos(1))), rnd(t2_end(pos(1))-t1_end(pos(1))));
 elseif strcmp(get(line_caller,'Tag'),'session_end');
   output_txt =  sprintf('Low: %ims\n High: %ims (%1.1f)', rnd(t1_end(pos(1))), ...
                        rnd(t2_end(pos(1))), logdiffs_end(pos(1)));
 elseif strcmpi(get(line_caller,'Tag'),'drop_fn_start')
   output_txt = sprintf('Start: %ims, %ims\n Drop = %i ms', rnd(t1_start(pos(1))), ...
                        rnd(t2_start(pos(1))),...
                        rnd((t2_start(pos(1))-t1_start(pos(1)))-(t2_end(pos(1))-t1_end(pos(1)))) );
 else
   output_txt =  sprintf('Low: %ims\n High: %ims (%1.1f)', rnd(t1_start(pos(1))), ...
                        rnd(t2_start(pos(1))), logdiffs_start(pos(1)));
  end;
  
 otherwise
  error(['Actions can only be either ''plot_me'' or ''update_me''; nothing else!']);

end;



function [num] = rnd(num)
  num = round(num / 10) * 10;