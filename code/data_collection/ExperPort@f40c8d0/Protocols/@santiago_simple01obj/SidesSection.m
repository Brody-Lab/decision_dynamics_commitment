% This function defines the reward side for each trial.
%
% Santiago Jaramillo - 2007.05.15

function SidesSection(obj,action)


GetSoloFunctionArgs; % See PROTOCOLNAMEobj.m for the list of
                     % variables passed to this function.

switch action
  case 'update'
    FutureTrials = [value(NdoneTrials)+1 : value(MaxTrials)];
    % -- Left:1  Right:0 --
    SidesListVec = rand(length(FutureTrials),1)<value(LeftProb);
    % -- Update only future trials --
    SidesList(FutureTrials) = SidesListVec;
    
  case 'initplot'
    TrialsToPlot = [ 1 : min(value(MaxTrials),value(NtrialsToPlot)) ];
    axes(value(hSidesAxes));
    hSidesPlot.value = plot(SidesList(TrialsToPlot),'ob','MarkerFaceColor','none');
    hold on;
    %%%%%%%% SLOW, fix by using index of trials to plot %%%%%%%%%%%
    TrialsHit = find(HitHistory(TrialsToPlot)==1) + TrialsToPlot(1)-1;
    TrialsError = find(HitHistory(TrialsToPlot)==0) + TrialsToPlot(1)-1;
    hHitPlot.value = plot(TrialsHit,SidesList(TrialsHit),'og','MarkerFaceColor','g');
    hErrorPlot.value = plot(TrialsError,SidesList(TrialsError),'or','MarkerFaceColor','r');
    hold off;
    ylim([-0.5,1.5])
    xlabel('Trial');
    set(gca,'YTick',[0,1],'YTickLabel',{'Right','Left'});
    
  case 'updateplot'
    %TrialsToPlot = [ max(1,value(NdoneTrials)-value(NtrialsToPlot)) : ...
    TrialsToPlot = [ 1 : min(value(MaxTrials),value(NtrialsToPlot)) ];
    axes(value(hSidesAxes));
    %plot(SidesList(TrialsToPlot),'ob');
    
    %%%%%%%%  REPEATED CODE from above, should be only once! %%%%%%%%
    hSidesPlot.value = plot(SidesList(TrialsToPlot),'ob','MarkerFaceColor','none');
    hold on;
    %%%%%%%% SLOW, fix by using index of trials to plot %%%%%%%%%%%
    TrialsHit = find(HitHistory(TrialsToPlot)==1) + TrialsToPlot(1)-1;
    TrialsError = find(HitHistory(TrialsToPlot)==0) + TrialsToPlot(1)-1;
    hHitPlot.value = plot(TrialsHit,SidesList(TrialsHit),'og','MarkerFaceColor','g');
    hErrorPlot.value = plot(TrialsError,SidesList(TrialsError),'or','MarkerFaceColor','r');
    ylim([-0.5,1.5])
    xlabel('Trial');
    set(gca,'YTick',[0,1],'YTickLabel',{'Right','Left'});
    
end
