function varargout = PsychometricSection(obj, action, varargin)
%PsychometricsSECTION: Primary routine for the Psychometrics plugin
%
%   This is a plugin which plots a psychometric function and updates it in
%   real time. In principle, this will work for any protocol involving
%   binary choices in response to two pulsed streams of evidence. However,
%   it was developed in the context of PBups and other tasks may need to
%   be modified slightly to work with it. See below for more details on
%   incorporating it into a protocol. Only  the last step may need to be
%   modified for non-PBups-esque protocols.
%
%   SYNTAX:
%   VARARGOUT = PsychometricSECTION(OBJ, ACTION, VARARGIN)
%
%   OBJ: Protocol object
%
%   ACTION: Action string
%
%
%   How to add to your protocol:
%
%   1) add 'psychometric' to the list of class inheritances of your
%   protocol object.
%
%   2) INITIALIZE
%
%   [x, y] = PsychometricsSection(obj, 'init', x, y): Initialization step, called from
%   your protocol's 'init' section. It places the button to show/hide the
%   PsychometricsSection window on the protocol window at the x and y
%   coordinates passed, and initializes the Psychometrics GUI. 
%
%   I would suggest putting this just after initializing PenaltySecion with
%   the line " nextrow(y) " appended before calling PsychometricsSection. 
%
%   i.e. something like:
%
% ---------
%  % COLUMN 4
%     [x, y] = PenaltySection(obj, 'init', x, y);
%     
%     next_row(y);      
%     [x,y] = PsychometricSection(obj,'init',x,y);   
%     
%     
%     next_row(y, 2);
%     
%     SC = state_colors(obj);
%     [x, y] = PokesPlotSection(obj, 'init', x, y, ...
%       struct('states',  SC));
%     PokesPlotSection(obj, 'set_alignon', 'wait_for_cpoke1(1,2)');
% -----------
%
%   3) UPDATE TRIAL BY TRIAL
%
%   PsychometricsSection(obj, 'update'): If placed in your
%   protocol's "trial_completed" section, the psychometrics plot will
%   update after every trial.
%
%   4) CLOSE
%
%   PsychometricsSection(obj, 'close'): Placed in the protocol's 'close'
%   section.
%
%   5) ADD A NEW ACTION, called 'psych_summary', to your protocol's SidesSection.m file that can be
%      called by @psychometric to get the data it needs to update at the end of each trial. This is
%      very similar to the action 'make_and_send_summary' that is used to write out data to the mysql table.  
%      The following bit of code will most likely do the trick:
%   -------
%   case 'psych_summary',
%     x.hits       = value(hit_history);
% 	  x.violations = value(violation_history);
% 	  x.samples    = value(previous_samples);	x.samples = x.samples(1:length(hit_history));
%     x.sides      = value(previous_sides);		x.sides   = x.sides(1:length(hit_history));
%     x.bupsdata   = PBupsSection(obj, 'get_all_bup_times');
%     [x.n_left,x.n_right] = deal(nan(size(x.hits)));
%     for tx=1:numel(x.hits)
%          x.n_left(tx)=sum(x.bupsdata{tx}.left<x.samples(tx));
%          x.n_right(tx)=sum(x.bupsdata{tx}.right<x.samples(tx));     
%     end
%     x.gamma = cellfun(@(x)x.gamma,x.bupsdata);
%  ------------
%
%   The idea is to return a structure with fields
%   'hits','violations','sides','gamma','n_left' and 'n_right' that
%   reflect the latest state of the behavior needed by @psychometric.
%
%   This is the only step that may not work without further modifications
%   for a non-PBups-esque protocol, since the equivalent field values are presumably calculated differently. 
%   However, as long as calling x = SidesSection(obj,'psych_summary') returns a structure with the
%   fields above, the plugin should work.
%
%   Adrian Bondy, 2017
%%

