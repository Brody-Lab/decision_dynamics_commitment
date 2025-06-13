function f = calib_flow(flows)

% function to calibrate flow controler

% parameters for calibration ('set flow' and 'actual flow')
set_flow_A = [0 1 2 4 8 10 20 40 60 80 90];
act_flow_A = [1.1 3.7 4.7 6.8 10.6 13.4 22.8 43.5 63.9 84.6 94.5];
set_flow_B = [0 1 2 4 8 10 20 40 60 80 90];
act_flow_B = [1.1 3.7 4.7 6.8 10.6 13.4 22.8 43.5 63.9 84.6 94.5];
set_flow_T = [0 20 50 100 200 400 600 700 800 900];
act_flow_T = [0 20 50 100 200 400 600 700 800 900];

for n = 1:length(flows)
    flow = flows(n);
    disp(n)
    switch n
    case 1 
        set_flow = set_flow_A;
        act_flow = act_flow_A;
        r1 = find(set_flow <= 10);
        p1 = polyfit(set_flow(r1),act_flow(r1),3);
        
        r2 = find(set_flow > 10);
        p2 = polyfit(set_flow(r2),act_flow(r2),1);
        
        figure
        plot(set_flow, act_flow,'o'); hold on 
        plot(0:10,polyval(p1,0:10))
        plot(10:100,polyval(p2,10:100))
        
        if flow >= 8
            p = p2
            p(end) = p(end) - flow;
            f(n) = roots(p);
        else p = p1    
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
        
        figure
        plot(set_flow, act_flow,'o'); hold on 
        plot(0:10,polyval(p1,0:10))
        plot(10:100,polyval(p2,10:100))
        
        if flow >= 8
            p = p2
            p(end) = p(end) - flow;
            f(n) = roots(p);
        else p = p1    
            p(end) = p(end) - flow;
            ff = roots(p);
            f(n) = min(ff);
        end
        
    case 3
        set_flow = set_flow_T;
        act_flow = act_flow_T;
        r1 = find(set_flow <= 100);
        p1 = polyfit(set_flow(r1),act_flow(r1),3);
        
        r2 = find(set_flow > 100);
        p2 = polyfit(set_flow(r2),act_flow(r2),1);
        
        figure
        plot(set_flow, act_flow,'o'); hold on 
        plot(0:100,polyval(p1,0:100))
        plot(100:1000,polyval(p2,100:1000))
        
        if flow >= 80
            p = p2;
            p(end) = p(end) - flow;
            f(n) = roots(p);
        else p = p1    
            p(end) = p(end) - flow;
            ff = roots(p);
            f(n) = min(ff);
        end
    end
end