
function crawl(top, cmd)
    cd(top);
    d=dir('.');
    d=d(3:end);
    
    flag=1;
    
    for i=1:length(d)
        
        if d(i).isdir
            crawl(d(i).name, cmd);
            flag=0;
        end
        
    end
    
    if flag
       % [S.t, S.y]=eval(cmd)
       eval(cmd);
       
    end
    
    cd ..
        
            

