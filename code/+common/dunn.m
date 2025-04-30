function dunn(x,g,varargin)
%Dunn procedure for multiple non parametric comparisons.
%This file is applicable for equal or unequal sample sizes
%
% Syntax: 	DUNN(X,GROUP, CTRL)
%      
%     Inputs:
%           X: data vector
%           GROUP - specifies grouping variables G. Grouping variables must
%           have one column per element of X.
%           CTRL - The first sample is a control group (1); there is not a
%           control group (0). (default=0).
%     Outputs:
%           - Sum of ranks and Mean rank vectors for each group.
%           - Ties factor
%           - Q-value for each comparison.
%           - Q critical value.
%           - whether or not Ho is rejected.
%
%      Example: 
%
%                                 Sample
%                   ---------------------------------
%                       1       2       3       4
%                   ---------------------------------
%                      7.68    7.71    7.74    7.71
%                      7.69    7.73    7.75    7.71
%                      7.70    7.74    7.77    7.74
%                      7.70    7.74    7.78    7.79
%                      7.72    7.78    7.80    7.81
%                      7.73    7.78    7.81    7.85
%                      7.73    7.80    7.84    7.87
%                      7.76    7.81            7.91
%                   ---------------------------------
%                                       
%       Data matrix must be:
%    x=[7.68 7.69 7.70 7.70 7.72 7.73 7.73 7.76 7.71 7.73 7.74 7.74 7.78 ...
%    7.78 7.80 7.81 7.74 7.75 7.77 7.78 7.80 7.81 7.84 7.71 7.71 7.74 7.79...
%    7.81 7.85 7.87 7.91];
%    g=[ones(1,8) repmat(2,1,8) repmat(3,1,7) repmat(4,1,8)];
%
%           Calling on Matlab the function: dunn(x,g) (there is not a control group)
%
%           Answer is:
% 
% STEPDOWN DUNN TEST FOR NON PARAMETRIC MULTIPLE COMPARISONS
%  
%     Group    N    Sum_of_ranks    Mean_rank
%     _____    _    ____________    _________
% 
%     1        8       55            6.875   
%     2        8    132.5           16.562   
%     3        7      145           20.714   
%     4        8    163.5           20.438   
% 
% Ties factor: 168
%  
%     Comparison          Q_value           Crit_Q          Comment      
%     __________    ____________________    ______    ___________________
% 
%     '3-1'         [            2.9493]    2.631     'Reject H0'        
%     '3-2'         [            0.8848]    2.631     'Fail to reject Ho'
%     '3-4'         'No comparison made'    2.631     'Accept Ho'        
%     '4-1'         [            2.9918]    2.631     'Reject H0'        
%     '4-2'         [            0.8548]    2.631     'Fail to reject Ho'
%     '2-1'         [            2.1370]    2.631     'Fail to reject Ho'%
%
%
%           Calling on Matlab the function: dunn(x,g,1) (sample 1 is the control group)
%
%           Answer is:
%
% STEPDOWN DUNN TEST FOR NON PARAMETRIC MULTIPLE COMPARISONS
%  
%     Group    N    Sum_of_ranks    Mean_rank
%     _____    _    ____________    _________
% 
%     1        8       55            6.875   
%     2        8    132.5           16.562   
%     3        7      145           20.714   
%     4        8    163.5           20.438   
% 
% Ties factor: 168
%  
%     Comparison    Q_value    Crit_Q          Comment      
%     __________    _______    ______    ___________________
% 
%     '1-2'          2.137     2.3877    'Fail to reject Ho'
%     '1-3'         2.9493     2.3877    'Reject H0'        
%     '1-4'         2.9918     2.3877    'Reject H0'        
%
%           Created by Giuseppe Cardillo
%           giuseppe.cardillo-edta@poste.it
%
% To cite this file, this would be an appropriate format:
% Cardillo G. (2006). Dunn's Test: a procedure for multiple, not
% parametric, comparisons.
% http://www.mathworks.com/matlabcentral/fileexchange/12827
%Input Error handling
p=inputParser;
addRequired(p,'x',@(x) validateattributes(x,{'numeric'},{'row','real','finite','nonnan','nonempty'}));
addRequired(p,'g',@(x) validateattributes(x,{'numeric'},{'row','real','finite','integer','nonnan','nonempty'}));
addOptional(p,'ctrl',0, @(x) isnumeric(x) && isreal(x) && isfinite(x) && isscalar(x) && (x==0 || x==1));
parse(p,x,g,varargin{:});
assert(length(x)==length(g),'Warning: X and G must have the same length')
ctrl=p.Results.ctrl;
clear p
disp('STEPDOWN DUNN TEST FOR NON PARAMETRIC MULTIPLE COMPARISONS')
disp(' ')
k=max(g); %number of groups
I = [find(g(1:end-1) ~= g(2:end)) length(g)];
N = diff([ 0 I ]); %elements of each group
Idx=g(I);
tot=sum(N); %total elements
R=ones(1,k); %preallocation of sum of ranks and mean rank vectors
[r,t]=tiedrank(x); %ranks and ties
f=(tot*(tot+1)/12)-(t/(6*(tot-1))); %costant denominator factor with ties correction
for I=1:k
    R(I)=sum(r(g==I)); %sum of ranks of each group
