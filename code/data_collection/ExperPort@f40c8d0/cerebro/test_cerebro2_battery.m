

power = [700,700];

base = cerebro2_init;

fopen(base);

cerebro2_send(base,'N'); drawnow; pause(3);
cerebro2_scan(base,1); drawnow; pause(3);
cerebro2_send(base,'W,0,1000,0,1000,0'); drawnow; pause(3);

cerebro2_send(base,['D,',num2str(power(1)),',',num2str(power(2))]); drawnow; pause(3);
cerebro2_scan(base,1); drawnow; pause(3);

cycle_time = 20;
while 1
            
    x = now;

    cerebro2_send(base,'T'); drawnow; pause(3);
    beep;
    cerebro2_scan(base,1); drawnow;
    
    pause_time = cycle_time - ((now - x) * 24 * 3600);
    disp(['Pausing for ',num2str(pause_time)]);
    pause(pause_time);
end

fclose(base);
disp(' ');
disp('COMPLETE');