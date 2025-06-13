

function [x, y] = TrialsSection(obj, action, x, y, varargin)

beta= []; % hack
GetSoloFunctionArgs(obj);

trial_attributes = {'pprob', 'side', 'wtr_mul', 'target1', 'target2'};
pre_attributes   = {'hitfrac', 'accfrac', 'posterior'};

switch action
   %% case init
   case 'init',
      gui_width = gui_position('get_width');
      SoloParamHandle(obj, 'my_gui_info', 'value', [x y double(gcf)], 'saveable', 0);
      
      ToggleParam(obj, 'showhide', 1, x, y, 'OnString', 'Showing Trials List', ...
         'OffString', 'Hiding Trials List'); next_row(y);
      set_callback(showhide, {mfilename, 'showhide'});   %#ok<NODEF>
         
         % Create our own figure window
         SoloParamHandle(obj, 'myfig', 'value', ...
            figure('Name', 'Trials Section', 'CloseRequestFcn', [mfilename '(' class(obj) ', ''hide'')'], ...
            'MenuBar', 'none'), ...
            'saveable', 0);
         gui_position('set_width', 120);
         figure(value(myfig));
         myx = 10; myy = 10;
         SoloParamHandle(obj, 'my_window_info', 'value', [myx, myy, value(myfig)], 'saveable', 0);
      
         SoloParamHandle(obj, 'existing_nClasses', 'value', 0, 'saveable', 0); 
         NumeditParam(obj, 'nClasses', 0, myx, myy, 'HorizontalAlignment', 'center'); next_column(myx);
         set_callback_on_load(nClasses, 1); %#ok<NODEF>
         set_callback(nClasses, {mfilename, 'nClasses'}); %#ok<NODEF>
         NumeditParam(obj, 'MaxSame', Inf, myx, myy, 'HorizontalAlignment', 'center', ...
            'TooltipString', sprintf('\nMax number of trials on same side before other side is forced.')); 
         next_column(myx);
         normalize = []; % hack because of Matlab bug; this var will be overriden by SoloParamHandle below
         PushbuttonParam(obj, 'normalize', myx, myy, 'label', 'normalize prob'); next_column(myx);
         set_callback(normalize, {mfilename, 'normalize'});
         HeaderParam(obj, 'valid_prob', 'P is normalized', myx, myy, 'position', [myx, myy, 140 20], ...
            'HorizontalAlignment', 'center'); myx = myx+140;
         set(get_ghandle(valid_prob), 'BackgroundColor', [0 0.7 0]);
         next_row(myy); myx = 10;
         
         HeaderParam(obj, 'HitfracHeader', 'hitfrac', myx, myy, 'position', [myx myy 68 20], ...
            'HorizontalAlignment', 'center'); myx = myx+72;
         HeaderParam(obj, 'AccfracHeader', 'accfrac', myx, myy, 'position', [myx myy 68 20], ...
            'HorizontalAlignment', 'center'); myx = myx+72;
         HeaderParam(obj, 'PosteriorHeader', 'posterior', myx, myy, 'position', [myx myy 68 20], ...
            'HorizontalAlignment', 'center'); myx = myx+70;
         next_row(myy); myx = 10;
         NumeditParam(obj, 'tau', 40, myx, myy, 'position', [myx myy 70 20], 'labelfraction', 0.4, ...
            'TooltipString', sprintf('\n# of trials over which exponential window weights responses for hitfrac')); myx=myx+70;
         NumeditParam(obj, 'beta', 4, myx, myy, 'position', [myx myy 70 20], 'labelfraction', 0.4, ...
            'TooltipString', sprintf('\nantibias beta')); myx=myx+70;         
         NumeditParam(obj, 'accweight', 1, myx, myy, 'position', [myx myy 100 20], 'labelfraction', 0.65, ...
            'TooltipString', sprintf(['\nweight that accfrac will have, relative to hitfrac, ' ...
            'for antibias purposes.\nA value of 0 means ignore accfrac, use only hitfrac. A value much ' ...
            'higher than 1 means ignore hitfrac, use only accfrac.'])); myx=myx+100;         
         NumeditParam(obj, 'minstart', 20, myx, myy, 'position', [myx myy 100 20], 'labelfraction', 0.5, ...
            'TooltipString', sprintf('\nMinimum # of trials that must have elapsed before antibias kicks in')); myx=myx+70;         
         
      % Return to the main figure window;   
      figure(my_gui_info(3));
      gui_position('set_width', gui_width);        
      
      ToggleParam(obj, 'nTargets', 1, x, y, 'OffString', '1 target sound', ...
         'OnString', '2 target sounds'); next_row(y);
      set_callback(nTargets, {mfilename, 'nTargets'});
      
      % Sound anchor times and delays:
      MenuParam(obj, 't1_on_anchor', {'Cin', 'Cout', 'Sin'}, 1, x, y, ...
         'position', [x, y, 150, 20], 'label', 'ON1 anchor', 'labelfraction', 0.5); 
      NumeditParam(obj, 't1_on_delay', 0, x, y, 'position', [x+150 y 50 20], ...
         'HorizontalAlignment', 'center', 'labelfraction', 0.1, 'TooltipString', sprintf(['\n Time in secs ' ...
         'after the anchor moment at which sound will start']));
      next_row(y);
      MenuParam(obj, 't1_off_anchor', {'Cin', 'Cout', 'Sin'}, 1, x, y, ...
         'position', [x, y, 150, 20], 'label', 'OFF1 anchor', 'labelfraction', 0.5); 
      NumeditParam(obj, 't1_off_delay', 0, x, y, 'position', [x+150 y 50 20], ...
         'HorizontalAlignment', 'center', 'labelfraction', 0.1, 'TooltipString', sprintf(['\n Time in secs ' ...
         'after the anchor moment at which sound will stop']));
      next_row(y, 1.5);
      
      
      MenuParam(obj, 't2_on_anchor', {'Cin', 'Cout', 'Sin'}, 1, x, y, ...
         'position', [x, y, 150, 20], 'label', 'ON2 anchor', 'labelfraction', 0.5); 
      NumeditParam(obj, 't2_on_delay', 0, x, y, 'position', [x+150 y 50 20], ...
         'HorizontalAlignment', 'center', 'labelfraction', 0.1, 'TooltipString', sprintf(['\n Time in secs ' ...
         'after the anchor moment at which sound will start']));
      next_row(y);
      %%% 'SndON' not yet functional, so remove it from menu
