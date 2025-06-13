function output = plotpsych(experimenter,rat,back,start,skip,varargin)

if nargin == 3
    start = 0;
    skip = [];
end
if nargin == 4
    skip = [];
end


pth = ['E:\Brody Lab\SoloData\Data\',experimenter,'\',rat,'\'];
cd(pth);
f = ['data_@SoundDiscrimination_',experimenter,'_',rat,'_'];
ymd = yearmonthday;

output = zeros(10,3,abs(back)+1);
use = abs(start) + 1;
for i = abs(start):abs(back)
    if back < 0; new = changedate(ymd,-i);
    else         new = changedate(ymd,i);
    end
    
    skipthisdate = 0;
    for temp = 1:length(skip)
        if strcmp(new,skip{temp})==1; skipthisdate = 1; end
    end
    if skipthisdate == 1; continue; end;
        
    try
        disp(['Loading: ',f,new,'a.mat']);
        load([pth,f,new,'a.mat']);
        leftend = saved.PsychSection_LeftEndPsych;
        rightend = saved.PsychSection_RightEndPsych;

        ph = saved_history.PsychSection_TrialType;
        ph = cell2mat(ph);
        hh = saved.SoundDiscrimination_hit_history;
        ph = ph(1:length(hh));


        for t = 1:10;

            if t <= 5
                output(t,1,i+1) = t;
                output(t,2,i+1) = length(find(hh(ph == t) == 0));
            else
                output(t,1,i+1) = t;
                output(t,2,i+1) = length(find(hh(ph == t) == 1));
            end
            output(t,3,i+1) = length(find(ph == t));
        end
    catch
        disp(['Error on file: ',f,new,'a.mat']);
        if use == i+1; use = use + 1; end
    end
end

data = zeros(10,3);
data(:,1) = output(:,1,use);
data(:,2) = sum(output(:,2,:),3);
data(:,3) = sum(output(:,3,:),3);

cnt = 0;
for t = 1:10;
    cnt=cnt+1;
    if data(cnt,3) == 0 && cnt ~= size(data,1)
        data(cnt:end-1,:) = data(cnt+1:end,:);
        data = data(1:end-1,:);
        cnt=cnt-1;
    elseif data(cnt,3) == 0 && cnt == size(data,1)
        data = data(1:end-1,:);
    end
end

output = data;

figure; hold on
set(gca,'fontsize',14);
plotpd(data);
shape = 'logistic';
numsim = 1e4;
prefs = batch('shape',shape,...
              'n_intervals',1,...
              'runs',numsim,...
              'lambda_limits',[0 0.3],...
              'cuts',[0.25 0.5 0.75],...
              'verbose','false');

outputPrefs = batch('write_pa', 'pa',...
                    'write_th', 'th');
disp('Calculating Psychometric Fit...');
psignifit(data, [prefs outputPrefs]);

plotpf(shape, pa.est);
p = zeros(1,3);
s = zeros(numsim,3);

disp('Calculating Error...')
for t = 1:3;
    p(t) = calcpsych(leftend,rightend,th.est(t));
end
for t = 1:numsim*3
    s(t) = calcpsych(leftend,rightend,th.sim(t));
end

W = (p(3) - p(1)) / p(2);
W = round(W * 1e3) / 1e3;

E = std((s(:,3) - s(:,1)) ./ s(:,2));
E = round(E * 1e3) / 1e3;

title([experimenter,': ',rat,'  Last ',num2str(abs(back)+1),' days',...
    '   Weber Ratio: ',num2str(W),' +/- ',num2str(E)]);

xlabel('Log Stimulus','Fontsize',16);
ylabel('Probability Choose Right','Fontsize',16);
axis([0 11 0 1]);

disp('Complete');

