function [] = jeffpsych_test(ratname, indate)

addpath('Analysis/jce_helpers/');

get_fields(ratname, 'use_dateset','given', 'given_dateset',{indate}, ...
    'datafields',{'sides','flipped','tones_list'});

wl = zeros(size(sides)); % 1 - went left, 0 - went right
wleft = union( intersect(find(sides == 1), find(hit_history==1)), ... % went left correctly
    intersect(find(sides == 0), find(hit_history==0))); % went left incorrectly
wl(wleft) = 1;

if ~flipped
 sc = 1-wl;
else
    sc = wl;
end;
%  save('sample_psychinput', 'tones_list', 'wl');

%load('sample_psychinput');

ratrow = rat_task_table(ratname);
task = ratrow{1,2};
if strcmpi(task(1:3),'dur')
    mp = sqrt(200*500);
    ispitch = 0;
    tones_list = tones_list*1000;
    fmt = '%3.2f';
    mybase = exp(1);
    stimunits = 'ms';
else
    mp = 11.3;
    ispitch = 1;
    fmt = '%1.2f';
    mybase = 2;
    stimunits = 'kHz';
end;

psychometric_curve(ratname, indate,'nodist',1);
%psychoplot4(tones_list*1000, wl);
out = psychoplot4_sp('init',tones_list, sc, mp,ispitch,'graphic_getweber', 0);
%figure; 
plot(out.interp_x, out.interp_y,'ob')
%title(sprintf('%s:%s', ratname, indate));

% print params
bh = out.betahat; ci = out.ci;

fprintf(1,'Lower bound = %1.1f (%1.2f - %1.2f)\n', bh(1), ci(1,1), ci(1,2));
fprintf(1,'Upper bound = %1.1f (%1.2f - %1.2f)\n', bh(2), ci(2,1), ci(2,2));
fprintf(1, ['Bias = ' fmt stimunits ' (' fmt ' - ' fmt ')\n'], mybase.^bh(3) - mp, mybase.^ci(3,1) - mp, mybase.^ci(3,2) - mp);
fprintf(1, ['Slope = ' fmt ' (' fmt ' - ' fmt ')\n'], bh(4), ci(4,1), ci(4,2));


2;

