function [x, y] = CurrentTrialPokesSubsection(obj, action, x, y)

GetSoloFunctionArgs;
% SoloFunction('CurrentTrialPokesSubsection', ...
%   'rw_args', {'RealTimeStates'}, ...
%   'ro_args', {'n_done_trials', 'n_started_trials', ...
%   'PokeStretch_history', 'StateStretch_history', ...
%   'PokeStretch', 'StateStretch', 'AlignOn', 'RewardSide', 'BOT', 'TOP'});

persistent last_plotted_handles
switch action,
 case 'init',  % ---------- CASE INIT ----------

   fig = gcf; % This is the protocol's main window, to which we add a menu:   
   MenuParam(obj, 'CurrentTrialPokes', {'view', 'hidden'}, 1, x, y); next_row(y);
   set_callback(CurrentTrialPokes, ...
                {'CurrentTrialPokesSubsection', 'view'});
   
   % Now make a figure for our Pokes Plot:
   SoloParamHandle(obj, 'myfig', 'value', figure, 'saveable', 0);
   screen_size = get(0, 'ScreenSize');
   set(value(myfig),'Position',[1 screen_size(4)-700, 435 650]); % put fig
                                                                 % at top left
   set(value(myfig), ...
       'Visible', 'on', 'MenuBar', 'none', 'Name', 'Pokes Plot', ...
       'NumberTitle', 'off', 'CloseRequestFcn', ...
       ['CurrentTrialPokesSubsection(' class(obj) '(''empty''), ''hide'')']);
   
   % UI param that controls what t=0 means in pokes plot:
   SoloParamHandle(obj, 'alignon', 'label', 'alignon', 'type', 'menu', 'string', ...
                   {'TrialStart', 'Cin', 'Cout'}, ...
                   'position', [1 1 160 20], 'value', 2);
   
   % Left edge of pokes plot:
   SoloParamHandle(obj, 't0', 'label', 't0', 'type', 'numedit', 'value', -4, ...
                   'position', [165 1 60 20], 'ToolTipString', ...
                   'time axis left edge');
   % Right edge of pokes plot:
   SoloParamHandle(obj, 't1', 'label', 't1', 'type', 'numedit', 'value', 15, ...
                   'position', [230 1 60 20], 'ToolTipString', ...
                   'time axis right edge');

   % Manual redraw:
   PushbuttonParam(obj, 'redraw', 295, 1);
   
   set_callback({t0;t1;alignon;redraw;},{'CurrentTrialPokesSubsection', 'redraw'});

   % An axis for the pokes plot:
   SoloParamHandle(obj, 'axpatches', 'saveable', 0, ...
                   'value', axes('Position', [0.1 0.18 0.8 0.77]));
   xlabel('secs'); ylabel('trials'); hold on;
   set(value(axpatches), 'Color', 0.3*[1 1 1], 'YLim', [0 30]);
  
   SoloParamHandle(obj, 'StateColor', 'value', struct( ...
       'wait_for_cpoke',            [0.2 0.2 0.2], ...
       'cpoke',                     [1 1 1],       ...
       'short_poke',                [1 1 0],       ...
       'cpoke_small',               [0.8 1 0.8],   ...
       'small_available',           [0.8 0.8 1],   ...
       'cpoke_large',               [0.5 1 0.5],   ...
       'large_available',           [0.6 0.6 1],   ...
       'small_reward',              [0 0 1],       ...
       'large_reward',              [0.5 0 0.8],   ...
       'time_out1',                 [0.7 0.7 0.7], ...
       'time_out2',                 [0.7 0.7 0.7], ...
       'state35',                   [0.5 0.5 0.5]));
   
% % An axis for the color codes and labels:
%    SoloParamHandle(obj, 'axhistlabels', 'saveable', 0, ...
%                    'value', axes('Position', [0.15 0.2 0.7 0.015]));
   
   figure(fig); % After finishing with our fig, go back to whatever was
                % the current fig before.
   
