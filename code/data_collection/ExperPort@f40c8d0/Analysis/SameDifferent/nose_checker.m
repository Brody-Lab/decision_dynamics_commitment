function [v, b, d, h] = nose_checker(ratname, daterange, varargin)
% [v, b, d, h] = nose_checker(ratname, daterange, varargin)
% pairs = { ...
%   'experimenter'   'Carlos'  ; ...
%   'tau'    30  ; ...
%   'doplot'  1  ; ...
%   'usedb'   1  ; ...
%   'show_c2sgap' 0 ; ...
%   'show_nose_in_center'  1 ; ...
%   'show_fixed_stim_dur'  0 ; ...
%   'show_c2sgap_rate'     0 ; ...
%   'show_temp_pun'        0 ; ...
% }; parseargs(varargin, pairs);


results = struct('hith', [], 'smhith', [], 'non_v', [], ...
  'smnon_v', [], 'nic', [], 'fsd', [], 'rt', [], 'mt', [], 'wspt', [], 'cbreaks', []);

pairs = { ...
  'experimenter'   'Carlos'  ; ...
  'tau'    30  ; ...
  'doplot'  1  ; ...
  'usedb'   1  ; ...
  'show_c2sgap' 0 ; ...
  'show_nose_in_center'  1 ; ...
  'show_fixed_stim_dur'  0 ; ...
  'show_c2sgap_rate'     0 ; ...
  'show_temp_pun'        0 ; ...
}; parseargs(varargin, pairs);

if usedb && show_temp_pun,
  error('sorry, to show_temp_pun I need usedb=0');
end;

d = 0.5; v = []; b = []; g = []; f = []; hh = []; 
cg = []; tp = []; rt = []; cb = {}; mt = []; wspt = [];
if usedb,
  if ischar(daterange),
    date_str = ['sessiondate="' daterange '"'];
  else
    if length(daterange) == 1,
      startdate= bdata(['select date_sub("' datestr(now,29) '" , interval ' num2str(-1*daterange) ' day)']);
      enddate  = bdata(['select date_sub("' datestr(now,29) '" , interval ' num2str(0) ' day)']);
    else
      startdate= bdata(['select date_sub("' datestr(now,29) '" , interval ' num2str(-1*daterange(1)) ' day)']);
      enddate  = bdata(['select date_sub("' datestr(now,29) '" , interval ' num2str(-1*daterange(end)) ' day)'])  
    end    
    date_str = ['sessiondate>="' startdate{1} '" and sessiondate<= "' enddate{1} '"'];
  end
  [sessid]=bdata(['select sessid from sessions where ratname="' ratname '" and ' date_str]);

else
  data = recall(ratname, experimenter, {'ProtocolsSection_parsed_events' ; 'nose_in_center' ; 'C2SGap$' ; 'fixed_stim_dur' ; 'hit_history' ; 'TempPunDur1$'}, ...
    'history', 1, 'daterange', daterange, 'protocol', 'SameDifferent');
  usessid = ones(1, size(data,1));
end;

if usedb, lstr = sprintf('%d, ', sessid); lstr = lstr(1:end-2);
  [allpd, allpdsessids] = bdata(['select protocol_data,sessid from sessions where sessid in  (' lstr ')']);
    
  [allpevsh, allvh, allgaph, allfsdh, allhith, allsessid] = bdata(['select ProtocolsSection_parsed_events,StimulusSection_nose_in_center,StimulusSection_C2SGap,StimulusSection_fixed_stim_dur,SoundTableSection_T1HitFrac,p.sessid from protocol.SameDifferent as p where p.sessid in (' lstr ')']) ;
  usessid = unique(allsessid);
end;

