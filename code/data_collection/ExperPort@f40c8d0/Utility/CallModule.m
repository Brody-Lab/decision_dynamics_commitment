function CallModule(name,action)
% CALLMODULE(NAME,ACTION)
% eval([name '(' action ')']);
		
%	fcn = [name '(''' action ''');'];
%	evalc(fcn);
    if isunix & ~strcmp(computer, 'MAC') & ~strcmp(computer, 'MACI') & ~strcmp(computer, 'GLNX86'),
       capitalize(sprintf('%s(''%s'');',name,action)),
       eval(capitalize(sprintf('%s(''%s'');',name,action)));
    else
       eval(sprintf('%s(''%s'');',name,action));
    end;
    
function [str] = capitalize(str)
    str = upper(str);
    return;
        