function [epid,fnames]=ts2epoch(ts,peh)

%
% [epid,fnames]=ts2epoch(ts,peh)
%

fnames=fieldnames(peh(1).states);
nfields=numel(fnames);
iskeepfield=true(nfields,1);
for k=1:nfields
  if ~isnumeric(peh(k).states.(fnames{k})) || strcmp(fnames{k},'state_0')
    iskeepfield(k)=false; 
  end
end
fnames=fnames(iskeepfield);
nfields=numel(fnames);
fieldcodes=1:nfields;
ntrials=numel(peh);

epid=zeros(size(ts));
for k=1:ntrials
  ctimes=[];
  cstates=[];
  for n=1:nfields
    ctimes=[ctimes; peh(k).states.(fnames{n})];
    cstates=[cstates; n*ones(size(peh(k).states.(fnames{n}),1),1)];
  end
%   [garb inds]=sort(ctimes(:,1));
%   ctimes=ctimes(inds,:);
%   cstates=cstates(inds);
  for n=1:numel(cstates), epid(ts>ctimes(n,1) & ts<=ctimes(n,2))=cstates(n); end  
end

fnames=[fnames mat2cell((1:numel(fnames))',ones(numel(fnames),1),1)];