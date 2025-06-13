function VirmenPlotSection(obj, action, varargin)

try
    
    GetSoloFunctionArgs(obj);
    
    switch action
        
        % init
        case 'init'
            
            subfigure(1,10,[2:5])
            
            suptitle('BPOD Virmen Tracker')
            set(gcf,'Color',[1 1 1])
            subplot(4,2,[1 2]);
            x = -1000;
            f1 = plot(x, 'LineWidth',2 ,'Color', [0.8 0.8 0]);
            line([-100 125],[50 50],'LineStyle',':','Color',[0 0 0])
            line([-100 125],[100 100],'LineStyle',':','Color',[0 0 0])
            ylabel('Speed (cm/s)')
            xlim([-100 125])
            ylim([0 125])
            
            subplot(4,2,[3 5 7])
            f3 = plot(x, 'LineWidth',1 ,'Color', [1 0 0]);
            hold on;
            f2 = plot(x, 'LineWidth',2 ,'Color', [0 0 0]);
            line([-0.2, -0.2], [-75 125],'LineStyle',':','Color',[0 0 0])
            line([-0.1, -0.1], [-75 125],'LineStyle',':','Color',[0 0 0])
            line([0.1,   0.1], [-75 125],'LineStyle',':','Color',[0 0 0])
            line([0.2,   0.2], [-75 125],'LineStyle',':','Color',[0 0 0])
            set(gca, 'XDir' , 'reverse')
            ylabel('y (cm)')
            xlabel('Rotational velocity (rev/s)')
            ylim([-75 125])
            xlim([-0.33, 0.33])
            
            
            subplot(4,2,[4 6 8])
            f4 = plot(x, 'LineWidth',2 ,'Color', [0 0 0]);
            line([50, 50], [-75 125],'LineStyle',':','Color',[0 0 0])
            line([-50, -50], [-75 125],'LineStyle',':','Color',[0 0 0])
            
            ylim([-75 125])
            xlim([-80, 80])
            xlabel('View angle (o)')
            set(gca, 'XDir' , 'reverse')
            
            drawnow;
            fs = [f1,f2,f3,f4];
            
            SoloParamHandle(obj, 'figure_virmen', 'value', fs);
            
            % plot
        case 'plot'
            
            single_vars = varargin{1};
            i = varargin{2};
            
            subplot(4,2,[1 2])
            
            
            refPos = single_vars(1:i,2);
            speed = sqrt(sum(single_vars(1:i,4:5).^2,2));
            set(figure_virmen(1),'XData', refPos, 'YData', speed);
            
            subplot(4,2,[3 5 7])
            rotvel = atan2(-rawvel(1:i,1).*sign(rawvel(1:i,2)), abs(rawvel(1:i,2)));
            
            rawvel2 = single_vars(1:i,[5 4 6]);
            
            set(figure_virmen(3),'YData', refPos, 'XData', rawvel2(:,3)/(2*pi));
            set(figure_virmen(2),'YData', refPos, 'XData', rotvel/(2*pi));
            
            subplot(4,2,[4 6 8])
            set(figure_virmen(4),'YData', refPos, 'XData', single_vars(1:i,3)*180/pi);
            
            drawnow;
            pause(0.01);
            
        case 'plot3'
            
            position = varargin{1};
            velocity = varargin{2};
            sensors  = varargin{3};
            
            subplot(4,2,[1 2])
            
            
            refPos = position(:,2);
            speed = sqrt(sum(velocity(:,1:2).^2,2));
            set(figure_virmen(1),'XData', refPos, 'YData', speed);
            
            subplot(4,2,[3 5 7])
            rawvel = double(sensors(:,[4 3]));
            rotvel = atan2(-rawvel(:,1).*sign(rawvel(:,2)), abs(rawvel(:,2)));
            
            rawvel2 = velocity(:,[2 1 3]);
            
            set(figure_virmen(3),'YData', refPos, 'XData', rawvel2(:,3)/(2*pi));
            set(figure_virmen(2),'YData', refPos, 'XData', rotvel/(2*pi));
            
            subplot(4,2,[4 6 8])
            set(figure_virmen(4),'YData', refPos, 'XData', position(:,3)*180/pi);
            
            drawnow;
            pause(0.01);
            
    end
    
catch err
    err
end

end