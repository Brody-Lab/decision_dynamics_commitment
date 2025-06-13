function test_2boost_cerebro(comport)

base=serial(comport);
set(base,'BaudRate',57600);
set(base,'terminator','');
set(base,'timeout',0.05);
fopen(base);

try fprintf(base,'N'); end; pause(1);
fscanf(base)

try fprintf(base,'D,1000,1000'); end
drawnow
x=tic;
while toc(x)<3
    if base.BytesAvailable > 0
        fscanf(base)
        break
    end
end

try fprintf(base,'W,0,10,90,5000,0'); end
drawnow
x=tic;
while toc(x)<3
    if base.BytesAvailable > 0
        fscanf(base)
        break
    end
end

try fprintf(base,'T'); end
drawnow
x=tic;
while toc(x)<3
    if base.BytesAvailable > 0
        fscanf(base)
        break
    end
end

fclose(base);
 
fscanf(base);


fprintf(base,'W,0,10,35,1000,0')
fscanf(base)
fprintf(base,'T')

fprintf(base,'D,500,500'); 
fscanf(base)

fprintf(base,'W,0,1000,0,1000,0')
fscanf(base)
fprintf(base,'T')