for i=1:numel(usessid)
  if usedb,
    sessid = usessid(i); myguys = (sessid==allsessid);
    pevsh = allpevsh(myguys); vh = allvh(myguys); gaph = allgaph(myguys); fsdh = allfsdh(myguys); hith = allhith(myguys);
    
    % [pevsh, vh, gaph, fsdh, hith] = bdata(['select ProtocolsSection_parsed_events,StimulusSection_nose_in_center,StimulusSection_C2SGap,StimulusSection_fixed_stim_dur,SoundTableSection_T1HitFrac from protocol.SameDifferent as p where p.sessid="' num2str(sessid(i)) '"']);
   % pd = bdata(['select protocol_data from sessions where sessid= "' num2str(sessid(i)) '"']);
   myguys = (sessid==allpdsessids);
   pd = allpd(myguys);
   if ~strcmp(pd, 'NULL'), if isfield(pd{1}, 'hits'), hith = pd{1}.hits; end; end;
    % fprintf(1, 'Got sessid %g, %d/%d\n', sessid(i), i, numel(sessid));
    drawnow;
  else
    sessid = usessid(i); %#ok<NASGU> % not really used here
    pevsh = data{i,1,1};
    vh    = cell2mat(data{i,1,2});
    gaph  = cell2mat(data{i,1,3});    
    if show_fixed_stim_dur, fsdh  = cell2mat(data{i,1,4}); end;
    hith  = cell2mat(data{i,1,5})';    
    th    = cell2mat(data{i,1,6});
  end;

  pevsh = pevsh(6:end); vh = vh(6:end); gaph = gaph(6:end); 
  if show_fixed_stim_dur, fsdh = fsdh(6:end); end; 
  hith = hith(6:end);
  if show_temp_pun, th = th(6:end); end;
  
  rth   = zeros(size(pevsh)); mth = zeros(size(pevsh)); 
  wspth = zeros(size(pevsh)); cbh = cell(size(pevsh));
  for j=1:numel(rth),
    if usedb, temp = pevsh{j}{1}; else temp = pevsh{j}; end;
    if ~isempty(temp.states.cpoke1) && isempty(temp.states.violation_state)
      if     ~isempty(temp.states.wait_for_spoke),    answert = temp.states.wait_for_spoke(end,2);
      elseif ~isempty(temp.states.center_2_side_gap), answert = temp.states.center_2_side_gap(end,2);
      else                                            answert = temp.states.cpoke1(end,2);                                
      end;
      u = find(temp.pokes.C(:,1)<answert, 1, 'last'); % last cpoke in before answer
      rth(j) = temp.pokes.C(u,2)-temp.states.cpoke1(end,2); % end of that cpoke is beginning of motion to answer
      mth(j) = answert - temp.pokes.C(u,2); % answer - end of last cpoke is movement time.
      
      if ~isempty(temp.states.wait_for_spoke), wspth(j) = diff(temp.states.wait_for_spoke(end,:)); else wspth(j) = 0; end;
      
      u = find(temp.states.cpoke1(end,1) < temp.pokes.C(:,2) & temp.pokes.C(:,2) < temp.states.cpoke1(end,2));
      u = u(u<size(temp.pokes.C,1));
      if isempty(u), cbh{j} = 0; 
      else           cbh{j} = temp.pokes.C(u+1,1) - temp.pokes.C(u,2);
      end;
    else
      hith(j)  = NaN;
      rth(j)   = NaN;
      mth(j)   = NaN;
      wspth(j) = NaN;
      cbh{j}   = NaN;
    end;      
  end;
    
  d  = [d  d(end)+numel(pevsh)]; %#ok<AGROW>
  v  = [v  ; vh(1:end-1)];    % nose_in_center  
  g  = [g  ; gaph];  % C2SGap
  if show_fixed_stim_dur, f  = [f  ; fsdh(1:end-1)]; end; % fixed_stim_dur
  hh = [hh ; hith];  % hits
  rt = [rt ; rth];
  mt = [mt ; mth];
  cb = [cb ; cbh];
  wspt = [wspt ; wspth];
  if show_temp_pun, tp = [tp ; th]; end;    % temp_pun
    
  for n = 1:numel(pevsh),
    if usedb,
      if rows(pevsh{n}{1}.states.cpoke1)>1, b = [b ; 0];
      else                                  b = [b ; 1];
      end;

      if rows(pevsh{n}{1}.states.center_2_side_gap)>1, cg = [cg ; 0];
      else                                             cg = [cg ; 1];
      end;
    else
      if rows(pevsh{n}.states.cpoke1)>1, b = [b ; 0];
      else                               b = [b ; 1];
      end;

      if rows(pevsh{n}.states.center_2_side_gap)>1, cg = [cg ; 0];
      else                                          cg = [cg ; 1];
      end;
    end;
  end;
