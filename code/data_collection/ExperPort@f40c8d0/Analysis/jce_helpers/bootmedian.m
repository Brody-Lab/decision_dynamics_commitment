function varargout=bootmedian(varargin)

BOOTS=5000;

if nargin==1
	% assume test whether mean of the population is differenct from zero.
	
	[B]=bootstrp(BOOTS, @nanmedian, varargin{1});
	
	ps=[0:0.01:100];
	sd_ps=prctile(B,ps);

	sd=0;
	
    if isnan(sd) 
        sd_p=1;
    elseif sd<sd_ps(1)||sd>sd_ps(end)
        sd_p=0.0001;
    else
        closest=qfind(sd_ps,sd);
        others=find(sd_ps==sd_ps(closest));
        if ps(others(1))<50 && ps(others(end))>50
            sd_p=1;
        elseif ps(others(1))>50
            sd_p=ps(others(1))/100;
            sd_p=2*(1-sd_p);
        else
            sd_p=ps(others(end))/100;
            sd_p=2*sd_p;
        end
	end    
	
	varargout{1}=sd_p;
	varargout{2}=prctile(B,[50 2.5 97.5]);
	
elseif nargin==2
	
    A=varargin{1};
	sA=numel(A);
	B=varargin{2};
	sB=numel(B);
	sd=nanmedian(A)-nanmedian(B);
	
	ALL_DATA=[A(:);B(:)];
	
	for bx=1:BOOTS
		
	shuff_d=ALL_DATA(randperm(numel(ALL_DATA)));
	A=shuff_d(1:sA);
	B=shuff_d(sA+1:end);
	
	boot_score(bx)=nanmedian(A)-nanmedian(B);
	end
	
	ps=[0:0.01:100];
	sd_ps=prctile(boot_score,ps);

	
    if isnan(sd) 
        sd_p=1;
    elseif sd<sd_ps(1)||sd>sd_ps(end)
        sd_p=0.0001;
    else
        closest=qfind(sd_ps,sd);
        others=find(sd_ps==sd_ps(closest));
        if ps(others(1))<50 && ps(others(end))>50
            sd_p=1;
        elseif ps(others(1))>50
            sd_p=ps(others(1))/100;
            sd_p=2*(1-sd_p);
        else
            sd_p=ps(others(end))/100;
            sd_p=2*sd_p;
        end
	end    
end
	varargout{1}=sd_p;
	% varargout{2}=prctile(B,50);
	