% End of case 'init'

    case 'update350',
        if strcmp(value(CurrentTrialPokes), 'view'),

            poke_stretch=value(PokeStretch); state_stretch=value(StateStretch);
            align_on=value(AlignOn); state_color=value(StateColor);
            fname_poke=fieldnames(poke_stretch); fname_state=fieldnames(state_stretch);

            set(value(axpatches), 'Ylim',[value(BOT), value(TOP)], ...
                'Xlim', [value(t0), value(t1)]);

            switch value(alignon),
                case 'TrialStart',
                    if align_on.TrialStart(n_started_trials)<=0,
                        return
                    else,
                        x0=align_on.TrialStart(n_started_trials);
                    end;
                case 'Cin',
                    if align_on.Cin(n_started_trials)<=0,
                        return
                    else,
                        x0=align_on.Cin(n_started_trials);
                    end;
                case 'Cout',
                    if align_on.Cout(n_started_trials)<=0,
                        return
                    else,
                        x0=align_on.Cout(n_started_trials);
                    end;
            end;

            if ~isempty(last_plotted_handles),
                delete(last_plotted_handles);
                last_plotted_handles=[];
            end;

            for i=1:size(fname_state),   %State patches
                start_stop=state_stretch.(fname_state{i});
                x_data=start_stop(:,[1 1 2 2])'-x0;
                y_data=repmat([0.05 0.95 0.95 0.05]'+n_started_trials-1,1,size(x_data,2));
                c_data=state_color.(fname_state{i});
                h=fill(x_data,y_data,c_data,'EdgeColor','none', ...
                    'Parent',value(axpatches));
                last_plotted_handles=[last_plotted_handles;h];
            end;

            for i=1:2,    %Poke lines
                start_stop=poke_stretch.(fname_poke{i});
                x_data=start_stop'-x0;
                switch i,
                 case 1,
                     add=0.5; col=0.0*[1 0.66 0];
                 case 2,
                     switch value(RewardSide),
                         case 'Left', add=0.8; col=0.6*[1 0.66 0];
                         case 'Right', add=0.2; col=0.6*[1 0.66 0];
                     end;
                end;
                y_data=(n_started_trials-1+add)*ones(size(x_data));
                line_width=100/(value(TOP)-value(BOT));
                l=line(x_data,y_data,'Parent',value(axpatches));
                set(l,'Color',col,'LineWidth',line_width);
                last_plotted_handles=[last_plotted_handles;l];
            end;
        end;
   
 case 'update', % trial_finished_action
   if strcmp(value(CurrentTrialPokes), 'view'),
         poke_stretch=value(PokeStretch); state_stretch=value(StateStretch);
         align_on=value(AlignOn); state_color=value(StateColor);                     
         fname_poke=fieldnames(poke_stretch); fname_state=fieldnames(state_stretch);                       
                       
         switch value(alignon),
             case 'TrialStart', x0=align_on.TrialStart(n_done_trials);
             case 'Cin',  x0=align_on.Cin(n_done_trials);
             case 'Cout',   x0=align_on.Cout(n_done_trials);
         end;
         if isempty(x0), x0=0; end;
         
%          if ~isempty(last_plotted_handles),
%              delete(last_plotted_handles);
%              last_plotted_handles=[];
%          end;

         for i=1:size(fname_state),   %State patches
             start_stop=state_stretch.(fname_state{i});
             x_data=start_stop(:,[1 1 2 2])'-x0;
             y_data=repmat([0.05 0.95 0.95 0.05]'+n_done_trials-1,1,size(x_data,2));
             c_data=state_color.(fname_state{i});
             fill(x_data,y_data,c_data,'EdgeColor','none', ...
             'Parent',value(axpatches));
         end;

         for i=1:2,    %Poke lines
             start_stop=poke_stretch.(fname_poke{i});
             x_data=start_stop'-x0;
             switch i,
                 case 1,
                     add=0.5; col=0.0*[1 0.66 0];
                 case 2,
                     switch value(RewardSide),
                         case 'Left', add=0.8; col=0.6*[1 0.66 0];
                         case 'Right', add=0.2; col=0.6*[1 0.66 0];
                     end;
             end;
             y_data=(n_done_trials-1+add)*ones(size(x_data));
             line_width=100/(value(TOP)-value(BOT));
             l=line(x_data,y_data,'Parent',value(axpatches));
             set(l,'Color',col,'LineWidth',line_width);
         end;
         
         set(value(axpatches), 'Ylim',[value(BOT), value(TOP)], ...
             'Xlim', [value(t0), value(t1)]);
   end;
         
 case 'redraw', % ------- CASE REDRAW 
   % Ok, on with redrawing
   if strcmp(value(CurrentTrialPokes), 'view'),
      if value(n_done_trials) > 0,
         poke_stretch=value(PokeStretch); state_stretch=value(StateStretch);
         state_history=value(StateStretch_history);
         poke_history=value(PokeStretch_history);
         align_on=value(AlignOn); state_color=value(StateColor);                     
         fname_poke=fieldnames(poke_stretch); fname_state=fieldnames(state_stretch);
         
         %first delete all patches
         delete(get(value(axpatches), 'Children'));
         last_plotted_handles=[];
         
         switch value(alignon),
             case 'TrialStart', fname_align='TrialStart';
             case 'Cin',  fname_align='Cin';
             case 'Cout',   fname_align='Cout';
         end;
         ttop = min(floor(value(TOP)), length(state_history));
         
         %State patches
         for i=1:size(fname_state), %loop for different states 
             start_stop_all=[];
             y_data=[];
             for j=ceil(value(BOT))+1:ttop,  %loop for trials
             start_stop= ...
             state_history{j}.(fname_state{i})-align_on.(fname_align)(j);
             start_stop_all=[start_stop_all;start_stop];
             y_data_one=repmat([0.05 0.95 0.95 0.05]'+j-1,1,size(start_stop,1));
             y_data=[y_data y_data_one];
             end;
             x_data=start_stop_all(:,[1 1 2 2])';
             c_data=state_color.(fname_state{i});
             fill(x_data,y_data,c_data,'EdgeColor','none', ...
             'Parent',value(axpatches));
         end;
         
         %Poke lines
         for i=1:2, %loop for different pokes
             x_data=[];y_data=[];
             switch i,
                 case 1,
                     add=0.5; col=0.0*[1 0.66 0];
                 case 2,
                     switch value(RewardSide),
                         case 'Left', add=0.8; col=0.6*[1 0.66 0];
                         case 'Right', add=0.2; col=0.6*[1 0.66 0];
                     end;
             end;
             for j=ceil(value(BOT))+1:ttop, %loop for different trials
                 start_stop= ...
                     poke_history{j}.(fname_poke{i});
                 x_data_one=start_stop'-align_on.(fname_align)(j);
                 x_data=[x_data x_data_one];
                 y_data_one=(j-1+add)*ones(size(x_data_one));
                 y_data=[y_data y_data_one];
             end;
             line_width=100/(value(TOP)-value(BOT));
             l=line(x_data,y_data,'Parent',value(axpatches));
             set(l,'Color',col,'LineWidth',line_width);
         end;
      end;

      set(value(axpatches), 'Ylim',[value(BOT), value(TOP)], ...
          'Xlim', [value(t0), value(t1)]);

      drawnow;
   end;
     
 case 'view', % ------ CASE VIEW
   switch value(CurrentTrialPokes),
    case 'hidden', set(value(myfig), 'Visible', 'off');
    case 'view',   
      set(value(myfig), 'Visible', 'on');
      CurrentTrialPokesSubsection(obj, 'redraw');
   end;
   
 case 'hide', % ------ CASE HIDE
   CurrentTrialPokes.value = 'hidden';
   set(value(myfig), 'Visible', 'off');   
     
 case 'trial_limits', % ----  CASE TRIAL_LIMITS
   switch value(trial_limits),
    case 'last n',
      set([get_ghandle(ntrials);    get_lhandle(ntrials)],    'Visible', 'on');
      set([get_ghandle(start_trial);get_lhandle(start_trial)],'Visible','off');
      set([get_ghandle(end_trial);  get_lhandle(end_trial)],  'Visible','off');
    
    case 'from, to',      
      set([get_ghandle(ntrials);    get_lhandle(ntrials)],    'Visible','off');
      set([get_ghandle(start_trial);get_lhandle(start_trial)],'Visible','on');
      set([get_ghandle(end_trial);  get_lhandle(end_trial)],  'Visible','on');
    
    otherwise
      error(['Don''t recognize this trial_limits val: ' value(trial_limits)]);
   end;
   drawnow;
   
 case 'delete', % ------------ case DELETE ----------
  delete(value(myfig));
  last_plotted_handles=[];
  
 otherwise,
   error(['Don''t know how to deal with action ' action]);
end;    


    
    
