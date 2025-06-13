function test_2boost_cerebro(comport)

base=serial(comport);
set(base,'BaudRate',57600);
set(base,'terminator','');
set(base,'timeout',0.05);
fopen(base);

send_and_read(base,'N');

disp('---------------------');
disp('HIGH POWER SLOW PULSE LEFT')
send_and_read(base,'D,2000,0');
send_and_read(base,'W,0,10,90,5000,0');
send_and_read(base,'T');
pause(5);

disp('---------------------');
disp('HIGH POWER SLOW PULSE RIGHT')
send_and_read(base,'D,0,2000');
send_and_read(base,'W,0,10,90,5000,0');
send_and_read(base,'T');
pause(5);

disp('---------------------');
disp('MEDIUM POWER SLOW PULSE BOTH')
send_and_read(base,'D,1500,1500');
send_and_read(base,'W,0,10,90,5000,0');
send_and_read(base,'T');
pause(5);

disp('---------------------');
disp('LOW POWER TONIC LEFT')
send_and_read(base,'D,1000,0');
send_and_read(base,'W,0,2000,0,2000,0');
send_and_read(base,'T');
pause(2);

disp('---------------------');
disp('LOW POWER TONIC RIGHT');
send_and_read(base,'D,0,1000');
send_and_read(base,'W,0,2000,0,2000,0');
send_and_read(base,'T');
pause(2);

fclose(base);

function send_and_read(base,command)

try fprintf(base,command); end
drawnow
x=tic;
while toc(x)<3
    if base.BytesAvailable > 0
        fscanf(base)
        %break
    end
end
