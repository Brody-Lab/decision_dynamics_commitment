function [y,inds]=qbetween3(x, start, finish,refs)
% [y,inds]=qbetween3(x, start, finish)
% works for sorted 1D vectors.
% using find you get o(n) , by assuming that the vector is sorted you get
% 2*o(log(n)).   which is WAY better.
% this version of qbetween returns the cell inds which tells you the
% indices from x in the values y, i.e. y{n}=x(inds{n}).

if nargin==3
	refs=zeros(size(start));
end



if numel(start)>1
	for sx=1:numel(start)
		[y{sx},inds{sx}]=qbetween3(x,start(sx), finish(sx), refs(sx));
	end
else
    if isempty(x) || (x(end)<start) || x(1)>finish
    y=[];
    inds=[];
    return
end 
    i=qfind(x, [start finish]);
    
    %qfind returns -1 if the target is less than min(x), since we are
    %getting 'between', we just take the first relevant x
    
    if i(1)==i(2)
        y=[];
        inds=[];
        return
    elseif i(1)==-1
        i(1)=1;
    end
    
    
    %this code deals with the fact that if there is no exact match, qfind
    %will return the index that is one lower than the target.  since we
    %want between, we just double check the end points.  every other point
    %will be valid.
    
    y=x(i(1):i(2));
    inds=i(1):i(2);
    if y(1)<start
        y=y(2:end);
        inds=inds(2:end);
    end
    
    if y(end)>finish
        y=y(1:end-1);
        inds=inds(1:end-1);
	end
	
	y=y-refs;
	
	
end
