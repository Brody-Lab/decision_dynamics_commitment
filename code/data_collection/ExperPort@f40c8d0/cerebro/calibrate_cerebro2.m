function calibrate_cerebro2(pwr_set,pulsedur,varargin)

if nargin < 1; pwr_set = 1000:300:2200; end
if nargin < 2; pulsedur = 2; end
do = {'Diode1','Diode2'};


base = cerebro2_init;

fopen(base);

cerebro2_send(base,'N'); drawnow; pause(1);
cerebro2_scan(base,1); drawnow; pause(1);
cerebro2_send(base,['W,0,',num2str(pulsedur * 1000),',0,',num2str(pulsedur * 1000),',0']); drawnow; pause(1);

for p = 1:numel(pwr_set);
    for s = 1:numel(do);
    
        if strcmp(do{s},'Diode1'); str = [num2str(pwr_set(p)),',0'];
        else                       str = ['0,',num2str(pwr_set(p))];
        end
        disp([do{s},' ',num2str(pwr_set(p)),'  ',str]);
            
        cerebro2_send(base,['D,',str]); drawnow; pause(5);
        cerebro2_scan(base,1); drawnow; pause(5);
        
        cerebro2_send(base,'T'); drawnow; pause(5);
        cerebro2_scan(base,1); drawnow; pause(45);
    end
end

fclose(base);
disp(' ');
disp('COMPLETE');