try
    %Nothing that happens in the PsychometricsSection file should affect the
    %rest of the protocol
    
    GetSoloFunctionArgs(obj);
    
    if ~exist('n_started_trials', 'var')
        n_started_trials = 0;
    end
    
    switch action
        %% CASE init
        case 'init'
            % e.g. PsychometricsSection(obj, 'init', x, y)
            
            %% Intial Step: Close existing windows if necessary
            feval(mfilename, obj, 'close');
            
            %% Step 1: Validation
            if nargin<4 
                error('Invalid number of number of arguments. The number of arguments has to be either 4 or 5.');
            elseif ~isobject(obj)
                error('The first argument has to be the protocol object');
            elseif ~isscalar(varargin{1}) || ~isscalar(varargin{2})
                error('The third and fourth arguments have to be scalars');
            elseif nargin==5 && ~isstruct(varargin{3})
                error('The fifth argument, if present, has to be a valid structure.');
            end
            x = varargin{1};
            y = varargin{2};
            varargout{1} = x;
            varargout{2} = y;
            
            
            %SESSION_INFO contains information about the experimenter,
            %ratname, settings_file, and protocol name, and keeps track of
            %these items throughout.
            temp = SavingSection(obj, 'get_all_info');
            SoloParamHandle(obj, 'SESSION_INFO', 'value', struct('experimenter', temp.experimenter, 'ratname', temp.ratname, 'settings_file', temp.settings_file, 'protocol', class(obj)));
            
            
            SoloParamHandle(obj, 'my_xyfig', 'value', [x y double(gcf)]);
            if ~exist('PsychometricsShow', 'var') || ~isa(PsychometricsShow, 'SoloParamHandle')
                ToggleParam(obj, 'PsychometricsShow', 0, x, y, 'OnString', 'Psychometrics Showing', ...
                    'OffString', 'Psychometrics Hidden', 'TooltipString', 'Show/Hide Psychometrics window'); next_row(y);
                set_callback(PsychometricsShow, {mfilename, 'show_hide'});
            end
            SoloParamHandle(obj, 'myfig', 'value', double(figure('CloseRequestFcn', [mfilename '(' class(obj) ', ''hide'');'], 'MenuBar', 'none', 'Name', mfilename, 'Units', 'normalized')), 'saveable', false);
            HeaderParam(obj, 'textHeader', [mfilename '(' SESSION_INFO.experimenter ', ' SESSION_INFO.ratname ')'], 1, 1);
            
            SoloParamHandle(obj, 'legend_position', 'value', [],'saveable',true,'save_with_settings',true);            
        
            
            %Settings panel
            hndl_uipanelSettings = uipanel('Units', 'normalized');
            hndl_uipanelFitSettings = uipanel('Units', 'normalized');            
            
            
            %% Formatting graphics elements
            %myfig
            set(value(myfig), ...
                'Units', 'normalized', ...
                'Name', mfilename, ...
                'Position', [0.0124      0.39     0.34       0.51],...
                'color','white');
            
            %textHeader
            set(get_ghandle(textHeader), ...
                'Units', 'normalized', ...
                'Parent', value(myfig), ...
                'Position', [0.054444     0.93        0.89    0.05], ...
                'FontSize', 12, ...
                'FontName', 'monospaced', ...
                'FontWeight', 'bold', ...
                'Tag', 'textHeader', ...
                'TooltipString', mfilename, ...
                'HorizontalAlignment', 'center', ...
                'BackgroundColor', 'white');
           
            
            %uipanelSettings
            set(hndl_uipanelSettings, ...
                'Units', 'normalized', ...
                'Parent', value(myfig), ...
                'Title', 'Settings', ...
                'Tag', 'uipanelSettings', ...
                'Position', [0.73    0.20        0.26     0.70]);
            
            ToggleParam(obj,'errBar',0,1,1,'label','Error Bars',...
                'TooltipString','show error bars in plot');
            
            set(get_ghandle(errBar),...
                'units','normalized',...
                'position',[0.52 0.9 0.45 0.08],...
                'FontSize',8,...
                'parent',hndl_uipanelSettings);   
            
            ToggleParam(obj,'nTrials',0,1,1,'label','N Trials',...
                'TooltipString','show n trials in plot');
            
            set(get_ghandle(nTrials),...
                'units','normalized',...
                'position',[0.02 0.9 0.45 0.08],...
                'FontSize',8,...
                'parent',hndl_uipanelSettings);  
            
            ToggleParam(obj,'showStimTrials',0,1,1,'label','Show Stim Trials',...
                'TooltipString','Plot stim trials separately');
            
            set(get_ghandle(showStimTrials),...
                'units','normalized',...
                'position',[0.52 0.81 0.45 0.08],...
                'FontSize',6,...
                'parent',hndl_uipanelSettings);   
            
            ToggleParam(obj,'probeTrialsOnly',0,1,1,'label','Probe Trials Only',...
                'TooltipString','Only plot probe trials');
            
            set(get_ghandle(probeTrialsOnly),...
                'units','normalized',...
                'position',[0.02 0.81 0.45 0.08],...
                'FontSize',6,...
                'parent',hndl_uipanelSettings);       
            
            ToggleParam(obj,'plotViolations',0,1,1,'label','Plot Violations',...
                'TooltipString','Plot violation fraction instead of choices');
            
            set(get_ghandle(plotViolations),...
                'units','normalized',...
                'position',[0.02 0.72 0.45 0.08],...
                'FontSize',6,...
                'parent',hndl_uipanelSettings);             

            MenuParam(obj,'xVal',{'gamma','bupDiff','log_click_ratio','rl_prob_diff'},'bupDiff',1,1,...
                'label','X Value',...
                'TooltipString','quantity on the abscissa');
            
            set(get_lhandle(xVal),...
                'units','normalized',...
                'position',[0.18,0.63,0.64,0.06],...
                'horizontalalignment','center',...
                'parent',hndl_uipanelSettings);
            
            set(get_ghandle(xVal),...
                'units','normalized',...
                'position',[0.18 0.52 0.64 0.14],...
                'parent',hndl_uipanelSettings);   
            
            MenuParam(obj,'normalization',{'none','totalBups'},'none',1,1,...
                'label','Normalization',...
                'TooltipString','normalization of bupDiff, does nothing for the other options for xval');
            
            set(get_lhandle(normalization),...
                'units','normalized',...
                'position',[0.18,0.53,0.64,0.06],...
                'horizontalalignment','center',...
                'parent',hndl_uipanelSettings);
            
            set(get_ghandle(normalization),...
                'units','normalized',...
                'position',[0.18 0.42 0.64 0.14],...
                'parent',hndl_uipanelSettings);   
            
            
            MenuParam(obj,'nPsychBins',{1,2,3,4,5,6,7,8,9,10,11,12,Inf},7,1,1,...
                'label','npsychbins',...
                'TooltipString','number of x-axis bins');
            
            set(get_lhandle(nPsychBins),...
                'units','normalized',...
                'position',[0.18,0.43,0.64,0.06],...
                'horizontalalignment','center',...
                'parent',hndl_uipanelSettings);
            
            set(get_ghandle(nPsychBins),...
                'units','normalized',...
                'position',[0.18 0.32 0.64 0.14],...
                'parent',hndl_uipanelSettings);              
            
            set_callback(errBar, {mfilename, 'update'}); %#ok<NODEF> (Defined just above)
            set_callback(nTrials, {mfilename, 'update'}); %#ok<NODEF> (Defined just above)
            set_callback(showStimTrials, {mfilename, 'update'}); %#ok<NODEF> (Defined just above)
            set_callback(probeTrialsOnly, {mfilename, 'update'}); %#ok<NODEF> (Defined just above)     
            set_callback(plotViolations, {mfilename, 'update'}); %#ok<NODEF> (Defined just above)                        
            set_callback(xVal, {mfilename, 'updateXVal'}); %#ok<NODEF> (Defined just above)
            set_callback(normalization, {mfilename, 'update'}); %#ok<NODEF> (Defined just above)
            set_callback(nPsychBins, {mfilename, 'update'}); %#ok<NODEF> (Defined just above)
            
            
            
            %% uipanel fit settings
            
            set(hndl_uipanelFitSettings, ...
                'Units', 'normalized', ...
                'Parent', hndl_uipanelSettings, ...
                'Title', 'Fit Settings', ...
                'Tag', 'uipanelFitSettings', ...
                'Position', [0.05    0.02  0.9     0.36]);            
           
            MenuParam(obj,'fitType',{'logit','probit','none'},...
                'logit',1,1,'label','Fit Type',...
                'TooltipString','type of fit to psychometric curve','labelpos','top');
            
            set(get_lhandle(fitType),...
                'units','normalized',...
                'position',[0.15,0.80,0.7,0.14],...
                'horizontalalignment','center',...
                'parent',hndl_uipanelFitSettings);
            
            set(get_ghandle(fitType), ...
                'units','normalized',...
                'Position', [0.15 0.66 0.7 0.13],...
                'parent',hndl_uipanelFitSettings);     
            
            ToggleParam(obj,'fitBias',1,1,1,'label','Fit Bias',...
                'TooltipString','include bias term in fit');
            
            set(get_ghandle(fitBias),...
                'units','normalized',...
                'position',[0.15 0.3 0.7 0.2],...
                'parent',hndl_uipanelFitSettings);
            
            ToggleParam(obj,'fitLapse',1,1,1,'label','Fit Lapse',...
                'TooltipString','include lapse term in fit');
            
            set(get_ghandle(fitLapse),...
                'units','normalized',...
                'position',[0.15 0.05 0.7 0.2],...
                'parent',hndl_uipanelFitSettings);            
            
            set_callback(fitLapse, {mfilename, 'update'}); %#ok<NODEF> (Defined just above)
            set_callback(fitBias, {mfilename, 'update'}); %#ok<NODEF> (Defined just above)
            
            set_callback(fitType, {mfilename, 'changeFitType'}); %#ok<NODEF> (Defined just above)

            
            %axPsychometrics
            SoloParamHandle(obj, 'axPsychometrics', 'value', double(axes('Units', 'normalized')), 'saveable', false);
            set(value(axPsychometrics), ...
                'Units', 'normalized', ...
                'Parent', value(myfig), ...
                'Tag', 'axPsychometrics', ...
                'Visible', 'on', ...
                'YLim', [0 1], ...
                'XLim',[-5 5],...
                'xtick',[],...
                'Position', [0.1     0.1     0.62     0.8]);
                
            ylabel('Fraction Chose Right');
            
            %% statistics display
            
            DispParam(obj,'percentCorrect','NaN % Correct (0/0)',1,1,'label','NaN % Correct (0/0)','labelpos','left');
            
            set(get_ghandle(percentCorrect),...
                'parent',value(myfig),...
                'units','normalized',...
                'horizontalalignment','center',...
                'position',[0.77 0.16 0.21 0.03]);
            
            set(get_lhandle(percentCorrect),'position',[-100 -100 1 1],'visible','off');
            
            DispParam(obj,'violationRate','NaN % Violated (0/0)',1,1,'label','NaN % Violated (0/0)','labelpos','left');
            
            set(get_ghandle(violationRate),...
                'parent',value(myfig),...
                'units','normalized',...
                'horizontalalignment','center',...
                'position',[0.77 0.12 0.21 0.03]);
            
            set(get_lhandle(violationRate),'position',[-100 -100 1 1],'visible','off');
            
            
            DispParam(obj,'biasRate','NaN % Right Bias',1,1,'label','NaN % Right Bias','labelpos','left');
            
            set(get_ghandle(biasRate),...
                'parent',value(myfig),...
                'units','normalized',...
                'horizontalalignment','center',...
                'position',[0.77 0.08 0.21 0.03]);     
            
            set(get_lhandle(biasRate),'position',[-100 -100 1 1],'visible','off');
            
            
            DispParam(obj,'lapse','NaN % Lapse Rate',1,1,'label','NaN % Lapse Rate','labelpos','left');
            
            set(get_ghandle(lapse),...
                'parent',value(myfig),...
                'units','normalized',...
                'horizontalalignment','center',...
                'position',[0.77 0.04 0.21 0.03]);       
            
            set(get_lhandle(lapse),'position',[-100 -100 1 1],'visible','off');
            
            
            
            %Reverting back to main protocol figure window and hide
            %PsychometricsSection window
            figure(my_xyfig(3));
            feval(mfilename, obj, 'hide');
            
            
           
        case 'changeFitType'
            if strcmp(value(fitType),'none')
                disable(fitLapse);
                disable(fitBias);
            else
                enable(fitLapse);
                enable(fitBias);
            end
            feval(mfilename,obj,'update');
           
            
        case 'updateXVal'
            if strcmp(value(xVal),'gamma')
                normalization.value = 'none';
                set(get_ghandle(normalization),'string',{'none'});
            else
                set(get_ghandle(normalization),'string',{'none','totalBups'});
            end
            feval(mfilename,obj,'update');
            
            
      
            
            %% CASE update
        case 'update'
            
            if PsychometricsShow==0 || ~n_done_trials
                return;
                % Don't update pokes plot if it is hidden
            end
            
          temp = SavingSection(obj, 'get_all_info');

          SESSION_INFO.value = struct('experimenter', temp.experimenter, 'ratname', temp.ratname, 'settings_file', temp.settings_file, 'protocol', class(obj));

          textHeader.value = [mfilename '(' SESSION_INFO.experimenter ', ' SESSION_INFO.ratname ')'];
  
     
                protocol_data.pd{1} = SidesSection(obj,'psych_summary');

                currentFig = double(get(0,'currentFigure'));

                
                axes(value(axPsychometrics));
                current_legend_position = get(findobj(gcf, 'tag', 'legend'),'position');                
                if ~isempty(current_legend_position)
                    legend_position.value=current_legend_position;
                end
                cla reset;
                
                warning('off','psychometrics:onlyOneChoice');
                warning('off','psychometrics:lessThanFour');
                
                pbups_psych_data = pbups_psych_internal(protocol_data,...
                    'fit', ~strcmp(value(fitType),'none'),...
                    'fittype', value(fitType),...
                    'fitLapse', logical(value(fitLapse)),...
                    'fitBias', logical(value(fitBias)),...
                    'xval', value(xVal),...
                    'plotCurves',true,...
                    'plotPerformance',false,...
                    'percentCorrect',true,...
                    'showN',logical(value(nTrials)),...
                    'errorbar',logical(value(errBar)),...
                    'normalization',value(normalization),...
                    'nPsychBins',value(nPsychBins),...                    
                    'showStimTrials',logical(value(showStimTrials)),...
                    'probeTrialsOnly',logical(value(probeTrialsOnly)),...
                    'plotViolations',logical(value(plotViolations)),...
                    'removeViolations',~logical(value(plotViolations)),...
                    'addTitle',false,...
                    'legend',true);

                warning('on','psychometrics:onlyOneChoice');
                warning('on','psychometrics:lessThanFour');    
               if value(showStimTrials) % do it again without separating trials so you can gather overall statistics. this is a hack, but oh well.
                pbups_psych_data = pbups_psych_internal(protocol_data,...
                    'fit', ~strcmp(value(fitType),'none'),...
                    'fittype', value(fitType),...
                    'fitLapse', logical(value(fitLapse)),...
                    'fitBias', logical(value(fitBias)),...
                    'xval', value(xVal),...
                    'plotCurves',false,...
                    'plotPerformance',false,...
                    'plot',false,...
                    'percentCorrect',true,...
                    'showN',logical(value(nTrials)),...
                    'errorbar',logical(value(errBar)),...
                    'normalization',value(normalization),...
                    'nPsychBins',value(nPsychBins),...                                        
                    'showStimTrials',false,...
                    'probeTrialsOnly',logical(value(probeTrialsOnly)),...
                    'addTitle',false,...
                    'plotViolations',logical(value(plotViolations)),...                    
                    'removeViolations',~logical(value(plotViolations)),...
                    'legend',false);                
               end
               if ~value(plotViolations)
                enable(biasRate);
                enable(lapse);
                enable(violationRate);
                enable(percentCorrect);                   
                biasRate.value = [num2str(round(pbups_psych_data.bias(1)*100)) ' % right bias'];
                lapse.value = [num2str(round(pbups_psych_data.lapse(1)*100)) ' % lapse rate'];
                violationRate.value = sprintf('%g%% violations', round(100*pbups_psych_data.violationRate)); 
                percentCorrect.value = [num2str(round(pbups_psych_data.percentCorrect*100)), '% correct (',num2str(round(pbups_psych_data.percentCorrect*length(pbups_psych_data.choices))) ,'/',num2str(length(pbups_psych_data.choices) )];
               else
                biasRate.value = NaN;
                lapse.value = NaN;
                violationRate.value = NaN; 
                percentCorrect.value = NaN;
                disable(biasRate);
                disable(lapse);
                disable(violationRate);
                disable(percentCorrect);
               end
                
                    
                legend_handle = findobj(gcf, 'tag', 'legend');
                if ~isempty(value(legend_position))
                    set(legend_handle,'position',value(legend_position));                
                end
                drawnow;

                figure(currentFig);
                

            
            %% CASE close
        case 'close'
            if exist('myfig', 'var') && isa(myfig, 'SoloParamHandle') && ishandle(value(myfig))
                delete(value(myfig));
            end
            clear(mfilename);
            
            %% CASE hide
        case 'hide'
            set(value(myfig), 'Visible', 'off');
            PsychometricsShow.value = false;
            
            %% CASE show
        case 'show'
            set(value(myfig), 'Visible', 'on');
            PsychometricsShow.value = true;
            feval(mfilename, obj, 'update');
            
            %% CASE show_hide
        case 'show_hide'
            if value(PsychometricsShow) %#ok<NODEF>
                feval(mfilename, obj, 'show');
            else
                feval(mfilename, obj, 'hide');
            end
            
            %% OTHERWISE
        otherwise
            error(['Unknown action ' action]);
    end
    
    
catch
    showerror;
end

end