%       MenuParam(obj, 't2_off_anchor', {'Cin', 'SndON', 'Cout', 'Sin'}, 1, x, y, ...
%          'position', [x, y, 150, 20], 'label', 'OFF2 anchor', 'labelfraction', 0.5); 
      MenuParam(obj, 't2_off_anchor', {'Cin', 'Cout', 'Sin'}, 1, x, y, ...
         'position', [x, y, 150, 20], 'label', 'OFF2 anchor', 'labelfraction', 0.5); 
      NumeditParam(obj, 't2_off_delay', 0, x, y, 'position', [x+150 y 50 20], ...
         'HorizontalAlignment', 'center', 'labelfraction', 0.1, 'TooltipString', sprintf(['\n Time in secs ' ...
         'after the anchor moment at which sound will stop']));
      next_row(y, 1.5);
      
      MenuParam(obj, 'side_lights', {'pro' 'anti' 'none'}, 1, x, y, ...
         'TooltipString', sprintf('\nLights to indicate appropriate response')); next_row(y);
      NumeditParam(obj, 'lights_delay', 0.05, x, y, 'position', [x y 115 20], 'labelfraction', 0.6, ...
         'TooltipString', sprintf('\nDelay between Cout and side lights on'));
      NumeditParam(obj, 'rw_delay', 0.6, x, y, 'position', [x+110 y 90 20], 'labelfraction', 0.6, ...
         'TooltipString', sprintf('\nDelay between correct response and water delivery')); next_row(y);

      nClasses.value = 1; callback(nClasses);
      
      SoloFunctionAddVars('SMASection', 'ro_args', {'nClasses', 'nTargets', ...
         't1_on_anchor', 't1_on_delay', 't1_off_anchor', 't1_off_delay', ...
         't2_on_anchor', 't2_on_delay', 't2_off_anchor', 't2_off_delay', ...
         'side_lights', 'lights_delay', 'rw_delay'});
      
      
   %% case nClasses
   case 'nClasses',
      if nClasses > existing_nClasses,        %#ok<NODEF>
         % If asking for more classes than exist, make them:
         orig_fig = double(gcf); 
         my_window_visibility = get(my_window_info(3), 'Visible');
         x = my_window_info(1); y = my_window_info(2); figure(my_window_info(3));
         set(my_window_info(3), 'Visible', my_window_visibility);
         
         next_row(y, 1+ value(existing_nClasses));
                 
         newvars = cell(nClasses - existing_nClasses, numel(trial_attributes));
         move({HitfracHeader, AccfracHeader PosteriorHeader, tau, beta, accweight, minstart}, ...
            0, 20*(nClasses - existing_nClasses));
         for newnum = (existing_nClasses + 1):value(nClasses),
            for i=1:numel(pre_attributes),
               DispParam(obj, ['class_' num2str(newnum) '_' pre_attributes{i}], 1, x, y, ...
                  'position', [x, y, 70, 20], 'labelfraction', 0.05);
               set(get_lhandle(eval(['class_' num2str(newnum) '_' pre_attributes{i}])), 'Visible', 'off'); 
               x= x+70;
            end;
            HeaderParam(obj, ['class_' num2str(newnum) '_header'], ['Class ' num2str(newnum)], x, y, ...
               'position', [x y 70 20]); x = x+70;
            for i=1:numel(trial_attributes),
               if     ismember(trial_attributes{i}, {'pprob', 'wtr_mul'}),   width = 100; frac = 0.5; def=1; 
               elseif ismember(trial_attributes{i}, {'side'}),               width = 80;  frac = 0.6; def='r';
               elseif ismember(trial_attributes{i}, {'target1', 'target2'}), width = 80;  frac = 0.6; def=1;                    
               end;
               if strcmp(trial_attributes{i}, 'side'), func = 'EditParam'; else func = 'NumeditParam'; end;
               feval(func, obj, ['class_' num2str(newnum) '_' trial_attributes{i}], def, x, y, ...
                     'position', [x y width 20], 'labelfraction', frac, 'label', trial_attributes{i}, ...
                     'HorizontalAlignment', 'center'); 
               newvars{newnum-existing_nClasses, i} = ['class_' num2str(newnum) '_' trial_attributes{i}]; 
               x = x+width;
               sph = eval(['class_' num2str(newnum) '_' trial_attributes{i}]);
               set_callback(sph, {mfilename, trial_attributes{i}, i}); 
               set(get_ghandle(sph), 'HorizontalAlignment', 'center');
            end;
            next_row(y); x = my_window_info(1);
         end;
         SoloFunctionAddVars('SMASection', 'ro_args', newvars(:));
         existing_nClasses.value = value(nClasses);
         figure(orig_fig);
         
      elseif nClasses < existing_nClasses,
         % If asking for fewer vars than exist, delete excess:
         trial_attributes_expanded = [trial_attributes pre_attributes];
         for oldnum = (nClasses+1):value(existing_nClasses);
            delete(eval(['class_' num2str(oldnum) '_header']));
            for i=1:numel(trial_attributes_expanded),
               sphname = ['class_' num2str(oldnum) '_' trial_attributes_expanded{i}];
               delete(eval(sphname));
            end;
         end;
         move({HitfracHeader, AccfracHeader, PosteriorHeader, tau, beta, accweight, minstart}, 0, 20*(nClasses - existing_nClasses));
         existing_nClasses.value = value(nClasses);
      end;
      
      % Now check for whether we are in the middle of load settings or load
      % data.
      
      varhandles = {};
      for i = 1:value(nClasses), 
         for j=1:numel(trial_attributes),            
            varhandles = [varhandles ; {eval(['class_' num2str(i) '_' trial_attributes{j}])}]; %#ok<AGROW>
         end;
      end;
      load_solouiparamvalues(obj, 'ratname', 'rescan_during_load', varhandles);

      
      feval(mfilename, obj, 'check_normalization');
      feval(mfilename, obj, 'nTargets');
      
      % If we can, let's send a change_nClasses message to SidesSection:
      % ---
      try
         feval('SidesSection', obj, 'change_nClasses');
      catch ME
         warning(ME.identifier, '%s couldn''t run SidesSection(%s, ''change_nClasses''), got error "%s"\n', ...
            mfilename, class(obj), ME.message);
      end;
      % -----

   %% check_normalization
   case 'check_normalization'
      totp = 0; 
      for i=1:value(nClasses), %#ok<NODEF>
         totp = totp + eval(['class_' num2str(i) '_pprob']);
      end;
      if totp ~= 1, x=0; set(get_ghandle(valid_prob), 'BackgroundColor', [1 0 0], 'String', 'P is not normalized');
      else          x=1; set(get_ghandle(valid_prob), 'BackgroundColor', [0 0.7 0], 'String', 'P is normalized');
      end;         
      
   %% normalize
   case 'normalize'
      totp = 0; 
      % First sum probs
      for i=1:value(nClasses), %#ok<NODEF>
         totp = totp + eval(['class_' num2str(i) '_pprob']);
      end;
      
      if totp == 0, return; end; % can't normalize if they add to zero!
      
      % Now normalize them, to three decimals to avoid funny
      % Matlab rounding errors
      new_totp = 0;
      for i=1:value(nClasses), 
         sph = eval(['class_' num2str(i) '_pprob']);
         sph.value = floor(1000*sph/totp)/1000; % guaranteed to be under
         new_totp = new_totp + sph;
      end;
      new_totp = round(10000*new_totp)/10000; % Make sure we're working to one decimal place
      
      % Then tot up if needed. Try to find a non-zero entry to add in the
      % tot-up.
      if nClasses > 0 && new_totp ~= 1,
         i=1;
         sph = eval(['class_' num2str(i) '_pprob']);
         while sph==0 && i<=nClasses, 
            i=i+1; 
            sph = eval(['class_' num2str(i) '_pprob']);
         end;
         if sph ~= 0, sph.value = sph + 1-new_totp; end;
      end;

      feval(mfilename, obj, 'check_normalization');
      
   %% case check_targets
   case 'check_targets'
      if isa(obj, 'clickstable'),
         nSounds = ClicksTableSection(obj, 'get', 'nSounds');
         for i=1:value(nClasses); %#ok<NODEF>
            t1sph = eval(['class_' num2str(i) '_target1']);
            t2sph = eval(['class_' num2str(i) '_target2']);
      
            if t1sph < 1, t1sph.value = 1; elseif t1sph > nSounds, t1sph.value = nSounds; end;
            if t2sph < 1, t2sph.value = 1; elseif t2sph > nSounds, t2sph.value = nSounds; end;
         end;
      end;

         
   %% case pprob
   case 'pprob'
      feval(mfilename, obj, 'check_normalization');
      
      
   %% case update_posterior
   case 'update_posterior'
            
      if n_done_trials==0, % No need to compute anything yet if we haven't done any trials.
         for i=1:value(nClasses), %#ok<NODEF>
            sp = eval(['class_' num2str(i) '_posterior']); sp.value = value(eval(['class_' num2str(i) '_pprob']));
         end;
         return;
      end;

      start_trial = max(floor(n_done_trials-3*tau), 1);
      kern_base = (start_trial : n_done_trials)';
      kern_fact = exp(-(n_done_trials - kern_base)/tau);
      kern_fact = kern_fact./sum(kern_fact);
      
      % Let's make an "accepted_trials" matrix; same shape as
      % rejected_trials (namely, n_done_trials by nClasses), with 1s
      % wherever he completed a cpoke, and 0s elsewhere. This is the same
      % info as in the vector trialclass_history, but will be a convenient
      % format for us.     
      accepted_trials = false(n_done_trials, value(nClasses));%#ok<NODEF>
      for i=1:value(nClasses)
         accepted_trials(:,i) = (trialclass_history==i);
      end;
      
      % For each class, find all trials with that trialclass; use the kernel on 
      % those trials alone to get the average hitfrac
      for i=1:value(nClasses), 
         u = accepted_trials(kern_base,i);
         if ~isempty(find(u,1)),
            mykern_fact = kern_fact(u); mykern_fact = mykern_fact/sum(mykern_fact);
            hitfrac = eval(['class_' num2str(i) '_hitfrac']);
            hitfrac.value = sum(mykern_fact .* hit_history(kern_base(u)));
         end;
      end;
      
      % Now find the fraction of accepted trials of each class, and
      % average. Weight the kernel by number of cpokes of that class at
      % each trial.
      tot = (accepted_trials + rejected_trials);
      accept_frac = accepted_trials./tot;
      tot = tot(kern_base,:); accept_frac = accept_frac(kern_base,:);
      for i=1:value(nClasses), 
         u = (tot(:,i)>0); % find trials where attempts of this class were made
         if ~isempty(find(u,1)),
            mykern_fact = kern_fact(u).*tot(u,i); % weight the kernel by number of attempts
            mykern_fact = mykern_fact/sum(mykern_fact);
            accfrac = eval(['class_' num2str(i) '_accfrac']);
            accfrac.value = sum(mykern_fact .* accept_frac(u,i));
         end;
      end;
      
      % Now use MaxSame and other rules to go from prior to posterior
      
      priors = zeros(value(nClasses), 1); sides = zeros(value(nClasses), 1);
      for i=1:value(nClasses),
         sp = eval(['class_' num2str(i) '_pprob']); priors(i) = value(sp);
         sp = eval(['class_' num2str(i) '_side']);  sides(i)  = value(sp);
      end;
      
      if n_done_trials >= MaxSame, % MaxSame rule may apply
         if all(sides_history(n_done_trials-MaxSame+1:n_done_trials)==sides_history(n_done_trials)), % if we've done MaxSame trials on one side
            if any(sides~=sides_history(n_done_trials) & priors>0), % and there are non-zero prob candidates on the other side
               priors(sides==sides_history(n_done_trials))=0; % set to zero those classes with the side most recently done
               priors = priors/sum(priors); % and normalize
            end
         end;
      end;
      
      % OK, now determine posterior
      if n_done_trials < minstart, % if fewer than minstart trials, just use prior prob
         posterior = priors;
      else % we want to use the antibias calculation
         combined_frac = zeros(value(nClasses), 1);
         for i=1:value(nClasses),
            accfrac = eval(['class_' num2str(i) '_accfrac']);
            hitfrac = eval(['class_' num2str(i) '_hitfrac']);            
            combined_frac(i) = (accfrac*accweight + hitfrac)/(accweight + 1);
         end;
         
         posterior = probabilistic_trial_selector(combined_frac, priors, value(beta));      
      end;

      for i=1:value(nClasses),
         sp = eval(['class_' num2str(i) '_posterior']); sp.value = posterior(i);
      end;
      
      
   %% case nTargets   
   case 'nTargets'
      if nTargets==0,
         for i=1:value(nClasses), %#ok<NODEF>
            sph = eval(['class_' num2str(i) '_target2']);
            disable(sph);
         end;
         disable({t2_on_anchor;t2_on_delay;t2_off_anchor;t2_off_delay});
         
      else
         for i=1:value(nClasses), %#ok<NODEF>
            sph = eval(['class_' num2str(i) '_target2']);
            enable(sph);
         end;         
         enable({t2_on_anchor;t2_on_delay;t2_off_anchor;t2_off_delay});
      end;
      
   %% case set
   case 'set'
      if strcmp(x, 'nClasses'),
         nClasses.value = y;
         callback(nClasses);
         return;
      elseif strcmp(x, 'all_pprobs'),
         if numel(y)==nClasses, %#ok<NODEF>
            for i=1:value(nClasses),
               sp = eval(['class_' num2str(i) '_pprob']);
               sp.value = y(i);
            end;            
         else
            warning('TrialsSection:BadFormat', 'Couldn''t set all_pprobs, vector passed was not right length');
         end;
      end;

      check_targets_flag = 0;
      % repackage x and y into varargin so we're always working with
      % triples of "class_num, attribute, value"
      varargin = [{x y} varargin];
      while numel(varargin)>=3,
         if isnumeric(varargin{1}) && ismember(varargin{2}, trial_attributes),
            if varargin{1}>=1 && varargin{1}<=nClasses, 
               sph = eval(['class_' num2str(varargin{1}) '_' varargin{2}]);
               sph.value = varargin{3};
               if ismember(varargin{2}, {'target1' 'target2'}), check_targets_flag = 1; end;
            end;
         end;
         varargin = varargin(4:end);
      end;
      
      if check_targets_flag, feval(mfilename, obj, 'check_targets'); end;
      
      
   %% case get
   case 'get'
      switch x,
         case 'nClasses'
            x = value(nClasses);  %#ok<NODEF>
            
         case 'fignum'
            x = my_window_info(3);
            
         otherwise  % it's a query of the form "%d %s" where %d is the trial class and %s is one of the trial attributes (e.g., 'pprob')
            if isscalar(x) && isnumeric(x) && nargin>=4,
               if ~ismember(y, [trial_attributes pre_attributes]),
                  fprintf(1, '%s: Sorry, don''t know how to get "%d %s"\n', mfilename, x, y);
                  return;
               else
                  sph_name = ['class_' num2str(x) '_' y];
                  x = value(eval(sph_name));
                  return;
               end;
            else
               fprintf(1, '%s: Sorry, don''t know how to get "%s"\n', mfilename, x);
            end;
      end;
      return;
            
      
   %% case target1, target2
   case {'target1' 'target2'}
      feval(mfilename, obj, 'check_targets');
      
   %% case showhide
   case 'showhide'
      if showhide==1,  %#ok<NODEF>
         set(value(myfig), 'Visible', 'on');
      else
         set(value(myfig), 'Visible', 'off');
      end;
      
   %% case hide
   case 'hide'
      set(value(myfig), 'Visible', 'off');
      showhide.value = 0;
      
   %% case close
   case 'close'
      currfig = double(gcf);
      
      % Get the original GUI position and figure:
      x = my_gui_info(1); y = my_gui_info(2); figure(my_gui_info(3));
      my_figure = my_window_info(3);
      
      % Delete all SoloParamHandles who belong to this object and whose
      % fullname starts with the name of this mfile:
      delete_sphandle('owner', ['^@' class(obj) '$'], ...
         'fullname', ['^' mfilename]);
      delete(my_figure);

      % Restore the current figure:
      if my_figure~=currfig,
         figure(currfig);
      end;

         
   %% case reinit
   case 'reinit',
      currfig = double(gcf);
      
      % Get the original GUI position and figure:
      x = my_gui_info(1); y = my_gui_info(2); figure(my_gui_info(3));
      my_figure = my_window_info(3);
      
      % Delete all SoloParamHandles who belong to this object and whose
      % fullname starts with the name of this mfile:
      delete_sphandle('owner', ['^@' class(obj) '$'], ...
         'fullname', ['^' mfilename]);
      delete(my_figure);
      
      % Reinitialise at the original GUI position and figure:
      [x, y] = feval(mfilename, obj, 'init', x, y);
      
      % Restore the current figure:
      figure(currfig);
end

      
      
