% This plugin plots the reward side for each trial and indicates
% hits and misses from previous trials.
%
% [x, y] = SidesPlotSection(obj, 'init', x, y, SidesList)
% [x, y] = SidesPlotSection(obj, 'init', x, y, SidesList, TrialType)
% [x, y] = SidesPlotSection(obj, 'init', x, y, SidesList, 'ntrials', 90)
%
% [x, y] = SidesPlotSection(obj, 'update', CurrentTrial, SidesList, HitHistory)
% [x, y] = SidesPlotSection(obj, 'update', CurrentTrial, SidesList, HitHistory, TrialType)
%
% [MinXlim, MaxXlim] = SidesPlotSection(obj,'update_xlim', CurrentTrial);
%
% 
% SidesList : vector of characters: r (right) or l (left)
% HitHistory: vector of 1s (correct) and 0s (mistake)
% HitHistory can also be a vector with more than just two
%  values, providing more information about the type of trial and
%  choice. For example:
%     NaN: future trial  (blue dot)
%      -1: miss trial    (red circle)
%       0: error trial   (red dot)
%       1: correct trial (green dot)
%       2: hit trial     (green circle)
% If HitHistory is empty, the plot of past trials is not changed.
%
% TrialType: vector of 0s and 1s.  Trials marked with 1 will be
%       plotted, others will be left blank.
%
% TO DO:
% - If units of axes are normalized resizing the window changes the
%   size of axes, which may create overlap of GUI objects.
% - Enable plotting stimulus/trial type. Maybe as other markers
%   between the right and left dots.
%
% Santiago Jaramillo - 2007.08.13
%
%%% CVS version control block - do not edit manually
%%%  $Revision$
%%%  $Date$
%%%  $Source$


function [x, y] = SidesPlotSection(obj, action, varargin)

GetSoloFunctionArgs(obj);

