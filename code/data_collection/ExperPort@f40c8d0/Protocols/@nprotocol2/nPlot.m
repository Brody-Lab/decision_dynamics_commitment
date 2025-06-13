function [ ] = nPlot(obj, action)
%build1 Summary of this function goes here
%   Detailed explanation goes here
%   line_wPl,line_wPr,line_sPl and line_sPr --> lines
%   dot_spl,dot_spr,dot_wpl,dot_wpr --> dots
% THINGS TO DO:
%   REFRESH PLOT
%   PLOT ACTUAL BINARY VECTOR
%   PLOT RAT'S CHOICES

GetSoloFunctionArgs;

switch action,
    case 'init',
        
        SoloParamHandle(obj,'hAxes', 'saveable', 0, 'value', axes('Position', [0.39 0.675 0.6 0.3]));
%         axis([0 value(blockSize) -0.5 1.5])
        set(value(hAxes),'xlim',[0 value(xRange)],'ylim', [-0.6 1.4]);hold on
%         a = plot(value(hAxes), 0,0, 'b-');
%         SoloParamHandle(obj,'line_wPl','value',a); hold on 
        SoloParamHandle(obj, 'dot_ratChoice_l','value',plot(value(hAxes),-1,0, ...
                        'LineStyle','none','MarkerSize', 7, 'Marker','<','Color','k',...
                        'MarkerFaceColor','k')); hold on
        SoloParamHandle(obj, 'dot_ratChoice_r','value',plot(value(hAxes),-1,0, ...
                        'LineStyle','none','MarkerSize', 7, 'Marker','>','Color','k',...
                        'MarkerFaceColor','k')); hold on
        SoloParamHandle(obj,'line_wPl','value',plot(value(hAxes),-1,0, 'b-')); hold on
        SoloParamHandle(obj,'line_wPr','value',plot(value(hAxes),-1,0,'b--')); hold on
        SoloParamHandle(obj,'line_sPl','value',plot(value(hAxes),-1,0,'r-')); hold on
        SoloParamHandle(obj,'line_sPr','value',plot(value(hAxes),-1,0,'r--')); hold on
        SoloParamHandle(obj,'dot_wPl','value',plot(value(hAxes),-1,0,'b<')); hold on
        SoloParamHandle(obj,'dot_wPr','value',plot(value(hAxes),-1,0,'b>')); hold on
        SoloParamHandle(obj,'dot_sPl','value',plot(value(hAxes),-1,0,'r<')); hold on
        SoloParamHandle(obj,'dot_sPr','value',plot(value(hAxes),-1,0,'r>')); hold on
        SoloParamHandle(obj, 'ratChoice_vec', 'value', 0);
        
        SoloParamHandle(obj, 'hPatch','value',patch(n_done_trials+[0.5 0.5 1.5 1.5],[-0.6 1.4 1.4 -0.6],...
            'y','EdgeColor', 'none'));
        hChildren = get(value(hAxes),'children');
        ordered_hChildren = [hChildren(2:end);hChildren(1)];
        set(value(hAxes),'children', ordered_hChildren);

        DeclareGlobals(obj, 'rw_args', {'line_wPl','line_wPr','line_sPl','line_sPr',...
            'dot_wPl','dot_wPr','dot_sPr','dot_sPr','hAxes','dot_ratChoice_l', 'dot_ratChoice_r',...
            'ratChoice_vec'});
% hold off;
%         plot(value(hAxes),0,0)
        hold on