end;

% hh(isnan(hh))=0;
t  = (1:numel(b))'; %#ok<NASGU>
sb  = zeros(size(b));
scg = zeros(size(cg)); 
sh  = zeros(size(hh));

results.hith    = hh;
results.nic     = v;
results.fsd     = f;
results.rt      = rt;
results.mt      = mt;
results.wspt    = wspt;
results.non_v   = b;
results.cbreaks = cb;


for i=1:numel(b),
  x = 1:i;
  
  kernel = exp(-(i-t(1:i))/tau);
  kernel = kernel / sum(kernel);
  
  sb(i)  = sum(b(x).*kernel);
  u = find(~isnan(hh(x)));
  sh(i)  = sum(hh(x(u)).*kernel(u))/sum(kernel(u));  
  scg(i) = sum(cg(x).*kernel);
end;
b  = sb;
hh = sh;
cg = scg;

results.smnon_v = b;
results.smhith  = hh;

if doplot,
  drawnow; fig=figure; clf; drawnow; 
  nplots = show_c2sgap+show_nose_in_center+show_fixed_stim_dur+show_c2sgap_rate+2+show_temp_pun;
  figure(fig);
  
  subplot(nplots,1,1); plot(hh); drawnow;
  ylim([0.5 1]);
  h = line([d ; d], get(gca, 'YLim')'*ones(1, length(d)));
  set(h, 'Color', 'k');
  title('hit_history', 'Interpreter', 'none');
  set(gca, 'YGrid', 'on');
  
  subplot(nplots,1,2); plot(b, '.-'); drawnow; 
  h = line([d ; d], get(gca, 'YLim')'*ones(1, length(d)));
  set(h, 'Color', 'k');
  title('non-violation rate', 'Interpreter', 'none');
  set(gca, 'YGrid', 'on');
  ylim([0.5 1]);

  plots_made = 2;
  
  if show_nose_in_center,
    plots_made = plots_made+1;
    subplot(nplots,1,plots_made); plot(v); drawnow;
    h = line([d ; d], get(gca, 'YLim')'*ones(1, length(d)));
    set(h, 'Color', 'k');
    set(gca, 'YGrid', 'on');
    title('nose_in_center', 'Interpreter', 'none');
  end;
  
  if show_c2sgap,
    plots_made = plots_made+1;
    subplot(nplots,1,plots_made); plot(g); drawnow;
    h = line([d ; d], get(gca, 'YLim')'*ones(1, length(d)));
    set(h, 'Color', 'k');
    set(gca, 'YGrid', 'on');
    title('C2SGap', 'Interpreter', 'none');
  end;

  if show_fixed_stim_dur,
    plots_made = plots_made+1;
    subplot(nplots,1,plots_made); plot(f); drawnow;
    h = line([d ; d], get(gca, 'YLim')'*ones(1, length(d)));
    set(h, 'Color', 'k');
    set(gca, 'YGrid', 'on');
    title('fixed_stim_dur', 'Interpreter', 'none');
  end;
  
  if show_c2sgap_rate,
    plots_made = plots_made+1;
    subplot(nplots,1,plots_made); plot(cg, '.-'); drawnow;
    h = line([d ; d], get(gca, 'YLim')'*ones(1, length(d)));
    set(h, 'Color', 'k');
    title('C2SGap violation rate', 'Interpreter', 'none');
    set(gca, 'YGrid', 'on');
    ylim([0.5 1]);
  end;

  if show_temp_pun,
    plots_made = plots_made+1;
    subplot(nplots,1,plots_made); plot(tp, '-'); drawnow;
    h = line([d ; d], get(gca, 'YLim')'*ones(1, length(d)));
    set(h, 'Color', 'k');
    set(gca, 'YGrid', 'on');
    title('temp pun', 'Interpreter', 'none');
  end;

  set(gcf, 'Name', ratname);
  drawnow;
end;

if nargout == 1, v = results; end;


  
