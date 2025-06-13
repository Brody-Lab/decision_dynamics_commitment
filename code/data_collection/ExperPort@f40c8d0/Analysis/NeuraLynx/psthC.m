function h=psthC(ev, ts, pre,post,binsz,cnd, meanflg, krn)

h=figure;
set(gcf, 'Renderer','opengl');
set(gcf,'Color','w')
hold on
if nargin<6
    cnd=1;
end

if nargin<7,
    meanflg = 0;
end;

if nargin<8
	dx=1000/binsz;
    krn=normpdf(-dx:dx,0,100/binsz);
	krn(1:dx)=0;
	krn=(krn)/sum(krn);
	%krn=1;
elseif isscalar(krn)
	dx=ceil(3*krn/binsz);
    krn=normpdf(-dx:dx,0,krn/binsz);
	krn(1:dx)=0;
	krn=(krn)/sum(krn);
end


clrs={'r','b','m','g','b','r','g','m'};

n_cnd=unique(cnd(~isnan(cnd)));

legstr = {''};
for ci=1:numel(n_cnd)
	sampz=sum(cnd==n_cnd(ci));
	[y,x]=tsraster(1000*ev(cnd==n_cnd(ci)),ts*1000,pre,post,binsz);
	ymn(ci,:) = mean(jconv(krn,y*1000/binsz));
	yst(ci,:)=stderr(jconv(krn,y*1000/binsz));

	hh=plot(x/1000,ymn(ci,:),clrs{ci});
	set(hh,'LineWidth',2);
	legstr{ci}=[num2str(n_cnd(ci)) ', n=' num2str(sampz)];

end

legend(legstr);


if ~meanflg,
    for ci=1:numel(n_cnd)

        %Sundeep Tuteja, 2010-05-10: I have made a change to this line. The
        %axis handle was specified as [] for some reason, causing error
        %messages. It might be necessary to review this line at a later
        %stage, but for now, I have replaced [] with gca.
        shadeplot(x/1000,ymn(ci,:)-yst(ci,:),ymn(ci,:)+yst(ci,:),{clrs{ci},gca,.6});

    end
end;
hold off
set(gca,'FontSize',20);

xlabel('Time from {\bfREF}  in Seconds')
ylabel('Firing Rate (Hz \pm Std. Err.)')
