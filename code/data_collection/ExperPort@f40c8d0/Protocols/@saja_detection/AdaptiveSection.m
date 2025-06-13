% This plugin modifies task difficulty to maintain a target level of
% performance.

% Peter Znamenskiy 2008-07-18

function [xpos, ypos, NewDifficulty] = AdaptiveSection(obj, action, varargin)

GetSoloFunctionArgs(obj);

switch action
  case 'init'
    xpos = varargin{1};
    ypos = varargin{2};
    
    MaxBlocks = 500;
    
    MenuParam(obj, 'AdjustMethod', {'constant_multiplier'}, 'constant_multiplier', ...
        xpos, ypos, 'TooltipString', 'Method for adjusting difficulty');
    
    NumeditParam(obj, 'TargetPerf', 0.7, xpos, ypos); next_row(ypos);
    NumeditParam(obj, 'StepSize', 0.8, xpos, ypos); next_row(ypos);
    NumeditParam(obj, 'BlockSize', 10, xpos, ypos); next_row(ypos);
    NumeditParam(obj, 'WarmupTrials', 0, xpos, ypos); next_row(ypos);
    %set_callback(BlockSize, {mfilename, 'update_gui'});    
        
    SoloParamHandle(obj, 'DifficultyHist','value',...
        nan(1,MaxBlocks));
    
    SoloParamHandle(obj, 'PerformanceHist','value',...
        nan(1,MaxBlocks));
    SoloParamHandle(obj, 'BlocksDone', 'value', 0);
    SoloParamHandle(obj, 'LastUpdated', 'value', 0);

    screen_size = get(0, 'ScreenSize');
    
    SoloParamHandle(obj, 'orig_fig', 'value', gcf);
    SoloParamHandle(obj, 'myfig', 'value', figure('Position', [1 screen_size(4)-740, 435 435], ...
      'closerequestfcn', [mfilename '(' class(obj) ', ''hide'');'], 'MenuBar', 'none', ...
      'Name', mfilename), 'saveable', 0);

    
    SoloParamHandle(obj, 'ShowBlocks', 'value', 40, 'saveable', 0);

    axescoords = [0.15, 0.2, 0.70, 0.7];
    SoloParamHandle(obj, 'hAxesPerf', 'saveable', 0, 'value',...
        axes('Position', axescoords));
    SoloParamHandle(obj, 'hAxesDiff', 'saveable', 0, 'value',...
        axes('Position', axescoords, 'Color', 'none'));    

%    SoloParamHandle(obj, 'perfdot', 'saveable', 0, 'value',...
%                    plot(value(hAxesPerf), -1, 1, 's','Color',ColorType1,'MarkerSize',MarkerSize));hold on;
%    SoloParamHandle(obj, 'diffdot', 'saveable', 0, 'value',...
%                    plot(value(hAxesDiff), -1, 1, 's','Color',ColorType2,'MarkerSize',MarkerSize));hold on;    
    
    figure(value(orig_fig));
                
    
  % called at the end of every trial; adjusts difficulty and updates
  % performance and difficulty plots
  case 'update'
    CorrectTrials = varargin{1};
    TrialsToInclude = varargin{2};
    CurrentDifficulty = varargin{3};

    DifficultyHist(value(BlocksDone)+1) = CurrentDifficulty;    
    
    % Is it time to update difficulty yet?
    if sum(TrialsToInclude) >= sum(TrialsToInclude(1:value(LastUpdated)))+value(BlockSize)
    disp('Updating difficulty...');
    BlocksDone.value = value(BlocksDone) + 1;
    LastUpdated.value = find(TrialsToInclude, 1, 'last' );
        
    IncludedTrials = CorrectTrials(TrialsToInclude);
    Performance = sum(IncludedTrials(end-value(BlockSize)+1:end)) / value(BlockSize);
    PerformanceHist(value(BlocksDone)) = Performance;
    
    switch value(AdjustMethod)
      case 'constant_multiplier'
          disp([ 'Performance: ' num2str(Performance) ]);
          disp([ 'Target performance: ' num2str(value(TargetPerf)) ]);
        if Performance > value(TargetPerf)
            NewDifficulty = CurrentDifficulty * value(StepSize);
        else
            NewDifficulty = CurrentDifficulty / value(StepSize);
        end
    end % SWITCH

    DifficultyHist(value(BlocksDone)+1) = NewDifficulty;
    AdaptiveSection(obj, 'update_gui');
    else
        NewDifficulty = CurrentDifficulty;
    end % IF
    xpos = 0; ypos = 0; % fix this!
    
  case 'update_gui'
    MarkerSize = 4;
    PerfColor = 'b';
    DiffColor = 'r';
    
    plot(value(hAxesPerf), 1:value(BlocksDone), PerformanceHist(1:value(BlocksDone)),...
        's','Color',PerfColor,'MarkerSize',MarkerSize);
    set(value(hAxesPerf), 'YAxisLocation','right', 'YColor', PerfColor, 'XTick', [],...
        'YLim', [ 0 1.2 ], 'XLim', [0 max([value(BlocksDone) 20])], 'YTick', [0:0.2:1],...
        'YGrid', 'on');
    ylabel(value(hAxesPerf), 'Performance');

    plot(value(hAxesDiff), 1:value(BlocksDone), DifficultyHist(1:value(BlocksDone)),...
        's','Color',DiffColor,'MarkerSize',MarkerSize);
    maxy = max(DifficultyHist(1:value(BlocksDone)));
    set(value(hAxesDiff), 'YLim', [0 maxy*1.2], 'YTick', [0:maxy/5:maxy],...
        'XLim', [0 max([value(BlocksDone) 20])], 'Color', 'none');
    ylabel(value(hAxesDiff), 'Difficulty');
    xlabel(value(hAxesDiff), 'Blocks');
    
    %set(value(diffdot), 'XData', 1:value(BlocksDone)+1, 'YData', DifficultyHist(1:value(BlocksDone)+1));
    %yScaleDiff = [ 0 max(DifficultyHist(1:value(BlocksDone)))*1.2 ];
    %set(value(hAxesDiff), 'YLim', yScaleDiff);
    %yScalePerf = get(value(hAxesPerf), 'YLim');
    
    % Scale performance values to match difficulty axes;
    %ScaledPerformanceHist = (PerformanceHist(1:value(BlocksDone)) - yScalePerf(1))/(yScalePerf(2) - yScalePerf(1));
    %ScaledPerformanceHist = ScaledPerformanceHist * (yScaleDiff(2) - yScaleDiff(1)) + yScaleDiff(1);
    
    %set(value(perfdot), 'XData', 1:value(BlocksDone), 'YData', PerformanceHist(1:value(BlocksDone)));

    % Make sure the axes didn't change
    %set(value(hAxesDiff), 'YLim', yScaleDiff);
end
