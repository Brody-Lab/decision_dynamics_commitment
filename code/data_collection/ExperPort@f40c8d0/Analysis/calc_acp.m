function [acp]=calc_acp(d1,d2,istr)

%
% acp=calc_acp(d1,d2,usetiedrank)
%
% Calculates average choice probability (area under ROC curve) for two
%   distributions d1 and d2 as a function of 'time.'  Each column is a time
%   point and each row is a sample at that time point.  d2 is assumed to
%   have higher values than d1.
%   usetiedrank is a boolean (default is true) which determines the method
%   of calculating the ACP.  Need to have statistics_toolbox to use
%   tied_rank, but the function checks for it.  tied_rank is faster for
%   very big matrices but slower for smaller matrices.  If you have to do a
%   lot of acp calculations on small matrices set istr=false, if you have
%   to do just a few acp calculations on very large matrices set istr=true,
%   or do not enter a third input variable.
%

% -- return NaN if either distribution is empty
if isempty(d1) || isempty(d2), acp=zeros(1,max(size(d1,2),size(d2,2)))+NaN; end

if ~exist('istr','var'), istr=true; end

% -- parameters
nd1=size(d1,1);
nd2=size(d2,1);
nt =size(d1,2);

% -- init
gt = zeros(nd1,nt);
eq = zeros(nd1,nt);

% -- count the number of d2 values that are higher and equal to d1 values
if istr && license('test','statistics_toolbox')
  isd2 = [true(nd2,1); false(nd1,1)];
  tr   = tiedrank([d2; d1]);
  acp  = (sum(tr(isd2,:),1) - 0.5*(nd2^2 + nd2))/(nd2*nd1);
else
  for k=1:nd2
    tmpd2=repmat(d2(k,:),nd1,1);
    gt(k,:)=sum(tmpd2>d1,1);
    eq(k,:)=sum(tmpd2==d1,1);
  end
  acp=(sum(gt,1)+0.5*sum(eq,1))/(nd1*nd2);
end