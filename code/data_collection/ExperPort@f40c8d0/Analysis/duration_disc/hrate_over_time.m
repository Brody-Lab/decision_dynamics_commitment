function [out] = hrate_over_time(hh, varargin)
% shows hit rate for successive blocks of 'window' trials

pairs = { ...
    'varwindow', 20 ; ...
    'chunk', 0 ; ... % 1 = non-overlapping windows, 0 = overlapping windows
    'lookahead', 0; ... %
    'use_exponential_filter', 1; ...
    };
parse_knownargs(varargin,pairs);

if chunk > 0,
    error('Sorry, I no longer show hit rates in chunks!');
end;

out ={};
out.chunked_hh = {};
out.overall_hh = [];
out.tally = [];
out.window = varwindow;

if isempty(hh)
    return;
end;

if use_exponential_filter == 0

if chunk > 0
    chunks = floor(length(hh)/varwindow);
    chunked_hh = [];
    for c = 1:chunks
        sidx = ((c-1)*varwindow)+1;
        eidx = c*varwindow;
        %    fprintf(1,'%i - %i\n', sidx,eidx);
        chunked_hh = vertcat(chunked_hh, [mean(hh(sidx:eidx)) std(hh(sidx:eidx))]);
    end;

else
    overall_rate = mean(hh);
    if lookahead > 0
        last_win = length(hh) - (varwindow-1);
        binned = zeros(1,last_win);
        for start_ind = 1:last_win
            binned(start_ind) = mean(hh(start_ind:start_ind+(varwindow-1)));
        end;
    else
        first_win = varwindow;
        binned = zeros(1, length(hh)-(varwindow-1));
        for idx = varwindow:length(hh)
            start_idx = max(1, (idx-varwindow)+1);
            binned(idx - (varwindow-1)) = mean(hh(start_idx:idx));
        end;
    end;
    chunked_hh = binned;
end;

out.chunked_hh = chunked_hh;

else
x = 1:length(hh);

nums=[];
  t = (1:length(hh))';
            a = zeros(size(t));
for i=1:length(hh),
    x = 1:i;
    kernel = exp(-(i-t(1:i))/varwindow);
    kernel = kernel(1:i) / sum(kernel(1:i));

    a(i) = sum(hh(x)' .*kernel);
end;
num = a;
out.chunked_hh = a;
end;

out.overall_hh = [mean(hh) std(hh)];
out.tally = length(hh);
