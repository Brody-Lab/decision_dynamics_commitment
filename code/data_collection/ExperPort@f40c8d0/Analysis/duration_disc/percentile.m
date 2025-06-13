function [pct] = percentile(data, p_array)
% returns value UNDER which p percent of the data lie.
% data should be a vector
% p ranges between 1 and 100.

[sorted idx] = sort(data);

pct = [];
for idx = 1:length(p_array)
    p = p_array(idx);
    if p < 1 || p > 100, error('p should be a number between 1 and 100'); end;
    if p == 100,
        val = NaN;
    else
        rankpos = (p/100) * (length(sorted)+1);

        ri = floor(rankpos);
        fr = mod(rankpos, 1);
        if fr == 0 % rank is an integer
            val = sorted(rankpos);
        else
            prevval = sorted(ri);
            nextval = sorted(ri+1);
            val = (fr*(nextval-prevval)) + prevval;
        end;
    end;

    pct = vertcat(pct, val);
end;


