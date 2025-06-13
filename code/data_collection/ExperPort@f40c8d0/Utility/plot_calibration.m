function plot_calibration

set_flow_A = [0 0.5 1 2 4 8 10 15 20 40 60 80 90];
act_flow_A = [1.5 3.9 4.3 5.5 7.6 12.2 14.3 19.1 24.8 46.5 66.8 87.4 97.8];

set_flow_B = [0 1 2 4 8 10 20 40 60 80 90];
act_flow_B = [1.1 3.8 5.0 7.8 11.4 13.9 23.4 44.1 64.5 85.3 95.1];

set_flow_T = [0 10 20 40 80 100 200 400 600 800 900];
act_flow_T = [4 11 20 40 80 100 203 430 659 865 985];

flows = [50 50 500];

for n = 1:length(flows)
    flow = flows(n);
    switch n
    case 1 
        set_flow = set_flow_A;
        act_flow = act_flow_A;
        r1 = find(set_flow <= 20);
        p1 = polyfit(set_flow(r1),act_flow(r1),3);
        
        r2 = find(set_flow > 10);
        p2 = polyfit(set_flow(r2),act_flow(r2),1);
        
        figure
        subplot(2,3,1)
        plot(set_flow, act_flow,'o'); hold on 
        plot(0:10,polyval(p1,0:10))
        plot(8:100,polyval(p2,8:100))
        plot(0:100,0:100,'r:')
        title('flow controller A')
        xlabel('set point')
        ylabel('actual flow')
        axis([0 100 0 100])
        subplot(2,3,4)
        plot(set_flow, act_flow,'o'); hold on 
        plot(0:10,polyval(p1,0:10))
        plot(8:100,polyval(p2,8:100))
        plot(0:100,0:100,'r:')
        xlabel('set point')
        ylabel('actual flow')
        axis([0 15 0 15])
        
        if flow >= 8
            p = p2;
            p(end) = p(end) - flow;
            f(n) = roots(p);
        else p = p1;
            p(end) = p(end) - flow;
            ff = roots(p);
            f(n) = min(ff);
        end
        
    case 2
        set_flow = set_flow_B;
        act_flow = act_flow_B;
        r1 = find(set_flow <= 10);
        p1 = polyfit(set_flow(r1),act_flow(r1),3);
        
        r2 = find(set_flow > 10);
        p2 = polyfit(set_flow(r2),act_flow(r2),1);
        
        if flow >= 8
            p = p2;
            p(end) = p(end) - flow;
            f(n) = roots(p);
        else p = p1;
            p(end) = p(end) - flow;
            ff = roots(p);
            f(n) = min(ff);
        end
        subplot(2,3,2)
        plot(set_flow, act_flow,'o'); hold on 
        plot(0:10,polyval(p1,0:10))
        plot(8:100,polyval(p2,8:100))
        plot(0:100,0:100,'r:')
        xlabel('set point')
        ylabel('actual flow')
        title('flow controller B')
        axis([0 100 0 100])
        subplot(2,3,5)
        plot(set_flow, act_flow,'o'); hold on 
        plot(0:10,polyval(p1,0:10))
        plot(8:100,polyval(p2,8:100))
        plot(0:100,0:100,'r:')
        xlabel('set point')
        ylabel('actual flow')
        axis([0 15 0 15])
        
    case 3
        set_flow = set_flow_T;
        act_flow = act_flow_T;
        r1 = find(set_flow <= 100);
        p1 = polyfit(set_flow(r1),act_flow(r1),3);
        
        r2 = find(set_flow > 100);
        p2 = polyfit(set_flow(r2),act_flow(r2),1);
        
        if flow >= 80
            p = p2;
            p(end) = p(end) - flow;
            f(n) = roots(p);
        else p = p1;
            p(end) = p(end) - flow;
            ff = roots(p);
            f(n) = min(ff);
        end
        subplot(2,3,3)
        plot(set_flow, act_flow,'o'); hold on 
        plot(0:100,polyval(p1,0:100))
        plot(80:1000,polyval(p2,80:1000))
        plot(0:1000,0:1000,'r:')
        xlabel('set point')
        ylabel('actual flow')
        title('flow controller for carrier')
        axis([0 1000 0 1000])
        subplot(2,3,6)
        plot(set_flow, act_flow,'o'); hold on 
        plot(0:100,polyval(p1,0:100))
        plot(80:1000,polyval(p2,80:1000))
        plot(0:1000,0:1000,'r:')
        xlabel('set point')
        ylabel('actual flow')
        axis([0 150 0 150])
    end
end