%         [#1 #2 ... is the middle of the figure ... #3 #4] is the relative size of the fig

        


    case 'build',
        plot1=load(['Protocols\@nprotocol2\WaterProfiles\',value(waterProfileLeft)]);        
        probVector_toPlot1(1,blockSize*length(plot1))=0;
        for i=1:1:length(plot1)
            probVector_toPlot1((i-1)*value(blockSize)+1:i*value(blockSize))=plot1(i);
        end;
        set(value(line_wPl),'XData',1:length(probVector_toPlot1),'YData',probVector_toPlot1); %(value(blockSize), plot1(i,:))%value(probvec_waterLeft)*blockSize
        
        plot2=load(['Protocols\@nprotocol2\WaterProfiles\',value(waterProfileRight)]);
        probVector_toPlot2(1,blockSize*length(plot2))=0;
        for i=1:1:length(plot2)
            probVector_toPlot2((i-1)*value(blockSize)+1:i*value(blockSize))=plot2(i);
        end;
        set(value(line_wPr), 'XData',1:length(probVector_toPlot2),'YData',probVector_toPlot2);
        
        plot3=load(['Protocols\@nprotocol2\ShockProfiles\',value(shockProfileLeft)]);
        probVector_toPlot3(1,blockSize*length(plot3))=0;
        for i=1:1:length(plot3)
            probVector_toPlot3((i-1)*value(blockSize)+1:i*value(blockSize))=plot3(i);
        end;
        set(value(line_sPl),'XData',1:length(probVector_toPlot3),'YData', probVector_toPlot3);
        
        plot4=load(['Protocols\@nprotocol2\ShockProfiles\',value(shockProfileRight)]);
        probVector_toPlot4(1,blockSize*length(plot3))=0;
        for i=1:1:length(plot4)
            probVector_toPlot4((i-1)*value(blockSize)+1:i*value(blockSize))=plot4(i);
        end;
        set(value(line_sPr),'XData',1:length(probVector_toPlot4),'YData', probVector_toPlot4);

        axis([0 value(xRange) -0.6 1.4])
        grid off
        axis normal

% CREATE VECTORS TO RELOCATE ON THE PLOT
        SoloParamHandle(obj,'plotShockLeft', 'value', value(probvec_shockLeft));
        for i=1:1:length(probvec_shockLeft)
            if probvec_shockLeft(i) ==1
                plotShockLeft(i) = -0.4;
            else 
                plotShockLeft(i) = -1.4;
            end;
        end;
        set(value(dot_sPl),'XData', 1:length(probvec_shockLeft), 'YData',value(plotShockLeft));
        
        SoloParamHandle(obj,'plotShockRight', 'value', value(probvec_shockRight));
        for i=1:length(probvec_shockRight)
            if probvec_shockRight(i) ==1
                plotShockRight(i) = -0.5;
            else
                plotShockRight(i) = -1.5;
            end
        end
        set(value(dot_sPr),'XData', 1:length(plotShockRight), 'YData',value(plotShockRight));
        
        SoloParamHandle(obj,'plotWaterLeft', 'value', value(probvec_waterLeft));
        for i=1:length(probvec_waterLeft)
            if probvec_waterLeft(i) ==1
                plotWaterLeft(i) = -0.1;
            else
                plotWaterLeft(i) = -1.1;
            end
        end
        set(value(dot_wPl),'XData', 1:length(plotWaterLeft), 'YData',value(plotWaterLeft));
        
        SoloParamHandle(obj,'plotWaterRight', 'value', value(probvec_waterRight));
        for i=1:length(probvec_waterRight)
            if probvec_waterRight(i) ==1
                plotWaterRight(i) = -0.2;
            else
                plotWaterRight(i) = -1.2;
            end
        end
        set(value(dot_wPr),'XData', 1:length(plotWaterRight), 'YData',value(plotWaterRight));
        
%         TRIAL STATUS BAR
%         axes(value(hAxes));  
%         SoloParamHandle(obj, 'hPatch','value',patch(n_done_trials+[0.5 0.5 1.5 1.5],[-0.5 1.5 1.5 -0.5],...
%             'y','EdgeColor', 'none'));
%         hChildren = get(value(hAxes),'children');
%         ordered_hChildren = [hChildren(2:end);hChildren(1)];
%         set(value(hAxes),'children', ordered_hChildren);
    
    

    case 'update'
%         axis([n_done_trials-value(xRange)/2 value(xRange) -0.5 1.5])
        set(value(hAxes),'xlim',floor(n_done_trials/value(xRange))*value(xRange)+[0 value(xRange)]);
    case 'next_trial'
        
        axes(value(hAxes));
        set(value(hPatch), 'XData',n_done_trials+[0.5 0.5 1.5 1.5],'YData',[-0.6 1.4 1.4 -0.6]);
            
        set(value(hAxes),'xlim',floor(n_done_trials/value(xRange))*value(xRange)+[0 value(xRange)]);
%         (n_done_trials-n_done_trials)*value(blockSize)+n_done_trials n_done_trials*value(blockSize)

% ACTUAL RAT'S CHOICES
%  ratChoice_vec = zeros(1,1);
%         for i=1:length(parsed_events_history) %#ok<ALIGN>
%             if ~isempty(parsed_events_history{n_done_trials}.pokes.L(1,1)) && ~isempty(parsed_events_history{n_done_trials}.pokes.R(1,1))
% %          find the lowest one and plot that
%             end%         end 

           if isempty(parsed_events)
           
           else
                if ~isempty(parsed_events.states.l_poke_in_shock_start)
                   ratChoice_vec(n_done_trials)=-0.301;
                end
                if ~isempty(parsed_events.states.r_poke_in_shock_start)
                   ratChoice_vec(n_done_trials)=-0.302;
                end
                if isempty(parsed_events.states.l_poke_in_shock_start) && isempty(parsed_events.states.r_poke_in_shock_start)
                   ratChoice_vec(n_done_trials)=0;
                end
            end

%             for i=1:length(ratChoice_vec)
%                 if ratChoice_vec(i) ==1
%                     ratChoice_vec(i) = -0.1;
%                 elseif ratChoice_vec(i) ==2
%                     ratChoice_vec(i) = -0.2;
%                 elseif ratChoice_vec(i) ==0
%                      ratChoice_vec(i) = 0;
%                 end
%             end

    L_choice_idx = find(value(ratChoice_vec)==-0.301);
    R_choice_idx = find(value(ratChoice_vec)==-0.302);
    set(value(dot_ratChoice_l),'XData', L_choice_idx, 'YData',ratChoice_vec(L_choice_idx));
    set(value(dot_ratChoice_r),'XData', R_choice_idx, 'YData',ratChoice_vec(R_choice_idx));

end;        






% %         if value(plotWaterLeft(n_done_trials+1)) == -1.1
% % %             plot(value(hAxes), n_done_trials+1, value(plotWaterLeft), 'wo')
% %         else
% %             plot(value(hAxes), n_done_trials+1, value(plotWaterLeft), 'ko')
% %         end;
% %         
% %         if value(plotWaterRight(n_done_trials+1)) == -1.2
% % %             plot(value(hAxes), n_done_trials+1, value(plotWaterRight), 'wo')
% %         else
% %             plot(value(hAxes), n_done_trials+1, value(plotWaterRight), 'ko')
% %         end;
% %         
% %         if value(plotShockLeft(n_done_trials+1)) == -1.3
% % %             plot(value(hAxes), n_done_trials+1, value(plotShockLeft), 'wo')
% %         else
% %             plot(value(hAxes), n_done_trials+1, value(plotShockLeft), 'ko')
% %         end;
% %         
% %         if value(plotShockRight(n_done_trials+1)) == -1.4
% % %             plot(value(hAxes), n_done_trials+1, value(plotShockRight), 'wo')
% %         else
% %             plot(value(hAxes), n_done_trials+1, value(plotShockRight), 'ko')
% %         end;        
        
%         plot(value(hAxes), n_done_trials+1, value(probvec_shockLeft(n_done_trials+1)), 'rx')%; hold off
%         plot(value(hAxes), n_done_trials+1, value(probvec_shockRight(n_done_trials+1)), 'ms')%; hold off
%         plot(value(hAxes), n_done_trials+1, value(probvec_waterLeft(n_done_trials+1)), 'b*')%; hold off
%         plot(value(hAxes), n_done_trials+1, value(probvec_waterRight(n_done_trials+1)), 'cd')%; hold off
        
%         axis([0 100 -0.5 1.5])
%         grid off
%         axis square

