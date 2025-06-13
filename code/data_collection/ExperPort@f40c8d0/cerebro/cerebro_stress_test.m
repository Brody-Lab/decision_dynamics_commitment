fprintf(base,'800,20000,10,40,0'); 
fscanf(base);
iti=20;
duration=20;
start=tic;
for i=1:10^5
    fprintf(base,'T');
    fscanf(base)
    pause(duration);
    time_elapsed(i)=toc(start);
    time_now(i) = now;
    a=timestr(time_elapsed(i));
    pause(iti);
    fprintf('%g trials completed. %s elapsed.\n',i,a)
end
    
% 
% iti=5;
% start=tic;
% for power=[100:50:1000]
%     mssg=sprintf('%g,%g,1000,0,0',power,power)
%     fprintf(base,mssg),pause(1);drawnow;
%     fscanf(base),drawnow;
%     pause(iti);    drawnow;
%     fprintf(base,'T')
% end