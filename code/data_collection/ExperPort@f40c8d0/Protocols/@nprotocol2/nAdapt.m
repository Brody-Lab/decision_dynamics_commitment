function [ ] = nAdapt(obj, action)
%SOUND Summary of this function goes here
%   Detailed explanation goes here
GetSoloFunctionArgs;
switch action,
    case 'init'
        if ~isempty(parsed_events.states.l_poke_in_shock_start) || ...
            ~isempty(parsed_events.states.r_poke_in_shock_start),
            err=[err 0];
        else
            err=[err 1];
        end
        if length(err)>=10
            for i=1:length(err)-9
                err_avg(i)=mean(err(i:(i+9)));
            end
        end
        T=0.15
        if err_avg(end) == 1,
            cPokeTime.value = value(cPokeTime)- 0.05;   
        elseif err_avg(end) == 0.9,
            cPokeTime.value = value(cPokeTime)- 0.05;   
        elseif err_avg(end) == 0.8,		
            cPokeTime.value = value(cPokeTime)- 0.05;   
        elseif err_avg(end) == 0.7,		
            cPokeTime.value = value(cPokeTime)- 0.05;   
        elseif err_avg(end) == 0.6,		 
            cPokeTime.value = value(cPokeTime)- 0.05;   
        elseif err_avg(end) == 0.5,		        
            cPokeTime.value = value(cPokeTime)- 0.04;         
        elseif err_avg(end) == 0.4,	                   
            cPokeTime.value = value(cPokeTime)- 0.03; 
        elseif err_avg(end) == 0.3,	               
            cPokeTime.value = value(cPokeTime)- 0.02;   
        elseif err_avg(end) == 0.2,	               
            cPokeTime.value = value(cPokeTime)- 0.01;   
        elseif err_avg(end) == 0.1,	               
            cPokeTime.value = value(cPokeTime)+ 0.01;   
        elseif err_avg(end) == 0.0,	               
            cPokeTime.value = value(cPokeTime)+ 0.02;
        end
        
    case 'distribution',
       % % delta=alpha(-D)^3 || f(x)=a(-x)^3
% % D=err_avg-T;%D=distance to target of the average of errors of the past
% % n trials
% % Dmin=-T;
% % Dmax=1-T;
% % delta = distribution of values to add to cPokeTime depending on D
% % delta_max = maximum value of delta to add or subtract from cPokeTime (set by us)
% % delta_max= alpha_max*(-Dmin)^3; 
% % delta_min = alpha_min*(-Dmax)^3;
% 
% % calculate alpha, for delta_min and Dmax only, [alpha = -0.097656]
% % alpha_max=(delta_max/(-Dmin)^3);
% % alpha_min=(delta_min/(-Dmax)^3);
% % alpha = delta_min / (-(1-T)^3);

err_avg=[0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1]; %example of error average
pow=3; % power of function (NB. increasing the power should need more variables)
T=0.5; % Target of err_avg to reinforce
D=err_avg-T; % x-axis or distance to target
nalpha=[];
delta=[];
if T < 0.5,
    nalpha=-0.05/(-(1-T)^pow); % delta_min = -0.05 
elseif T > 0.5,
    nalpha=0.05/(-(-T)^pow); % delta_max = 0.05
elseif T == 0.5
    nalpha=0.4; % -0.05/(-(0.5)^3)= 0.05/(-(-0.5)^3) = 0.4
end
for i=1:length(D)
delta(i)=nalpha*(-(D(i)^pow));
end
plot(D,delta); hold off

end