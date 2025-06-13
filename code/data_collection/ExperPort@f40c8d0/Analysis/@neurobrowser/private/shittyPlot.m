function shittyPlot(sessid,c_x, action)
%% GRANT SCRATCH PAD

[eS]=bdata('select evnt_strt from events where sessid="{Si}"',sessid);
[rat, sdate]=bdata('select ratname, sessiondate from sessions where sessid="{Si}"',sessid);

[cellid, sc, clust, spks ,wv]=bdata(['select a.cellid, sc_num, cluster, ts, wave from spktimes as a, cells as b where a.cellid=b.cellid and a.cellid in (' c_x   ') and a.sessid="{Si}" '],sessid);
eS=eS{1};
sc=sc+1;

% get basics conditionals

sides=eS.saved.PerformanceSection_previous_sides;
pro=eS.saved.PerformanceSection_previous_cntxt;
correct=eS.saved.PerformanceSection_gotit_history;
RT=eS.saved.PerformanceSection_RT;

% get basic events

lightOn=extract_event(eS.peh, 'wait_for_poke2',1);
pk2=extract_event(eS.peh, 'wait_for_poke2',2);
pk3=extract_event(eS.peh, 'wait_for_poke3',2);
locSnd=extract_event(eS.peh, 'poke2sound',1);
cntxSnd=extract_event(eS.peh, 'poke1sound',1);
reward=extract_event(eS.peh, 'give_reward');


switch action,
%% 
	case 'rasters',
M=fig_place(numel(spks));

for cx=1:numel(spks)
	c_spks=spks{cx};
	figure
	tsraster2(pk3, c_spks, 5E3, 5E3);
	title([num2str(cx) ' ' rat{1} '\_' sdate{1} '\_TT' num2str(sc(cx)) 'C' num2str(clust(cx)) ', Poke3']);
	xlabel('Time (secs)');
	set(gcf, 'Position',M(cx,:));
end
	


%% subplot with PSTH 
	case 'sides',
gt=find(1==correct);
pk3g=locSnd(gt);
sdgt=sides(gt);
lt=find(sdgt==-1);
rt=find(sdgt==1);
st=[rt;lt];

NN=numel(cellid)+1;

clrs={'r' 'k' 'g' 'b','m','c','y','r','k'};
figure
%pagefig('height',NN,'width',3)
h=subplot(NN,1,NN);
set(gcf,'renderer','painters')

	for cx=1:(NN-1)
			subplot(NN,1,cx)
			c_spks=spks{cx};
			[y,x]=tsraster2(pk3g(st), c_spks, 4E3, 2E3,0 );
			plot(x/1000,y,clrs{cx});
			if cx==1
				title( {[rat{1} '\_' sdate{1}], ['CELLID:' num2str(cellid(cx))  ', TT' num2str(sc(cx)) 'C' num2str(clust(cx))]});
			else
				title(['CELLID:' num2str(cellid(cx))  ', TT' num2str(sc(cx)) 'C' num2str(clust(cx))]);
			end

			ylim([0 ceil(max(y))])
			set(gca,'YTick',[]);
			set(gca,'Box','off')
			drawnow
			subplot(NN,1,NN)
			hold on
			krn=normpdf(-20:20,0,5);
			psth(pk3g(st), c_spks, 4E3, 2E3, 10, krn,{clrs{cx},gca,0.7});

		end


ylabel('Firing Rate (Hz \pm StdErr)')
xlabel('Time from response (sec)')
% 
% 
 ch=get(gcf,'Children');
% p1=get(ch(5),'Position');
% set(ch(5),'Position',p1+[0 -.05 0 +0.05]);
% set(gca,'Position', p1+[0 -.5 0 +.05]);
ylabel(ch(2),'Trials ordered by response: right trials on top')
set(gcf,'Renderer','painters');


