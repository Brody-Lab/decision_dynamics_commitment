function [varargout]=sqlget(colm,tabl,where)
%function out=sqlget(colm,tabl,where)
    
    if ~exist('where')
        where=[];
    end
    

    n=length(find(colm==','))+1;
    if n~=nargout
        warning('Number of columns must equal number of outputs');
        return;
    end
    out='C1';
    for i=2:n
        out=[out ' C' num2str(i)];
    end
    
    out=['[' out ']'];
    
    if where
        sql=['select ' colm ' from ' tabl ' where '  where];
    else
        sql=['select ' colm ' from ' tabl];
    end
    
    eval([out '=mym(sql);'])
    
    for i=1:n 
        varargout(i)={eval(['C' num2str(i)])}; 
    end
        