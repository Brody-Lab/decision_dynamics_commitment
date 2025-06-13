function varargout=psychoplot(x_vals, varargin)
% [stats]=psychoplot(x_vals, went_right)
% [stats]=psychoplot(x_vals, hits, sides)
%
% x_vals        the experimenter controlled value on each trial.
% went_right    a vector of [0,1]'s the same length as x_vals describing
%               the response on that trials
% OR
%
% hits          a vector of the correct/incorrect history as [0,1,nan]'s.
%               Nans are exluded automatically
% sides         a vector of [-1, 1]'s or ['LR']'s that say what the subject
%               should have done on that trial



if nargin==2
    went_right=varargin{1};
    gd=~isnan(went_right);
    went_right=went_right(gd);
    x_vals=x_vals(gd);
elseif nargin==3
    hits=varargin{1};
    sides=varargin{2};
 
    gd=~isnan(hits);
    hits=hits(gd);
    sides=sides(gd);
    x_vals=x_vals(gd);
    
    if isnumeric(sides(1))
        went_right=(hits==1 & sides==1) | (hits==0 & sides==-1); 
    else
        sides=lower(sides);
        went_right=(hits==1 & sides=='r') | (hits==0 & sides=='l');
    end
end

x_s=linspace(min(x_vals), max(x_vals), 100);
fig_h=figure;

if numel(unique(went_right))==2
     [b,d,S]=glmfit(x_vals, went_right,'binomial','link','probit');
     [y_s,DYLO,DYHI]=glmval(b,x_s,'probit',S);
     
sortedM=sortrows([x_vals(:) went_right(:)]);
rawD=jconv(normpdf(-10:10, 0, 2), sortedM(:,2)');
plot(sortedM(:,1), rawD,'o')
else
     [b,d,S]=glmfit(x_vals, went_right);
     [y_s,DYLO,DYHI]=glmval(b,x_s,'identity',S);
     plot(x_vals,went_right,'o');
end

%x_s=x_vals;
hold on
plot(x_s, y_s,'k-');
plot(x_s,y_s-DYLO,':');
plot(x_s,y_s+DYHI,':');





if nargout>=1
    varargout{1}=S;
end