switch action,
  case 'init',      % ------------ CASE INIT --------------------
                    % Save the figure and the position in the figure where we are
                    % going to start adding GUI elements:
                    %SoloParamHandle(obj, 'my_gui_info', 'value', [x y gcf]);

    x = varargin{1};
    y = varargin{2};
    SideList = varargin{3};
    if(nargin>5)
        TrialType = varargin{4};
    else
        TrialType = [];
    end
    HitHistory = [];
    
    % -- Is the number of trials given as parameter? --
    IsArgPresent = strcmp('ntrials',varargin);
    if(any(IsArgPresent))
        IndArg = find(IsArgPresent)+1;
        NtrialsToPlot = varargin{IndArg};
    else
        NtrialsToPlot = 90;
    end

    MyFigPosition = get(gcf,'Position');
    MarkerSize = 4;
    oldunits = get(gcf, 'Units'); set(gcf, 'Units', 'normalized');
    SoloParamHandle(obj, 'hAxesSides', 'saveable', 0, 'value', double(axes('Position', [0.1, 0.82, 0.8, 0.12]))); % axes
                                                                                            %SoloParamHandle(obj, 'hAxesSides',  'value', axes('Position', [x,y, 0.8, 0.12])); % axes
    SoloParamHandle(obj, 'bdot', 'saveable', 0, 'value',...
                    plot(-1, 1, 'bo','MarkerSize',MarkerSize)); hold on; % blue dots
    SoloParamHandle(obj, 'gdot', 'saveable', 0, 'value',...
                    plot(-1, 1, 'go','MarkerSize',MarkerSize)); hold on; % green dots
    SoloParamHandle(obj, 'rdot', 'saveable', 0, 'value',...
                    plot(-1, 1, 'ro','MarkerSize',MarkerSize)); hold on; % red dots
    SoloParamHandle(obj, 'odot', 'saveable', 0, 'value',...
                    plot(-1, 1, 'mo','MarkerSize',MarkerSize+4)); hold on; % next trial indicator
    set(value(bdot),'MarkerFaceColor','b');
    set(value(gdot),'MarkerFaceColor','g');
    set(value(rdot),'MarkerFaceColor','r');
    
    SoloParamHandle(obj, 'gcirc', 'saveable', 0, 'value',...
                    plot(-1, 1, 'go','MarkerSize',MarkerSize)); hold on; % green circles
    SoloParamHandle(obj, 'rcirc', 'saveable', 0, 'value',...
                    plot(-1, 1, 'ro','MarkerSize',MarkerSize)); hold on; % red circles
    
    
    % -- Trial types --
    SoloParamHandle(obj, 'stimtype', 'saveable', 0, 'value',...
                    plot(-1, 1, 'kx','MarkerSize',MarkerSize)); hold on; % Trial type indicator

    
    
    %%% THIS PART HAS BEEN COMMENTED OUT %%%
    if(~1)
    SoloParamHandle(obj, 'thl','value', text( -1 * ones(1,maxtrials), 0.5*ones(1,maxtrials),'l'));
    SoloParamHandle(obj, 'thr','value', text(-ones(1,maxtrials), 0.5*ones(1,maxtrials),'r'));
    SoloParamHandle(obj, 'thh','value', text(-ones(1,maxtrials), 0.5*ones(1,maxtrials),'h'));
    SoloParamHandle(obj, 'thm','value', text(-ones(1,maxtrials), 0.5*ones(1,maxtrials),'m'));
    set([value(thl);value(thr);value(thh);value(thm)], ...
        'HorizontalAlignment', 'Center', 'VerticalAlignment', ...
        'middle', 'FontSize', 8, 'FontWeight', 'bold', 'Color', 'b', ...
        'FontName', 'Helvetica', 'Clipping', 'on');
    end
    
    set(value(hAxesSides), 'YTick', [0 1], 'YTickLabel', {'Right', 'Left'});
    y = y + round(0.12*MyFigPosition(4));
    next_row(y,2);
    set(gcf, 'Units', oldunits);
    ylim([-0.5,1.5]);
    xlim([1,100]);
    
    % The following object is necessary for knowing the CurrentTrial when 
    %  the NtrialsInPlot box is changed and its callback is run.
    SoloParamHandle(obj, 'CurrentTrialSPH','value',1);
    
    % "width", an EditParam to control the # of trials in the plot:
    SoloParamHandle(obj, 'NtrialsInPlot', 'type', 'edit', 'label', 'ntrials', ...
                    'labelpos', 'bottom','TooltipString', 'Number of trials in plot', ...
                    'value', NtrialsToPlot, 'position', round([MyFigPosition(3:4).*[0.92,0.84], 35, 40]));
    set_callback(NtrialsInPlot, {mfilename, 'update_xlim'});

    SidesPlotSection(obj,'update',value(CurrentTrialSPH),SideList,HitHistory,TrialType);
    return;

    
  case 'update',     % ------------ CASE UPDATE --------------------
    CurrentTrialSPH.value = varargin{1};
    SideList   = varargin{2};
    if(nargin>4)
        HitHistory = varargin{3};
        if(nargin>5)
            TrialType = varargin{4};
        else
            TrialType = [];
        end
    else
        HitHistory = [];
    end
    
    CurrentTrial = value(CurrentTrialSPH);
    if(CurrentTrial<1), CurrentTrial=1; end
    
    %%% BUG: check when close to MaxTrials %%%
    %%% SideList(IndexFuture) will give an error
    
    [mn, mx] = SidesPlotSection(obj,'update_xlim');
    
    % -- Convert to numbers:  1: Left  0: Right --
    SideListNumeric = double(value(SideList)=='l');
    
    % -- First, the future trials --
    IndexFuture = CurrentTrial:mx;
    set(value(odot), 'XData', CurrentTrial, 'YData', SideListNumeric(CurrentTrial));
    
    set(value(bdot), 'XData', IndexFuture, 'YData', SideListNumeric(IndexFuture));
    %set(value(hAxesSides), 'XLim', [mn-1 mx+1]);
    
    % -- Plot past trials according to responses --
    if(~isempty(HitHistory))
        IndexToPlot = mn:CurrentTrial-1;
        IndexCorrectTrials = (HitHistory(IndexToPlot)==1);
        set(value(gdot), 'XData', IndexToPlot(IndexCorrectTrials),...
                         'YData', SideListNumeric(IndexToPlot(IndexCorrectTrials)));
        
        IndexMistakeTrials = (HitHistory(IndexToPlot)==0);
        set(value(rdot), 'XData', IndexToPlot(IndexMistakeTrials),...
                         'YData', SideListNumeric(IndexToPlot(IndexMistakeTrials)));
        
        IndexHitTrials = (HitHistory(IndexToPlot)==2);
        set(value(gcirc), 'XData', IndexToPlot(IndexHitTrials),...
                          'YData', SideListNumeric(IndexToPlot(IndexHitTrials)));
        
        IndexMissTrials = (HitHistory(IndexToPlot)==-1);
        set(value(rcirc), 'XData', IndexToPlot(IndexMissTrials),...
                          'YData', SideListNumeric(IndexToPlot(IndexMissTrials)));
    end
    
    % -- Plot type of trial --
    if(~isempty(TrialType))
        IndexSelected = find(TrialType(mn:mx)==1)+mn-1;
        set(value(stimtype), 'XData', IndexSelected, 'YData', repmat(0.5,length(IndexSelected),1));
    end    

    return;
    
  case 'update_xlim'
    %disp(n_done_trials); %%%DEBUG%%%
    %value(NtrialsInPlot); %%%DEBUG%%%
    % -- Use the last value of CurrentTrialSPH --
    mn = max(round(value(CurrentTrialSPH) - 2*value(NtrialsInPlot)/3), 1);
    mx = mn+value(NtrialsInPlot)-1;   
    set(value(hAxesSides), 'XLim', [mn-1 mx+1]);
    x = mn; y = mx;                     % Return these values
    %disp([mn,mx]); %%%DEBUG%%%
    
    return;
    
end

 
