function varargout=seqregress(Y,X)
% This runs a regress on each column of X substituting the residuals from the previous regression.
% Don't include a column of ones.

ncols=size(X,2);
beta=ones(ncols,1);
sigB=beta;
rsq=beta;

R=Y;

for xi=1:ncols

YN=R;

F=[X(:,xi) ones(size(YN))];
[B,BINT,R,RINT,STATS] = regress(YN,F);
beta(xi)=B(1);
sigB(xi)=(BINT(1,1)*BINT(1,2))>0;
rsq(xi)=STATS(1);

end

if nargout>0
varargout{1}=rsq;
end

if nargout>1
varargout{2}=beta;
end

if nargout>2
varargout{3}=sigB;
end

