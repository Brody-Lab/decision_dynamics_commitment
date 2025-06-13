function M=fig_place(n, varargin)

pairs={'border' 15;...
	    'ss'     get(0,'ScreenSize');};
parseargs(varargin, pairs);

if strcmp(get_hostname,'mol-cce788')
	ss=[1440 300 1920 1200];
end

% is the screen wide or square?

scrW=ss(3)-30;
scrH=ss(4)-150;
widescr = (scrW/scrH)>1.4;

if widescr
    nr=ceil(round(sqrt(n))-.1*n);
else
    nr=round(sqrt(n));
end    

    nc=ceil(n/nr);

fig_w=round(scrW/nc);
fig_h=round(scrH/nr)-70;

fig_ind=1;

M=zeros(n,4);

for ri=0:(nr-1)
    for ci=0:(nc-1)
        M(fig_ind,:)=[ss(1)+border+ci*fig_w ss(2)+border+ri*(fig_h+70) fig_w fig_h];
        fig_ind=fig_ind+1;
        if fig_ind>n
            return
        end
    end
end
    

    