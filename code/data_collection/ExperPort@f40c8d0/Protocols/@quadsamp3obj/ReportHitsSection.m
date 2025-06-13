function  [x,  y]  =  ReportHitsSection(obj, action, x, y, SChoiceWin, Sbeta)
%
% This section is responsible for computing % correct on the indicated
% most recent trials. 
   
beta = [];
GetSoloFunctionArgs;
% SoloFunction('ReportHitsSection', 'ro_args', ...
%             {'Sound_type', 'hit_history', 'n_done_trials', 'priors'});


switch action,
 case 'init'
   fig = gcf; 
   SoloParamHandle(obj, 'my_xyfig', 'value', [x y fig]);
   SoloParamHandle(obj, 'SWinbeta', 'value', {SChoiceWin, Sbeta});
   next_row(y, 0.5);
   
   ToggleParam(obj, 'ReportHits', 1, x, y, 'label', '% correct window', ...
               'TooltipString', 'Show/Hide window that shows % correct', ...
               'OnFontWeight', 'normal', 'OffFontWeight', 'normal', ...
               'position', [x y 100 20]);
   set_callback(ReportHits, {mfilename, 'window_toggle'});
   next_row(y);
   oldx = x; oldy = y;
   
   SoloParamHandle(obj, 'myfig', 'saveable', 0, 'value', ...
       figure('Position', [1039, 336, 300, 360], ...
              'MenuBar', 'none', 'Name', mfilename, 'NumberTitle', 'off', ...
              'CloseRequestFcn', [mfilename '(' class(obj) ...
                       '(''empty''), ''hide_window'');']));

   
   % ------ INIT: First column of figure ----------

   x = 10; y = 10;
   LogsliderParam(obj, 'TrialWindow', 30, 10, 400, x, y, 'TooltipString', ...
    sprintf('number of trials back over\nwhich to compute %% correct'), ...
             'labelfraction', 0.3, 'position', [x y 120 20]);
   set_callback(TrialWindow, {mfilename, 'update'});
   next_row(y); 
   DispParam(obj, 'rightguys', NaN, x, y, 'label', 'Right % correct', ...
             'labelfraction', 0.7, 'position', [x y 120 20]); 
   next_row(y);
   DispParam(obj, 'leftguys', NaN, x, y, 'label', 'Left % correct', ...
             'labelfraction', 0.7, 'position', [x y 120 20]);
   next_row(y);
   DispParam(obj, 'overall', NaN, x, y, 'label', 'overall % correct', ...
             'labelfraction', 0.7, 'position', [x y 120 20]); 
   next_row(y);

   
   SoloParamHandle(obj, 'hitsax', 'value', ...
                   axes('Units', 'pixels', 'Position', [35, y+40,100,100],...
                        'TickDir', 'out'), 'saveable', 0);
   set(get(value(hitsax), 'Title'), 'String', '% correct');

   y = y+170;
   DispParam(obj, 'class1', NaN, x, y, 'label', '% hit', 'position', ...
             [x, y,130 20], 'labelfraction', 0.3); next_row(y);
   DispParam(obj, 'class2', NaN, x, y, 'label', '% hit', 'position', ...
             [x, y,130 20], 'labelfraction', 0.3); next_row(y);
   DispParam(obj, 'class3', NaN, x, y, 'label', '% hit', 'position', ...
             [x, y,130 20], 'labelfraction', 0.3); next_row(y);
   DispParam(obj, 'class4', NaN, x, y, 'label', '% hit', 'position', ...
             [x, y,130 20], 'labelfraction', 0.3); next_row(y);
   
   set([get_ghandle(class3);get_lhandle(class3);get_ghandle(class4); ...
        get_lhandle(class4)], 'Visible', 'off'); 
   
   % ------ INIT: Second column of figure ----------

   x = 160; y = 10;
   LogsliderParam(obj, 'ChoiceWindow', 30, 10, 400, x, y, 'TooltipString', ...
    sprintf(['number of trials back over\nwhich to compute %% correct\n' ...
             'for purposes of choosing next trial']), ...
             'labelfraction', 0.4, 'position', [x y 140 20]);
   next_row(y); next_row(y);
   SliderParam(obj, 'beta', 2.2, 0, 10, x, y, 'TooltipString', ...
    sprintf(['When this is 0, past performance\ndoesn''t affect choice\n' ...
             'of next trial. When this is large,\nthe next trial is ' ...
             'almost guaranteed\nto be the one with smallest %% correct']),...
               'labelfraction', 0.4, 'position', [x y 140 20]);
   set_callback({ChoiceWindow; beta}, {mfilename, 'update_chooser'});
   next_row(y); next_row(y); 

   
   SoloParamHandle(obj, 'choiceax', 'value', ...
                   axes('Units', 'pixels', 'Position', [x+25,y+40,100,100],...
                        'TickDir', 'out'), 'saveable', 0);
   set(get(value(choiceax), 'Title'), 'String', 'prob. of choice');

   
   y = y+170;
   DispParam(obj, 'choice1', NaN, x, y, 'label', '%prob', 'position', ...
             [x, y,130 20], 'labelfraction', 0.3); next_row(y);
   DispParam(obj, 'choice2', NaN, x, y, 'label', '%prob', 'position', ...
             [x, y,130 20], 'labelfraction', 0.3); next_row(y);
   DispParam(obj, 'choice3', NaN, x, y, 'label', '%prob', 'position', ...
             [x, y,130 20], 'labelfraction', 0.3); next_row(y);
   DispParam(obj, 'choice4', NaN, x, y, 'label', '%prob', 'position', ...
             [x, y,130 20], 'labelfraction', 0.3); next_row(y);
   
   set([get_ghandle(choice3);get_lhandle(choice3);get_ghandle(choice4); ...
        get_lhandle(choice4)], 'Visible', 'off'); 

   
   
   % ------- finished with init
   
   x = oldx; y = oldy; figure(fig);
   return;

 
 
 case 'update', % ----- case UPDATE ------
   
   if ~value(ReportHits), return; end;

   ntrials = round(value(TrialWindow));
   start = n_done_trials - ntrials + 1; if start<1, start=1; end;   
   stop  = n_done_trials;
   if stop<start, return; end;

   axes(value(hitsax)); cla;
   if EnableTypeTwos==0, priors=priors([1 3],:); else priors=priors(:,:); end;
   uniquefs = priors(:,1:2);
   xlim([min(uniquefs(:,1))*0.2, max(uniquefs(:,1))*1.2]);
   ylim([min(uniquefs(:,2))*0.5, max(uniquefs(:,2))*1.2]);
   xlabel('f1'); ylabel('f2');
   set(gca, 'XTick', unique(uniquefs(:,1)), 'YTick', unique(uniquefs(:,2)));

   % First individual stim classes:
   percents = NaN*ones(rows(uniquefs), 1);
   for i=1:rows(uniquefs),
      u=find(side_list(start:stop)==priors(i,4));
      if ~isempty(u),
         percents(i) = mean(hit_history(start+u-1));
      end;
      t=text(uniquefs(i,1), uniquefs(i,2), sprintf('%.0f', percents(i)*100));
      set(t, 'Color', 'k', 'FontName', 'Helvetica', 'FontWeight', 'bold', ...
             'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
      sph = eval(['class' num2str(i)]);
      sph.value = sprintf('%.2f-%.2f : %3.0f',uniquefs(i,1),uniquefs(i,2),...
                          percents(i)*100);
   end;

   if EnableTypeTwos==1,
      set([get_ghandle(class3);get_lhandle(class3);get_ghandle(class4); ...
           get_lhandle(class4)], 'Visible', 'on'); 
   else
      set([get_ghandle(class3);get_lhandle(class3);get_ghandle(class4); ...
           get_lhandle(class4)], 'Visible', 'off'); 
   end;
   
   % Now rights
   u = find(side_list(start:stop) <= 0.5);
   if ~isempty(u), rightguys.value = mean(hit_history(start+u-1)); end;

   % Now lefts
   u = find(side_list(start:stop) > 0.5);
   if ~isempty(u), leftguys.value = mean(hit_history(start+u-1)); end;
   
   overall.value = mean(hit_history(start:stop));
   

 case 'update_chooser', % ----- case UPDATE_CHOOSER ------

   if ~value(ReportHits), return; end;

   SWinbeta{1}.value = value(ChoiceWindow);
   SWinbeta{2}.value = value(beta);
   
   ntrials = round(value(ChoiceWindow));
   start = n_done_trials - ntrials + 1; if start<1, start=1; end;   
   stop  = n_done_trials;

   if EnableTypeTwos==0, priors=priors([1 3],:); else priors=priors(:,:); end;
   uniquefs = priors(:,1:2);

   if EnableTypeTwos==1,
      set([get_ghandle(choice3);get_lhandle(choice3);get_ghandle(choice4); ...
           get_lhandle(choice4)], 'Visible', 'on'); 
   else
      set([get_ghandle(choice3);get_lhandle(choice3);get_ghandle(choice4); ...
           get_lhandle(choice4)], 'Visible', 'off'); 
   end;
   
   % First individual stim classes:
   percents = ones(rows(uniquefs), 1);
   if start<=stop,
      for i=1:rows(uniquefs),
         u=find(side_list(start:stop)==priors(i,4));
         if ~isempty(u), percents(i) = mean(hit_history(start+u-1));
         else            percents(i) = 1;
         end;
      end;
   end;

   choices = probabilistic_trial_selector(percents, priors(:,3), value(beta));

   axes(value(choiceax)); cla;
   xlim([min(uniquefs(:,1))*0.2, max(uniquefs(:,1))*1.2]);
   ylim([min(uniquefs(:,2))*0.4, max(uniquefs(:,2))*1.2]);
   xlabel('f1'); ylabel('f2');
   set(gca, 'XTick', unique(uniquefs(:,1)), 'YTick', unique(uniquefs(:,2)),...
            'TickDir', 'out');
   for i=1:rows(uniquefs),
      t=text(uniquefs(i,1), uniquefs(i,2), sprintf('%.0f', choices(i)*100));
      set(t, 'Color', 'k', 'FontName', 'Helvetica', 'FontWeight', 'bold', ...
             'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
      sph = eval(['choice' num2str(i)]);
      sph.value = sprintf('%.2f-%.2f : %3.0f',uniquefs(i,1),uniquefs(i,2),...
                          choices(i)*100);
   end;
   
   
 case 'delete'            , % ------------ case DELETE ----------
   delete(value(myfig));
   
   
 case 'hide_window'       , % ------------ case HIDE ----------
   ReportHits.value = 0;
   set(value(myfig), 'Visible', 'off');
   
 case 'show_window',        % ------------ case SHOW ----------
   ReportHits.value = 1;
   set(value(myfig), 'Visible', 'on');
   ReportHitsSection(obj, 'update');
   ReportHitsSection(obj, 'update_chooser');

 case 'window_toggle',
   if value(ReportHits) == 1,
      set(value(myfig), 'Visible', 'on');
      ReportHitsSection(obj, 'update');
      ReportHitsSection(obj, 'update_chooser');
   else
      set(value(myfig), 'Visible', 'off');
   end;

 case 'enable_chooser',
   set(get_ghandle({beta;ChoiceWindow}), 'Enable', 'on');
   set(findobj(value(choiceax), 'Type', 'text'), 'Color', 0.0*[1 1 1]);

 case 'disable_chooser',
   set(get_ghandle({beta;ChoiceWindow}), 'Enable', 'off');
   set(findobj(value(choiceax), 'Type', 'text'), 'Color', 0.6*[1 1 1]);
   
 case 'reinit',  % --------------------  CASE REINIT
   x = my_xyfig(1); y = my_xyfig(2); fig = my_xyfig(3);
   SChoiceWin = SWinbeta{1}; Sbeta = SWinbeta{2};

   delete(value(myfig));
   delete_sphandle('handlelist', ...
                   get_sphandle('owner', class(obj), 'fullname', mfilename));
   
   figure(fig);
   feval(mfilename, obj, 'init', x, y, SChoiceWin, Sbeta);
   
 otherwise
   error(['Don''t know how to handle action ' action]);
end;


return;
