function [] = logistic_equations
% sandbox to play with different parameters that characterize a logistic
% function and to see the result and understand what it is that these
% parameters do.

% sigmoidal function used commonly to fit resource-limited growth data.
% a=0.79*100; % carrying capacity.
% m=-0.0001*100; % controls P0 and whether graph grows or decays
% n=0.0002*100;  % shifts graph horizontally and together with m, determines whether graph models growth or decay.
% tau=0.02; % controls slope (Rate of growth)

%a=100;m=0.01; n=0.1; tau=0.1;
a=100; m=0; n=1; tau =0.1;
% m=-0.0002;
% n = 0.0024;
% tau=0.02;
% Features of graph:
% Start population  = a * (m/n)
% Growth rate depends on ratio of m and n.
% When m = n, there is no growth
% When m > n, there is decay
% When m < n, there is growth.
% The shape of the logistic also depends on m & n
%  In particular, inflection point is a function of (m/n)
%   If n < 0: you get a double-sided exponential (hyperbolic)

int = 5:0.02:8;

%t = -6:0.02:6
t = int - mean(int);
data=[];

figure;

pct95_mark=[];% idx at which each graph reaches 95th point.
num_array=[];
den_array=[];
for f=[1 3]%n = 1:5 
    num = 1 + (m * exp(-t ./(tau*f)));
    num_array = horzcat(num_array,num);
    den = 1 + (n * exp(-t ./(tau*f)));
    den_array = horzcat(den_array,den);
    data = a * (num./den);

    minp=min(find(data > round(0.95*a)));
    pct95_mark = horzcat(pct95_mark, minp);

    % now get the weber for this graph.

    l=plot(t, data,'-r');
    hold on;
    clr=rand(1,3);
    set(l,'LineWidth',3);
    if f== 5, set(l,'Color','b');
    elseif f==1, set(l,'Color','r');else set(l,'Color','k');end;
    %text(min(t)+0.5,data(1)*1.1, sprintf('%s=%i','tau',tau*f));
    %set(t,'Color',clr);

    fprintf(1,'when %s = %i, pct95 reached at %i\n', 'n', n, minp);
end;
line([min(t) max(t)], [a/2 a/2],'LineStyle',':','Color','k');
%set(gca,'YLim',[0 100]);

figure; 
subplot(1,2,1); 
plot(1:length(num_array),num_array,'.g', 1:length(den_array), den_array, '.b');
legend({'num','den'});
subplot(1,2,2);
plot(num_array ./ den_array, '.r');
title('logistic function');


% in rat data,
% carrying capacity is known. --> a is known from data
% initial population is known. --> there are constraints on m & n
%   We see growth, so we want m > n.
%   p0 = a * (m/n)
%   Therefore, (m/n) = (p0/a)
%   Therefore, m = (p0/a) * n.

% We need to solve for m (once we have m, we can derive n) and tau.
