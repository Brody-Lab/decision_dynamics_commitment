function [] = side_rewards(rat, task, date, varargin)

pairs = { ...
    'windows', -1 ; ...
    'show_trend', 0 ; ...
    };
parse_knownargs(varargin, pairs);

load_datafile(rat, task, date(1:end-1), date(end));

sides = saved.SidesSection_side_list;

hh = eval(['saved.' task '_hit_history']);
hh = hh(find(~isnan(hh)));

sides = sides(1:length(hh));

left = find(sides == 1); right = find(sides == 0);

lp = sum(hh(left))/length(left);
left_stdev = sqrt((lp*(1-lp))/length(left));
rp = sum(hh(right))/length(right);
right_stdev = sqrt((rp*(1-rp))/length(right));

fprintf(1, '\nSIDE REWARDS:\n');
fprintf(1, '----------------------\n');
fprintf(1, 'Trials = %i\n', length(hh));
fprintf(1, 'OVERALL LEFT: %i rewards/%i trials (%2.1f%%), SD: %2.1f%%\n', sum(hh(left)), length(left),  lp*100, left_stdev*100)
fprintf(1,'OVERALL RIGHT: %i rewards/%i trials (%2.1f%%), SD: %2.1f%%\n\n', sum(hh(right)), length(right), rp*100, right_stdev*100)

left_pct = cell(0,0); right_pct = cell(0,0);i=0;

if windows > 0
    start = 1; fin = start+(windows-1);
    while fin <= length(hh)
        i = i+1; hh2 = hh(start:fin);
        sides2=sides(start:fin); left2 = find(sides2==1); right2= find(sides2==0);
        lp2 = sum(hh2(left2))/length(left2); rp2=sum(hh2(right2))/length(right2);
    %    fprintf(1,'%i to %i: LHS: (%i/%i) (%2.1f%%)\n', start, fin, sum(hh2(left2)), length(left2), lp2*100)
    %    fprintf(1,'%i to %i: RHS: (%i/%i) (%2.1f%%)\n\n', start, fin, sum(hh2(right2)), length(right2), rp2*100)
              left_pct{i} = [start fin sum(hh2(left2)) length(left2) lp2*100];
        right_pct{i} =  [start fin sum(hh2(right2)) length(right2) rp2*100];

        start = start+windows;
        fin = start+(windows-1);
  
    end;

    if start < length(hh)
        i = i+1;
        fin = length(hh); hh2 = hh(start:fin);
        sides2=sides(start:fin); left2 = find(sides2==1); right2= find(sides2==0);
        lp2 = sum(hh2(left2))/length(left2); rp2=sum(hh2(right2))/length(right2);
                left_pct{i} = [start fin sum(hh2(left2)) length(left2) lp2*100];
        right_pct{i} =  [start fin sum(hh2(right2)) length(right2) rp2*100];

    %    fprintf(1,'%i to %i: LHS: (%i/%i) (%2.1f%%)\n', start, fin, sum(hh2(left2)), length(left2), lp2*100)
    %    fprintf(1,'%i to %i: RHS: (%i/%i) (%2.1f%%)\n\n', start, fin, sum(hh2(right2)), length(right2), rp2*100)

    end;


    if show_trend        
%        figure;
        left = []; right=[]; bins = [];
        for k = 1:length(left_pct), 
            bins = [bins left_pct{k}(2)];
            left = [left left_pct{k}(5)]; 
            right = [right right_pct{k}(5)]; 
        end;
        plot(bins, left, '-b.', bins, right, '-g.');
        for k = 1:length(left_pct) 
            text(bins(k)-(windows/20), left(k)+5, sprintf('%i/%i', left_pct{k}(3), left_pct{k}(4)), 'Color', [0 0 0.6]);
            text(bins(k)-(windows/20), right(k)+5, sprintf('%i/%i', right_pct{k}(3), right_pct{k}(4)), 'Color', [0 0.6 0]);
        end;
        legend('Left trials', 'Right trials', 'Location','SouthEast');
        ylabel(sprintf('%% Rewards (by side)\n %i-trial windows', windows));
        xlabel('Trial #');
        title(sprintf('%s: %s (%s)\nSide rewards: n=%i', ...
                make_title(rat), make_title(task), date, length(hh)));
       % set(gca, 'Position', [200 153 314 247]);
       axis([0 length(hh)+(windows/2) 0 110]);

    end;
end;


