function [] = fft_me(x,varargin)
% Fast fourier transforms any signal provided.
% Shows signal and fourier transformation

pairs = { ...
    'issound', 0 ; ...
    'srate', 50e6/1024 ; ...
    'min_sound', 0.2 * 1000 ;...
    'max_sound', 1 * 1000 ; ...
    'view_sample', 1000 ; ... % how many samples you want to see in the graph
    'ff_lim', [800 1500] ; ... % which freq to see in FF
    'curvecolour', 'r'; ...
    };
parse_knownargs(varargin, pairs);

% clip first 500s to eliminate ramp
if issound > 0
    x = x(500:end);
end;
% note that the bin size in the vector of Fourier coefficients = (1/t)
% where t = (length of vector) / (sampling rate)
% The longer the vector, the smaller the bin size.
y = fft(x);


% plot the signal
subplot(2,1,1);
vidx = min(view_sample, length(x));
l=plot(1:vidx, x(1:vidx), '-b');
set(l,'Color', curvecolour);
ylabel('Function x');
xlabel('the other axis');

title('The function x');

% plot the Fourier decomposition
subplot(2,1,2);
dur = srate/length(y);
time_step = dur;
xlbl = 0:dur:srate;

y2 = y(2:end);
xlbl = xlbl(2:end); 

 
% Looking at coefficients of first half of the array suffices since
% the Xth component is the same as the (N-X)th component.
if isreal(x),
   if mod(x,2) < 1 % even numdbers
       idx = 1:length(x)/2;
   else
       idx = 1:(length(x)/2)-1;
   end;
end;
y2 = y2(idx);
xlbl=xlbl(idx);

% % We will only look at the human-audible range of sound, from 20Hz to
% % 20,000Hz
% if issound > 0
%     min_idx = 100;
%     max_idx = min(length(y2), 20000);
%     y2 = y2(min_idx:max_idx);
%     xlbl = round(xlbl(min_idx : max_idx));
% end;
%    
% y2=y;
l=plot(xlbl, abs(y2),'-b');
hold on;
line([0 length(xlbl)], [2 2], 'LineStyle',':');

% "large components" are those with value >=2
idx = find(abs(y2)>=2);
xrange=xlbl(idx);
fprintf(1,'Range of large values = [%1.2f, %1.2f]', min(xrange), max(xrange));


set(l,'Color', curvecolour);
set(gca,'XLim',ff_lim);
ylabel('Fourier coeffs');
title('Fourier coefficients');
xlabel('Modulus of Fourier coeffs');

%set(gca,'XTick',1:round((1/4)*length(y2)):length(y2));
% 
% y3 = y(2:min(length(y),round(srate)));
% [min2max idx_min2max] = sort(y3);
% max2min = min2max(end:-1:1); 
% idx_max2min = idx_min2max(end:-1:1);
% 
% topn =10;
% fprintf(1,'Top %i frequencies:\n',topn);
% fprintf(1,'\t%3.0f\n', idx_max2min(1:topn));

function [b] = find_bin(wanted_freq, bin_size)
b = wanted_freq / bin_size;