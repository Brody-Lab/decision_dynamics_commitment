function lesion_rats(str)

g=mym(2,'open','sonnabend.princeton.edu','jerlich',str)
mym(2,'use bdata')
update_comments

all_rats=bdata('select distinct(ratname) from sessions where ratname regexp "{S}" order by ratname', '^J01[0-6]$|J009');
clf

%% PRO
pa_s={'anti','pro'};
m={'x' 'o' 's' '.' 'x' 'o' 's' '.'};
for pax=1:2
	subplot(1,2,pax);
	set(gca,'FontSize',14);
	hold on;
	for rx=1:numel(all_rats)
		[perf]=bdata('select total_correct from sessions where ratname="{S}" and comments="{S}" and sessiondate>"2007-11-23" order by sessiondate', all_rats{rx}, pa_s{pax});
		if rx<5
			plot(perf,['-b' m{rx}]);
		else
			plot(perf,['-r' m{rx}]);
		end
	end
	xlabel('Sessions');
	title(pa_s{pax});

% 	for x=1:2
% 		if x==1
% 	[aperf]=bdata('select avg(total_correct) from sessions where ratname regexp "J009|J01[0-3]" and comments="{S}" and sessiondate>"2007-11-23" group by ratname, sessiondate order by sessiondate', pa_s{pax});
% h=plot(aperf,'b-'); set(h,'linewidth',3);
% 		else
% 				[aperf]=bdata('select avg(total_correct) from sessions where ratname regexp "J01[3-6]" and comments="{S}" and sessiondate>"2007-11-23" group by ratname, sessiondate order by sessiondate', pa_s{pax});
% h=plot(aperf,'r-'); set(h,'linewidth',3);
% 		end
% 	end

end

hold off

