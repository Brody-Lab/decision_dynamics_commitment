function [vals] = psychometric_graphall(rat, task, varargin)

pairs = {
    'binmin', 0 ; ...
    'binmax', 0 ; ...
    'from', '000000'; ...
    'to', '9999999'; ...
    'dates' , [] ; ...
    'start_ind', 1; ...
    'get_psychdates_only', 0 ; ...
    'noplot' , 1 ; ...
    'binsamp', 0; ...
    'pitches', 0 ; ...
    };
parse_knownargs(varargin, pairs);


% $$$     dates = available_dates(rat, task);
% $$$     stdate = [start_date([1:2 4:5 7:8]) 'a'];
% $$$     start_ind = find(strcmp(dates, stdate));
  
  dates = get_files(rat, 'fromdate', from, 'todate', to);

vals = cell(0,0);
vals{1,1} = 'date';
if get_psychdates_only == 0
    vals{1,2} = 'weber ratio';
    vals{1,3} = 'binomial fit params';
    vals{1,4} = 'bias';
    vals{1,5} = 'bisection point';
    vals{1,6} = '-1sigma point';
    vals{1,7} = '+1sigma point';
else
    vals{1,2} = '# psychometric trials';
end;
ctr = 2;

for i = start_ind:rows(dates)
    p = get_psychometric_trials(rat, task, dates{i});
    if numel(p) > 0
       fprintf(1,'%s: Psychometric trials\n', dates{i});
        if get_psychdates_only > 0
            vals{ctr,1} = dates{i};
            vals{ctr,2} = numel(p);
        else
                vals{ctr,1} = dates{i};
                [vals{ctr, 2}, vals{ctr, 3}, vals{ctr,4}, blah, blah2, ...
                    vals{ctr,5}, vals{ctr,6}, vals{ctr, 7}] = psychometric_curve(rat, task, dates{i}, ...
                    'nodist', 1, 'noplot', noplot, ...
                    'pitches', pitches, ... 
                    'binmin', binmin, 'binmax', binmax, 'binsamp', binsamp);
                if noplot == 0
                savefig(gcf, ['smallpsych_' dates{i}], ...
                   rat, 'preset', 'singlepsych');
%                savefig(gcf, [ rat '_psych_' dates{i} '.eps']);       

                end;
        end;
         ctr = ctr  + 1;
    end;
end;

