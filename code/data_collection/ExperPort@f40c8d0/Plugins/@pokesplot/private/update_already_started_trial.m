% [] = update_already_started_trial(time, trialnum, parsed_events, latest_parsed_events, ...
%     my_state_colors, alignon, axpokesplot, (sph)trial_info, [spikenum==1]);
%
% 
% Uses latest_parsed_events to update the plot of a trial that was already
% initialized with initialize_trial.m.
%

function [] = update_already_started_trial(time, trialnum, parsed_events, latest_parsed_events, ...
  my_state_colors, alignon, axpokesplot, trial_info, spikenum);

%% alignment time
   if trial_info(trialnum).align_found == 0, % Not found align pt yet
     atime = find_align_time(value(alignon), parsed_events); % Give it a shot.
     if ~isnan(atime),
       %     We've found the first event in this trial of the class
       %       selected to align the trial to, therefore we must move all
       %       of the rectangles in the plot for this trial to the proper
       %       positions.
       delta = atime - trial_info(trialnum).align_time;  % newly found align pt! must deal w/it (there is align p already because default behavior on not finding is to use start time)
       trial_info(trialnum).align_time = atime;
       trial_info(trialnum).align_found = 1;
       % Now correct this trial's plot's x position:
       ghandles = trial_info(trialnum).ghandles; 
       for guys={'states' 'pokes'}
         fnames = fieldnames(ghandles.(guys{1})); 
         for i=1:length(fnames),
           gh = ghandles.(guys{1}).(fnames{i});
           for j=1:length(gh), set(gh(j), 'XData', get(gh(j), 'XData') - delta); end;
         end; % end fnames loop
       end; % end guys loop
       gh = ghandles.spikes;
       for j=1:length(gh), set(gh(j), 'XData', get(gh(j), 'XData') - delta); end;       
     end; % end if ~isnan
   end; % end if trial_info

   atime = trial_info(trialnum).align_time;

   % Height at which we're going to plot this trial:
   y0 = trialnum-0.45; y1 = trialnum+0.45;

   % Get all possible plottable names:
   %     This includes things like pokes.C, pokes.L,
   %       states.check_next_trial_ready, ...  i.e. all poke and state
   %       events.
   ghandles = trial_info(trialnum).ghandles;
   

   
