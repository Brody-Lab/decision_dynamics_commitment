
function [theta]=nan_bad_thetas(theta, apoints,x,y,doidx)



if ~iscell(apoints)
	apoints={apoints};
end

%% First Pass just find frames with only one color


bad_thetas=zeros(numel(theta),numel(apoints));

for cx=1:numel(apoints)
	points=apoints{cx};
	n_samp=size(points,2);
	[r,g,b]=vid_bitfield(points);
	fprintf('\tgot r,g,b targets, now looking for bad frames\n')
	if nargin<5
		doidx=[1 n_samp];
	end
	if isempty(r)
		c1=g;
		c2=b;
	elseif isempty(g)
		c1=r;
		c2=b;
	else
		c1=r;
		c2=g;
	end
	
	e1=1;
	e2=1;
	tic
	
	c1t=c1(:,1);
	c2t=c2(:,1);
	c1d=c1(:,2:3);
	c2d=c2(:,2:3);
	
	parfor px=doidx(1):doidx(2)
		
% 		if mod(px,10000)==0
% 			tt=toc;
% 			fprintf('%d %% done, %d sec elapsed\n',round(100*px/n_samp),round(tt))
% 			tic;
% 		end
% 		
		
		[~,i1]=qbetween(c1t,px-0.1,px+0.1);
		[~,i2]=qbetween(c2t,px-0.1,px+0.1);
		
		
		if isempty(i1) ||isempty(i2);
			%we only have one light.  theta is bad
			bad_thetas(px,cx)=1;
		else
			
			
			t1=c1d(i1,:);
			t2=c2d(i2,:);
			
			% we have 2 lights, but let's check that they are not reflections.
			oo=[x(px) y(px)];
			
			% Note: 100 pixels works for currect setup, but a change in the camera
			% could change this.
			t1_far=min(hyp(t1-repmat(oo,size(t1,1),1)))>100;
			t2_far=min(hyp(t2-repmat(oo,size(t2,1),1)))>100;
			
			if t1_far || t2_far
				bad_thetas(px,cx)=1;
			end
			
			
		end
	end
end

theta(prod(bad_thetas,2)==1)=nan;




function y=hyp(x)
y=sqrt(sum(x.^2,2));


