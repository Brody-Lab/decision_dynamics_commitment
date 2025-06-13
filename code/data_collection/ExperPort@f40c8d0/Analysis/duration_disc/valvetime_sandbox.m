function [] = valvetime_sandbox

ratlist = {'S035','S034','S038','S036','S039'};

lw = [];
rw = [];
for r = 1:length(ratlist)
    load_datafile(ratlist{r}, '080917a');
    lw = horzcat(lw,saved.WaterSection_LeftWValve);
    rw = horzcat(rw,saved.WaterSection_RightWValve);    
end;

2;