%% states

   % ------------ NOW STATES ------------
   
   if isempty(latest_parsed_events.states.starting_state)  ||  ...                         % Either no events or no
       isempty(latest_parsed_events.states.(latest_parsed_events.states.starting_state)),  % state-changing events:
     currstat = parsed_events.states.ending_state;                                         % extend current state up to
     if isfield(ghandles.states, currstat) && ~isempty(ghandles.states.(currstat)) && ...  % current time
         ~isempty(parsed_events.states.(currstat)) && isnan(parsed_events.states.(currstat)(end,2)),
       xdata = get(ghandles.states.(currstat)(end), 'XData');
       set(ghandles.states.(currstat)(end), 'XData', [xdata(1:2) ; time*[1 1]'-atime]);
     end;
   end;
   
   snames   = fieldnames(my_state_colors.states);
   fillables_X = cell2struct(cell(size(snames)), snames, 1);
   fillables_Y = cell2struct(cell(size(snames)), snames, 1);
   fillables_C = cell2struct(cell(size(snames)), snames, 1);
   have_things_to_plot = 0; handle_owners = [];
   for i=1:length(snames),
     % If there is something for this plottable,
     if isfield(latest_parsed_events.states, snames{i}) && ~isempty(latest_parsed_events.states.(snames{i})),
       this_state = latest_parsed_events.states.(snames{i});
       % If the latest events don't tell us where the first patch should start:
       if isnan(this_state(1,1)),
         % If there was a previous existing patch, it's all explained-- we
         % complete it. But if no previous patch, don't know how to plot
         % this. We'll skip it
         if ~isempty(ghandles.states.(snames{i})),
           xdata = get(ghandles.states.(snames{i})(end), 'XData');
           set(ghandles.states.(snames{i})(end), 'XData', [xdata(1:2) ; this_state(1,2)*[1 1]'-atime]);
         end;
         % Ok, we've handled this entry, remove it from the list of entries:
         this_state = this_state(2:end,:);
       end;
       % Ok, now to entries that all have a well-defined starting time:
       for j=1:size(this_state,1),
         x0 = this_state(j,1); x1 = this_state(j,2); if isnan(x1), x1 = time; end;
         fillables_X.(snames{i}) = [fillables_X.(snames{i}) [x0 x0 x1 x1]' - atime];
         fillables_Y.(snames{i}) = [fillables_Y.(snames{i}) [y0 y1 y1 y0]'];
         fillables_C.(snames{i}) = my_state_colors.states.(snames{i});
         have_things_to_plot = 1; handle_owners = [handle_owners ; i];
       end;
     end;
   end;

   if have_things_to_plot,
     str = []; for i=1:length(snames),
       if ~isempty(fillables_X.(snames{i})),
         str = sprintf(['%s fillables_X.(snames{%d}), fillables_Y.(snames{%d}), ' ...
           'fillables_C.(snames{%d}),'], str, i, i, i);
       end;
     end;
     str = sprintf(['fill(%s ''HitTest'', ''off'', ''EdgeColor'', ''none'', ''Parent'', axpokesplot);'], str); % <~> added the HitTest 'off' entry here 2007.09.06 to make this gui object click-through (so that underlying object's callback executes instead when clicked (for pokesplot click script hook))
     hs = eval(str);
     for i=1:length(snames), ghandles.states.(snames{i}) = ...
       [ghandles.states.(snames{i}) ; hs(find(handle_owners==i))]; end;
   end;

%% pokes
   % ------------ NOW POKES ------------
   
   pokenames = fieldnames(latest_parsed_events.pokes.starting_state);
   for i=1:length(pokenames),
     switch pokenames{i}(1), case 'C', offset=0; case 'L', offset=0.3; case 'R', offset = -0.3; otherwise, offset=0; end;
     if  isempty(latest_parsed_events.pokes.(pokenames{i})) &&  ...    % If there are no changes in this poke
         strcmp(latest_parsed_events.pokes.starting_state.(pokenames{i}), 'in'), 
       if ~isempty(ghandles.pokes.(pokenames{i})),
         xdata = get(ghandles.pokes.(pokenames{i})(end), 'XData');
         set(ghandles.pokes.(pokenames{i})(end), 'XData', [xdata(1:end-1) time-atime]);
       else
         ghandles.pokes.(pokenames{i}) = ...
           line([trial_info(trialnum).start_time time]-atime, trialnum*[1 1]+offset, [1 1], ...
           'HitTest','off', ... % this line to make this gui object click-through (so that underlying object's callback executes instead when clicked (for pokesplot click script hook))
           'Parent', axpokesplot, 'LineWidth', 4, 'Color', my_state_colors.pokes.(pokenames{i}));
       end;
     elseif ~isempty(latest_parsed_events.pokes.(pokenames{i})), % There *are* changes in this poke in latest_parsed_events
       this_poke = latest_parsed_events.pokes.(pokenames{i});
       if isnan(this_poke(1,1))
         %     e.g. [NaN 2351.53] in ...pokes.C indicates that this
         %     event began before the period with which this
         %     update's latest_parsed_events is concerned.
         if ~isempty(ghandles.pokes.(pokenames{i})),
           xdata = get(ghandles.pokes.(pokenames{i})(end), 'XData');
           set(ghandles.pokes.(pokenames{i})(end), 'XData', [xdata(1:end-1) this_poke(1,2)-atime]);
         end;
         this_poke = this_poke(2:end,:);
       end;
% --- Both the next ways of doing this seem to take the same time; the first a wee bit faster, the second
% as used currently...
        if size(this_poke, 1)>0,
          x = this_poke; u = find(isnan(x(:,2))); if ~isempty(u), x(u,2)=time; end; 
          x = x-atime;
          x = [x NaN*ones(size(x,1),1)]; y = trialnum*ones(size(x))+offset; y(:,3) = NaN; z = ones(size(y)); z(:,3) = NaN; %#ok<AGROW>
          x = x'; x = x(:)'; y = y'; y = y(:)'; z = z'; z = z(:)';
          if isempty(ghandles.pokes.(pokenames{i})),
            ghandles.pokes.(pokenames{i}) = line(x(1:3), y(1:3), z(1:3), ...
              'HitTest','off', ... % this line to make this gui object click-through (so that underlying object's callback executes instead when clicked (for pokesplot click script hook))
              'Parent', axpokesplot, 'LineWidth', 4, 'Color', my_state_colors.pokes.(pokenames{i}));
            x = x(4:end); y = y(4:end); z = z(4:end);
          end;
          xdata = get(ghandles.pokes.(pokenames{i})(end), 'XData');
          ydata = get(ghandles.pokes.(pokenames{i})(end), 'YData');
          zdata = get(ghandles.pokes.(pokenames{i})(end), 'ZData');
          set(ghandles.pokes.(pokenames{i})(end), 'XData', [xdata x], 'YData', [ydata y], 'ZData', [zdata z]);
        end;
%       for j=1:size(this_poke,1), %     for each row (for each event)
%         x0 = this_poke(j,1); x1 = this_poke(j,2); if isnan(x1), x1 = time; end;
%         ghandles.pokes.(pokenames{i}) = [ghandles.pokes.(pokenames{i}) ; ...
%           line([x0 x1]-atime, trialnum*[1 1]+offset, [1 1], ...
%           'HitTest','off', ... % <~> added this line 2007.09.06 to make this gui object click-through (so that underlying object's callback executes instead when clicked (for pokesplot click script hook))
%           'Parent', axpokesplot, 'LineWidth', 4, 'Color', my_state_colors.pokes.(pokenames{i}))];
%       end; % end for       
% --- CDB       
     end; % end if isempty(latest_parsed_events.(pokenames{i})
   end;
   
%% spikes   
   % ------------ NOW SPIKES ------------

   if isfield(latest_parsed_events, 'spikes'),
     if iscell(latest_parsed_events.spikes)
       if nargin<9, spikenum = 1; end;
       if spikenum > length(latest_parsed_events.spikes), spikes = []; 
       else spikes = latest_parsed_events.spikes{spikenum};
       end;
     else
       spikes = latest_parsed_events.spikes;
     end;
     n = length(spikes);
     if n > 0, 
       x = [spikes(:) spikes(:)]-atime; x = [x NaN*ones(n,1)];
       y = [(trialnum-0.4)*ones(n,1) (trialnum+0.4)*ones(n,1) NaN*ones(n,1)];
       z = [2*ones(n,2) NaN*ones(n,1)];
       x = x'; x = x(:)'; y = y'; y = y(:)'; z = z'; z = z(:)';
       if isempty(ghandles.spikes)
         ghandles.spikes = line(x(1:3), y(1:3), z(1:3), 'HitTest','off', ...
           'Parent', axpokesplot, 'Color', my_state_colors.spikes);
         x = x(4:end); y = y(4:end); z = z(4:end);
       end;
       xdata = get(ghandles.spikes, 'XData');
       ydata = get(ghandles.spikes, 'YData');
       zdata = get(ghandles.spikes, 'ZData');
       set(ghandles.spikes, 'XData', [xdata x], 'YData', [ydata y], 'ZData', [zdata z]);
     end;
   end;


%%   
   trial_info(trialnum).ghandles = ghandles;

