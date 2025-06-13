function [diode1,diode2] = compute_cerebro2_calibration(pwr_set,pulsedur,varargin)

if nargin < 1; pwr_set  = 1000:300:2200; end
if nargin < 2; pulsedur = 2; end
if nargin < 3; period = 0.1; end

pulsepoints = pulsedur * 68;

[fname,pname] = uigetfile('*.txt');
file = [pname,fname];
f = fopen(file);
x = fread(f);
fclose(f);

nl = find(x == 10);
L = nl(3:end)+1;

x = char(x');

P = [];
T = [];
for i = 1:numel(L)
    try
        T(i) = datenum(x(L(i):L(i)+24),'mm/dd/yyyy HH:MM:SS.FFF PM');
        P(i) = str2num(x(L(i)+25:L(i)+34));
    catch
        T(i) = nan;
        P(i) = nan;
    end
end
T = T - min(T);
T = T * (24 * 3600);

firstd = P(2:end) - P(1:end-1);

on  = find(firstd >  nanstd(firstd)*2);

ON = [];
OFF = [];
for i = 1:numel(on);
    if i > 1 && abs(on(i) - ON(end)) < (pulsedur / period) * 3
        continue; 
    end
    
    temp = firstd(on(i)-10:on(i)+10 + (pulsedur / period));
    
    beston = find(temp == max(temp),1,'first');
    bestoff = find(temp == min(temp),1,'last');

    ON(end+1) = on(i) + (beston - 11);
    OFF(end+1) = on(i) + (bestoff - 11);
end

diode1_pulses = 1:2:(numel(pwr_set))*2;
diode2_pulses = 2:2:(numel(pwr_set))*2;

pwr_set1 = pwr_set;
pwr_set2 = pwr_set;

expected_pulses = numel(pwr_set) * 2;
if numel(ON) < expected_pulses
    disp('Missing Pulses')
    if expected_pulses - numel(ON) > 1
        disp('More than one missing pulse. Rerun Calibration.')
        return;
    end
    
    IPI = ON(2:end) - ON(1:end-1);
    biggap = find(IPI > median(IPI) * 1.5);
    
    if isempty(biggap)
        disp('Missing either first or last pulse. Rerun Calibration.')
        return;
    end
    
    missing1 = find(diode1_pulses-1 == biggap);
    missing2 = find(diode2_pulses-1 == biggap);
    
    if ~isempty(missing1)
        missing_pulse_num = diode1_pulses(missing1);
        diode1_pulses(missing1) = [];
        pwr_set1(missing1) = [];
    else
        missing_pulse_num = diode2_pulses(missing2);
        diode2_pulses(missing2) = [];
        pwr_set2(missing2) = [];
    end
    
    diode1_pulses(diode1_pulses > missing_pulse_num) = diode1_pulses(diode1_pulses > missing_pulse_num) - 1;
    diode2_pulses(diode2_pulses > missing_pulse_num) = diode2_pulses(diode2_pulses > missing_pulse_num) - 1;
end
    
pwr = [];
try
    for i = 1:numel(ON)
        pwr(i) = mean(P(ON(i)+1:OFF(i)));
    end
end
pwr = pwr * 1000;

diode1 = polyfit(pwr(diode1_pulses),pwr_set1,1);
diode2 = polyfit(pwr(diode2_pulses),pwr_set2,1);

disp(['DIODE 1: ',num2str(diode1(1)),' ',num2str(diode1(2))]);
disp(['DIODE 2: ',num2str(diode2(1)),' ',num2str(diode2(2))]);

figure('color','w'); hold on;
plot(pwr(diode1_pulses),pwr_set1,'ok')
plot([0,40],[diode1(2),(30*diode1(1)) + diode1(2)],'-r')
set(gca,'fontsize',18);
xlabel('Power, mW');
ylabel('Cerebro Power Setting');
title('DIODE 1')

figure('color','w'); hold on;
plot(pwr(diode2_pulses),pwr_set2,'ok')
plot([0,40],[diode2(2),(30*diode2(1)) + diode2(2)],'-r')
set(gca,'fontsize',18);
xlabel('Power, mW');
ylabel('Cerebro Power Setting');
title('DIODE 2')

d = P(2:end) - P(1:end-1);
on = find(d > 0.5);
for i = 1:numel(on)
    p(i) = mean(P(on(i)+1:on(i)+44));
end
