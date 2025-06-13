function [tostate prevdur] = timeout_state(ratname, doffset,varargin)

pairs ={...
    'slist', {'pre_chord','cue','chord'}; ...
    };
parse_knownargs(varargin,pairs);

pstruct =get_pstruct(ratname, doffset);

tostate = zeros(rows(pstruct), length(slist));% tally of timeouts that occur in each RealTimeState (col) in each trial(row)
prevdur = cell(rows(pstruct), length(slist)); % for each trial (row) and state (col), duration of the state before the timeout occurred

for k = 1:rows(pstruct)
    curr=pstruct{k}.timeout;
    
	for t = 1:rows(curr) % for each timeout instance
        for s = 1:length(slist) % look at each state
            stimes1 = eval(['pstruct{k}.' slist{s} ';']); stimes=stimes1(:,2); % get exit times
            r1=find((curr(t,1) - stimes) > -0.02); % did this timeout start within 20 ms of the state ending
            r2=find((curr(t,1) - stimes) <= 0); %did this timeout start between 0 and 20ms of the state ending.
            reltime = intersect(r1,r2);
            if k == 83
                2;
            end;
            if ~isempty(reltime)                
                tostate(k,s) = tostate(k,s)+1;       
                t2=diff(stimes1(reltime,:));
                if t2 > 0.5 && s==2
                    2;
                end;
                
                prevdur{k,s} = horzcat(prevdur{k,s},t2);
            end;            
        end;
    end;
end;

% t = sub__flatten(prevdur(:,2));


function [bflat] = sub__flatten(b)

bflat =[];
for k = 1:rows(b)
 bflat =horzcat(bflat, b{k});
end;


% 
% ratlist = rat_task_table(ratname);
% task = ratlist{1,2};
% 
% rts = eval(['saved_history.' task '_RealTimeStates;']);
% rts = rts(1:end-1);
% 
% pstruct = pstruct(f:t);
% rts = rts(f:t);
% 
% to_states = {}; % struct - key is state, value is raw count
% for j = 1:length(state_list)
%     eval(['to_states.' state_list{j} ' = 0;']);
% end;
% for k = 1:rows(pstruct)
%     curr = pstruct{k}; curr_rts = rts{k};
%     for j = 1:length(state_list)
%         currstate = state_list{j};
%         statenums = eval(['curr_rts.' currstate]);
%         for m = 1:rows(curr.center1_states)
%             idx = find(statenums == curr.center1_states(m,2));
%             if ~isempty(idx)
%                 eval(['to_states.' currstate ' = to_states.' currstate '+1;']);
%             end;
%         end;
%     end;
% end;