%% subplot PROANTI with PSTH
	case 'context',

		gt=1:numel(pro);
		pk3g=pk3(gt);
		sdgt=pro(gt);
		at=find(sdgt==-1);
		pt=find(sdgt==1);
		st=[pt;at];

		NN=numel(cellid)+1;

		clrs={'r' 'k' 'g' 'b','m','c','y','r','k'};
		figure
		%pagefig('height',NN,'width',3)
		h=subplot(NN,1,NN);
		set(gcf,'renderer','painters')

		for cx=1:(NN-1)
			subplot(NN,1,cx)
			c_spks=spks{cx};
			[y,x]=tsraster2(pk3g(st), c_spks, 4E3, 2E3,0 );
			plot(x/1000,y,clrs{cx});
			if cx==1
				title( {[rat{1} '\_' sdate{1}], ['CELLID:' num2str(cellid(cx))  ', TT' num2str(sc(cx)) 'C' num2str(clust(cx))]});
			else
				title(['CELLID:' num2str(cellid(cx))  ', TT' num2str(sc(cx)) 'C' num2str(clust(cx))]);
			end

			ylim([0 ceil(max(y))])
			set(gca,'YTick',[]);
			set(gca,'Box','off')
			drawnow
			subplot(NN,1,NN)
			hold on
			krn=normpdf(-20:20,0,5);
			psth(pk3g(st), c_spks, 4E3, 2E3, 10, krn,{clrs{cx},gca,0.7});

		end

		ylabel('Firing Rate (Hz \pm StdErr)')
		xlabel('Time from response (sec)')
		%
		%
		ch=get(gcf,'Children');
		% p1=get(ch(5),'Position');
		% set(ch(5),'Position',p1+[0 -.05 0 +0.05]);
		% set(gca,'Position', p1+[0 -.5 0 +.05]);
		ylabel(ch(2),'Trials ordered by context: Pro trials on top')
		set(gcf,'Renderer','painters');
%%	case 'context',
	case 'correct'
gt=[1:nume(correct)];
pk3g=pk3(gt);
sdgt=correct(gt);
at=find(sdgt==0);
pt=find(sdgt==1);
st=[pt;at];

NN=numel(cellid)+1;

clrs={'r' 'k' 'g' 'b','m','c','y','r','k'};
figure
%pagefig('height',NN,'width',3)
h=subplot(NN,1,NN);
set(gcf,'renderer','painters')
	for cx=1:(NN-1)
			subplot(NN,1,cx)
			c_spks=spks{cx};
			[y,x]=tsraster2(pk3g(st), c_spks, 4E3, 2E3,0 );
			plot(x/1000,y,clrs{cx});
			if cx==1
				title( {[rat{1} '\_' sdate{1}], ['CELLID:' num2str(cellid(cx))  ', TT' num2str(sc(cx)) 'C' num2str(clust(cx))]});
			else
				title(['CELLID:' num2str(cellid(cx))  ', TT' num2str(sc(cx)) 'C' num2str(clust(cx))]);
			end

			ylim([0 ceil(max(y))])
			set(gca,'YTick',[]);
			set(gca,'Box','off')
			drawnow
			subplot(NN,1,NN)
			hold on
			krn=normpdf(-20:20,0,5);
			psth(pk3g(st), c_spks, 4E3, 2E3, 10, krn,{clrs{cx},gca,0.7});

		end

ylabel('Firing Rate (Hz \pm StdErr)')
xlabel('Time from response (sec)')
% 
% 
 ch=get(gcf,'Children');
% p1=get(ch(5),'Position');
% set(ch(5),'Position',p1+[0 -.05 0 +0.05]);
% set(gca,'Position', p1+[0 -.5 0 +.05]);
ylabel(ch(2),'Trials ordered by correct: correct trials on top')
set(gcf,'Renderer','painters');

%%
	case 'waves'
h=figure;
pagefig('height',2,'width',2)
hold on
for ci=1:2;
	
	waveplot(wv{c_x(ci)},{clrs{ci},h,.6})
		
	
end

set(gca,'XTick',[16 16+32+5 16+32*2+10 16+32*3+15])
set(gca, 'XTickLabel', {'ch. 0', 'ch. 1', 'ch. 2' , 'ch. 3'}) 
ylabel('Waveforms (\muV \pm stdev)');


h=figure;
pagefig('height',2,'width',2)
hold on
for ci=3:4;
	
	waveplot(wv{c_x(ci)},{clrs{ci},h,.6})
		
	
end

set(gca,'XTick',[16 16+32+5 16+32*2+10 16+32*3+15])
set(gca, 'XTickLabel', {'ch. 0', 'ch. 1', 'ch. 2' , 'ch. 3'}) 
ylabel('Waveforms (\muV \pm stdev)');


%% do all the XCORRS
	case 'xcorrs'
figure
xlist=nchoosek(1:9,2);
y=zeros(6,200);
for xi=1:size(xlist,1)
	s1=spks{c_x(xlist(xi,1))};
	s2=spks{c_x(xlist(xi,2))};
	[y(xi,:),x]=tsxcorr(s1*1000,s2*1000,500, 500, 5);
end
plot(x,y/1000);

end
