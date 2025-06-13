%[y,x]=tsxcorr(ref, targ, pre,post, binsz)
% takes two vectors of timestamps (us), a lag, and a bin size (us) and returns the 
% cross-correlelogram.

function [M,varargout]=tsxcorr(ref, targ, pre,post, binsz)

if nargin<5
    binsz=1E3;
end

if nargout>1
    varargout{1}=-pre:binsz:(post-binsz);
end

targ=row(targ);


 M=zeros(1, ((pre+post)/binsz));
for i=1:length(ref)
    %
    bins=(ref(i)-pre):binsz:(ref(i)+post);
    %[n,ind]=histc(qbetween(targ,bins(1),bins(end)), bins);
    [n,ind]=histc(targ, bins);
    M=M+n(1:end-1);
end

M=M/numel(ref)*1E3/binsz;


