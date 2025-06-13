% function [csv, cout]=calc_cout(peh)
%
% Inputs:
% peh		parsed events history
%
% Outputs:
% csv		a vector of length n_completed_trials that is 1 if there was a center-side violation
% cout		the time of the last cout after the go signal and before the first side poke.


function [csv, cout]=calc_cout(peh)

cin=extract_event(peh,'cpoke1(end,1)');
gos=extract_event(peh,'cpoke1(end,end)');
wfs=extract_event(peh,'wait_for_spoke(1,1)');
spoke=extract_event(peh,'wait_for_spoke(1,2)');

csv=zeros(size(peh));
cout=nan+zeros(size(peh));

for tx=1:numel(peh)
	if isnan(cin(tx)) || isnan(wfs(tx))
		cout(tx)=nan;
	else
		
		Cp=peh(tx).pokes.C;
		Op=sortrows([peh(tx).pokes.L; peh(tx).pokes.R]);
		stime=Op(find(Op>cin(tx),1,'first'));
		if isempty(stime)
			cout(tx)=nan;
			continue
		end
		
		if stime<gos
			cout(tx)=nan;
			csv(tx)=1;
		else
			% check for center side overlap
			bad1=overlap(Cp,Op,cin(tx),spoke(tx));
			bad2=overlap(Op,Cp,cin(tx),spoke(tx));
			
			if bad1 || bad2
				csv(tx)=1;
			end
		end
		
		if csv(tx)==0
			coutpidx=find(Cp(:,2)<stime,1,'last');
			if ~isempty(coutpidx)
			cout(tx)=Cp(coutpidx,2);
			else
				cout(tx)=nan;
			end
		end
	end
end



function y=overlap(a,b,cin,spoke)
y=0;
[foo]=qbetween(sort(a(:)),b(:,1),b(:,2));
if ~iscell(foo)
	foo={foo};
end

for cx=1:numel(foo)
	
	if ~isempty(foo{cx})
		% there was a center-side overlap
		%check if it was during the interesting part of the trial
		foo2=qbetween(foo{cx},cin, spoke+2);
		if ~isempty(foo2)
			y=1;
		end
	end
end