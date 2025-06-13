function [imcx,mcx,ccx,imcx2]=align_twovectors(x,y,startbin,nbins,scoretype)

%
% [imcx,mcx,ccx,imcx2]=align_twovectors(x,y,startbin,nbins,isnorm)
%   Finds the segment of y in the range of y(startbin) to y(startbin+nbins-1)-- 
%   call the segment y1--that is most similar in shape to x.
%   Returns the starting index imcx that has the maximum correlation mcx
%   between x and y1.  By default, this function normalizes x and y1 in the
%   range of (0,1), i.e. (x-min(x))/range(x) and (y1-min(y1))/range(y1).
%   Set isnorm to false to use no normalization.
%   x is assumed shorter than y.  ccx gives the values of the correlation
%   for each value of the delay.
%

if nargin<3, startbin=1; end
if nargin<4, nbins=numel(x)-numel(y)+1; end
if nargin<5, scoretype=1; end

ccx=zeros(1,nbins);
if scoretype==1, x=(x-min(x))/range(x); end
nx=numel(x);
for k=0:(nbins-1)
  bins=(startbin+k):(startbin+nx+k-1);
  switch scoretype
    case 1
      tmpy=(y(bins)-min(y(bins)))/range(y(bins));
      cc=corrcoef(x,tmpy);
      ccx(k+1)=cc(1,2);
    case 2
      tmpy=y(bins);
      cc=corrcoef(x,tmpy);
      ccx(k+1)=cc(1,2);
    case 3
      tmpy=y(bins);
      ccx(k+1)=norm(x-tmpy);
  end
  
  
end

if scoretype<3, [mcx,imcx]=max(ccx);
else            [mcx,imcx]=min(ccx);
end
imcx2=startbin+imcx-1;