end
Mr=[(R./N)' Idx']; %mean ranks of each group 
disp(array2table([Idx' N' R' Mr(:,1)],'VariableNames',{'Group','N','Sum_of_ranks','Mean_rank'}))
fprintf('Ties factor: %d\n',2*t)
disp(' ')
clear Idx R r t %clear unnecessary variables
count=0;
switch ctrl
    case 0 %Without control group
        kstar = 0.5*k*(k-1);
        alf = 1-0.95.^(1/kstar); %Sidak's value of alpha
        vcrit = -realsqrt(2)*erfcinv(2-alf); %critical value
        Mr=sortrows(Mr,-1); %sort the mean ranks;
        %In the second column of Mr there is the groups index. When sorted, this
        %index will be used by Qvalue function to point the correct N values
        %Compare the biggest mean rank with the lowest;
        %then check with the second and so on...
        %If there is no difference (Q<=vcrit) the intermediate comparisons
        %are unnecessary.
        pb{kstar,4} = [];
        for I=1:k-1
            comp=1; %Comparison checker
            for J=k:-1:I+1
                count=count+1;
                if comp %Comparison is necessary
                    Qvalue
                else %Comparison is not necessary
                    pb(count,:)={strcat(int2str(Mr(I,2)),'-',int2str(Mr(J,2))) 'No comparison made' vcrit 'Accept Ho'};
                end
            end
        end
    case 1 %With control group
        %Qcrit is the matrix of critical values (I don't know the Dunn
        %distribution in this case) as reported in Stanton A. Glantz.
        %Critical value is the kth value.
        I=1;
        %Qcrit=[0 1.960 2.242 2.394 2.498 2.576 2.639 2.690 2.735 2.773 2.807 2.838 2.866 2.891 2.914 2.936 2.955 2.974 2.992 3.008 3.024 3.038 3.052 3.066 3.078];
        %vcrit=Qcrit(k);
        %clear Qcrit %clear unnecessary matrix
        alf = 1-0.95.^(1/(k-1)); %Sidak's value of alpha
        vcrit = -realsqrt(2)*erfcinv(2-alf); %critical value
        pb{k-1,4} = []; I=1;
        for J=2:k
            count=count+1;
            Qvalue
        end
end
disp(cell2table(pb,'VariableNames',{'Comparison','Q_value','Crit_Q','Comment'}))
function Qvalue
    num=abs(diff(Mr([I J]))); %Numerator is the absolute difference of the mean ranks
    denom=sqrt(f*sum(1./N(Mr([I J],2)))); %Complete Denominator with ties correction
    Q=num/denom; %Q value
    
    pb(count,1:3)={strcat(int2str(Mr(I,2)),'-',int2str(Mr(J,2))) Q vcrit}; %vectors of comparisons
    if Q>vcrit
        pb(count,4)={'Reject H0'};
        comp=1; %more comparisons are required
    elseif Q<=vcrit
        pb(count,4)={'Fail to reject Ho'};
        comp=0; %No more intermediate comparisons are required
    end
end
end