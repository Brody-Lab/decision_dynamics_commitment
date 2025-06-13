function [timetocin] = timeout_length(p)

% Given the output of parse_trials, returns the length (milliseconds) of each timeout state in which there was a centerpoke

timetocin = cell(0,0);
for tr = 1:size(p,1)
	q = p{tr}; 
	cpokes= q.center1;
	to = q.timeout; precd = q.pre_chord; cd = q.chord;
	temp = [];
	for ctr = 1:rows(to)
		cin_this_to = find(cpokes(:,1) > to(ctr,1) & cpokes(:,1) < to(ctr,2));
		if length(cin_this_to) > 0
			precd_exits = find(precd(:,2) - to(ctr,1) < 0.3);
			temp = [temp
				cpokes(cin_this_to(1),1) - precd(precd_exits,2)] ;
		end;
	end;
	timetocin{tr} = temp;
end;
