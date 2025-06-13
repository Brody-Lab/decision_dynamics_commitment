function [] = timeout_whenoccurs(ratname, from, to)

dateset = get_files(ratname,'fromdate', from, 'todate',to);

slist={'cue'};
megaprev=[];
for d=1:length(dateset)
    [tos prevdur]=timeout_state(ratname, dateset{d}, 'slist', slist);
    for k=1:length(prevdur)
        try
        megaprev=vertcat(megaprev, prevdur{k}');
            catch
                2;
            end;
    end;
end;

2;
megaprev=megaprev(find(megaprev<0.5));

binlist=generate_bins(200,500, 8);
megaprev=megaprev*1000;
figure; hist(megaprev, binlist);
ylabel('timeout count');
xlabel('duration of preceding cue state');
title(sprintf('%s from %s to %s', ratname, from, to));

2;