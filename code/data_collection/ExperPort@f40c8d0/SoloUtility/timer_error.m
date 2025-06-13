function timer_error(obj,event,lle)

a=lasterror;
f=figure
set(f,'position',[100 100 900 900]);
set(f,'Color',[1 0 0]);

showstack(a);
	error('TIMERERROR:catcherror','Let us debug');



function showstack(le)
fprintf(1,'\n');
for xi=1:numel(le.stack)
	fprintf(1,'On line %i of %s\n',le.stack(xi).line, le.stack(xi).file);
end